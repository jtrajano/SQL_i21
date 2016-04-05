CREATE VIEW [dbo].[vyuEMEntity]
	AS 
	SELECT A.*,
			B.strType
		FROM tblEMEntity A
			JOIN [tblEMEntityType] B
				ON A.intEntityId = B.intEntityId
