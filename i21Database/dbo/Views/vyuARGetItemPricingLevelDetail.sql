CREATE VIEW [dbo].[vyuARGetItemPricingLevelDetail]
AS
SELECT 
	EMEL.intEntityId 
	, ICIPL.intItemId	
	, ICIPL.intItemUnitMeasureId
	, EMEL.intEntityLocationId
	, intWarehouseId							= ICIL.intLocationId
	, ARC.intCompanyLocationPricingLevelId
	, strPricing								= 'Inventory - Pricing Level' COLLATE Latin1_General_CI_AS
	, strPricingName							= SMCL.strLocationName + ' - ' + ICIPL.strPriceLevel
	, dblPrice									= UOMQty.dblUOMQuantity * ICIPL.dblUnitPrice		
FROM 
	tblEMEntityLocation EMEL 
INNER JOIN (SELECT 
				intItemLocationId
				, intLocationId
				, intItemId
			FROM
				tblICItemLocation) ICIL ON ICIL.intLocationId = EMEL.intWarehouseId
INNER JOIN  (SELECT
				 intItemId
				 , intItemUnitMeasureId
				 , intItemLocationId
				 , strPriceLevel
				 , dblUnitPrice
			 FROM 
				tblICItemPricingLevel) ICIPL ON ICIL.intItemId = ICIPL.intItemId AND ICIL.intItemLocationId = ICIPL.intItemLocationId
INNER JOIN (
			SELECT 
				intEntityId
				, intCompanyLocationPricingLevelId 
			FROM 
				tblARCustomer
			) ARC ON EMEL.intEntityId = ARC.intEntityId 
LEFT JOIN (
			SELECT intCompanyLocationId
				, intCompanyLocationPricingLevelId
				, strPricingLevelName 				 
			FROM 
				tblSMCompanyLocationPricingLevel
			) SMCLPL ON EMEL.intWarehouseId = SMCLPL.intCompanyLocationId AND ARC.intCompanyLocationPricingLevelId = SMCLPL.intCompanyLocationPricingLevelId   
INNER JOIN (
			SELECT 
				intCompanyLocationId
				, strLocationName 
			FROM 
				tblSMCompanyLocation 
			) SMCL ON EMEL.intWarehouseId = SMCL.intCompanyLocationId
CROSS APPLY (SELECT dblUOMQuantity FROM
	[dbo].[fnARGetLocationItemVendorDetailsForPricing]
	(
		ICIPL.intItemId
		,EMEL.intEntityId
		,ICIPL.intItemUnitMeasureId
		,NULL
		,NULL
		,NULL
		,NULL
	)) UOMQty

 
