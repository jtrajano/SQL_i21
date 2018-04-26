CREATE VIEW [dbo].[vyuARCommission]
AS 
SELECT C.*
	 , strCommissionEntityName		= E.strName
	 , intCommissionEntityId		= C.intEntityId
     , strCommissionPlanName		= CP.strCommissionPlanName
	 , strCommissionScheduleName	= CS.strCommissionScheduleName
	 , dblHurdle					= ISNULL(CP.dblHurdle, 0.00)
	 , dblCalculationAmount			= ISNULL(CP.dblCalculationAmount, 0.00)
	 , strDateRange					= CONVERT(NVARCHAR(20), C.dtmStartDate, 101) + ' - ' + CONVERT(NVARCHAR(20), C.dtmEndDate, 101)
	 , strBasis						= CP.strBasis
	 , strCalculationType			= CP.strCalculationType	 
	 , strBillId					= BILL.strBillId
	 , strPaymentRecordNum			= PAYMENT.strPaymentRecordNum
	 , strPaycheckId				= PAYCHECK.strPaycheckId
	 , strCompanyName				= COMPANY.strCompanyName
	 , strCompanyAddress			= COMPANY.strCompanyAddress	 
FROM dbo.tblARCommission C WITH (NOLOCK)
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON C.intEntityId = E.intEntityId
LEFT JOIN (
	SELECT intCommissionPlanId
		 , strCommissionPlanName
		 , strBasis
		 , strCalculationType
		 , dblCalculationAmount
		 , dblHurdle
	FROM dbo.tblARCommissionPlan WITH (NOLOCK)
) CP ON C.intCommissionPlanId = CP.intCommissionPlanId
LEFT JOIN (
	SELECT intCommissionScheduleId
		 , strCommissionScheduleName
	FROM dbo.tblARCommissionSchedule WITH (NOLOCK)
) CS ON C.intCommissionScheduleId = CS.intCommissionScheduleId
LEFT JOIN (
	SELECT intBillId
		 , strBillId
	FROM dbo.tblAPBill WITH (NOLOCK)
) BILL ON C.intBillId = BILL.intBillId
LEFT JOIN (
	SELECT intPaymentId
		 , strPaymentRecordNum 
	FROM dbo.tblAPPayment WITH (NOLOCK)
) PAYMENT ON C.intPaymentId = PAYMENT.intPaymentId
LEFT JOIN (
	SELECT intPaycheckId
		 , strPaycheckId
	FROM dbo.tblPRPaycheck WITH (NOLOCK)
) PAYCHECK ON C.intPaycheckId = PAYCHECK.intPaycheckId
OUTER APPLY (
	SELECT TOP 1 strCompanyName 
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0)
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
WHERE C.ysnConditional = 0 OR (C.ysnConditional = 1 AND C.ysnApproved = 1)