CREATE VIEW [dbo].[vyuCTGetNeedPlanWeek]
AS
SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY (SELECT 1))) AS intNeedPlanId,strNeedPlan 
FROM 
(
	SELECT DISTINCT CASE WHEN intWeek < 10 THEN '0'+LTRIM(intWeek) 
							   ELSE LTRIM(intWeek)
						  END 
	+'-'+LTRIM(intYear) AS strNeedPlan
	FROM tblRKStgBlendDemand
)t
