BEGIN
FOR i IN 1..10000
LOOP 
    INSERT INTO MyTable(val)
    VALUES (DBMS_RANDOM.RANDOM);
END LOOP;
END;