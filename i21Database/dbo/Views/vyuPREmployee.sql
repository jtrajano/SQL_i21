CREATE VIEW [dbo].[vyuPREmployee]
AS
SELECT
Emp.[intEntityId],
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
INNER JOIN dbo.tblEMEntity AS Ent ON Ent.intEntityId = Emp.[intEntityId]
LEFT JOIN 
(SELECT A.intEntityId, A.ysnDefaultContact, B.strPhone, B.strTitle FROM dbo.[tblEMEntityToContact] A 
	LEFT JOIN tblEMEntity B ON A.intEntityContactId = B.intEntityId) AS Con 
	ON Con.intEntityId = Ent.intEntityId AND Con.ysnDefaultContact = 1
LEFT JOIN dbo.[tblEMEntityLocation] AS Loc ON Loc.intEntityId = Emp.[intEntityId] AND Loc.ysnDefaultLocation = 1
LEFT JOIN dbo.tblSMUserSecurity AS Sec ON Sec.intEntityUserSecurityId = Ent.intEntityId