CREATE VIEW [dbo].[vyuCTGetNeedPlanWeek]
AS
 SELECT
 CONVERT(INT,ROW_NUMBER() OVER(ORDER BY (SELECT 1))) AS intNeedPlanId
,CONVERT(NVARCHAR,dtmImportDate,106) strNeedPlan
FROM 
(   SELECT DISTINCT dtmImportDate FROM 
	(
		SELECT DISTINCT dtmImportDate FROM tblRKStgBlendDemand WHERE dblQuantity >0 
		UNION
		SELECT DISTINCT dtmImportDate FROM tblRKArchBlendDemand WHERE dblQuantity >0
	 )t 
)t
