CREATE VIEW [dbo].[vyuARCommissionRecap]
AS
SELECT CR.*
	 , CS.strCommissionScheduleName
	 , CP.strCommissionPlanName
	 , strDateRange					=	CONVERT(NVARCHAR(10), ISNULL(CR.dtmStartDate, '01/01/1900'), 1) + ' - ' + CONVERT(NVARCHAR(10), ISNULL(CR.dtmEndDate, GETDATE()), 1) COLLATE Latin1_General_CI_AS
FROM 
	tblARCommissionPlan CP
INNER JOIN 
	tblARCommissionRecap CR ON CP.intCommissionPlanId = CR.intCommissionPlanId 
LEFT JOIN (
	SELECT intCommissionScheduleId
		 , strCommissionScheduleName
	FROM tblARCommissionSchedule
) CS ON CR.intCommissionScheduleId = CS.intCommissionScheduleId