#Область СлужебныеПроцедурыИФункции

Функция СоздатьРеализации(ПараметрыЗапуска)Экспорт
	
	//Ответственный = Пользователи.ТекущийПользователь();
	
	АбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Организация КАК Организация,
		|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
		|	ДоговорыКонтрагентов.Ссылка КАК Договор
		|ПОМЕСТИТЬ ВТ_Договоры
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.ВидДоговора = &АбонентскаяПлата
		|	И ДоговорыКонтрагентов.ВКМ_ДатаНачала <= &НачалоПериода
		|	И ДоговорыКонтрагентов.ВКМ_ДатаОкончания >= &КонецПериода
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Договоры.Организация КАК Организация,
		|	ВТ_Договоры.Контрагент КАК Контрагент,
		|	ВТ_Договоры.Договор КАК Договор,
		|	РеализацияТоваровУслуг.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ ВТ_СРеализацией
		|ИЗ
		|	ВТ_Договоры КАК ВТ_Договоры
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|		ПО ВТ_Договоры.Договор = РеализацияТоваровУслуг.Договор
		|ГДЕ
		|	РеализацияТоваровУслуг.Дата МЕЖДУ &НачалоПериода И &КонецПериода
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Договоры.Организация КАК Организация,
		|	ВТ_Договоры.Контрагент КАК Контрагент,
		|	ВТ_Договоры.Договор КАК Договор,
		|	ВТ_СРеализацией.Ссылка КАК Ссылка,
		|	ВТ_Договоры.Договор.ВКМ_СуммаЕжемесячнойПлаты КАК СуммаЕжемесячнойПлаты
		|ИЗ
		|	ВТ_Договоры КАК ВТ_Договоры
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_СРеализацией КАК ВТ_СРеализацией
		|		ПО ВТ_Договоры.Договор = ВТ_СРеализацией.Договор
		|ГДЕ
		|	ВТ_СРеализацией.Ссылка ЕСТЬ NULL";
	
	Запрос.УстановитьПараметр("АбонентскаяПлата",Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание );
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(ПараметрыЗапуска.ДатаНачала));
	Запрос.УстановитьПараметр("КонецПериода",КонецДня(ПараметрыЗапуска.ДатаОкончания));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	СписокДляЗаполнения = Новый Массив;
	    	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
					
		ДокументЗаказ = Документы.ЗаказПокупателя.СоздатьДокумент();
		ДокументЗаказ.Дата = ПараметрыЗапуска.ДатаОкончания;
		ДокументЗаказ.Организация = ВыборкаДетальныеЗаписи.Организация;
		ДокументЗаказ.Контрагент = ВыборкаДетальныеЗаписи.Контрагент;
		ДокументЗаказ.Договор = ВыборкаДетальныеЗаписи.Договор;  
	//	ДокументЗаказ.Ответственный = Ответственный;
		ТабЧасть = ДокументЗаказ.Услуги.Добавить();  
		ТабЧасть.Номенклатура = АбонентскаяПлата;
		ТабЧасть.Количество = 1;
		ТабЧасть.Цена = ВыборкаДетальныеЗаписи.СуммаЕжемесячнойПлаты;  
		ТабЧасть.Сумма = 1 * ТабЧасть.Цена; 
		
		ДокументЗаказ.Записать(РежимЗаписиДокумента.Проведение); 
		
		ДокОбъект = Документы.РеализацияТоваровУслуг.СоздатьДокумент(); 
		ДокОбъект.Дата = ПараметрыЗапуска.ДатаОкончания;
		ДокОбъект.Организация = ВыборкаДетальныеЗаписи.Организация;
        
		ДокОбъект.Заполнить(ДокументЗаказ.Ссылка); 
		
		ДокОбъект.Записать(РежимЗаписиДокумента.Запись);
		
		ДокОбъект.ВыполнитьАвтозаполнение(ДокОбъект);
		ДокОбъект.ПроверитьЗаполнение();
		ДокОбъект.Записать(РежимЗаписиДокумента.Проведение);
		
		ДанныеДляЗаполнения = Новый Структура;

		ДанныеДляЗаполнения.Вставить("Договор",ВыборкаДетальныеЗаписи.Договор);
		ДанныеДляЗаполнения.Вставить("Реализация",ДокОбъект.Ссылка);
		
		СписокДляЗаполнения.Добавить(ДанныеДляЗаполнения);
					
	КонецЦикла;   
	
	Возврат СписокДляЗаполнения;
		
КонецФункции	

#КонецОбласти

