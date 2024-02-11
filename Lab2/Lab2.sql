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



--task3
CREATE OR REPLACE TRIGGER cascade_delete 
BEFORE DELETE ON GROUPS
FOR EACH ROW
BEGIN 
    DELETE FROM students
    WHERE GROUP_ID = :OLD.ID;
END;

INSERT INTO GROUPS(NAME, C_VAL) VALUES('group_check_cascade', 35);
SELECT * FROM GROUPS;
INSERT INTO STUDENTS(NAME, GROUP_ID) VALUES('st_check_cascade', (select id from groups where name = 'group_check_cascade'));
SELECT * FROM STUDENTS;
DELETE FROM GROUPS WHERE Name = 'group_check_cascade';



--task4
CREATE TABLE LOG_STUDENTS 
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ACTION VARCHAR(6),
  DATETIME TIMESTAMP,
  STUDENT_ID NUMBER,
  NAME VARCHAR2(20),
  GROUP_ID NUMBER
);

DROP TABLE LOG_STUDENTS

CREATE OR REPLACE TRIGGER student_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON STUDENTS
FOR EACH ROW
BEGIN
   IF INSERTING THEN
      INSERT INTO LOG_STUDENTS(ACTION, DATETIME, STUDENT_ID, NAME, GROUP_ID)
      VALUES('INSERT', SYSTIMESTAMP, :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
   ELSIF UPDATING THEN
      INSERT INTO LOG_STUDENTS(ACTION, DATETIME, STUDENT_ID, NAME, GROUP_ID)
      VALUES('UPDATE', SYSTIMESTAMP, :OLD.ID, :OLD.NAME, :OLD.GROUP_ID);
   ELSIF DELETING THEN
      INSERT INTO LOG_STUDENTS(ACTION, DATETIME, STUDENT_ID, NAME, GROUP_ID)
      VALUES('DELETE', SYSTIMESTAMP, :OLD.ID, :OLD.NAME, :OLD.GROUP_ID);
   END IF;
END;

--можно для проверки использовать проверку из task3
select * from log_students;


--task5
--CREATE OR REPLACE PROCEDURE restore_students_info (
--    date_time   IN TIMESTAMP,
--    time_offset IN INTERVAL DAY TO SECOND
--) IS
--BEGIN
--    IF date_time IS NOT NULL THEN --все записи на конкретную дату и время 
--        SELECT * 
--        FROM log_students
--        WHERE datetime = date_time;
--    ELSIF time_offset IS NOT NULL THEN --все записи в рамках этого смещения времени
--        SELECT *
--        FROM log_students
--        WHERE datetime >= SYSTIMESTAMP - time_offset;
--    END IF;
--END;


CREATE OR REPLACE PROCEDURE restore_students_info (
    date_time   IN TIMESTAMP,
    time_offset IN INTERVAL DAY TO SECOND
) IS
BEGIN
    IF date_time IS NOT NULL THEN --все записи на конкретную дату и время 
        FOR action_info IN (SELECT * FROM log_students WHERE TRUNC(datetime, 'MI') = TRUNC(date_time, 'MI')) --TRUNC для обрезания миллисекунд и других меньших единиц времени
        LOOP
            dbms_output.put_line('Action: ' || action_info.action);
            dbms_output.put_line('Datetime: ' || to_char(action_info.datetime, 'YYYY-MM-DD HH24:MI:SS'));
            dbms_output.put_line('Student ID: ' || action_info.student_id);
            dbms_output.put_line('Name: ' || action_info.NAME);
            dbms_output.put_line('Group ID: ' || action_info.GROUP_ID);
            dbms_output.put_line('---------------------------');
        END LOOP;
    ELSIF time_offset IS NOT NULL THEN --все записи в рамках этого смещения времени
        FOR action_info IN (SELECT * FROM log_students WHERE datetime >= systimestamp - time_offset)
        LOOP
            dbms_output.put_line('Action: ' || action_info.action);
            dbms_output.put_line('Datetime: ' || to_char(action_info.datetime, 'YYYY-MM-DD HH24:MI:SS'));
            dbms_output.put_line('Student ID: ' || action_info.student_id);
            dbms_output.put_line('Name: ' || action_info.NAME);
            dbms_output.put_line('Group ID: ' || action_info.GROUP_ID);
            dbms_output.put_line('---------------------------');
        END LOOP;
    END IF;
END;

execute dbms_output.put_line('----------- NEW-(date_time: 2024-02-11 13:08:24)----------------');
execute restore_students_info(TO_TIMESTAMP('2024-02-11 13:08:24', 'YYYY-MM-DD HH24:MI:SS'), NULL);
execute dbms_output.put_line('----------- NEW-(3 hours)----------------');
execute restore_students_info(NULL, INTERVAL '3' HOUR);
execute dbms_output.put_line('----------- NEW-(2 days)----------------');
execute restore_students_info(NULL, INTERVAL '2' DAY);




