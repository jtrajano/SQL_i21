CREATE VIEW [dbo].[vyuARGetItemStockPOS]
AS 
SELECT DISTINCT intItemId				= ITEMS.intItemId
	 , intStorageLocationId				= IL.intStorageLocationId
	 , intIssueUOMId					= ITEMS.intItemUOMId
	 , intIssueUnitMeasureId			= ITEMS.intUnitMeasureId
	 , intCompanyLocationId				= CL.intCompanyLocationId
	 , strItemNo						= ITEMS.strItemNo
	 , strDescription					= ITEMS.strDescription
	 , strStatus						= ITEMS.strStatus
	 , strLocationName					= CL.strLocationName
	 , strType							= ITEMS.strType
	 , strStorageLocationName			= SL.strName
	 , strIssueUOM						= UM.strUnitMeasure
	 , strIssueUPC						= ITEMS.strIssueUPC
	 , strIssueLongUPC					= ITEMS.strIssueLongUPC
	 , strLotTracking					= ITEMS.strLotTracking
	 , strMaintenanceCalculationMethod	= ITEMS.strMaintenanceCalculationMethod
	 , dblSalePrice						= ISNULL([dbo].[fnICConvertUOMtoStockUnit](ITEMS.intItemId,ITEMS.intItemUOMId,1), 1) * ISNULL(IP.dblSalePrice, 0)
	 , dblUnitOnHand					= ISNULL([dbo].[fnICConvertUOMtoStockUnit](ITEMS.intItemId,ITEMS.intItemUOMId,1), 1) * ISNULL(ISTOCK.dblUnitOnHand, 0)
	 , dblOnOrder						= ISNULL(ISTOCK.dblOnOrder, 0)
	 , dblOrderCommitted				= ISNULL(ISTOCK.dblOrderCommitted, 0)
	 , dblAvailable						= (ISNULL([dbo].[fnICConvertUOMtoStockUnit](ITEMS.intItemId,ITEMS.intItemUOMId,1), 1) * ISNULL(ISTOCK.dblUnitOnHand, 0)) - (ISNULL(ISTOCK.dblUnitReserved, 0) + ISNULL(ISTOCK.dblConsignedSale, 0))	 
	 , dblMaintenanceRate				= ISNULL(ITEMS.dblMaintenanceRate, 0)
	 , dblDefaultFull					= ISNULL(ITEMS.dblDefaultFull, 0)
	 , ysnListBundleSeparately			= ISNULL(ITEMS.ysnListBundleSeparately, CAST(0 AS BIT))
	 , intDepositPLUId					= IL.intDepositPLUId
	 , intDepositedItemId				= depositedItem.intItemId
	 , strDepositedItemUpcCode			= depositedItem.strUpcCode
	 , intDepositedItemUnitMeasureId	= depositedItem.intUnitMeasureId
	 , ysnHasAddOnItem					= CAST(CASE WHEN ADDON.intAddOnItemId IS NOT NULL THEN 1 ELSE 0 END AS BIT)
FROM (
	SELECT intItemId		= ITEM.intItemId
		 , strItemNo
		 , strDescription
		 , strStatus
		 , strType
		 , strIssueUPC		= IUOM.strUpcCode
		 , strIssueLongUPC	= IUOM.strLongUPCCode
		 , strLotTracking
		 , strMaintenanceCalculationMethod
		 , dblMaintenanceRate
		 , dblDefaultFull
		 , ysnListBundleSeparately
		 , IUOM.intUnitMeasureId
		 , IUOM.intItemUOMId
	FROM dbo.tblICItem ITEM WITH (NOLOCK)
	INNER JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON ITEM.intItemId = IUOM.intItemId
	WHERE IUOM.ysnStockUOM = 1

	UNION ALL

	SELECT intItemId		= ITEM.intItemId
		 , strItemNo
		 , strDescription
		 , strStatus
		 , strType
		 , strIssueUPC		= ALTUPC.strUpcCode
		 , strIssueLongUPC	= ALTUPC.strLongUpcCode
		 , strLotTracking
		 , strMaintenanceCalculationMethod
		 , dblMaintenanceRate
		 , dblDefaultFull
		 , ysnListBundleSeparately
		 , IUOM.intUnitMeasureId
		 , IUOM.intItemUOMId
	FROM dbo.tblICItem ITEM WITH (NOLOCK)
	INNER JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON ITEM.intItemId = IUOM.intItemId
	INNER JOIN dbo.tblICItemUomUpc ALTUPC WITH (NOLOCK) ON IUOM.intItemUOMId = ALTUPC.intItemUOMId
) ITEMS
INNER JOIN dbo.tblICItemLocation IL WITH (NOLOCK) ON ITEMS.intItemId = IL.intItemId
INNER JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON IL.intLocationId = CL.intCompanyLocationId
--INNER JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON ITEMS.intItemId = IUOM.intItemId
INNER JOIN dbo.tblICUnitMeasure UM WITH (NOLOCK) ON ITEMS.intUnitMeasureId = UM.intUnitMeasureId
LEFT JOIN dbo.tblICItemPricing IP WITH (NOLOCK) ON IL.intItemId = IP.intItemId AND IL.intItemLocationId = IP.intItemLocationId
LEFT JOIN dbo.tblICItemStock ISTOCK WITH (NOLOCK) ON ITEMS.intItemId = ISTOCK.intItemId AND IL.intItemLocationId = ISTOCK.intItemLocationId
LEFT JOIN dbo.tblICStorageLocation SL WITH (NOLOCK) ON IL.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN(
	SELECT
		intItemAddOnId,
		intItemId,
		intAddOnItemId,
		dblQuantity,
		ysnAutoAdd,
		dtmEffectivityDateFrom	= ISNULL(dtmEffectivityDateFrom, CAST('01/01/1900' AS DATE)),
	    dtmEffectivityDateTo	= ISNULL(dtmEffectivityDateTo, CAST('12/31/9999' AS DATE))
	FROM tblICItemAddOn
	WHERE ysnAutoAdd = 1
) ADDON ON ITEMS.intItemId = ADDON.intItemId
OUTER APPLY (
	SELECT TOP 1 PLU.intItemId, PLU.strUpcCode, PLU.intUnitMeasureId
	FROM (
		SELECT childItem.intItemId, childItem.strUpcCode, childItem.intUnitMeasureId
		FROM tblICItemUOM childItem WITH(NOLOCK)
		INNER JOIN (
			SELECT intItemId
			FROM tblICItem
		) parentItem ON childItem.intItemId = parentItem.intItemId
		INNER JOIN(
			SELECT  intUnitMeasureId
					,strUnitMeasure					
			FROM tblICUnitMeasure
		) childItemUom ON childItem.intUnitMeasureId = childItemUom.intUnitMeasureId
		WHERE childItem.intItemUOMId = IL.intDepositPLUId
		GROUP BY childItem.intItemId, childItem.strUpcCode, childItem.intUnitMeasureId, parentItem.intItemId
	) PLU (intItemId, strUpcCode, intUnitMeasureId)
) depositedItem
GO