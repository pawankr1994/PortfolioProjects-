SELECT * 
FROM [Census Project].dbo.Data1

SELECT *
FROM [Census Project].dbo.Data2;

-- State name starting with letter A
SELECT DISTINCT State
FROM[Census Project]..Data1
WHERE LOWER(State) LIKE 'a%';
--
SELECT DISTINCT State
FROM[Census Project]..Data1
WHERE LOWER(State) LIKE 'a%' OR LOWER(State) LIKE 'b%';
--
SELECT DISTINCT State
FROM[Census Project]..Data1
WHERE LOWER(State) LIKE 'a%' OR LOWER(State) LIKE '%d';

-- Total Number of row present in dataset
SELECT count(*) 
FROM[Census Project]..Data1

SELECT count(*) 
FROM[Census Project]..Data2

-- Population of India
SELECT sum(Population) AS Population
FROM [Census Project]..Data2;

-- Dataset for Jharkhand and Bihar
SELECT *
FROM [Census Project]..Data1
WHERE State IN ('Bihar','Jharkhand');

-- Average Growth of India
SELECT avg(Growth)*100 AS AvgGrowthPercentage
FROM [Census Project]..Data1;

-- Average Growth of State of India
SELECT State, ROUND(AVG(Growth)*100,2) AS AvgGrowthPercentage
FROM [Census Project]..Data1 GROUP BY State;

-- Top three state showing highest growth 
SELECT TOP 3 State, ROUND(AVG(Growth)*100,2) AS AvgGrowthPercentage
FROM [Census Project]..Data1 GROUP BY State
ORDER BY AvgGrowthPercentage DESC;

-- Lowest three state of growth 
SELECT TOP 3 State, ROUND(AVG(Growth)*100,2) AS AvgGrowthPercentage
FROM [Census Project]..Data1 GROUP BY State
ORDER BY AvgGrowthPercentage ASC;
--
SELECT State, Growth
FROM [Census Project]..Data1 
WHERE State in ('Bihar','Jharkhand');

--
SELECT State, avg(Growth)*100 
FROM (
    SELECT State, Growth
    FROM [Census Project]..Data1 
    WHERE State = 'Bihar'
) AS Subquery
GROUP BY State;
--
SELECT State, SUM(Growth) 
FROM [Census Project]..Data1 
GROUP BY State
HAVING State = 'Bihar';

-- Average Sex Ratio of State of India
SELECT State, round(avg(Sex_Ratio),0) as AvgSexRatio 
FROM [Census Project]..Data1 GROUP BY State
ORDER BY AvgSexRatio DESC;
-- Lowest three state 
SELECT TOP 3 State, round(avg(Sex_Ratio),0) as AvgSexRatio 
FROM [Census Project]..Data1 GROUP BY State
ORDER BY AvgSexRatio ASC;
--
SELECT State, round(avg(Sex_Ratio),0) 
FROM [Census Project]..Data1 
GROUP BY State
HAVING State = 'Bihar';

-- Average Literacy of State of India
SELECT State, round(avg(Literacy),2) as AvgLiteracy 
FROM [Census Project]..Data1 GROUP BY State
ORDER BY AvgLiteracy DESC;

SELECT State, round(avg(Literacy),2) as AvgLiteracy 
FROM [Census Project]..Data1 GROUP BY State
HAVING round(avg(Literacy),2)>90
ORDER BY AvgLiteracy DESC;

SELECT State, round(avg(Literacy),2) as AvgLiteracy 
FROM [Census Project]..Data1 
GROUP BY State
HAVING State = 'Bihar';

-- Top and Bottom of 3 State in Literacy
DROP TABLE IF EXISTS #topstate;
CREATE TABLE #topstate
(state nvarchar(255),
topstate float)

INSERT INTO #topstate
SELECT State, round(avg(Literacy),0) as AvgLiteracy  
FROM [Census Project]..Data1 GROUP BY State;

SELECT  TOP 3 * FROM #topstate ORDER BY #topstate.topstate DESC;

DROP TABLE IF EXISTS #bottomstate;
CREATE TABLE #bottomstate
(state nvarchar(255),
bottomstate float)

INSERT INTO #bottomstate
SELECT State, round(avg(Literacy),0) as AvgLiteracy  
FROM [Census Project]..Data1 GROUP BY State;

SELECT  TOP 3 * FROM #bottomstate ORDER BY #bottomstate.bottomstate ASC;

--
SELECT * FROM(
SELECT  TOP 3 * FROM #topstate ORDER BY #topstate.topstate DESC) a
UNION
SELECT * FROM (
SELECT  TOP 3 * FROM #bottomstate ORDER BY #bottomstate.bottomstate ASC) b;

-- Joining Table:
SELECT a.District, a.State, b.Population, a.Sex_Ratio from [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District;

-- Calculating number of males and females
SELECT c.District, c.State, ROUND(c.Population/(c.Sex_Ratio +1),0) Males, ROUND((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) Female
FROM
(SELECT a.District, a.State, b.Population, a.Sex_Ratio/1000 Sex_Ratio FROM [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) c;
--
SELECT d.State, SUM(d.Males)  Male, SUM(d.Female) Female
FROM
(SELECT c.District, c.State, ROUND(c.Population/(c.Sex_Ratio +1),0) Males, ROUND((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) Female
FROM
(SELECT a.District, a.State, b.Population, a.Sex_Ratio/1000 Sex_Ratio FROM [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) c) d
GROUP BY d.State;

-- Total Literacy rate
SELECT c.District, c.State, c.Population, ROUND(c.Literacy_Rate*c.Population,0) AS LiteratePeople, ROUND((1-c.Literacy_Rate)*c.Population,0) AS IlliteratePeople
FROM
(SELECT a.District, a.State, b.Population, a.Literacy/100 AS Literacy_Rate FROM [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) AS c;

--
SELECT d.State,SUM(d.LiteratePeople) AS LiteratePeople, SUM(d.IlliteratePeople) AS IlliteratePeople
FROM
(SELECT c.District, c.State, c.Population, ROUND(c.Literacy_Rate*c.Population,0)AS LiteratePeople, ROUND((1-c.Literacy_Rate)*c.Population,0) AS IlliteratePeople
FROM
(SELECT a.District, a.State, b.Population, a.Literacy/100 AS Literacy_Rate FROM [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) AS c) AS d
GROUP BY d.State ;

-- Previous Population
SELECT c.District, c.State, c.Growth, ROUND(c.Population/(1+c.Growth),0) AS PreviousPopulation, c.Population AS CurrentPopulation
FROM
(SELECT a.District, a.State, b.Population, a.Growth from [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) AS c;
--

SELECT d.State, SUM(d.PreviousPopulation) AS PreviousPopulation, SUM(d.CurrentPopulation) AS CurrentPopulation 
FROM
(SELECT c.District, c.State, c.Growth, ROUND(c.Population/(1+c.Growth),0) AS PreviousPopulation, c.Population AS CurrentPopulation
FROM
(SELECT a.District, a.State, b.Population, a.Growth from [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) AS c) AS d
GROUP BY d.State;
--
SELECT SUM(e.PreviousPopulation) PrevPopINDIA, SUM(e.CurrentPopulation) CurrPopINDIA FROM
(SELECT d.State, SUM(d.PreviousPopulation) AS PreviousPopulation, SUM(d.CurrentPopulation) AS CurrentPopulation 
FROM
(SELECT c.District, c.State, c.Growth, ROUND(c.Population/(1+c.Growth),0) AS PreviousPopulation, c.Population AS CurrentPopulation
FROM
(SELECT a.District, a.State, b.Population, a.Growth from [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) AS c) AS d
GROUP BY d.State
) e;


-- Population vs Area

(SELECT SUM(e.PreviousPopulation) PrevPopINDIA, SUM(e.CurrentPopulation) CurrPopINDIA FROM
(SELECT d.State, SUM(d.PreviousPopulation) AS PreviousPopulation, SUM(d.CurrentPopulation) AS CurrentPopulation 
FROM
(SELECT c.District, c.State, c.Growth, ROUND(c.Population/(1+c.Growth),0) AS PreviousPopulation, c.Population AS CurrentPopulation
FROM
(SELECT a.District, a.State, b.Population, a.Growth from [Census Project]..Data1 a
INNER JOIN
[Census Project]..Data2 b ON a.District = b.District) AS c) AS d
GROUP BY d.State
) e)

-- Top three district from each state with highest literacy rate
SELECT a.*
FROM
(SELECT District, State, Literacy, RANK() OVER(PARTITION BY State ORDER BY Literacy DESC) RNK
FROM [Census Project] ..Data1) a
WHERE a.RNK IN (1,2,3) ORDER BY STATE;
