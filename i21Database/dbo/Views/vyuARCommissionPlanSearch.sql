CREATE VIEW [dbo].[vyuARCommissionPlanSearch]
AS
SELECT CP.intCommissionId
	 , CP.intCommissionAccountId
	 , CP.strCommissionPlanName
	 , CP.strDescription
	 , CP.strBasis
	 , CP.strEntities
	 , CP.strCalculationType
	 , CP.strHurdleFrequency
	 , CP.strHurdleType
	 , CP.dblHurdle
	 , CP.dblCalculationAmount
	 , CP.dtmStartDate
	 , CP.dtmEndDate
	 , CP.ysnPaymentRequired
	 , CP.ysnActive
	 , strCommissionAccountId = A.strAccountId
FROM tblARCommissionPlan CP
LEFT JOIN tblGLAccount A ON CP.intCommissionAccountId = A.intAccountId