CREATE VIEW vyuQMBuyingEfficiency
AS 
SELECT intTeaTypeId				= S.intSampleTypeId
	 , intSampleId				= S.intSampleId
	 , intTeaGroupId			= ITEM.intCommodityId
	 , intTeaItemId				= ITEM.intItemId
	 , intBrokerId				= S.intBrokerId

	 , strYear					= DATENAME(YEAR, S.dtmSaleDate)
	 , strSaleNumber			= S.strSaleNumber
	 , strMonth					= DATENAME(MONTH, S.dtmSaleDate)
	 , strTeaType				= ST.strSampleTypeName
	 , strTeaGroup				= IC.strDescription
	 , strTeaItem				= ITEM.strItemNo
	 , strCustomerMixingUnit	= CAST('Customer Mixing Unit' AS NVARCHAR(100))
	 , dtmSaleDate				= S.dtmSaleDate
	 , strBrokerName			= E.strName
	 , strBrokerNo				= E.strEntityNo
	 
	 , intNoOfPackages			= CAST(ISNULL(S.intNoOfPackages, 0) AS NUMERIC(18, 6))
	 , dblWeight				= ISNULL(INITUOM.dblWeight, 0)
	 , dblBoughtPrice			= ISNULL(S.dblBasePrice, 0)
	 , dblBoughtKgs				= ISNULL(INITUOM.dblWeight, 0)
	 , dblBoughtPackage			= CAST(ISNULL(S.intNoOfPackages, 0) AS NUMERIC(18, 6))
	 
	 , dblBuyer1Price			= ISNULL(S.dblB1Price, 0)
	 , dblBuyer1Kgs				= ISNULL(B1UOM.dblWeight, 0)
	 , dblBuyer1NetSavingValue	= ISNULL(S.dblB1Price, 0) - ISNULL(S.dblBasePrice, 0) * ISNULL(B1UOM.dblWeight, 1)
	 , dblBuyer1PriceDiff		= ISNULL(S.dblB1Price, 0) - ISNULL(S.dblBasePrice, 0)
	 , dblBuyer1Package			= ISNULL(S.dblB1QtyBought, 0)

	 , dblBuyer2Price			= ISNULL(S.dblB2Price, 0)
	 , dblBuyer2Kgs				= ISNULL(B2UOM.dblWeight, 0)
	 , dblBuyer2NetSavingValue	= ISNULL(S.dblB2Price, 0) - ISNULL(S.dblBasePrice, 0) * ISNULL(B2UOM.dblWeight, 1)
	 , dblBuyer2PriceDiff		= ISNULL(S.dblB2Price, 0) - ISNULL(S.dblBasePrice, 0)
	 , dblBuyer2Package			= ISNULL(S.dblB2QtyBought, 0)

	 , dblBuyer3Price			= ISNULL(S.dblB3Price, 0)
	 , dblBuyer3Kgs				= ISNULL(B3UOM.dblWeight, 0)
	 , dblBuyer3NetSavingValue	= ISNULL(S.dblB3Price, 0) - ISNULL(S.dblBasePrice, 0) * ISNULL(B3UOM.dblWeight, 1)
	 , dblBuyer3PriceDiff		= ISNULL(S.dblB3Price, 0) - ISNULL(S.dblBasePrice, 0)
	 , dblBuyer3Package			= ISNULL(S.dblB3QtyBought, 0)

	 , dblBuyer4Price			= ISNULL(S.dblB4Price, 0)
	 , dblBuyer4Kgs				= ISNULL(B4UOM.dblWeight, 0)
	 , dblBuyer4NetSavingValue	= ISNULL(S.dblB4Price, 0) - ISNULL(S.dblBasePrice, 0) * ISNULL(B4UOM.dblWeight, 1)
	 , dblBuyer4PriceDiff		= ISNULL(S.dblB4Price, 0) - ISNULL(S.dblBasePrice, 0)
	 , dblBuyer4Package			= ISNULL(S.dblB4QtyBought, 0)

	 , dblBuyer5Price			= ISNULL(S.dblB5Price, 0)
	 , dblBuyer5Kgs				= ISNULL(B5UOM.dblWeight, 0)
	 , dblBuyer5NetSavingValue	= ISNULL(S.dblB5Price, 0) - ISNULL(S.dblBasePrice, 0) * ISNULL(B5UOM.dblWeight, 1)
	 , dblBuyer5PriceDiff		= ISNULL(S.dblB5Price, 0) - ISNULL(S.dblBasePrice, 0)
	 , dblBuyer5Package			= ISNULL(S.dblB5QtyBought, 0)
FROM tblQMSample S 
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
LEFT JOIN tblEMEntity E ON S.intBrokerId = E.intEntityId
LEFT JOIN tblICItemUOM INITUOM ON S.intNetWtPerPackagesUOMId = INITUOM.intItemUOMId AND S.intItemId = INITUOM.intItemId
LEFT JOIN tblICItemUOM B1UOM ON S.intB1QtyUOMId = B1UOM.intItemUOMId AND S.intItemId = B1UOM.intItemId
LEFT JOIN tblICItemUOM B2UOM ON S.intB2QtyUOMId = B2UOM.intItemUOMId AND S.intItemId = B2UOM.intItemId
LEFT JOIN tblICItemUOM B3UOM ON S.intB3QtyUOMId = B3UOM.intItemUOMId AND S.intItemId = B3UOM.intItemId
LEFT JOIN tblICItemUOM B4UOM ON S.intB4QtyUOMId = B4UOM.intItemUOMId AND S.intItemId = B4UOM.intItemId
LEFT JOIN tblICItemUOM B5UOM ON S.intB5QtyUOMId = B5UOM.intItemUOMId AND S.intItemId = B5UOM.intItemId
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodity IC ON ITEM.intCommodityId = IC.intCommodityId