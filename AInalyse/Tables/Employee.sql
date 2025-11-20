CREATE TABLE employee (
  id int NOT NULL,
  name varchar(30) DEFAULT NULL,
  department varchar(9) DEFAULT NULL,
  active tinyint(1) DEFAULT NULL,
  role varchar(20) DEFAULT NULL,
  PRIMARY KEY (id)
);