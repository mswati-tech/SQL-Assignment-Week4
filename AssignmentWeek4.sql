CREATE DATABASE Project_info; /*Creating a database 'Project_info'*/
USE Project_info;	/*Further utilising the created database to insert tables*/

/*Creating table 'Projects'*/
CREATE TABLE Projects (
project_id INT PRIMARY KEY, 
project_name VARCHAR(255), 
budget DECIMAL(10,2), 
start_date DATE,
team_id INT UNIQUE
);

/*Creating table 'Tasks'*/
CREATE TABLE Tasks (
task_id INT PRIMARY KEY, 
task_name VARCHAR(255), 
member_name VARCHAR(100), 
due_date DATE, 
task_completed BOOLEAN,
project_id INT,
FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

/*Creating table 'Teams'*/
CREATE TABLE Teams (
member_id INT,
member_name VARCHAR(100),
team_id INT PRIMARY KEY,
role VARCHAR(100),
FOREIGN KEY (team_id) REFERENCES Projects(team_id)
);

/*Populating the Projects table. No task will reference the Projects.project_ID = 6*/
INSERT INTO Projects (project_id, project_name, budget, start_date, team_id) VALUES
(1, 'AI Chatbot', 50000.00, '2023-10-01', 101),
(2, 'Data Science', 30000.00, '2023-11-15', 102),
(3, 'Web Design', 45000.00, '2023-12-05', 103),
(4, 'Mobile App', 60000.00, '2024-01-10', 104),
(5, 'Market Research', 25000.00, '2024-02-20', 105),
(6, 'Inventory Analysis', 40000.00, '2024-03-15', 106);

/*Populating the Teams table and added NULL values in the Teams.member_id = 6*/
INSERT INTO Teams (member_id, member_name, role, team_id) VALUES
(1, 'Swati Mishra', 'Team Lead', 105),
(2, 'Rahul Pandey', 'Developer', 101),
(3, 'Kritika Awasthi', 'Team Lead', 102),
(4, 'Neha Shukla', 'Analyst', 103),
(5, 'Dimpal Tripathi', 'Team Lead', 104),
(6, 'Rahul Mishra', NULL, 106);

/*Populating the Tasks table and added a few NULL values*/
INSERT INTO Tasks (task_id, task_name, member_name, due_date, task_completed, project_id) VALUES
(201, 'UI Design', 'Swati Mishra', '2023-11-01', TRUE, 1),
(202, 'Backend Setup', 'Rahul Mishra', '2023-11-10', FALSE, 1),
(203, 'Data Cleanup', 'Kritika Awasthi', '2023-12-01', TRUE, 2),
(204, 'User Testing', 'Neha Shukla', '2024-01-05', FALSE, 3),
(205, 'App Deployment', 'Rahul Pandey', '2024-02-01', TRUE, 4),
(206, 'Inventory Review', NULL, '2024-02-15', NULL, 5);

/*Question #1
Declare the CTE 'ProjectsTasks' to COUNT the number of tasks GROUP BY project_id and SUM(IF(task_completed = TRUE))*/
WITH ProjectsTasks AS (
  SELECT 
    project_id,
    COUNT(*) AS total_tasks_by_project,
    SUM(task_completed = TRUE) AS total_completed_tasks_by_project
  FROM Tasks
  GROUP BY project_id
)
SELECT * FROM ProjectsTasks; -- Output the 'ProjectsTasks' CTE

/*Question #2
Declared a CTE 'RankedMembers' and used Tasks table to ROW_NUMBER() member_name(s) across all project_id(s) that have been assigned tasks
*/
WITH RankedMembers AS (
  SELECT
    member_name,
    project_id,
    task_completed,
    ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY task_completed DESC) AS highest_members
  FROM Tasks
)
SELECT * 
FROM RankedMembers 
LIMIT 2; -- From the CTE 'RankedMembers' output only first two rows

/*Question #3
Parent query finds out the tasks that have due_date earlier than child query where the average due_date is calculated
Hence, it is a correlated subquery */
SELECT task_id, task_name, due_date -- Parent query
FROM Tasks
WHERE due_date < (SELECT AVG(due_date) FROM Tasks); -- Child query

/*Question #4
Subquery: Output the column values from project_id, project_name, budget from Projects table (Parent query) where 
budget = MAX(budget). This is child query*/
SELECT project_id, project_name, budget FROM Projects -- Outer query
WHERE budget = (SELECT MAX(budget) FROM Projects); -- Inner query

/*Question #5
Created a CTE 'Percent_CompletedTasks and implemented the percentage formula where the task_completed is True
to the total number of tasks in the Tasks table. Aggregated using the Group By command.*/
WITH Percent_CompletedTasks AS (
  SELECT 
    project_id,
    (SUM(task_completed = TRUE)/COUNT(*)) * 100 AS Projectwise_CompletedTasks_Percentage
  FROM Tasks
  GROUP BY project_id
)
SELECT * FROM Percent_CompletedTasks;

/*Question #6
ORDER BY and COUNT with the PARTITION window function will provide row-level details */
SELECT 
  member_name AS assigned_to,
  task_name,
  COUNT(*) OVER (PARTITION BY member_name) AS task_count
FROM Tasks
ORDER BY assigned_to;

/*Question #7
Used JOIN to join where both member_name(s) in Tasks and Teams table are the same, and then output the task_name
and the member_name FROM Tasks where both the conditions are satisified that the role is 'Team Lead' and due date is
15 days from the assumed current date = 2023-11-5*/ 
SELECT
  Tasks.task_name,
  Teams.member_name
FROM
  Tasks
JOIN
  Teams ON Tasks.member_name = Teams.member_name
WHERE
  Teams.role = 'Team Lead'
  AND Tasks.due_date = DATE_ADD('2023-10-17', INTERVAL 15 DAY);
  
/*Question #8
Since the Projects table appears first MySQL will treat it as the left table and Tasks appears later therefore it will
be treated as the right table. Therefore, the query below states that all the values in the Projects Table that have
an entry in the Tasks table.*/
SELECT
Projects.project_id
FROM
Projects
LEFT JOIN
Tasks ON Projects.project_id = Tasks.project_id
WHERE
Tasks.project_id IS NULL;

/*Question #9
Created and populated the table and linked it to the Projects table using project_id. Used the RANL() window function.
It is easier to use in the CTE 'ProjectAccuracyAI', simply PARTITION BY project_id and arrange it in descending order
with the ORDER BY function.*/
CREATE TABLE Model_Training (
  training_id INT PRIMARY KEY,
  project_id INT,
  model_name VARCHAR(100),
  accuracy DECIMAL(5,2),
  training_date DATE,
  FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

INSERT INTO Model_Training (training_id, project_id, model_name, accuracy, training_date)
VALUES
  (1, 1, 'SVM Classifier', 88.75, '2023-10-10'),
  (2, 1, 'Transformers', 91.50, '2023-10-12'),
  (3, 2, 'Decision Tree', 75.00, '2023-11-20'),
  (4, 2, 'Random Forest', 82.30, '2023-11-22'),
  (5, 3, 'KNN', 68.90, '2023-12-10'),
  (6, 3, 'XGBoost', 85.25, '2023-12-11'),
  (7, 4, 'Bayesian', 89.50, '2024-01-12'),
  (8, 4, 'Polynomial Fitting', 92.60, '2024-01-15'),
  (9, 5, 'Linear Regression', 72.10, '2024-02-22');

WITH ProjectAccuracyAI AS (
  SELECT 
    project_id, 
    model_name, 
    accuracy,
    RANK() OVER (PARTITION BY project_id ORDER BY accuracy DESC) AS rank_acc
  FROM Model_Training
)
SELECT * 
FROM ProjectAccuracyAI 
WHERE rank_acc = 1;

/* Question #10
The table was created and populated. Performed a JOIN to satisfy both conditions from two different tables. 
It will retrieve all projects with datasets larger than 10GB that were updated within the last 30 days from today.*/
CREATE TABLE Data_Sets (
  dataset_id INT PRIMARY KEY,
  project_id INT,
  dataset_name VARCHAR(255),
  size_gb DECIMAL(5,2),
  last_updated DATE,
  FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

INSERT INTO Data_Sets (dataset_id, project_id, dataset_name, size_gb, last_updated) VALUES
(1, 1, 'Customer Behavior', 12.5, '2025-07-10'),
(2, 2, 'Sales Trends', 8.0, '2025-07-15'),
(3, 3, 'Web Analytics', 15.0, '2025-06-15'), -- old date
(4, 4, 'App Feedback', 20.0, '2025-07-25'),
(5, 5, 'Survey Responses', 9.5, '2025-07-28'),
(6, 1, 'Clickstream Data', 13.2, '2025-07-20');

SELECT DISTINCT
  Projects.project_id,
  Projects.project_name,
  Data_Sets.dataset_name,
  Data_Sets.size_gb,
  Data_Sets.last_updated
FROM
  Projects
JOIN
  Data_Sets ON Projects.project_id = Data_Sets.project_id
WHERE
  Data_Sets.size_gb > 10
  AND Data_Sets.last_updated >= CURDATE() - INTERVAL 30 DAY;






