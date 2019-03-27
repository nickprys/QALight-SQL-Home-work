-- /* Везде, где необходимо данные придумать самостоятельно. */
--Для каждого задания (кроме 4-го) можете использовать конструкцию
-------------------------
-- начать транзакцию
begin transaction
-- проверка до изменений
SELECT * FROM EXAM_MARKS
-- изменения
-- insert into SUBJECTS (ID,NAME,HOURS,SEMESTER) values (25,'Этика',58,2),(26,'Астрономия',34,1)
-- insert into EXAM_MARKS ...
-- delete from EXAM_MARKS where SUBJ_ID in (...)
-- проверка после изменений
SELECT * FROM EXAM_MARKS --WHERE STUDENT_ID > 120
-- отменить транзакцию
rollback


-- 1. Необходимо добавить двух новых студентов для нового учебного 
--    заведения "Винницкий Медицинский Университет".
begin transaction

select * from STUDENTS
insert into STUDENTS (id, SURNAME, NAME, GENDER, STIPEND, COURSE,CITY, BIRTHDAY, UNIV_ID)
values (46, 'Petrov', 'Fedor','m', 600, 5, 'Винница','1990-12-01 00:00:00',16)

insert into STUDENTS (id, SURNAME, NAME, GENDER, STIPEND, COURSE,CITY, BIRTHDAY, UNIV_ID)
values (47, 'Petrov', 'Andrey','m', 600, 5, 'Винница','1990-12-01',16 )

insert into UNIVERSITIES (id,  NAME, rating, CITY)
values (16, 'ВМУ', '777','Винница')

-- 2. Добавить еще один институт для города Ивано-Франковск, 
--    1-2 преподавателей, преподающих в нем, 1-2 студента,
--    а так же внести новые данные в экзаменационную таблицу.
insert into UNIVERSITIES (id,  NAME, rating, CITY)
values (17, 'ИФУ', '777','Ивано-Франковск')

insert into STUDENTS (id, SURNAME, NAME, GENDER, STIPEND, COURSE,CITY, BIRTHDAY, UNIV_ID)
values (48, 'Petrov', 'Василий','m', 600, 5, 'Ивано-Франковск','1990-12-01',17 )

insert into LECTURERS (id, SURNAME, NAME, CITY,  UNIV_ID)
values (26, 'Petrov', 'Сергей','Ивано-Франковск',17 )

insert into  EXAM_MARKS (id, STUDENT_ID, SUBJ_ID, MARK,  EXAM_DATE)
values (121,48,2,5,'1999-12-01')

-- 3. Известно, что студенты Павленко и Пименчук перевелись в ОНПУ. 
--    Модифицируйте соответствующие таблицы и поля.
update STUDENTS  set UNIV_ID = (select u.id from UNIVERSITIES u where u.name ='ОНПУ') 
where SURNAME = 'Павленко' or surname = 'Пименчук'

-- 4. В учебных заведениях Украины проведена реформа и все студенты, 
--    у которых средний бал не превышает 3.5 балла - отчислены из институтов. 
--    Сделайте все необходимые удаления из БД.
--    Примечание: предварительно "отчисляемых" сохранить в архивационной таблице
insert into students_archive 
select * from students  s where s.id in 
(select em.student_id  from EXAM_MARKS em 
group by em.student_id
having avg(em.MARK)<3.5)

delete from students 
where STUDENTS.id in 
(select ID from 
STUDENTS_ARCHIVE)

delete from EXAM_MARKS
where STUDENT_id in 
(select em.student_id  from EXAM_MARKS em 
group by em.student_id
having avg(em.MARK)<3.5)




-- 5. Студентам со средним балом 4.75 начислить 12.5% к стипендии,
--    со средним балом 5 добавить 200 грн.
--    Выполните соответствующие изменения в БД.
update students set stipend=stipend * 1.125 where id in
(select em.student_id  from EXAM_MARKS em 
group by em.student_id
having avg(em.MARK)>4.75) 
update students   set stipend=stipend + 200 where id in
(select em.student_id  from EXAM_MARKS em 
group by em.student_id
having avg(em.MARK)=5)



-- 6. Необходимо удалить все предметы, по котором не было получено ни одной оценки.
--    Если таковые отсутствуют, попробуйте смоделировать данную ситуацию.
insert into  SUBJECTS
(id,name)
values (8,'Химия')

insert into EXAM_MARKS
(SUBJ_ID)
values( 8)

delete from SUBJECTS
where id in 
(select em.subj_id from EXAM_MARKS em
where em.mark is null)




-- 7. Лектор 3 ушел на пенсию, необходимо корректно удалить о нем данные.
delete from LECTURERS where id =3
delete from SUBJ_LECT where LECTURER_ID =3