CREATE PROCEDURE [dbo].[uspARGetItemPricingLevelDetail]
(
	@ItemId INT
	,@CustomerId INT
	,@LocationId INT
	,@ItemUOMId INT
)
AS
DECLARE @UOMQuantity				NUMERIC(18,6)
		,@MultiPricingLevel			NVARCHAR(100)

SELECT TOP 1 
	@UOMQuantity = dblUOMQuantity
FROM
	[dbo].[fnARGetLocationItemVendorDetailsForPricing]
	(
		@ItemId
		,@CustomerId
		,@LocationId
		,@ItemUOMId
		,NULL
		,NULL
		,NULL
	);		

SELECT 
	@MultiPricingLevel = SMLCPL.strPricingLevelName 
FROM 
	tblARCustomer ARC 
INNER JOIN (SELECT 
				intCompanyLocationPricingLevelId
				, strPricingLevelName
			FROM 
				[tblSMCompanyLocationPricingLevel]
			) SMLCPL ON ARC.intCompanyLocationPricingLevelId = SMLCPL.intCompanyLocationPricingLevelId
WHERE 
	ARC.intEntityCustomerId = @CustomerId

SELECT 
	EMEL.intEntityLocationId
	, EMEL.intWarehouseId
	, ARC.intCompanyLocationPricingLevelId
	, strPricingLevelName					= SMCL.strLocationName + ' - ' + ICIPL.strPriceLevel
	, dblUnitPrice							= @UOMQuantity * ICIPL.dblUnitPrice		
FROM 
	tblEMEntityLocation EMEL 
INNER JOIN (SELECT 
				intItemLocationId
				, intLocationId
				, intItemId
			FROM
				tblICItemLocation) ICIL ON ICIL.intLocationId = EMEL.intWarehouseId
INNER JOIN  tblICItemPricingLevel ICIPL ON ICIL.intItemId = ICIPL.intItemId AND ICIL.intItemLocationId = ICIPL.intItemLocationId
INNER JOIN (
			SELECT 
				intEntityCustomerId
				, intCompanyLocationPricingLevelId 
			FROM 
				tblARCustomer
			) ARC ON EMEL.intEntityId = ARC.intEntityCustomerId 
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
WHERE 
	EMEL.intEntityId = @CustomerId
	AND EMEL.ysnDefaultLocation = 1
	AND ICIL.intItemId = @ItemId
 