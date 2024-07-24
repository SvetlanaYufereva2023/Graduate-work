
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, Режим)
	
	// получим данные из договора
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.ВКМ_ДатаНачала КАК ВКМ_ДатаНачала,
		|	ДоговорыКонтрагентов.ВКМ_ДатаОкончания КАК ВКМ_ДатаОкончания,
		|	ДоговорыКонтрагентов.ВКМ_СтоимостьЧаса КАК ВКМ_СтоимостьЧаса,
		|	ДоговорыКонтрагентов.ВидДоговора КАК ВидДоговора
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Договор);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();  
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		СтавкаЧаса = ВыборкаДетальныеЗаписи.ВКМ_СтоимостьЧаса; 
		ДатаНачала = ВыборкаДетальныеЗаписи.ВКМ_ДатаНачала;
		ДатаОкончания = ВыборкаДетальныеЗаписи.ВКМ_ДатаОкончания; 
		ВидДоговора = ВыборкаДетальныеЗаписи.ВидДоговора;
	  	
	КонецЦикла;
	
	// Проверим, что вид договора - абоненсткое обслуживание
	
	Если ВидДоговора <> Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Необходимо выбрать договор на абонентское обслуживание,выбран %1",ВидДоговора);
		Сообщение.Сообщить();
		Отказ = Истина;
		Возврат;   
		
	КонецЕсли;	

	
	// Проверим, что договор действует
	Если ДатаНачала <> Неопределено И ДатаНачала > Дата Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Договор не действительный, договор вступает в силу с %1",ДатаНачала);
		Сообщение.Сообщить();   
		Отказ = Истина;
		Возврат;
		ИначеЕсли ДатаОкончания <> Неопределено И ДатаОкончания < Дата Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Договор не действительный, действие договора закончилось %1",ДатаОкончания);
		Сообщение.Сообщить();   
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	        	
	Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина;  
	
	Для Каждого Строка из ВыполненныеРаботы Цикл;
		
		Движение = Движения.ВКМ_ВыполненныеКлиентуРаботы.Добавить();
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.Договор = Договор;
		Движение.КоличествоЧасов = Строка.ЧасыКОплатеКлиенту;  
		Движение.СуммаКОплате = Движение.КоличествоЧасов * СтавкаЧаса ; 
		
		КонецЦикла;	     

   //Найдем ставку часа специалиста
   
    Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.Период КАК Период,
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	ВЫБОР
		|		КОГДА ВКМ_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот = """"
		|			ТОГДА ""ПроцентНеУстановлен""
		|		ИНАЧЕ ВКМ_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот
		|	КОНЕЦ КАК ПроцентОтРабот
		|ИЗ
		|	РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(&Дата, Сотрудник = &Сотрудник) КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних";
	
	Запрос.УстановитьПараметр("Сотрудник",Специалист);  
	Запрос.УстановитьПараметр("Дата",Дата);
	
	РезультатЗапроса = Запрос.Выполнить();  
		
	Движения.ВКМ_ВыполненныеСотрудникомРаботы.Записывать = Истина;
    
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();   
	
		
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл    
		
		Если ВыборкаДетальныеЗаписи.ПроцентОтРабот = "ПроцентНеУстановлен" Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Процен оплаты специалисту %1 на дату документа %2 не установлен. Документ не может быть проведен",Специалист,Дата);
		Сообщение.Сообщить();   
		Отказ = Истина;
		Возврат;
	КонецЕсли;

		
		ПроцентОтРабот = ВыборкаДетальныеЗаписи.ПроцентОтРабот;
		
	КонецЦикла;      
	
	Для Каждого Строка из ВыполненныеРаботы Цикл
		
		Движение = Движения.ВКМ_ВыполненныеСотрудникомРаботы.Добавить();
		Движение.Период = Дата;
		Движение.Сотрудник = Специалист;
		Движение.ЧасовКОплате = Строка.ЧасыКОплатеКлиенту;
		Движение.СуммаКОплате = Строка.ЧасыКОплатеКлиенту * СтавкаЧаса * ПроцентОтРабот / 100; 
		
	КонецЦикла;
	
  	
КонецПроцедуры

 #КонецОбласти
 
 #КонецЕсли
