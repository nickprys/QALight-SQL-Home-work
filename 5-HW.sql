-- 0. Отобразите для каждого из курсов количество парней и девушек. 
select   course, gender, count (*) as cnt
from students
group by course, gender



-- 1. Напишите запрос для таблицы EXAM_MARKS, выдающий даты, для которых средний балл 
--    находиться в диапазоне от 4.22 до 4.77. Формат даты для вывода на экран: 
--    день месяць, например, 05 Jun.
select left(CONVERT(VARCHAR,EXAM_DATE,6),7), avg(mark) as mark_avg

from EXAM_MARKS
group by EXAM_DATE
having  avg(mark) between 4.22 and 4.77



-- 2. Напишите запрос, который по таблице EXAM_MARKS позволяет найти промежуток времени (*),
--    который занял у студента в течении его сессии, кол-во всех попыток сдачи экзаменов, 
--    а также их максимальные и минимальные оценки. В выборке дожлен присутствовать 
--    идентификатор студента.
--    Примечание: таблица оценок - покрывает одну сессию, (*) промежуток времени -
--    количество дней, которые провел студент на этой сессии - от первого до 
--    последнего экзамена включительно
--    Примечание-2: функция DAY() для решения не подходит! 
select student_id,

count(*) DAYqty, 
 
 DATEDIFF(day,min(exam_date),max(exam_date))+1 AS DiffDate  ,
 max(mark) MAX, min(mark) MIN

from EXAM_MARKS
group by STUDENT_ID





-- 3. Покажите список идентификаторов студентов, которые имеют пересдачи. 
select STUDENT_ID

from exam_marks
group by student_id, SUBJ_ID
having count(*) >1





-- 4. Напишите запрос, отображающий список предметов обучения, вычитываемых за самый короткий 
--    промежуток времени, отсортированный в порядке убывания семестров. Поле семестра в 
--    выходных данных должно быть первым, за ним должны следовать наименование и 
--    идентификатор предмета обучения.

select SEMESTER, name,id
from SUBJECTS
 where hours = (select 
min (hours)
 from 
SUBJECTS)
order by SEMESTER desc


-- 5. Напишите запрос с подзапросом для получения данных обо всех положительных оценках(4, 5) Марины 
--    Шуст (предположим, что ее персональный номер неизвестен), идентификаторов предметов и дат 
--    их сдачи.
select mark 
from exam_marks
where STUDENT_ID =
(select id
from STUDENTS
where name = 'Марина' and surname = 'Шуст')and mark in (4,5)

-- 6. Покажите сумму баллов для каждой даты сдачи экзаменов, при том, что средний балл не равен 
--    среднему арифметическому между максимальной и минимальной оценкой. Данные расчитать только 
--    для студенток. Результат выведите в порядке убывания сумм баллов, а дату в формате dd/mm/yyyy.
select convert(varchar,exam_date,103),
sum(mark) sum_mark
from EXAM_MARKS
where student_ID in (select id from students where gender = 'f')
group by exam_date
having avg(mark) <> (min(mark) + max(mark))/2 
 
order by sum_mark desc

-- 7. Покажите имена и фамилии всех студентов, у которых средний балл по предметам
--    с идентификаторами 1 и 2 превышает средний балл этого же студента
--    по всем остальным предметам. Используйте вложенные подзапросы, а также конструкцию
--    AVG(case...), либо коррелирующий подзапрос.
--    Примечание: может так оказаться, что по "остальным" предметам (не 1ый и не 2ой) не было
--    получено ни одной оценки, в таком случае принять средний бал за 0 - для этого можно
--    использовать функцию ISNULL().
select name, surname
from STUDENTS 
where id in (
select student_id
from EXAM_MARKS
group by STUDENT_ID
having 
avg (case when subj_id in (1,2) then mark end ) > 
  isnull(avg(  case when subj_id in (3,4,5,6,7) then mark  end  ),0))
  --
  
 select name, surname
from STUDENTS 
where id in(
  select STUDENT_ID
   from EXAM_MARKS
  group by STUDENT_ID
having avg(case when subj_id in (1,2) then mark end)> 
isnull(avg(case when subj_id not in (1,2) then mark end),0))

-- 8. Напишите запрос, выполняющий вывод общего суммарного и среднего баллов каждого 
--    экзаменованого второкурсника, его идентификатор и кол-во полученных оценок при условии, 
--    что он успешно сдал 3 и более предметов.

select student_id, avg(mark)as avg_m,sum(mark) as sum_m, count(mark) as count_m

from EXAM_MARKS
where student_id  in (select id from students where course = 2)
group by student_id
having count (distinct case when mark>=3 then SUBJ_ID) >= 3 



-- 9. Вывести названия всех предметов, средний балл которых превышает средний балл по всем 
--    предметам университетов г.Днепропетровска. Используйте вложенные подзапросы.

select name from SUBJECTS
where id in (

select subj_id from exam_marks
 group by SUBJ_ID 
 
 having  avg(mark) 

> 
(select avg (mark) from exam_marks 
where STUDENT_ID in(select id from students where UNIV_ID = (select id from UNIVERSITIES where city = 'Днепр'))))

