CREATE VIEW [dbo].[vyuMBILDriver]
	AS
	
SELECT Entity.intEntityId
	, strDriverNo = Entity.strEntityNo
	, strDriverName = Entity.strName
FROM tblEMEntityType EntityType
LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = EntityType.intEntityId
WHERE EntityType.strType = 'Trucker'