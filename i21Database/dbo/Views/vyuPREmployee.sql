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
Con.strPhone,
Con.strTitle,
Loc.strAddress,
Loc.strCity,
Loc.strState,
Loc.strZipCode,
Loc.strCountry,
Emp.ysnActive,
Pay.strPayGroup
FROM dbo.tblPREmployee AS Emp
INNER JOIN dbo.tblEntity AS Ent ON Ent.intEntityId = Emp.intEntityId
LEFT JOIN dbo.tblEntity AS Con ON Con.[intEntityId] = Emp.intEntityId
LEFT JOIN dbo.tblEntityLocation AS Loc ON Loc.intEntityId = Emp.intEntityId
LEFT JOIN dbo.tblPRPayGroup AS Pay ON Pay.intPayGroupId = Emp.intPayGroupId