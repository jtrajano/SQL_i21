CREATE VIEW [dbo].[vyuARGetItemStockPOS]
AS 
SELECT intItemId						= ITEMS.intItemId
	 , intStorageLocationId				= IL.intStorageLocationId
	 , intIssueUOMId					= IUOM.intItemUOMId
	 , intIssueUnitMeasureId			= IUOM.intUnitMeasureId
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
	 , dblSalePrice						= ISNULL(IP.dblSalePrice, 0)
	 , dblUnitOnHand					= ISNULL(ISTOCK.dblUnitOnHand, 0)
	 , dblOnOrder						= ISNULL(ISTOCK.dblOnOrder, 0)
	 , dblOrderCommitted				= ISNULL(ISTOCK.dblOrderCommitted, 0)
	 , dblAvailable						= ISNULL(ISTOCK.dblUnitOnHand, 0) - (ISNULL(ISTOCK.dblUnitReserved, 0) + ISNULL(ISTOCK.dblConsignedSale, 0))	 
	 , dblMaintenanceRate				= ISNULL(ITEMS.dblMaintenanceRate, 0)
	 , dblDefaultFull					= ISNULL(ITEMS.dblDefaultFull, 0)
	 , ysnListBundleSeparately			= ISNULL(ITEMS.ysnListBundleSeparately, CAST(0 AS BIT))
	 , intDepositPLUId					= IL.intDepositPLUId
	 , intDepositedItemId				= depositedItem.intItemId
	 , strDepositedItemUpcCode			= depositedItem.strUpcCode
	 , intDepositedItemUnitMeasureId	= depositedItem.intUnitMeasureId
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
	FROM dbo.tblICItem ITEM WITH (NOLOCK)
	INNER JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON ITEM.intItemId = IUOM.intItemId

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
	FROM dbo.tblICItem ITEM WITH (NOLOCK)
	INNER JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON ITEM.intItemId = IUOM.intItemId
	INNER JOIN dbo.tblICItemUomUpc ALTUPC WITH (NOLOCK) ON IUOM.intItemUOMId = ALTUPC.intItemUOMId
) ITEMS
INNER JOIN dbo.tblICItemLocation IL WITH (NOLOCK) ON ITEMS.intItemId = IL.intItemId
INNER JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON IL.intLocationId = CL.intCompanyLocationId
INNER JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON ITEMS.intItemId = IUOM.intItemId
INNER JOIN dbo.tblICUnitMeasure UM WITH (NOLOCK) ON IUOM.intUnitMeasureId = UM.intUnitMeasureId
LEFT JOIN dbo.tblICItemPricing IP WITH (NOLOCK) ON IL.intItemId = IP.intItemId AND IL.intItemLocationId = IP.intItemLocationId
LEFT JOIN dbo.tblICItemStock ISTOCK WITH (NOLOCK) ON ITEMS.intItemId = ISTOCK.intItemId AND IL.intItemLocationId = ISTOCK.intItemLocationId
LEFT JOIN dbo.tblICStorageLocation SL WITH (NOLOCK) ON IL.intStorageLocationId = SL.intStorageLocationId
OUTER APPLY (
	SELECT TOP 1 addOn.intItemId, addOn.strUpcCode, addOn.intUnitMeasureId
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
	) addOn (intItemId, strUpcCode, intUnitMeasureId)
) depositedItem
GO