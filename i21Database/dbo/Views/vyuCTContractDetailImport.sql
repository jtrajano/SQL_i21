
Create VIEW [dbo].vyuCTContractDetailImport
AS


SELECT CD.intContractDetailImportId
	   ,CD.intContractDetailImportHeaderId
	   ,CD.strContractNumber
	   ,CD.intSequence
	   ,CD.dtmStartDate
	   ,CD.dtmEndDate
	   ,CD.dtmUpdatedAvailability
	   ,strLocationName = CD.strLocation
	   ,CL.intCompanyLocationId
	   ,CD.strBook
	   ,B.intBookId
	   ,CD.strSubBook
	   ,SB.intSubBookId
	   ,strItemNo = CD.strItem
	   ,IT.intItemId
	   ,CD.strPurchasingGroup
	   ,PG.intPurchasingGroupId
	   ,CD.strGrade
	   ,strGardenMark = CD.strGarden
	   ,GM.intGardenMarkId
	   ,CD.strVendorLotId
	   ,CD.strReference
	   ,CD.dblQuantity
	   ,CD.strQuantityUOM
	   ,intItemUOMId = qIuom.intItemUOMId
	   ,CD.dblNetWeight
	   ,CD.strWeightUOM
	   ,intNetWeightUOMId = wIuom.intItemUOMId
	   ,CD.strContainerType
	   ,CT.intContainerTypeId
	   ,CD.strPricingType
	   ,PT.intPricingTypeId
	   ,CD.dblCashPrice
	   ,CD.strPriceUOM
	   ,intPriceItemUOMId = pIuom.intItemUOMId
	   ,CD.strPriceCurrency
	   ,PCUR.intCurrencyID
	   ,CD.strFreightTerms
	   ,FT.intFreightTermId
	   ,CD.strLoadingPoint
	   ,intLoadingPointId = LP.intCityId
	   ,CD.strDestinationPoint
	   ,intDestinationPointId = DP.intCityId
	   ,CD.strShippineLine
	   ,CD.strStorageLocation
	   ,SL.intStorageLocationId
	   ,CD.dtmEtaPol
	   ,CD.dtmEtaPod
	   ,CD.guiUniqueId
	   ,null strMessage
	   ,null ysnImported
	   ,CD.intConcurrencyId
FROM tblCTContractDetailImport CD
LEFT JOIN tblSMCompanyLocation	CL		ON CL.strLocationName	=	CD.strLocation			collate database_default
LEFT JOIN tblCTBook				B		ON B.strBook			=	CD.strBook				collate database_default
LEFT JOIN tblCTSubBook			SB		ON SB.strSubBook		=	CD.strSubBook			collate database_default
LEFT JOIN tblICItem				IT		ON IT.strItemNo			=	CD.strItem				collate database_default
LEFT JOIN tblSMPurchasingGroup	PG		ON PG.strName			=	CD.strPurchasingGroup	collate database_default
LEFT JOIN tblQMGardenMark		GM		ON GM.strGardenMark		=	CD.strGarden			collate database_default
LEFT JOIN tblICUnitMeasure		QUOM	ON QUOM.strUnitMeasure	=	CD.strQuantityUOM		collate database_default
LEFT JOIN tblICItemUOM			qIuom	ON qIuom.intItemId		=	IT.intItemId			AND qIuom.intUnitMeasureId = QUOM.intUnitMeasureId
LEFT JOIN tblICUnitMeasure		WUOM	ON WUOM.strUnitMeasure	=	CD.strWeightUOM			collate database_default
LEFT JOIN tblICItemUOM			wIuom	ON wIuom.intItemId		=	IT.intItemId			AND wIuom.intUnitMeasureId = WUOM.intUnitMeasureId
LEFT JOIN tblLGContainerType	CT		ON CT.strContainerType	=	CD.strContainerType		collate database_default
LEFT JOIN tblCTPricingType		PT		ON PT.strPricingType	=	CD.strPricingType		collate database_default
LEFT JOIN tblICUnitMeasure		PUOM	ON PUOM.strUnitMeasure	=	CD.strPriceUOM			collate database_default
LEFT JOIN tblICItemUOM			pIuom	ON pIuom.intItemId		=	IT.intItemId			AND pIuom.intUnitMeasureId = PUOM.intUnitMeasureId
LEFT JOIN tblSMCurrency			PCUR	ON PCUR.strCurrency		=	CD.strPriceCurrency		collate database_default
LEFT JOIN tblSMFreightTerms		FT		ON FT.strFreightTerm	=	CD.strFreightTerms		collate database_default
LEFT JOIN tblSMCity				LP		ON LP.strCity			=	CD.strLoadingPoint		collate database_default
LEFT JOIN tblSMCity				DP		ON DP.strCity			=	CD.strDestinationPoint  collate database_default
LEFT JOIN tblICStorageLocation	SL		ON SL.strName			=	CD.strStorageLocation  collate database_default




