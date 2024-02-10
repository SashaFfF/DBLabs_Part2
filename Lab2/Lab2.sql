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