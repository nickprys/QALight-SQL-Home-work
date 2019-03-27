-- 1. Создайте модифицируемое представление для получения сведений обо всех студентах, 
--    круглых отличниках. Используя это представление, напишите запрос обновления, 
--    "расжалующий" их в троечников.
update EXAM_MARKS set mark = 3
where student_id in (select * from upd5)

create view  upd5 as
(select student_id from exam_marks em 
group by STUDENT_ID
having avg(mark) = 5)


-- 2. Создайте представление для получения сведений о количестве студентов 
--    обучающихся в каждом городе.
create view std_cnt as 
(select u.CITY,count(*) cnt from STUDENTS s left join UNIVERSITIES u on s.UNIV_ID = u.ID
group by u.CITY)




-- 3. Создайте представление для получения сведений по каждому студенту: 
--    его ID, фамилию, имя, средний и общий баллы.

create view std_about as 
(select  s.id,s.NAME, s.surname, avg(em.mark) avgm,sum(em.mark) smm
from  exam_marks em 
right join students  s on s.id=em.student_id
group by em.STUDENT_ID,s.ID,s.name, s.SURNAME)


-- 4. Создайте представление для получения сведений о студенте фамилия, 
--    имя, а также количестве экзаменов, которые он сдал успешно, и количество,
--    которое ему еще нужно досдать (с учетом пересдач двоек).
select em.STUDENT_ID,count (*) from EXAM_MARKS em 
where em.mark >2
group by em.STUDENT_ID





-- 5. Какие из представленных ниже представлений являются обновляемыми?
C

-- A. CREATE VIEW DAILYEXAM AS
--    SELECT DISTINCT STUDENT_ID, SUBJ_ID, MARK, EXAM_DATE
--    FROM EXAM_MARKS


-- B. CREATE VIEW CUSTALS AS
--    SELECT SUBJECTS.ID, SUM (MARK) AS MARK1
--    FROM SUBJECTS, EXAM_MARKS
--    WHERE SUBJECTS.ID = EXAM_MARKS.SUBJ_ID
--    GROUP BY SUBJECT.ID


-- C. CREATE VIEW THIRDEXAM
--    AS SELECT *
--    FROM DAILYEXAM
--    WHERE EXAM_DATE = '2012/06/03'


-- D. CREATE VIEW NULLCITIES
--    AS SELECT ID, SURNAME, CITY
--    FROM STUDENTS
--    WHERE CITY IS NULL
--    OR SURNAME BETWEEN 'А' AND 'Д'
--    WITH CHECK OPTION


-- 6. Создайте представление таблицы STUDENTS с именем STIP, включающее поля 
--    STIPEND и ID и позволяющее вводить или изменять значение поля 
--    стипендия, но только в пределах от 100 д о 500.

create view as stip
(select id, stipend from students)