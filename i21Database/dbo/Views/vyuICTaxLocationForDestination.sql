CREATE VIEW [dbo].[vyuICTaxLocationForDestination]
AS


SELECT  
	intTaxLocationId = intCompanyLocationId
	,strLocationName strTaxLocation
	,intEntityId = CAST(NULL AS INT) 
FROM 
	tblSMCompanyLocation
WHERE
	ysnLocationActive = 1