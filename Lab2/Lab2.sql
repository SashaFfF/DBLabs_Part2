--task1
CREATE TABLE GROUPS 
(
  ID NUMBER,
  NAME VARCHAR2(20),
  C_VAL NUMBER,
  CONSTRAINT group_pk PRIMARY KEY (ID)
);

CREATE TABLE STUDENTS 
(
    ID NUMBER,
    NAME VARCHAR2(20),
    GROUP_ID NUMBER,
    FOREIGN KEY (GROUP_ID) REFERENCES GROUPS(ID),
    CONSTRAINT student_pk PRIMARY KEY (ID)
);

--task2
--unique id
CREATE OR REPLACE TRIGGER check_unique_group_id
BEFORE INSERT OR UPDATE ON GROUPS
FOR EACH ROW
DECLARE 
    count_id NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO count_id
    FROM GROUPS
    WHERE ID = :NEW.ID;
    
    IF(count_id!=0) THEN 
      raise_application_error(-20001, 'Ошибка: Поле ID в таблице GROUPS должно быть уникальным.');
    END IF;
END;

CREATE OR REPLACE TRIGGER check_unique_student_id
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW
DECLARE 
    count_id NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO count_id
    FROM students
    WHERE ID = :NEW.ID;
    
    IF(count_id!=0) THEN 
      RAISE_APPLICATION_ERROR(-20002, 'Ошибка: Поле ID в таблице STUDENTS должно быть уникальным.');
    END IF;
END;

insert into groups(id, name, c_val) values(1, 'group1', 20);
insert into students(id, name, group_id) values(1, 'student1', 1);

ALTER TRIGGER GENERATE_AUTO_INCREMENT_STUDENTS DISABLE;
insert into students(id, name, group_id) values(2, 'student1', 1);
ALTER TRIGGER GENERATE_AUTO_INCREMENT_STUDENTS ENABLE;



--autoincrement
CREATE OR REPLACE TRIGGER GENERATE_AUTO_INCREMENT_GROUPS
BEFORE INSERT ON GROUPS
FOR EACH ROW
BEGIN
--Oracle/PLSQL функция COALESCE возвращает первое ненулевое выражение из списка
  SELECT COALESCE(MAX(ID), 0) + 1
  INTO :NEW.ID
  FROM GROUPS;
END;

CREATE OR REPLACE TRIGGER GENERATE_AUTO_INCREMENT_STUDENTS
BEFORE INSERT ON STUDENTS
FOR EACH ROW
BEGIN
--Oracle/PLSQL функция COALESCE возвращает первое ненулевое выражение из списка
  SELECT COALESCE(MAX(ID), 0) + 1
  INTO :NEW.ID
  FROM STUDENTS;
END;

insert into students(name, group_id) values('student', 1);
SELECT * FROM STUDENTS;
insert into groups(name, c_val) values('group', 30);
select * from groups;



--unique group.name
CREATE OR REPLACE TRIGGER check_unique_group_name
BEFORE INSERT OR UPDATE ON GROUPS
FOR EACH ROW
DECLARE
  count_name NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO count_name
    FROM GROUPS
    WHERE NAME = :NEW.NAME;
    
    IF(count_name!=0) THEN 
      RAISE_APPLICATION_ERROR(-20003, 'Ошибка: Поле NAME в таблице GROUPS должно быть уникальным.');
    END IF;
END;

insert into groups(name, c_val) values('group', 30);


