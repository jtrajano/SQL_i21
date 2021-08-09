CREATE VIEW [dbo].[vyuPRVanguard401kPanel]
AS
SELECT
	strSocialSecurity = EMP.strSocialSecurity
	,strLastName = EMP.strLastName
	,strFirstName = EMP.strFirstName
	,strMI = SUBSTRING(EMP.strMiddleName, 0, 1)
	,strDivisionalCode = ''
	,dblTotalCompensation = dblNetPayTotal
	,dblEmployee401k = ISNULL([EMP401K].dblTotal, 0)
	,dblRoth401k = ISNULL([ROTH401K].dblTotal, 0)
	,dblLoanPayment = ISNULL([LOAN].dblTotal, 0)
	,dblMatch = ISNULL([MATCH].dblTotal, 0)
	,dblProfitSharing = ISNULL([PROFSHR].dblTotal, 0)
	,dblSafeHarbor = ISNULL([SAFEHM].dblTotal, 0)
	,dblHours = PC.dblTotalHours
	,strAddress1 = LOC.strAddress
	,strAddress2 = ''
	,strCity = LOC.strCity
	,strState = LOC.strState
	,strZip = LOC.strZipCode
	,dtmDateOfBirth = EMP.dtmBirthDate
	,dtmCurrentDateOfHire = EMP.dtmDateHired
	,dtmEmployeeEligibilityDate = [EMP401K].dtmBeginDate 
	,dtmCurrentDateOfTerm = EMP.dtmTerminated
	,dtmPriorDateOfHire = EMP.dtmOriginalDateHired
	,dtmPriorDateOfTerm = EMP.dtmTerminated
	,dblEstimatedAnnualCompensation = dblNetPayTotal * CASE (EMP.strPayPeriod) 
														WHEN 'Daily' THEN 365
														WHEN 'Weekly' THEN 52
														WHEN 'Bi-Weekly' THEN 26
														WHEN 'Semi-Monthly' THEN 24
														WHEN 'Monthly' THEN 12
														WHEN 'Quarterly' THEN 4
													ELSE 1 END
	,strEmploymentStatus = 'NNN'
	,strHCECode = 'N'
	,strKeyEECode = 'NN'
	,strEnrollmentEligibility = 'N'
	,strUnionStatusCode = 'N'
	,dtmPayDate = PC.dtmPayDate
FROM tblPREmployee [EMP]
	INNER JOIN tblEMEntityLocation [LOC] ON [EMP].intEntityId = [LOC].intEntityId AND [LOC].ysnDefaultLocation = 1
	INNER JOIN tblPRPaycheck [PC] ON EMP.intEntityId = PC.intEntityEmployeeId
	LEFT JOIN vyuPRPaycheckDeduction [EMP401K] ON [EMP401K].intPaycheckId = PC.intPaycheckId AND [EMP401K].strDeduction = 'PN'
	LEFT JOIN vyuPRPaycheckDeduction [ROTH401K] ON [ROTH401K].intPaycheckId = PC.intPaycheckId AND [ROTH401K].strDeduction = '<roth>'
	LEFT JOIN vyuPRPaycheckDeduction [LOAN] ON [LOAN].intPaycheckId = PC.intPaycheckId AND [LOAN].strDeduction = '<loan>'
	LEFT JOIN vyuPRPaycheckDeduction [MATCH] ON [MATCH].intPaycheckId = PC.intPaycheckId AND [MATCH].strDeduction = '<match>'
	LEFT JOIN vyuPRPaycheckDeduction [PROFSHR] ON [PROFSHR].intPaycheckId = PC.intPaycheckId AND [PROFSHR].strDeduction = '<profitsharing>'
	LEFT JOIN vyuPRPaycheckDeduction [SAFEHM] ON [SAFEHM].intPaycheckId = PC.intPaycheckId AND [SAFEHM].strDeduction = 'SH'
	LEFT JOIN vyuPRPaycheckDeduction [SAFEHNEC] ON [SAFEHNEC].intPaycheckId = PC.intPaycheckId AND [SAFEHNEC].strDeduction = '<safeharbornec>'

GO