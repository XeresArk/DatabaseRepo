DROP PROCEDURE sp_oldest_employee_per_department;

DELIMITER $$

CREATE PROCEDURE sp_oldest_employee_per_department()
BEGIN
    SELECT 
        d.deptno,
        d.dname,
        e.empno,
        e.ename,
        e.hiredate
    FROM dept d
    JOIN emp e ON e.deptno = d.deptno
    WHERE e.hiredate = (
        SELECT MIN(e2.hiredate)
        FROM emp e2
        WHERE e2.deptno = d.deptno
    )
    ORDER BY d.deptno;
END $$

DELIMITER ;