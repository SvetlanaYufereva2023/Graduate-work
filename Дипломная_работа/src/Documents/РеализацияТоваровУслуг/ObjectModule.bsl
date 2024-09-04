
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Ответственный = Пользователи.ТекущийПользователь();
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ОбработкаЗаказов.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;  
	Движение = Движения.ОбработкаЗаказов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Заказ = Основание;
	Движение.СуммаОтгрузки = СуммаДокумента;    
	
	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Сумма;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;   
	
	// ВКМ добавляем изменение в запись регистра Продажи и Взаиморасчетов с покупателями при изменении суммы реализации     
	Движения.ЗадолженностьПокупателей.Записывать = Истина;  
	Движение = Движения.ЗадолженностьПокупателей.ДобавитьПриход();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Сумма = СуммаДокумента;  
	
	Движения.Продажи.Записывать = Истина;
	Для Каждого ТекСтрокаУслуги из Услуги Цикл   
		Движение = Движения.Продажи.Добавить();
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;  
		Движение.Договор = Договор;
		Движение.Номенклатура = ТекСтрокаУслуги.Номенклатура;
		Движение.Сумма = ТекСтрокаУслуги.Сумма;
	КонецЦикла;
	
	// ВКМ добавляем изменение в запись регистра Продажи и Взаиморасчетов с покупателями при изменении суммы реализации
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказПокупателя.Организация КАК Организация,
	               |	ЗаказПокупателя.Контрагент КАК Контрагент,
	               |	ЗаказПокупателя.Договор КАК Договор,
	               |	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
	               |	ЗаказПокупателя.Товары.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Товары,
	               |	ЗаказПокупателя.Услуги.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Услуги
	               |ИЗ
	               |	Документ.ЗаказПокупателя КАК ЗаказПокупателя
	               |ГДЕ
	               |	ЗаказПокупателя.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
	
	ТоварыОснования = Выборка.Товары.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
	КонецЦикла;
	
	УслугиОснования = Выборка.Услуги.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
	КонецЦикла;
	
	Основание = ДанныеЗаполнения;
	
КонецПроцедуры

//ВКМ Добавлена функция автоматического заполнения суммой абоненской платы и выполеннных работ
Процедура ВыполнитьАвтозаполнение(ДокОбъект)Экспорт 
	
	АбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	ВыполненныеРаботы = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	
	Если НЕ ЗначениеЗаполнено(АбонентскаяПлата)Тогда
	ОбщегоНазначения.СообщитьПользователю("Необходимо заполнить значение константы Номенклатура абонентской платы");
		 Возврат;
	КонецЕсли;	 
	Если НЕ ЗначениеЗаполнено(ВыполненныеРаботы)Тогда
	ОбщегоНазначения.СообщитьПользователю("Необходимо заполнить значение константы Номенклатура работы специалиста");
		 Возврат;
	КонецЕсли;	  
	
	Если Договор.ВидДоговора <> Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание Тогда
	ОбщегоНазначения.СообщитьПользователю("Автозаполнение возможно только для договора на абонентское обслуживание");
		Возврат;	
	КонецЕсли;
		
	ДоговорДействует = ПроверитьДействиеДоговора();  
		
	Если ДоговорДействует Тогда
	
	Товары.Очистить();
	Услуги.Очистить();
	Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	РеализацияТоваровУслуг.Ссылка КАК Ссылка,
		|	РеализацияТоваровУслуг.Договор.Ссылка КАК ДоговорСсылка,
		|	РеализацияТоваровУслуг.Договор.ВКМ_СуммаЕжемесячнойПлаты КАК СуммаЕжемесячнойПлаты,
		|	РеализацияТоваровУслуг.Договор.ВКМ_СтоимостьЧаса КАК СтоимостьЧаса,
		|	ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботыОбороты.КоличествоЧасовОборот, 0) КАК КоличествоЧасов,
		|	ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботыОбороты.СуммаКОплатеОборот, 0) КАК СуммаКОплате
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(&ДатаНачала, &ДатаОкончания, , Договор = &Договор) КАК ВКМ_ВыполненныеКлиентуРаботыОбороты
		|		ПО РеализацияТоваровУслуг.Договор = ВКМ_ВыполненныеКлиентуРаботыОбороты.Договор
		|ГДЕ
		|	РеализацияТоваровУслуг.Ссылка = &Ссылка";     
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);  
	Запрос.УстановитьПараметр("ДатаНачала", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("ДатаОкончания", КонецМесяца(Дата));
	Запрос.УстановитьПараметр("Договор", Договор);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();  
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Если ВыборкаДетальныеЗаписи.СуммаЕжемесячнойПлаты > 0 Тогда
			
			НоваяСтрока = ДокОбъект.Услуги.Добавить();    
			НоваяСтрока.Номенклатура = АбонентскаяПлата;
			НоваяСтрока.Количество = 1;
			НоваяСтрока.Цена = ВыборкаДетальныеЗаписи.СуммаЕжемесячнойПлаты;    
			НоваяСтрока.Сумма = ВыборкаДетальныеЗаписи.СуммаЕжемесячнойПлаты; 
			ДокОбъект.Записать(РежимЗаписиДокумента.Проведение);
			
		КонецЕсли; 
		
		Если ВыборкаДетальныеЗаписи.СуммаКОплате > 0 Тогда
			
			НоваяСтрока = ДокОбъект.Услуги.Добавить();    
			НоваяСтрока.Номенклатура = ВыполненныеРаботы;
			НоваяСтрока.Количество = ВыборкаДетальныеЗаписи.КоличествоЧасов;
			НоваяСтрока.Цена = ВыборкаДетальныеЗаписи.СуммаКОплате / ВыборкаДетальныеЗаписи.КоличествоЧасов;   
			НоваяСтрока.Сумма = ВыборкаДетальныеЗаписи.СуммаКОплате; 
			ДокОбъект.Записать(РежимЗаписиДокумента.Проведение);  
			
		КонецЕсли;
		
	КонецЦикла;   
	КонецЕсли;
	
КонецПроцедуры	   
//ВКМ Добавлена функция автоматического заполнения суммой абоненской платы и выполеннных работ

Функция ПроверитьДействиеДоговора()
	 
	ДоговорДейстует = Истина; 
	 
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.ВКМ_ДатаНачала КАК ВКМ_ДатаНачала,
		|	ДоговорыКонтрагентов.ВКМ_ДатаОкончания КАК ВКМ_ДатаОкончания
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Договор);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();  
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ДатаНачала = ВыборкаДетальныеЗаписи.ВКМ_ДатаНачала;
		ДатаОкончания = ВыборкаДетальныеЗаписи.ВКМ_ДатаОкончания; 
		  	
	КонецЦикла;
	
	Если ДатаНачала <> Неопределено И ДатаНачала > Дата Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Автозаполнение не возможно. Договор не действительный, договор вступает в силу с %1",ДатаНачала);
		Сообщение.Сообщить();   
		Отказ = Истина;
		ДоговорДейстует = Ложь;
		ИначеЕсли ДатаОкончания <> Неопределено И ДатаОкончания < Дата Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Автозаполнение не возможно. Договор не действительный, действие договора закончилось %1",ДатаОкончания);
		Сообщение.Сообщить();   
		Отказ = Истина;
		ДоговорДейстует = Ложь;
	КонецЕсли;
	
	Возврат ДоговорДейстует;
    	
КонецФункции
 #КонецОбласти

#КонецЕсли
