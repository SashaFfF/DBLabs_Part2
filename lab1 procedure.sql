CREATE TABLE mytable (
    id  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    val NUMBER
);


--task 5
CREATE or replace PROCEDURE insertValue (
    insert_val IN NUMBER
) IS
BEGIN
    INSERT INTO mytable ( val )
    VALUES ( insert_val );
END;

CREATE PROCEDURE deleteValue (delete_id IN NUMBER) IS
BEGIN
    DELETE FROM MyTable
    WHERE id = delete_id;
END;

CREATE PROCEDURE updateValue (id IN NUMBER, update_val IN NUMBER) IS
BEGIN
    UPDATE MyTable
    SET val = update_val
    WHERE id = id;

END;

execute insertValue(10);
execute deletevalue(1);
execute insertValue(1);
execute updateValue(2, 123);

select * from mytable;
