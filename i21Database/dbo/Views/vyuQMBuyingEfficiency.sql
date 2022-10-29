CREATE VIEW vyuQMBuyingEfficiency
AS 
SELECT intTeaTypeId				= S.intSampleTypeId
	 , intSampleId				= S.intSampleId
	 , intTeaGroupId			= ITEM.intCommodityId
	 , intTeaItemId				= ITEM.intItemId
	 , intBrokerId				= S.intBrokerId

	 , strYear					= DATENAME(YEAR, S.dtmSaleDate)
	 , strSaleNumber			= S.strSampleNote
	 , strMonth					= DATENAME(MONTH, S.dtmSaleDate)
	 , strTeaType				= ST.strSampleTypeName
	 , strTeaGroup				= IC.strDescription
	 , strTeaItem				= ITEM.strItemNo
	 , strCustomerMixingUnit	= CAST('Customer Mixing Unit' AS NVARCHAR(100))
	 , dtmSaleDate				= S.dtmSaleDate
	 , strBrokerName			= E.strName
	 , strBrokerNo				= E.strEntityNo
	 
	 , intNoOfPackages			= S.intNoOfPackages
	 , dblWeight				= INITUOM.dblWeight
	 , dblBoughtPrice			= IB.dblPrice
	 , dblBoughtKgs				= INITUOM.dblWeight
	 , dblBoughtPackage			= IB.dblQtyBought
	 
	 , dblBuyer1Price			= OB.dblB1Price
	 , dblBuyer1Kgs				= B1UOM.dblWeight
	 , dblBuyer1NetSavingValue	= ISNULL(OB.dblB1Price, 0) - ISNULL(IB.dblPrice, 0) * ISNULL(B1UOM.dblWeight, 1)
	 , dblBuyer1PriceDiff		= ISNULL(OB.dblB1Price, 0) - ISNULL(IB.dblPrice, 0)
	 , dblBuyer1Package			= OB.dblB1QtyBought

	 , dblBuyer2Price			= OB.dblB2Price
	 , dblBuyer2Kgs				= B2UOM.dblWeight
	 , dblBuyer2NetSavingValue	= ISNULL(OB.dblB2Price, 0) - ISNULL(IB.dblPrice, 0) * ISNULL(B2UOM.dblWeight, 1)
	 , dblBuyer2PriceDiff		= ISNULL(OB.dblB2Price, 0) - ISNULL(IB.dblPrice, 0)
	 , dblBuyer2Package			= OB.dblB2QtyBought

	 , dblBuyer3Price			= OB.dblB3Price
	 , dblBuyer3Kgs				= B3UOM.dblWeight
	 , dblBuyer3NetSavingValue	= ISNULL(OB.dblB3Price, 0) - ISNULL(IB.dblPrice, 0) * ISNULL(B3UOM.dblWeight, 1)
	 , dblBuyer3PriceDiff		= ISNULL(OB.dblB3Price, 0) - ISNULL(IB.dblPrice, 0)
	 , dblBuyer3Package			= OB.dblB3QtyBought

	 , dblBuyer4Price			= OB.dblB4Price
	 , dblBuyer4Kgs				= B4UOM.dblWeight
	 , dblBuyer4NetSavingValue	= ISNULL(OB.dblB4Price, 0) - ISNULL(IB.dblPrice, 0) * ISNULL(B4UOM.dblWeight, 1)
	 , dblBuyer4PriceDiff		= ISNULL(OB.dblB4Price, 0) - ISNULL(IB.dblPrice, 0)
	 , dblBuyer4Package			= OB.dblB4QtyBought

	 , dblBuyer5Price			= OB.dblB5Price
	 , dblBuyer5Kgs				= B5UOM.dblWeight 
	 , dblBuyer5NetSavingValue	= ISNULL(OB.dblB5Price, 0) - ISNULL(IB.dblPrice, 0) * ISNULL(B5UOM.dblWeight, 1)
	 , dblBuyer5PriceDiff		= ISNULL(OB.dblB5Price, 0) - ISNULL(IB.dblPrice, 0)
	 , dblBuyer5Package			= OB.dblB5QtyBought
FROM tblQMSample S 
INNER JOIN tblQMSampleInitialBuy IB ON S.intInitialBuyId = IB.intInitialBuyId AND S.intSampleId = IB.intSampleId
INNER JOIN tblQMSampleOtherBuyers OB ON S.intOtherBuyerId = OB.intOtherBuyerId AND S.intSampleId = OB.intSampleId
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
LEFT JOIN tblEMEntity E ON S.intBrokerId = E.intEntityId
LEFT JOIN tblICItemUOM INITUOM ON IB.intQtyUOMId = INITUOM.intItemUOMId AND S.intItemId = INITUOM.intItemId
LEFT JOIN tblICItemUOM B1UOM ON OB.intB1QtyUOMId = B1UOM.intItemUOMId AND S.intItemId = B1UOM.intItemId
LEFT JOIN tblICItemUOM B2UOM ON OB.intB2QtyUOMId = B2UOM.intItemUOMId AND S.intItemId = B2UOM.intItemId
LEFT JOIN tblICItemUOM B3UOM ON OB.intB3QtyUOMId = B3UOM.intItemUOMId AND S.intItemId = B3UOM.intItemId
LEFT JOIN tblICItemUOM B4UOM ON OB.intB4QtyUOMId = B4UOM.intItemUOMId AND S.intItemId = B4UOM.intItemId
LEFT JOIN tblICItemUOM B5UOM ON OB.intB5QtyUOMId = B5UOM.intItemUOMId AND S.intItemId = B5UOM.intItemId
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodityAttribute IC ON ITEM.intCommodityId = IC.intCommodityId