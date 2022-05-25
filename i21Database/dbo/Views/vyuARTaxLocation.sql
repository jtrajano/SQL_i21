CREATE VIEW [dbo].[vyuARTaxLocation]
AS 
SELECT 
	 intTaxLocationId	= intCompanyLocationId
	,strLocationName
	,strAddress
	,strFobPoint		= 'Origin'
	,intEntityId		= 0
	,strType			= 'Company'
FROM vyuSMGetCompanyLocationSearchList
WHERE ysnLocationActive = 1

UNION ALL

SELECT
	 intTaxLocationId	= intEntityLocationId
	,strLocationName
	,strAddress
	,strFobPoint
	,intEntityId
	,strType			= 'Entity'
FROM vyuEMEntityLocationSearch EMELS
LEFT JOIN tblSMFreightTerms SMFT ON EMELS.intFreightTermId = SMFT.intFreightTermId
WHERE EMELS.ysnActive = 1