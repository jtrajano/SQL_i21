CREATE VIEW [dbo].[vyuEMEntity]
	AS 
	SELECT A.*,
			B.strType
		FROM tblEntity A
			JOIN tblEntityType B
				ON A.intEntityId = B.intEntityId
