CREATE VIEW [dbo].[vyuICTaxLocationForOrigin]
AS

SELECT  
	intTaxLocationId = intEntityLocationId
	,strLocationName strTaxLocation
	,intEntityId 
FROM 
	tblEMEntityLocation
WHERE
	ysnActive = 1