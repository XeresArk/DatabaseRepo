DROP FUNCTION fn_department_with_max_salary;

DELIMITER $$

CREATE FUNCTION fn_department_with_max_salary()
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE max_sal INT;
    DECLARE result VARCHAR(200);

    -- Step 1: Find maximum salary in the company
    SELECT MAX(sal)
    INTO max_sal
    FROM emp;

    -- Step 2: Find all departments having employees with that salary
    SELECT GROUP_CONCAT(DISTINCT deptno)
    INTO result
    FROM emp
    WHERE sal = max_sal;

    RETURN result;
END $$

DELIMITER ;