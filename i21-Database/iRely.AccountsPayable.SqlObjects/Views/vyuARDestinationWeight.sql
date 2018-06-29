CREATE VIEW [dbo].[vyuARDestinationWeight]
	AS 
SELECT
	[intWeightGradeId]
	,[strWeightGradeDesc]
	,CAST(CASE WHEN strWhereFinalized = 'Origin' THEN 1 ELSE 2 END AS INT) AS intOriginDest
FROM
	tblCTWeightGrade
