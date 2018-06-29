CREATE VIEW [dbo].[vyuARCommissionRecap]
AS
SELECT CR.*
	 , CS.strCommissionScheduleName
	 , CP.strCommissionPlanName
	 , strDateRange					=	CONVERT(NVARCHAR(10), ISNULL(CR.dtmStartDate, '01/01/1900'), 1) + ' - ' + CONVERT(NVARCHAR(10), ISNULL(CR.dtmEndDate, GETDATE()), 1)
FROM 
	tblARCommissionPlan CP
INNER JOIN 
	tblARCommissionRecap CR ON CP.intCommissionPlanId = CR.intCommissionPlanId 
-- INNER JOIN 
-- 	(SELECT 
-- 		intCommissionRecapId 
-- 	 FROM 
-- 		tblARCommissionRecapDetail) CRD ON CR.intCommissionRecapId = CRD.intCommissionRecapId
LEFT JOIN 
	(SELECT
		intCommissionScheduleId
		, strCommissionScheduleName
	 FROM 
		tblARCommissionSchedule) CS ON CR.intCommissionScheduleId = CS.intCommissionScheduleId