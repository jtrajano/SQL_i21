CREATE VIEW vyuPRReportEmployeeDetail AS

SELECT
	 EMP.intEntityId
	,EMP.strEmployeeId
	,CASE WHEN dbo.fnAESDecryptASym(EMP.strSocialSecurity) = '' OR dbo.fnAESDecryptASym(EMP.strSocialSecurity) IS NULL  THEN 'No SSN Setup'
		ELSE dbo.fnAESDecryptASym(EMP.strSocialSecurity) END AS strSocialSecurity
	,EMP.strFirstName
	,CASE WHEN EMP.strMiddleName = '' OR EMP.strMiddleName IS NULL THEN '' ELSE UPPER(LEFT(EMP.strMiddleName,1)) + '.' END AS strMiddleName
	,EMP.strLastName
	,EL.strAddress
	,E.strEmail
	,EL.strCity
	,EL.strState
	,EL.strZipCode
	,FORMAT(CAST(EMP.dtmDateHired AS DATE), 'MM/dd/yyyy') AS dtmDateHired
	,FORMAT(CAST(EMP.dtmTerminated AS DATE), 'MM/dd/yyyy') AS dtmTerminated
	,strDepartment = SUBSTRING((SELECT ', '+ D.strDepartment AS [text()] FROM tblPREmployeeDepartment ED
							INNER JOIN tblPRDepartment D ON ED.intDepartmentId = D.intDepartmentId
							WHERE EMP.intEntityId = ED.intEntityEmployeeId
							ORDER BY ED.intEmployeeDepartmentId ASC
							FOR XML PATH ('')
						), 2, 1000) COLLATE Latin1_General_CI_AS 
	,SM.strCompanyName
	,dbo.fnConvertToFullAddress(SM.strAddress,SM.strCity, SM.strState,SM.strZip) AS strCompanyAddress
FROM tblPREmployee EMP
LEFT JOIN tblEMEntity E
on EMP.intEntityId = E.intEntityId + 1
LEFT JOIN tblEMEntityLocation EL
on EMP.intEntityId = EL.intEntityId
CROSS JOIN tblSMCompanySetup 
SM