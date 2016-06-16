CREATE VIEW [dbo].[vyuARCommission]
AS 
SELECT strCommissionEntityName	= E.strName
	 , intCommissionEntityId	= C.intEntityId
     , CP.strCommissionPlanName
	 , CS.strCommissionScheduleName
	 , CP.dblHurdle
	 , strDateRange				= CONVERT(NVARCHAR(20), C.dtmStartDate, 101) + ' - ' + CONVERT(NVARCHAR(20), C.dtmEndDate, 101)
	 , C.*
	 , strCompanyName			= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	 , strCompanyAddress		= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
FROM tblARCommission C
	LEFT JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
	LEFT JOIN tblARCommissionPlan CP ON C.intCommissionPlanId = CP.intCommissionPlanId
	LEFT JOIN tblARCommissionSchedule CS ON C.intCommissionScheduleId = CS.intCommissionScheduleId
WHERE C.ysnConditional = 0 OR (C.ysnConditional = 1 AND C.ysnApproved = 1)