drop view emp_dept_view;

CREATE VIEW emp_dept_view AS
SELECT 
    e.empno,
    e.ename,
    e.job,
    e.mgr,
    e.hiredate,
    e.sal,
    e.comm,
    e.deptno,
    d.dname,
    d.loc
FROM emp e
JOIN dept d ON e.deptno = d.deptno;