create table emp(   
  empno    int,   
  ename    varchar(10),   
  job      varchar(9),   
  mgr      int,   
  hiredate date,   
  sal      int,   
  comm     int,   
  deptno   int,   
  constraint pk_emp primary key (empno),   
  constraint fk_deptno foreign key (deptno) references dept (deptno)   
);