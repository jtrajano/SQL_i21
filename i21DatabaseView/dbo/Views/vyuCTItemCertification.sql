CREATE VIEW [dbo].[vyuCTItemCertification]

AS 

	SELECT	IC.intItemCertificationId,
			IC.intItemId,
			IC.intCertificationId,
			CF.strCertificationName 
	FROM	tblICItemCertification	IC
	JOIN	tblICCertification		CF ON CF.intCertificationId = IC.intCertificationId
