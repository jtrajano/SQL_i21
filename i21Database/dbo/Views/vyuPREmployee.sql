CREATE VIEW [dbo].[vyuPREmployee]
AS
SELECT
Emp.intEntityEmployeeId,
Emp.strEmployeeId,
Emp.strLastName,
Emp.strFirstName,
Emp.strNameSuffix,
Emp.strMiddleName,
Sec.intEntityUserSecurityId,
Emp.intRank,
Ent.strPhone,
Ent.strTitle,
Loc.strAddress,
Loc.strCity,
Loc.strState,
Loc.strZipCode,
Loc.strCountry,
Emp.ysnActive,
Emp.strPayPeriod
FROM dbo.tblPREmployee AS Emp
INNER JOIN dbo.tblEntity AS Ent ON Ent.intEntityId = Emp.[intEntityEmployeeId]
LEFT JOIN dbo.tblEntityLocation AS Loc ON Loc.intEntityId = Emp.[intEntityEmployeeId] AND Loc.ysnDefaultLocation = 1
LEFT JOIN dbo.tblSMUserSecurity AS Sec ON Sec.intEntityUserSecurityId = Ent.intEntityId