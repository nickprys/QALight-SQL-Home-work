-- 1. Напишите запрос, выдающий список фамилий преподавателей английского
--    языка с названиями университетов, в которых они преподают.
--    Отсортируйте запрос по городу, где расположен университ, а
--    затем по фамилии лектора.

select SURNAME,u.name from LECTURERS l
join SUBJ_LECT sl on l.id =sl.LECTURER_ID
join SUBJECTS s on sl.SUBJ_ID=s.ID
join UNIVERSITIES u on l.UNIV_ID=u.id
where s.NAME = 'Английский'
order by u.CITY,l.SURNAME
--


-- 2. Напишите запрос, который выполняет вывод данных о фамилиях, сдававших экзамены 
--    студентов, учащихся в Б.Церкви, вместе с наименованием каждого сданного ими предмета, 
--    оценкой и датой сдачи.
select s.SURNAME, sb.NAME, em.MARK,em.EXAM_DATE from STUDENTS s
join UNIVERSITIES u on s.univ_id = u.id
join EXAM_MARKS em on  s.ID = em.STUDENT_ID
join SUBJECTS sb on em.SUBJ_ID= sb.ID
where u.CITY = 'Белая Церковь'


-- 3. Используя оператор JOIN, выведите объединенный список городов с указанием количества 
--    учащихся в них студентов и преподающих там же преподавателей.

select count(s.ID)s_count, u.city , 
count(l.id) l_count from STUDENTS s 
right join 
UNIVERSITIES u on s.UNIV_ID =u.ID 
left join 
LECTURERS l on l.univ_id=u.id
group by u.CITY


-- 4. Напишите запрос который выдает фамилии всех преподавателей и наименование предметов,
--    которые они читают в КПИ
select l.SURNAME,sb.NAME from LECTURERS l 
left join SUBJ_LECT sl on l.ID = sl.LECTURER_ID 
left join SUBJECTS sb on sl.SUBJ_ID=sb.ID 
where UNIV_ID=1

-- 5. Покажите всех студентов-двоешников, кто получил только неудовлетворительные оценки (2) 
--    и по каким предметам, а также тех кто не сдал ни одного экзамена. 
--    В выходных данных должны быть приведены фамилии студентов, названия предметов и 
--    оценка, если оценки нет, заменить ее на прочерк.

select s.surname,cast(em.SUBJ_ID as varchar)subj, sb.NAME, cast(em.MARK as varchar) mark
from STUDENTS s 
left join EXAM_MARKS em on s.ID=em.STUDENT_ID
left join SUBJECTS sb  on em.SUBJ_ID=sb.ID 

where em.MARK=2
union
select surname ,'-','-','-'
from STUDENTS s where not exists
(select 1 from EXAM_MARKS em
where s.id = em.STUDENT_ID)
 --
select s.SURNAME
from STUDENTS s
   left join EXAM_MARKS em on em.STUDENT_ID=s.id
    and em.MARK>2 
   where em.id is null
  
 --

     

-- 6. Напишите запрос, который выполняет вывод списка университетов с рейтингом, 
--    превышающим 490, вместе со значением максимального размера стипендии, 
--    получаемой студентами в этих университетах.
select u.NAME , max(s.STIPEND) from UNIVERSITIES u  left join STUDENTS s on u.ID=s.UNIV_ID 
where rating > 490
group by u.NAME

-- 7. Расчитать средний бал по оценкам студентов для каждого университета, 
--    умноженный на 100, округленный до целого, и вычислить разницу с текущим значением

--    рейтинга университета.
select cast(100*avg(mark) as int) - rating from UNIVERSITIES u right join STUDENTS s on u.id=s.UNIV_ID
left join EXAM_MARKS em on s.id=em.STUDENT_ID 
group by univ_id, rating


-- 8. Написать запрос, выдающий список всех фамилий лекторов из Киева попарно. 
--    При этом не включать в список комбинации фамилий самих с собой,
--    то есть комбинацию типа "Коцюба-Коцюба", а также комбинации фамилий, 
--    отличающиеся порядком следования, т.е. включать лишь одну из двух 
--    комбинаций типа "Хижна-Коцюба" или "Коцюба-Хижна".
select   l1.surname,l.surname from lecturers l , lecturers l1
where  l1.surname>l.surname and l.CITY='Киев' and l1.CITY='Киев'

select l.surname+l1.surname from LECTURERS l cross join LECTURERS l1
where l.CITY='Киев' and l1.CITY='Киев' and l.surname<>l1.surname
and l.SURNAME 


-- 9. Выдать информацию о всех университетах, всех предметах и фамилиях преподавателей, 
--    если в университете для конкретного предмета преподаватель отсутствует, то его фамилию
--    вывести на экран как прочерк '-' (воспользуйтесь ф-ей isnull)

select u.name,isnull(l.SURNAME,'-'),isnull(sb.NAME,'-') from UNIVERSITIES u 
left join lecturers l on u.id=l.UNIV_ID
left join subj_lect sl on sl.LECTURER_ID=l.ID 
cross join  SUBJECTS sb

select*
from UNIVERSITIES u cross join subjects s
left join (

select (lect.univ_id,lect.surname
from LECTURERS lect left join SUBJ_LECT s1 on s1.LECTURER_ID=lect.id) as t on u.id=t.univ_id and s.id =t.subj_id


-- 10. Кто из преподавателей и сколько поставил пятерок за свой предмет?



select l.SURNAME, count(*)
from EXAM_MARKS em 
join STUDENTS s on em.STUDENT_ID=s.id
join SUBJ_LECT sl on sl.SUBJ_ID = em.SUBJ_ID
join LECTURERS l on sl.LECTURER_ID=l.id
where s.UNIV_ID=l.UNIV_ID and em.MARK=5
group by l.SURNAME


-- 11. Добавка для уверенных в себе студентов: показать кому из студентов какие экзамены
--     еще досдать.
select s.SURNAME, em.SUBJ_ID, em.MARK, em.ID
from STUDENTS s,EXAM_MARKS em
  -- left join EXAM_MARKS em on em.STUDENT_ID=s.id
   --where
     --em.MARK=2 
	 group by em.SUBJ_ID
having count(em.mark)<2

  
  select  em.SUBJ_ID,em.STUDENT_ID, em.MARK
from EXAM_MARKS em where em.mark =2
  -- left join EXAM_MARKS em on em.STUDENT_ID=s.id
   --where
     --em.MARK=2 
--
group by em.SUBJ_ID
having count(em.mark)<2

--