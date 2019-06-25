CREATE VIEW [dbo].[vyuSTSearchRevertHolder]
AS
SELECT 
	RH.*
	, E.strName
FROM tblSTRevertHolder RH
INNER JOIN tblEMEntity E
	ON RH.intEntityId = E.intEntityId
	   