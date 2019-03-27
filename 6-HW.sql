-- 1. Напишите запрос с EXISTS, позволяющий вывести данные обо всех студентах, 
--    обучающихся в вузах с рейтингом не попадающим в диапазон от 488 до 571
select * from STUDENTS s
where exists (
select rating from UNIVERSITIES u
where rating not between 488 and 571 and u.id = s.UNIV_ID)

-- 2. Напишите запрос с EXISTS, выбирающий всех студентов, для которых в том же городе, 
--    где живет и учится студент, существуют другие университеты, в которых он не учится.
--select * from students 
--where exists
select * from students s where exists
(select city from students s
where  city in ( select city from UNIVERSITIES u where id=s.UNIV_ID)) and  
   city in (select city from UNIVERSITIES
                group by city 
             having count(*)>1)
 

-- 3. Напишите запрос, выбирающий из таблицы SUBJECTS данные о названиях предметов обучения, 
--    экзамены по которым были хоть как-то сданы более чем 12 студентами, за первые 10 дней сессии. 
--    Используйте EXISTS. Примечание: по возможности выходная выборка должна быть без пересдач.


select name from SUBJECTS sb
where exists (select count(subj_id) from EXAM_MARKS em where sb.id=em.SUBJ_ID 
 and em.EXAM_DATE between min(EXam_date) and min(exam_date)+9
 group by SUBJ_ID
 having count(*)>11 )
 --
 select name from SUBJECTS sb where exists (
 select subj_id 
 from exam_marks em
 where EXAM_DATE <=(select min (exam_date)+9 from EXAM_MARKS) and em.subj_id = sb.id
 group by subj_id
 having count(distinct student_id)>12)
 

-- 4. Напишите запрос EXISTS, выбирающий фамилии всех лекторов, преподающих в университетах
--    с рейтингом, превосходящим рейтинг каждого харьковского универа.
select surname from LECTURERS l
where exists (select *  from UNIVERSITIES u where u.id=l.univ_id and rating > 
(select max(rating) from UNIVERSITIES
where city = 'Харьков'))

-- 5. Напишите 2 запроса, использующий ANY и ALL, выполняющий выборку данных о студентах, 
--    у которых в городе их постоянного местожительства нет университета.
select surname from students s
where s.city <> all (select  u.city from UNIVERSITIES u)

select * from students s
 where not s.city = any(select  u.city from UNIVERSITIES u)


-- 6. Напишите запрос выдающий имена и фамилии студентов, которые получили
--    максимальные оценки в первый и последний день сессии.
--    Подсказка: выборка должна содержать по крайне мере 2х студентов.
select name, surname from students s  
where id in 
(select STUDENT_ID from EXAM_MARKS
where EXAM_DATE = (select max(exam_date) from EXAM_MARKS) and 
mark = (select max(mark) from EXAM_MARKS
where EXAM_DATE = (select max(exam_date)from EXAM_MARKS))
union 
select STUDENT_ID from EXAM_MARKS
where EXAM_DATE = (select min(exam_date) from EXAM_MARKS) and 
mark = (select max(mark) from EXAM_MARKS
where EXAM_DATE = (select min(exam_date)from EXAM_MARKS)))


-- 7. Напишите запрос EXISTS, выводящий кол-во студентов каждого курса, которые успешно 
--    сдали экзамены, и при этом не получивших ни одной двойки.
select  count(*) from STUDENTS s
--
where exists (select * from EXAM_MARKS em  where em.STUDENT_ID = s.id and mark in(3,4,5)) 
and not exists 
(select * from EXAM_MARKS em  where em.STUDENT_ID = s.id and mark in(2))

group by course

-- 8. Напишите запрос EXISTS на выдачу названий предметов обучения, 
--    по которым было получено максимальное кол-во оценок.
select name from SUBJECTS s
where exists (  
select count(MARK) cnt
from EXAM_MARKS em 
group by SUBJ_ID 
having count(MARK) = (select max(cnt) from (select count(MARK) cnt
from EXAM_MARKS em 
group by SUBJ_ID) as A) and s.id=em.subj_id )

-- 9. Напишите команду, которая выдает список фамилий студентов по алфавиту, 
--    с колонкой комментарием: 'успевает' у студентов , имеющих все положительные оценки, 
--    'не успевает' для сдававших экзамены, но имеющих хотя бы одну 
--    неудовлетворительную оценку, и комментарием 'не сдавал' – для всех остальных.
--    Примечание: по возможности воспользуйтесь операторами ALL и ANY.
select   surname,'успевает' from students s
where exists (select * from EXAM_MARKS em where s.id = em.student_id and mark >= 3) and
not exists (select * from EXAM_MARKS em where s.id = em.student_id and mark = 2)
union 
select  surname,'не успевает' from students s
where exists (select * from EXAM_MARKS em where s.id = em.student_id and MARK in (2))
union 
select  surname,'не сдавал' from students s
where not exists (select * from EXAM_MARKS em where s.id = em.student_id )
order by SURNAME
-- union или union all Березовский все равно попадвет дважды :(

-- 10. Создайте объединение двух запросов, которые выдают значения полей 
--     NAME, CITY, RATING для всех университетов. Те из них, у которых рейтинг 
--     равен или выше 500, должны иметь комментарий 'Высокий', все остальные – 'Низкий'.
select name, city,rating ,'высокий'rating from UNIVERSITIES u
where rating >=500
union all
select name, city,rating ,'низкий' from UNIVERSITIES u
where rating <500

-- 11. Напишите UNION запрос на выдачу списка фамилий студентов 4-5 курсов в виде 3х полей выборки:
--     SURNAME, 'студент <значение поля COURSE> курса', STIPEND
--     включив в список преподавателей в виде
--     SURNAME, 'преподаватель из <значение поля CITY>', <значение зарплаты в зависимости от города проживания (придумать самим)>
--     отсортировать по фамилии
--     Примечание: достаточно учесть 4-5 городов.
select s.surname, 'студент'role ,cast(course as varchar)+' курса', stipend from students s
where course in (4,5)
union  all
select l.surname, 'преподаватель из', city , case when city ='Киев' then 10000
                                           when city ='Луганск' then 5000 
										    when city ='Львов' then 8000 
										   when city ='Луцк' then 6000 end
										                    from lecturers l

order by surname