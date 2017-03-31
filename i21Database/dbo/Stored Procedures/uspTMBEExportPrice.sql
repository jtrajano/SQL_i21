CREATE PROCEDURE [dbo].[uspTMBEExportPrice]
	@intEntityUserSecurityId INT
AS
DECLARE @intDefaultLocationId INT

SELECT @intDefaultLocationId = intCompanyLocationId
FROM tblSMUserSecurity
WHERE [intEntityId] = @intEntityUserSecurityId

SELECT DISTINCT
	* 
FROM (
SELECT
	ID = prices.dblPrice
	,name = item.strShortName
	,perUnit = CAST(ROUND(prices.dblPrice,4) AS NUMERIC (16,4))
FROM tblICItem item
	OUTER APPLY (
		SELECT TOP 1
			Item.intItemId intItemId,
			dblPrice = CAST(ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0) AS NUMERIC(18, 6)),
			ItemLocation.intLocationId intLocationId
		FROM vyuICGetItemStock Item
			LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = Item.intVendorId
			LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId and ItemPricing.intItemLocationId = Item.intItemLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
			LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
				AND ItemLocation.intItemId = Item.intItemId
		WHERE item.intItemId = Item.intItemId
			AND (ItemLocation.intLocationId = @intDefaultLocationId OR @intDefaultLocationId IS NULL)
			AND ISNULL(ItemPricing.dblSalePrice * ItemUOM.dblUnitQty, 0) > 0
		ORDER BY ysnStockUnit DESC, ItemLocation.intLocationId DESC
	) prices
WHERE item.ysnAvailableTM = 1
	OR item.strType = 'Service'
UNION ALL
SELECT DISTINCT
	ID = A.dblPrice
	,name = (CASE WHEN C.intItemId IS NULL THEN ISNULL(B.strShortName,'') ELSE ISNULL(C.strShortName,'') END)
	,perUnit = CAST(ROUND(dblPrice,4) AS NUMERIC (16,4))
FROM tblTMDispatch A
INNER JOIN tblICItem B
	ON A.intProductID = B.intItemId
LEFT JOIN tblICItem C
	ON A.intSubstituteProductID = C.intItemId
UNION ALL
--- CustomerPricing
SELECT DISTINCT
	ID = B.dblPrice
	,name = A.strShortName
	,perUnit = CAST(ROUND(B.dblPrice,4) AS NUMERIC (16,4))
FROM(
	SELECT
		Z.intProduct
		,D.intCustomerNumber
		,Z.intLocationId
		,Z.intCompanyLocationPricingLevelId
		,C.strShortName
	FROM tblTMSite Z
	INNER JOIN tblTMCustomer D
		ON Z.intCustomerID = D.intCustomerID
	INNER JOIN tblICItem C
		ON Z.intProduct = C.intItemId
) A
CROSS APPLY (
    SELECT TOP 1 dblPrice, strPricing, intContractDetailId FROM dbo.fnARGetItemPricingDetails(
        A.intProduct
        ,A.intCustomerNumber
        ,A.intLocationId
        ,NULL
		,(SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference  )
        ,GETDATE()
        ,1
        ,NULL  --@ContractHeaderId		INT
	    ,NULL  --@ContractDetailId		INT
	    ,NULL  --@ContractNumber		NVARCHAR(50)
	    ,NULL  --@ContractSeq			INT
	    ,NULL  --@AvailableQuantity		NUMERIC(18,6)
	    ,NULL  --@UnlimitedQuantity     BIT
	    ,NULL  --@OriginalQuantity		NUMERIC(18,6)
	    ,1     --@CustomerPricingOnly	BIT
        ,NULL  --@ItemPricingOnly
        ,0     --@ExcludeContractPricing
	    ,NULL  --@VendorId				INT
	    ,NULL  --@SupplyPointId			INT
	    ,NULL  --@LastCost				NUMERIC(18,6)
	    ,NULL  --@ShipToLocationId      INT
	    ,NULL  --@VendorLocationId		INT
        ,A.intCompanyLocationPricingLevelId -- @PricingLevelId
        ,NULL
        ,NULL
        ,NULL --TermId
        ,NULL --@GetAllAvailablePricing		
        )
) B


) Z

GO