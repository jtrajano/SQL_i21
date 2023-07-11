CREATE VIEW [dbo].[vyuHDRoughCutCapacity]
AS 
SELECT
	strSourceName = S.strName
	,strTicketNumber = HDT.strTicketNumber
	,strSubject = HDT.strSubject
	,strCustomerName = C.strName
	,A.*
FROM [dbo].[tblHDRoughCutCapacity] A
LEFT JOIN [dbo].[tblHDTicket] HDT ON HDT.intTicketId = A.intTicketId
LEFT JOIN [dbo].[tblEMEntity] S ON S.intEntityId = A.intSourceEntityId
LEFT JOIN [dbo].[tblEMEntity] C ON C.intEntityId = A.intCustomerEntityId
WHERE
	dblPlanFirstWeek IS NOT NULL
	OR dblPlanSecondWeek IS NOT NULL
	OR dblPlanThirdWeek IS NOT NULL
	OR dblPlanForthWeek IS NOT NULL
	OR dblPlanFifthWeek IS NOT NULL
	OR dblPlanSixthWeek IS NOT NULL
	OR dblPlanSeventhWeek IS NOT NULL
	OR dblPlanEighthWeek IS NOT NULL
	OR dblPlanNinthWeek IS NOT NULL
	OR dblPlanTenthWeek IS NOT NULL
	OR dblPlanEleventhWeek IS NOT NULL
	OR dblPlanTwelfthWeek IS NOT NULL
	OR dblEstimateFirstWeek IS NOT NULL
	OR dblEstimateSecondWeek IS NOT NULL
	OR dblEstimateThirdWeek IS NOT NULL
	OR dblEstimateForthWeek IS NOT NULL
	OR dblEstimateFifthWeek IS NOT NULL
	OR dblEstimateSixthWeek IS NOT NULL
	OR dblEstimateSeventhWeek IS NOT NULL
	OR dblEstimateEighthWeek IS NOT NULL
	OR dblEstimateNinthWeek IS NOT NULL
	OR dblEstimateTenthWeek IS NOT NULL
	OR dblEstimateEleventhWeek IS NOT NULL
	OR dblEstimateTwelfthWeek IS NOT NULL
	OR dblFirstWeek IS NOT NULL
	OR dblSecondWeek IS NOT NULL
	OR dblThirdWeek IS NOT NULL
	OR dblForthWeek IS NOT NULL
	OR dblFifthWeek IS NOT NULL
	OR dblSixthWeek IS NOT NULL
	OR dblSeventhWeek IS NOT NULL
	OR dblEighthWeek IS NOT NULL
	OR dblNinthWeek IS NOT NULL
	OR dblTenthWeek IS NOT NULL
	OR dblEleventhWeek IS NOT NULL
	OR dblTwelfthWeek IS NOT NULL
