CREATE VIEW [dbo].[vyuPREmployee]
AS
SELECT
Ent.intEntityId,
Emp.intEmployeeId,
Emp.strEmployeeId,
Emp.strLastName,
Emp.strFirstName,
Emp.strNameSuffix,
Emp.strMiddleName,
Emp.strWorkPhone,
Con.strPhone,
Con.strTitle,
Con.strDepartment,
Loc.strAddress,
Loc.strCity,
Loc.strState,
Loc.strZipCode
FROM dbo.tblPREmployee AS Emp
INNER JOIN dbo.tblEntity AS Ent ON Ent.intEntityId = Emp.intEntityId
LEFT JOIN dbo.tblEntityContact AS Con ON Con.[intEntityContactId] = Emp.intEntityId
LEFT JOIN dbo.tblEntityLocation AS Loc ON Loc.intEntityId = Emp.intEntityId