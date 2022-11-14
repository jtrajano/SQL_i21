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
	 , strCustomerMixingUnit	= B.strBook
	 , dtmSaleDate				= S.dtmSaleDate
	 , strBrokerName			= E.strName
	 , strBrokerNo				= E.strEntityNo
	 
	 , dblPackages				= ISNULL(S.dblSampleQty, 0)
	 , dblWeight				= ISNULL(S.dblRepresentingQty, 0)
	 , dblBoughtPrice			= ISNULL(S.dblB1Price, 0)
	 , dblBoughtKgs				= ISNULL(S.dblB1QtyBought, 0)
	 , dblBoughtPackage			= ISNULL(S.dblB1QtyBought, 0)

	 , dblCompetitorPrice		= ((ISNULL(S.dblB2Price, 0) * ISNULL(S.dblB2QtyBought, 0)) + (ISNULL(S.dblB3Price, 0) * ISNULL(S.dblB3QtyBought, 0)) + (ISNULL(S.dblB4Price, 0) * ISNULL(S.dblB4QtyBought, 0)) + (ISNULL(S.dblB5Price, 0) * ISNULL(S.dblB5QtyBought, 0))) / 
	 							  ISNULL(NULLIF(ISNULL(S.dblB2QtyBought, 0) + ISNULL(S.dblB3QtyBought, 0) + ISNULL(S.dblB4QtyBought, 0) + ISNULL(S.dblB5QtyBought, 0), 0), 1)
	 , dblCompetitorKgs			= ISNULL(S.dblB2QtyBought, 0) + ISNULL(S.dblB3QtyBought, 0) + ISNULL(S.dblB4QtyBought, 0) + ISNULL(S.dblB5QtyBought, 0)
	 , dblNetSavingValue		= ((((ISNULL(S.dblB2Price, 0) * ISNULL(S.dblB2QtyBought, 0)) + (ISNULL(S.dblB3Price, 0) * ISNULL(S.dblB3QtyBought, 0)) + (ISNULL(S.dblB4Price, 0) * ISNULL(S.dblB4QtyBought, 0)) + (ISNULL(S.dblB5Price, 0) * ISNULL(S.dblB5QtyBought, 0))) / 
	 							  ISNULL(NULLIF(ISNULL(S.dblB2QtyBought, 0) + ISNULL(S.dblB3QtyBought, 0) + ISNULL(S.dblB4QtyBought, 0) + ISNULL(S.dblB5QtyBought, 0), 0), 1)) - ISNULL(S.dblB1Price, 0)) * ISNULL(S.dblB1QtyBought, 0)
	 , dblPriceDifference		= (((ISNULL(S.dblB2Price, 0) * ISNULL(S.dblB2QtyBought, 0)) + (ISNULL(S.dblB3Price, 0) * ISNULL(S.dblB3QtyBought, 0)) + (ISNULL(S.dblB4Price, 0) * ISNULL(S.dblB4QtyBought, 0)) + (ISNULL(S.dblB5Price, 0) * ISNULL(S.dblB5QtyBought, 0))) /  
	 							  ISNULL(NULLIF(ISNULL(S.dblB2QtyBought, 0) + ISNULL(S.dblB3QtyBought, 0) + ISNULL(S.dblB4QtyBought, 0) + ISNULL(S.dblB5QtyBought, 0), 0), 1)) - ISNULL(S.dblB1Price, 0)
	 , dblCompetitorPackage		= ISNULL(S.dblB2QtyBought, 0) + ISNULL(S.dblB3QtyBought, 0) + ISNULL(S.dblB4QtyBought, 0) + ISNULL(S.dblB5QtyBought, 0)
FROM tblQMSample S 
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
LEFT JOIN tblEMEntity E ON S.intBrokerId = E.intEntityId
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodity IC ON ITEM.intCommodityId = IC.intCommodityId
LEFT JOIN tblCTBook B ON S.intBookId = B.intBookId