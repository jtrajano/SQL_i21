CREATE VIEW [dbo].[vyuARCommissionRecap]
AS
SELECT CR.*
	 , CS.strCommissionScheduleName
	 , CP.strCommissionPlanName
	 , strDateRange = CONVERT(NVARCHAR(10), ISNULL(CR.dtmStartDate, '01/01/1900'), 1) + ' - ' + CONVERT(NVARCHAR(10), ISNULL(CR.dtmEndDate, GETDATE()), 1)
 FROM tblARCommissionRecap CR
	INNER JOIN tblARCommissionRecapDetail CRD ON CR.intCommissionRecapId = CRD.intCommissionRecapId
	LEFT JOIN tblARCommissionSchedule CS ON CR.intCommissionScheduleId = CS.intCommissionScheduleId
	LEFT JOIN tblARCommissionPlan CP ON CR.intCommissionPlanId = CR.intCommissionPlanId