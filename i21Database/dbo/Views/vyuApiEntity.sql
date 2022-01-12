CREATE VIEW [dbo].[vyuApiEntity]
AS
SELECT
    Entity.intEntityId,
    Entity.strName,
	Entity.strEntityNo,
	Entity.ysnActive,
	EntityType.strType,
	EntityLocation.intEntityLocationId,
	EntityLocation.strLocationName
FROM tblEMEntity Entity
JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityId = Entity.intEntityId
JOIN tblEMEntityType EntityType ON EntityType.intEntityId = Entity.intEntityId