CREATE VIEW vyuPRReportEmployee401K
AS
SELECT DISTINCT
	ROW_NUMBER() OVER(ORDER BY EE.strLastName) AS intRowNumber,
	dbo.fnAESDecryptASym(EE.strSocialSecurity) AS strSSN,
	EE.strLastName AS strLastName,
	EE.strFirstName AS strFirstName,
	PC.dtmPayDate,
	ISNULL(PC.dblGross,0) AS strGrossPay,
	SUM(ISNULL(PCDE.dblTotal,0)) AS dblEEPreTax,
	SUM(ISNULL(PCDC.dblTotal,0)) AS dblERMatch,
	SUM(ISNULL(PCDE.dblTotal,0) + ISNULL(PCDC.dblTotal,0)) AS dblTotal401K,
	PC.dblGross *.025 AS dblMax401k,
	SM.strCompanyName,      
	dbo.fnConvertToFullAddress(SM.strAddress,SM.strCity, SM.strState,SM.strZip) AS strCompanyAddress  
from tblPRPaycheck PC
LEFT JOIN tblPRPaycheckDeduction PCD
ON PC.intPaycheckId = PCD.intPaycheckId

LEFT JOIN tblPRTypeDeduction TD
ON PCD.intTypeDeductionId = TD.intTypeDeductionId

LEFT JOIN tblPRPaycheckDeduction PCDE
ON PC.intPaycheckId = PCDE.intPaycheckId
and TD.intTypeDeductionId = PCDE.intTypeDeductionId
and PCDE.strPaidBy = 'Employee'

LEFT JOIN tblPRPaycheckDeduction PCDC
ON PC.intPaycheckId = PCDC.intPaycheckId
and TD.intTypeDeductionId = PCDC.intTypeDeductionId
and PCDC.strPaidBy = 'Company'

LEFT JOIN tblPREmployee EE
ON PC.intEntityEmployeeId = EE.intEntityId

CROSS JOIN tblSMCompanySetup SM

WHERE PCD.intPaycheckDeductionId is not null
AND TD.strCategory = '401(k)'
AND YEAR(PC.dtmPayDate) = YEAR(GETDATE())
GROUP BY EE.strFirstName,EE.strMiddleName,EE.strLastName,strSocialSecurity,PC.dblGross,PC.intPaycheckId,PC.dtmPayDate,SM.strCompanyName,SM.strAddress,SM.strCity, SM.strState,SM.strZip