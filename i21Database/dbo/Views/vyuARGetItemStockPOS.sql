CREATE VIEW [dbo].[vyuARGetItemStockPOS]
AS 
SELECT intItemId						= ITEM.intItemId
	 , intStorageLocationId				= IL.intStorageLocationId
	 , intIssueUOMId					= IUOM.intItemUOMId
	 , strItemNo						= ITEM.strItemNo
	 , strDescription					= ITEM.strDescription
	 , strStatus						= ITEM.strStatus
	 , strLocationName					= CL.strLocationName
	 , strType							= ITEM.strType
	 , strStorageLocationName			= SL.strName
	 , strIssueUOM						= UM.strUnitMeasure
	 , strIssueUPC						= IUOM.strUpcCode
	 , strIssueLongUPC					= IUOM.strLongUPCCode
	 , strLotTracking					= ITEM.strLotTracking
	 , strMaintenanceCalculationMethod	= ITEM.strMaintenanceCalculationMethod
	 , dblSalePrice						= ISNULL(IP.dblSalePrice, 0)
	 , dblUnitOnHand					= ISNULL(ISTOCK.dblUnitOnHand, 0)
	 , dblOnOrder						= ISNULL(ISTOCK.dblOnOrder, 0)
	 , dblOrderCommitted				= ISNULL(ISTOCK.dblOrderCommitted, 0)
	 , dblAvailable						= ISNULL(ISTOCK.dblUnitOnHand, 0) - (ISNULL(ISTOCK.dblUnitReserved, 0) + ISNULL(ISTOCK.dblConsignedSale, 0))	 
	 , dblMaintenanceRate				= ISNULL(ITEM.dblMaintenanceRate, 0)
	 , dblDefaultFull					= ISNULL(ITEM.dblDefaultFull, 0)
	 , ysnListBundleSeparately			= ISNULL(ITEM.ysnListBundleSeparately, CAST(0 AS BIT))
FROM dbo.tblICItem ITEM WITH (NOLOCK)
INNER JOIN dbo.tblICItemLocation IL WITH (NOLOCK) ON ITEM.intItemId = IL.intItemId
INNER JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON IL.intLocationId = CL.intCompanyLocationId
INNER JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON ITEM.intItemId = IUOM.intItemId
INNER JOIN dbo.tblICUnitMeasure UM WITH (NOLOCK) ON IUOM.intUnitMeasureId = UM.intUnitMeasureId
LEFT JOIN dbo.tblICItemPricing IP WITH (NOLOCK) ON IL.intItemId = IP.intItemId AND IL.intItemLocationId = IP.intItemLocationId
LEFT JOIN dbo.tblICItemStock ISTOCK WITH (NOLOCK) ON ITEM.intItemId = ISTOCK.intItemId AND IL.intItemLocationId = ISTOCK.intItemLocationId
LEFT JOIN dbo.tblICStorageLocation SL WITH (NOLOCK) ON IL.intStorageLocationId = SL.intStorageLocationId