-- Drop the existing database if needed
DROP DATABASE IF EXISTS performance_management;

-- Create a new database
CREATE DATABASE performance_management;
USE performance_management;

-- Create the 'users' table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(100) NOT NULL,
  role ENUM('HoD', 'Supervisor', 'Employee') NOT NULL,
  department VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  assigned_supervisor INT,
  assigned_hod INT,
  FOREIGN KEY (assigned_supervisor) REFERENCES users(id),
  FOREIGN KEY (assigned_hod) REFERENCES users(id)
);

-- Create the 'departments' table
CREATE TABLE departments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

-- Create the 'department_objectives' table
CREATE TABLE department_objectives (
  id INT AUTO_INCREMENT PRIMARY KEY,
  department_id INT NOT NULL,
  description TEXT NOT NULL,
  weightage FLOAT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Create the 'kpis' table
CREATE TABLE kpis (
  id INT AUTO_INCREMENT PRIMARY KEY,
  department_objective_id INT,
  name VARCHAR(100) NOT NULL,
  unit VARCHAR(50) NOT NULL,
  weightage FLOAT NOT NULL,
  created_by INT,
  created_at DATE,
  FOREIGN KEY (department_objective_id) REFERENCES department_objectives(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create the 'employee_kpis' table
CREATE TABLE employee_kpis (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  kpi_id INT NOT NULL,
  value FLOAT NOT NULL,
  graded_by INT,
  grade INT,
  eval_date DATE,
  FOREIGN KEY (employee_id) REFERENCES users(id),
  FOREIGN KEY (kpi_id) REFERENCES kpis(id),
  FOREIGN KEY (graded_by) REFERENCES users(id)
);

-- Create the 'grades' table
CREATE TABLE grades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  grade INT NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES users(id)
);

-- Create the 'employee_departmental_objectives' table
CREATE TABLE employee_departmental_objectives (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  departmental_objective_id INT NOT NULL,
  achieved_value INT NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES users(id),
  FOREIGN KEY (departmental_objective_id) REFERENCES department_objectives(id)
);
