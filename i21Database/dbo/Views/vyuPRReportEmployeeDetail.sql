CREATE VIEW vyuPRReportEmployeeDetail AS

SELECT DISTINCT    
  EMP.intEntityId    
 ,EMP.strEmployeeId    
 ,CASE WHEN (dbo.fnAESDecryptASym(EMP.strSocialSecurity) = '' OR dbo.fnAESDecryptASym(EMP.strSocialSecurity) IS NULL)  THEN 'No SSN Setup'    
  WHEN (LEN(dbo.fnAESDecryptASym(EMP.strSocialSecurity)) >= 100)  THEN ''     
  ELSE dbo.fnAESDecryptASym(EMP.strSocialSecurity) END AS strSocialSecurity    
 ,EMP.strFirstName    
 ,CASE WHEN EMP.strMiddleName = '' OR EMP.strMiddleName IS NULL THEN '' ELSE UPPER(LEFT(EMP.strMiddleName,1)) + '.' END AS strMiddleName    
 ,EMP.strLastName    
 ,EL.strAddress    
 ,E.strEmail    
 ,EL.strCity    
 ,EL.strState    
 ,EL.strZipCode    
 ,EMP.dtmDateHired  
 ,EMP.dtmTerminated  
 ,strDepartment = SUBSTRING((SELECT ', '+ D.strDepartment AS [text()] FROM tblPREmployeeDepartment ED    
       INNER JOIN tblPRDepartment D ON ED.intDepartmentId = D.intDepartmentId    
       WHERE EMP.intEntityId = ED.intEntityEmployeeId    
       ORDER BY ED.intEmployeeDepartmentId ASC    
       FOR XML PATH ('')    
      ), 2, 1000) COLLATE Latin1_General_CI_AS     
 ,SM.strCompanyName    
 ,dbo.fnConvertToFullAddress(SM.strAddress,SM.strCity, SM.strState,SM.strZip) AS strCompanyAddress    
FROM tblPREmployee EMP    
LEFT JOIN tblEMEntityLocation EL    
ON EMP.intEntityId = EL.intEntityId    
and EL.ysnDefaultLocation = 1    
LEFT JOIN tblEMEntityToContact ETC    
ON EMP.intEntityId = ETC.intEntityId    
and ETC.ysnDefaultContact = 1    
LEFT JOIN tblEMEntity E    
ON ETC.intEntityContactId = E.intEntityId    
CROSS JOIN tblSMCompanySetup SM  