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
	 , strTeaType				= CT.strCatalogueType 
	 , strTeaGroup				= ISNULL(Brand.strBrandCode, '') + ISNULL(Region.strDescription, '') + ISNULL(VG.strName, '')
	 , strTeaItem				= ITEM.strItemNo
	 , strCustomerMixingUnit	= B.strBook
	 , dtmSaleDate				= S.dtmSaleDate
	 , strBrokerName			= E.strName
	 , strBrokerNo				= E.strEntityNo
	 
	 , dblPackages				= ISNULL(S.dblRepresentingQty, 0)
	 , dblWeight				= ISNULL(S.dblSampleQty, 0)
	 , dblBoughtPrice			= ISNULL(S.dblB1Price, 0)
	 , dblBoughtKgs				= CS.dblB1Weight
	 , dblBoughtPackage			= ISNULL(S.dblB1QtyBought, 0)

	 , dblCompetitorPrice		= ((ISNULL(S.dblB2Price, 0) * CS.dblB2Weight) + 
								   (ISNULL(S.dblB3Price, 0) * CS.dblB3Weight) + 
								   (ISNULL(S.dblB4Price, 0) * CS.dblB4Weight) + 
								   (ISNULL(S.dblB5Price, 0) * CS.dblB5Weight)) / 
	 							  ISNULL(NULLIF(CS.dblCompetitorWeight, 0), 1)
	 , dblCompetitorKgs			= CS.dblCompetitorWeight
	 , dblNetSavingValue		= ((((ISNULL(S.dblB2Price, 0) * CS.dblB2Weight) + 
								     (ISNULL(S.dblB3Price, 0) * CS.dblB3Weight) + 
								     (ISNULL(S.dblB4Price, 0) * CS.dblB4Weight) + 
								     (ISNULL(S.dblB5Price, 0) * CS.dblB5Weight)) / 
	 							  ISNULL(NULLIF(CS.dblCompetitorWeight, 0), 1)) - ISNULL(S.dblB1Price, 0)) * CS.dblB1Weight
	 , dblPriceDifference		= (((ISNULL(S.dblB2Price, 0) * CS.dblB2Weight) + 
								    (ISNULL(S.dblB3Price, 0) * CS.dblB3Weight) + 
								    (ISNULL(S.dblB4Price, 0) * CS.dblB4Weight) + 
								    (ISNULL(S.dblB5Price, 0) * CS.dblB5Weight)) / 
	 							  ISNULL(NULLIF(CS.dblCompetitorWeight, 0), 1)) - ISNULL(S.dblB1Price, 0)
	 , dblCompetitorPackage		= ISNULL(S.dblB2QtyBought, 0) + ISNULL(S.dblB3QtyBought, 0) + ISNULL(S.dblB4QtyBought, 0) + ISNULL(S.dblB5QtyBought, 0)
FROM tblQMSample S 
INNER JOIN (
	SELECT intSampleId			= SS.intSampleId
		 , dblB1Weight			= ISNULL(SS.dblB1QtyBought, 0) * ISNULL(IUM1.dblUnitQty, 1)
		 , dblB2Weight			= ISNULL(SS.dblB2QtyBought, 0) * ISNULL(IUM2.dblUnitQty, 1)
		 , dblB3Weight			= ISNULL(SS.dblB3QtyBought, 0) * ISNULL(IUM3.dblUnitQty, 1)
		 , dblB4Weight			= ISNULL(SS.dblB4QtyBought, 0) * ISNULL(IUM4.dblUnitQty, 1)
		 , dblB5Weight			= ISNULL(SS.dblB5QtyBought, 0) * ISNULL(IUM5.dblUnitQty, 1)
		 , dblCompetitorWeight	= (ISNULL(SS.dblB2QtyBought, 0) * ISNULL(IUM2.dblUnitQty, 1)) + 
								  (ISNULL(SS.dblB3QtyBought, 0) * ISNULL(IUM3.dblUnitQty, 1)) +
								  (ISNULL(SS.dblB4QtyBought, 0) * ISNULL(IUM4.dblUnitQty, 1)) +
								  (ISNULL(SS.dblB5QtyBought, 0) * ISNULL(IUM5.dblUnitQty, 1))
	FROM tblQMSample SS
	LEFT JOIN tblICItemUOM IUM1 ON SS.intB1QtyUOMId = IUM1.intUnitMeasureId AND SS.intItemId = IUM1.intItemId
	LEFT JOIN tblICItemUOM IUM2 ON SS.intB2QtyUOMId = IUM2.intUnitMeasureId AND SS.intItemId = IUM2.intItemId
	LEFT JOIN tblICItemUOM IUM3 ON SS.intB3QtyUOMId = IUM3.intUnitMeasureId AND SS.intItemId = IUM3.intItemId
	LEFT JOIN tblICItemUOM IUM4 ON SS.intB4QtyUOMId = IUM4.intUnitMeasureId AND SS.intItemId = IUM4.intItemId
	LEFT JOIN tblICItemUOM IUM5 ON SS.intB5QtyUOMId = IUM5.intUnitMeasureId AND SS.intItemId = IUM5.intItemId
) CS ON S.intSampleId = CS.intSampleId
INNER JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
Left JOIN tblQMCatalogueType CT on CT.intCatalogueTypeId =S.intCatalogueTypeId 
LEFT JOIN tblEMEntity E ON S.intBrokerId = E.intEntityId
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN dbo.tblICCommodityAttribute Region WITH (NOLOCK) ON Region.intCommodityAttributeId = ITEM.intRegionId
LEFT JOIN dbo.tblICBrand Brand WITH (NOLOCK) ON Brand.intBrandId = ITEM.intBrandId
LEFT JOIN dbo.tblCTValuationGroup VG WITH (NOLOCK) ON VG.intValuationGroupId = ITEM.intValuationGroupId
		
LEFT JOIN tblICCommodity IC ON ITEM.intCommodityId = IC.intCommodityId
LEFT JOIN tblCTBook B ON S.intBookId = B.intBookId