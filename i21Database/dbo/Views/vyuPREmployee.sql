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
strPhone = CASE WHEN (Ent.strPhone <> '') THEN Ent.strPhone ELSE Con.strPhone END,
strTitle = CASE WHEN (Ent.strTitle <> '') THEN Ent.strTitle ELSE Con.strTitle END,
Loc.strAddress,
Loc.strCity,
Loc.strState,
Loc.strZipCode,
Loc.strCountry,
Emp.ysnActive,
Emp.strPayPeriod
FROM dbo.tblPREmployee AS Emp
INNER JOIN dbo.tblEntity AS Ent ON Ent.intEntityId = Emp.[intEntityEmployeeId]
LEFT JOIN 
(SELECT A.intEntityId, A.ysnDefaultContact, B.strPhone, B.strTitle FROM dbo.tblEntityToContact A 
	LEFT JOIN tblEntity B ON A.intEntityContactId = B.intEntityId) AS Con 
	ON Con.intEntityId = Ent.intEntityId AND Con.ysnDefaultContact = 1
LEFT JOIN dbo.tblEntityLocation AS Loc ON Loc.intEntityId = Emp.[intEntityEmployeeId] AND Loc.ysnDefaultLocation = 1
LEFT JOIN dbo.tblSMUserSecurity AS Sec ON Sec.intEntityUserSecurityId = Ent.intEntityId