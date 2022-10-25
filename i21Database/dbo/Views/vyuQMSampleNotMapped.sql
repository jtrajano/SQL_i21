CREATE VIEW vyuQMSampleNotMapped
AS
SELECT S.intSampleId
	,ST.intControlPointId
	,I.strDescription
	,IR.strReceiptNumber
	,INVS.strShipmentNumber
	,CH.intContractTypeId
	,CD.intContractHeaderId AS intLinkContractHeaderId
	,ST.strSampleTypeName
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber
	,L.strLoadNumber
	,IC.strContractItemName
	,I.strItemNo
	,I1.strItemNo AS strBundleItemNo
	,E.intEntityId AS intPartyName
	,E.strName AS strPartyName
	,ETC.intEntityContactId AS intPartyContactId
	,W.strWorkOrderNo
	,LS.strSecondaryStatus AS strLotStatus
	,UOM.strUnitMeasure AS strSampleUOM
	,UOM1.strUnitMeasure AS strRepresentingUOM
	,SS.strSecondaryStatus AS strSampleStatus
	,SS1.strSecondaryStatus AS strPreviousSampleStatus
	,CS.strSubLocationName
	,S1.strSampleNumber AS strParentSampleNo
	,SL.strName AS strStorageLocationName
	,CD.strItemSpecification
	,B.strBook
	,SB.strSubBook
	,E1.strName AS strForwardingAgentName
	,CASE 
		WHEN S.strSentBy = 'Self'
			THEN CL1.strLocationName
		ELSE E2.strName
		END AS strSentByValue
	,ST.ysnPartyMandatory
	,ST.ysnMultipleContractSeq
	,CH.dblQuantity AS dblHeaderQuantity
	,U2.strUnitMeasure AS strHeaderUnitMeasure
	,SC.strSamplingCriteria
	,RS.strSampleNumber AS strRelatedSampleNumber
	-- Cupping Session Fields
    ,CSH.strCuppingSessionNumber
	,CSH.intCuppingSessionId
	,CSH.dtmCuppingDate
	,CSH.dtmCuppingTime
	,CSD.intRank
    ,CSD.intCuppingSessionDetailId
	,CompanyLocation.strLocationName AS strCompanyLocationName
	-- Auction
	, SaleYear.strSaleYear AS strSaleYear 
	, CatalogueType.strCatalogueType AS strCatalogueType 
	, BR.strName AS strBroker
	, Grade.strDescription AS strGrade
	, LeafCategory.strAttribute2 AS strLeafCategory
	, MLT.strDescription AS strManufacturingLeafType
	, Season.strDescription AS strSeason
	, GardenMark.strGardenMark AS strGardenMark
	, ProductLine.strDescription AS strProductLine
	, Producer.strName AS strProducer 
	, PG.strName AS strPurchaseGroup
	, Currency.strCurrency AS strCurrency
	, ECT.strName AS strEvaluatorsCodeAtTBO
	, City.strCity AS strFromLocationCode
	, Size.strBrandCode AS strBrandCode
	, VG.strName AS strValuationGroupName
	, MarketZone.strMarketZoneCode AS strMarketZoneCode
	, DSL.strName AS strDestinationStorageLocationName
FROM tblQMSample S
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN tblQMSamplingCriteria SC ON SC.intSamplingCriteriaId = S.intSamplingCriteriaId
LEFT JOIN tblQMSampleStatus SS1 ON SS1.intSampleStatusId = S.intPreviousSampleStatusId
LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblICInventoryShipment INVS ON INVS.intInventoryShipmentId = S.intInventoryShipmentId
LEFT JOIN tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN tblMFWorkOrder W ON W.intWorkOrderId = S.intWorkOrderId
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = S.intLotStatusId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = S.intSampleUOMId
LEFT JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN tblICCommodityUnitMeasure CM ON CM.intCommodityUnitMeasureId = CH.intCommodityUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = CM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
LEFT JOIN tblQMSample S1 ON S1.intSampleId = S.intParentSampleId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = S.intForwardingAgentId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = S.intSentById
LEFT JOIN tblSMCompanyLocation CL1 ON CL1.intCompanyLocationId = S.intSentById
LEFT JOIN vyuCTEntityToContact ETC ON E.intEntityId = ETC.intEntityId AND ETC.ysnDefaultContact = 1
LEFT JOIN tblQMSample RS ON RS.intSampleId = S.intRelatedSampleId
LEFT JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
LEFT JOIN tblQMCuppingSession CSH ON CSH.intCuppingSessionId = CSD.intCuppingSessionId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON S.intCompanyLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblQMSaleYear SaleYear ON SaleYear.intSaleYearId = S.intSaleYearId 
LEFT JOIN tblQMCatalogueType CatalogueType ON CatalogueType.intCatalogueTypeId = S.intCatalogueTypeId 
LEFT JOIN vyuEMEntity BR ON BR.intEntityId = S.intBrokerId
	AND BR.strType = 'Broker'
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = S.intGradeId
	AND Grade.strType = 'Grade'
LEFT JOIN tblICCommodityAttribute2 LeafCategory ON LeafCategory.intCommodityAttributeId2 = S.intLeafCategoryId
LEFT JOIN tblICCommodityAttribute MLT ON MLT.intCommodityAttributeId = S.intManufacturingLeafTypeId
LEFT JOIN tblQMGardenMark GardenMark ON GardenMark.intGardenMarkId = S.intGardenMarkId
LEFT JOIN tblICCommodityAttribute Season ON Season.intCommodityAttributeId = S.intGradeId
	AND Grade.strType = 'Season'
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = S.intProductLineId
LEFT JOIN vyuEMEntity Producer ON Producer.intEntityId = S.intProducerId
	AND BR.strType = 'Producer'
LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = S.intPurchaseGroupId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = S.intCurrencyId
LEFT JOIN vyuEMEntity ECT ON ECT.intEntityId = S.intEvaluatorsCodeAtTBOId
	AND BR.strType = 'User'
LEFT JOIN tblSMCity City ON City.intCityId = S.intFromLocationCodeId
LEFT JOIN tblICBrand Size ON Size.intBrandId = S.intBrandId
LEFT JOIN tblARMarketZone MarketZone ON MarketZone.intMarketZoneId = S.intMarketZoneId
LEFT JOIN tblICStorageLocation DSL ON DSL.intStorageLocationId = S.intDestinationStorageLocationId
LEFT JOIN tblCTValuationGroup VG ON VG.intValuationGroupId = S.intValuationGroupId