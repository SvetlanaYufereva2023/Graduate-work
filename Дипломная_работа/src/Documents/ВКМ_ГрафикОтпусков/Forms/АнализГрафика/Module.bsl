
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Адрес = Параметры.Адрес;  
	ТаблицаЗначений.Загрузить(ПолучитьИзВременногоХранилища(Адрес));
	
	Для Каждого Стр из ТаблицаЗначений Цикл
		
		Серия = Диаграмма.УстановитьСерию("Отпуска");
		Точка = Диаграмма.УстановитьТочку(Стр.Сотрудник);
		Значение = Диаграмма.ПолучитьЗначение(Точка,Серия);
		Интервал = Значение.Добавить();
		Интервал.Начало = Стр.ДатаНачала;
		Интервал.Конец = Стр.ДатаОкончания;
		
	КонецЦикла;
	
КонецПроцедуры
