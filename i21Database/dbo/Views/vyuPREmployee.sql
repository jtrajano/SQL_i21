CREATE VIEW [dbo].[vyuPREmployee]
AS
SELECT
Ent.intEntityId,
intEmployeeId = Emp.intEntityEmployeeId,
Emp.strEmployeeId,
Emp.strLastName,
Emp.strFirstName,
Emp.strNameSuffix,
Emp.strMiddleName,
Emp.intUserSecurityId,
Emp.intRank,
Con.strPhone,
Con.strTitle,
Loc.strAddress,
Loc.strCity,
Loc.strState,
Loc.strZipCode,
Loc.strCountry,
Emp.ysnActive,
Emp.strPayPeriod
FROM dbo.tblPREmployee AS Emp
INNER JOIN dbo.tblEntity AS Ent ON Ent.intEntityId = Emp.[intEntityEmployeeId]
LEFT JOIN dbo.tblEntity AS Con ON Con.[intEntityId] = Emp.[intEntityEmployeeId]
LEFT JOIN dbo.tblEntityLocation AS Loc ON Loc.intEntityId = Emp.[intEntityEmployeeId]