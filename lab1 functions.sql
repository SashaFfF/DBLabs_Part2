CREATE OR REPLACE FUNCTION checkEvenOddValues
RETURN VARCHAR2 
IS
    even_count NUMBER;
    odd_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO even_count
    FROM MyTable
    WHERE mod(val, 2) = 0;
    
    SELECT COUNT(*)
    INTO odd_count
    FROM MyTable
    WHERE mod(val, 2) = 1;
    
    IF even_count>odd_count THEN
    RETURN 'TRUE';
    ELSIF odd_count>even_count THEN 
    RETURN 'FALSE';
    ELSE 
    RETURN 'EQUAL';
    END IF;
END;

CREATE OR REPLACE FUNCTION generateInsertCommand (param_id IN NUMBER)
RETURN VARCHAR2 
IS 
    insert_command VARCHAR2(100);
    val NUMBER;
BEGIN
    SELECT val
    INTO val
    FROM MyTable
    WHERE id = param_id;
    
    insert_command := 'INSERT INTO MyTable(id, val) VALUES(' || param_id || ',' || val || ');';
    RETURN insert_command;
END;

CREATE OR REPLACE FUNCTION calculateYearlyBonus(monthly_salary IN NUMBER, bonus_percent IN NUMBER) 
RETURN NUMBER 
IS
  yearly_bonus NUMBER;
BEGIN
    IF MOD(bonus_percent, 1) != 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Процент годовых премиальных должен быть ЦЕЛЫМ числом');
    END IF;
    
    IF bonus_percent < 0 OR bonus_percent > 100 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Процент годовых премиальных может принимать значение от 0 до 100');
    END IF;
    
    yearly_bonus := ( 1 + bonus_percent / 100 ) * 12 * monthly_salary;
    RETURN yearly_bonus;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Некорректный ввод. Процент годовых премиальных должен быть ЧИСЛОМ');
END;

DECLARE
    compare_even_odd VARCHAR2(5);
    insert_command VARCHAR2(100);
    ID NUMBER := 31611;
    yearly_bonus NUMBER;
BEGIN
    compare_even_odd := checkEvenOddValues();
    insert_command := generateInsertCommand(ID);
    yearly_bonus := calculateYearlyBonus(1000, 10);
    DBMS_OUTPUT.PUT_LINE('Результат сравнения четных и нечетных значений: ' || compare_even_odd);
    DBMS_OUTPUT.PUT_LINE('Команда вставки для записи с ID = '|| iD || ': ' || insert_command);
    DBMS_OUTPUT.PUT_LINE('Общее вознаграждение за год: ' || yearly_bonus);
END;