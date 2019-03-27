-- Внимание! Во всех результирующих выборках должны быть учтены все записи, даже
-- те, которые содержать NULL поля, однако, склейка не должна быть NULL записью!
-- Для этого используйте либо CASE, либо функцию 
-- ISNULL(<выражение>, <значение по умолчанию>) -- Microsoft SQL Server
-- IFNULL(<выражение>, <значение по умолчанию>) -- MySQL
-- COALESCE(<выражение>, <значение по умолчанию>) -- ANSI SQL (стандарт)
-- Соблюдать это условие достаточно для двух полей BIRTHDAY и UNIV_ID.
-- В качестве <значения по умолчания> используйте строку 'unknown'.



-- 1. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала один столбец типа varchar, содержащий последовательность разделенных 
--    символом ';' (точка с запятой) значений столбцов этой таблицы, и при этом 
--    текстовые значения должны отображаться прописными символами (верхний регистр), 
--    то есть быть представленными в следующем виде: 
--    1;КАБАНОВ;ВИТАЛИЙ;M;550;4;ХАРЬКОВ;01/12/1990;2.
--    ...
--    примечание: в выборку должны попасть студенты из любого города из 5 букв
select  
 
( cast(ID as VARCHAR))+ ' ;' +
UPPER(SURNAME ) + ';'+
UPPER(NAME) + ';'+
UPPER(cast(GENDER as VARCHAR)) + ';'+
cast(STIPEND as VARCHAR) + ';' +
cast(COURSE as VARCHAR) +';'+
UPPER(CITY ) + ';' +
case when birthday is null then 'unknown'
else CONVERT(VARCHAR, BIRTHDAY,104)
end+ ';' +

isnull(cast(univ_id as varchar), 'unknown')

from students 
where LEN(city) = 5

-- 2. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде: 
--    В.КАБАНОВ;местожительства-ХАРЬКОВ;родился-01.12.90
--    ...
--    примечание: в выборку должны попасть студенты, фамилия которых содержит вторую
--    букву 'е' и предпоследнюю букву 'и', либо же фамилия заканчивается на 'ц'
select LEFT (name,1) +'.'+
UPPER(surname) +';'+
'местожительство-' +
UPPER(CITY) + ';'+
'родился-' +
case when birthday is null then 'unknown'
else CONVERT(VARCHAR, BIRTHDAY,104)
end
from STUDENTS
where surname like '_е%' and surname like '%и_' or surname like '%ц'


-- 3. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    т.цилюрик;местожительства-Херсон; учится на IV курсе
--    ...
--    примечание: курс указать римскими цифрами (воспользуйтесь CASE), 
--    отобрать студентов, стипендия которых кратна 200
select 
lower(left(name,1))+'.' + 
lower(surname) + ';'+
'местожительство-' +
city + ';' +
'учиться на '  +
case when  course in (1) then  'I'
when course in (2) then 'II'
when course in (3) then 'III'
when course in (4) then 'IV'
when course in (5) then 'V'
end
+ ' курсе', stipend
-- stipend для наглядности
from students
where stipend % 200 = 0

-- 4. Составьте запрос для таблицы STUDENT таким образом, чтобы выборка 
--    содержала столбец в следующего вида:
--     Нина Федосеева из г.Днепропетровск родилась в 1992 году
--     ...
--     Дмитрий Коваленко из г.Хмельницкий родился в 1993 году
--     ...
--     примечание: для всех городов, в которых более 8 букв
select 
name +' '+ surname + ' из г. ' + city +
case when GENDER = 'm' then 
' родился в ' else 'родилась в' 
end +
LEFT (CONVERT(VARCHAR,Birthday,112),4) + ' году'
from students
where LEN(city) >8


-- 5. Вывести фамилии, имена студентов и величину получаемых ими стипендий, 
--    при этом значения стипендий первокурсников должны быть увеличены на 17.5%
select surname, name, course, 
case  when course in (1) then stipend * 1.175
else STIPEND 
end
as stipend
from students

-- 6. Вывести наименования всех учебных заведений и их расстояния 
--    (придумать/нагуглить/взять на глаз) до Киева.
select distinct city,
case when city in ('Харьков') then 450
when city in ('Львов') then 500
when city in ('Белая Церковь')then 100
when city in ('Горловка')then 650
when city in ('Днепр')then 600
when city in ('Донецк')then 800
when city in ('Ивано-Франковск')then 500 
when city in ('Кременчуг')then 450
when city in ('Луцк')then 650 
when city in ('Херсон') then 450
when city in ('Киев') then 0
when city in ('Полтава') then 550
when city in ('Ровно') then 500
when city in ('Мариуполь') then 550
when city in ('Хмельницкий') then 550
when city in ('Винница') then 350
when city in ('Одесса') then 450
when city in ('Севастополь') then 1050
when city in ('Макеевка') then 800
when city in ('Черновцы') then 450
end
as distanse
from students 

-- 7. Вывести все учебные заведения и их две последние цифры рейтинга.
select distinct
name, 
RIGHT (rating,2)
from UNIVERSITIES


-- 8. Составьте запрос для таблицы UNIVERSITY таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    Код-1;КПИ-г.Киев;Рейтинг относительно ДНТУ(501) +756
--    ...
--    Код-11;КНУСА-г.Киев;рейтинг относительно ДНТУ(501) -18
--    ...
--    примечание: рейтинг вычислить относительно ДНТУшного, а также должен 
--    присутствовать знак (+/-), рейтинг ДНТУ заранее известен = 501
select 
'Код-' + cast (id as varchar) + ';' + name + '-г.' + city + ';'+ 
'Рейтинг относительно ДНТУ(501) '+ 
case when RATING >501 then '+' else''
end +

  cast((rating -501) as varchar)


from UNIVERSITIES


-- 9. Составьте запрос для таблицы UNIVERSITY таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    Код-1;КПИ-г.Киев;рейтинг состоит из 12 сотен
--    Код-2;КНУ-г.Киев;рейтинг состоит из 6 сотен
--    ...
--    примечание: в рейтинге необходимо указать кол-во сотен
select 
'Код-' + cast (id as varchar) + ';' + name + '-г.' + city + ';'+ 
'Рейтинг состоит из '+ 
cast(floor(rating / 100) as varchar)+
' сотен'

from UNIVERSITIES