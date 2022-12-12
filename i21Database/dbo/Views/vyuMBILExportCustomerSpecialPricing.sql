CREATE VIEW [dbo].[vyuMBILExportCustomerSpecialPricing]
 AS   
	WITH
		Items
		as
		(
			Select I.intCategoryId, I.intItemId, IL.intLocationId, I.strItemNo, StockUOM.intItemUOMId
			From tblICItem I
				INNER JOIN tblICItemLocation IL on I.intItemId = IL.intItemId
				LEFT JOIN tblICItemUOM StockUOM on StockUOM.intItemId = I.intItemId AND StockUOM.ysnStockUnit = 1

		),
		ETItems
		AS
		(
			SELECT DISTINCT intItemId
			FROM [vyuETExportItem]
		),
		MainItems
		AS
		(
			SELECT a.*
			FROM Items a
				JOIN ETItems b ON b.intItemId = a.intItemId
		)
,
		CompPref
		AS
		(
			SELECT TOP 1
				intDefaultCurrencyId
			FROM tblSMCompanyPreference
		),
		Main
		as
		(
			SELECT
				DISTINCT
				b.strCustomerNumber  
	, ICItems.strItemNo  
	--,ISNULL(c.dblPrice ,0) as dblPrice  
	--,c.strPricing  COLLATE Latin1_General_CI_AS AS strPricing  
	, z.intEntityId  
	, ICItems.intLocationId  
	, intShipToId
	, ICItems.intItemId
	, ICItems.intItemUOMId
    , (SELECT TOP 1
					intDefaultCurrencyId
				FROM tblSMCompanyPreference) AS intDefaultCurrencyId
			from tblARCustomerSpecialPrice a
				join tblARCustomer b
				on a.intEntityCustomerId = b.[intEntityId]
				join tblEMEntity z
				on a.intEntityCustomerId = z.intEntityId
				join tblEMEntityLocation d
				on d.intEntityId = b.[intEntityId] --and d.ysnDefaultLocation = 1    

				INNER JOIN MainItems ICItems
				ON (a.intCategoryId = ICItems.intCategoryId
					AND ICItems.intLocationId = d.intWarehouseId
					AND a.intItemId IS NULL)
					OR (a.intItemId = ICItems.intItemId
					AND ICItems.intLocationId = d.intWarehouseId
					AND a.intItemId IS NOT NULL)
			Where strPriceBasis <> 'O'
		)

	SELECT
		ROW_NUMBER() OVER(ORDER BY strCustomerNumber) AS intCustomerPricingId   
	, strCustomerNumber  
	, strItemNo
	, ISNULL(c.dblPrice ,0) as dblPrice  
	, c.strPricing  COLLATE Latin1_General_CI_AS AS strPricing  
	, intEntityId  
	, intLocationId
	From Main
	OUTER APPLY dbo.[fnARGetCustomerPricingDetails](    
		intItemId
		,intEntityId
		,intLocationId
		,intItemUOMId
		,cast(getdate() as date)
		,null
		,null
		,null
		,null
		,intShipToId
		,null
		,null
		,0
		,intDefaultCurrencyId
		) c