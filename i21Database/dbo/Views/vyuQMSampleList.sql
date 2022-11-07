﻿CREATE VIEW vyuQMSampleList
AS
SELECT S.intSampleId
	,S.strSampleNumber
	,S.strSampleRefNo
	,ST.strSampleTypeName
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractNumber
	,CH1.strContractNumber AS strContract
	,dbo.fnQMGetAssignedSequences(S.intSampleId) COLLATE Latin1_General_CI_AS AS strAssignedSequences
	,CY.strCommodityCode
	,CY.strDescription AS strCommodityDescription
	,CH.strCustomerContract
	,IC.strContractItemName
	,I1.strItemNo AS strBundleItemNo
	,I.strItemNo
	,I.strDescription
	,S.strContainerNumber
	,SH.strLoadNumber
	,S.strLotNumber
	,SS.strStatus
	,CASE WHEN S.dtmSampleReceivedDate = CAST('1900-01-01' AS DATE) THEN NULL ELSE S.dtmSampleReceivedDate END  AS dtmSampleReceivedDate
	,S.strSampleNote
	,E.intEntityId AS intPartyName
	,E.strName AS strPartyName
	,ETC.intEntityContactId AS intPartyContactId
	,S.strRefNo
	,S.strSamplingMethod
	,S.dtmTestedOn
	,U.strName AS strTestedUserName
	,LS.strSecondaryStatus AS strLotStatus
	,S.strCountry
	,S.dblSampleQty
	,UM.strUnitMeasure AS strSampleUOM
	,S.dblRepresentingQty
	,UM1.strUnitMeasure AS strRepresentingUOM
	,S.strMarks
	,CS.strSubLocationName
	,S.dtmTestingStartDate
	,S.dtmTestingEndDate
	,S.dtmSamplingEndDate
	,S.intContractDetailId
	,ST.intSampleTypeId
	,CH.intContractHeaderId AS intLinkContractHeaderId
	,CH.intSalespersonId
	,CH1.intContractHeaderId
	,I.intItemId
	,S.intItemBundleId
	,SH.intLoadId
	,C.intLoadContainerId
	,S.intCompanyLocationSubLocationId
	,ISNULL(L.intLotId, (
			SELECT TOP 1 intLotId
			FROM tblICLot
			WHERE intParentLotId = PL.intParentLotId
			)) AS intLotId
	,S.intSampleUOMId
	,S.intRepresentingUOMId
	,S.intLocationId
	,CL.strLocationName
	,IR.strReceiptNumber
	,INVS.strShipmentNumber AS strInvShipmentNumber
	,WO.strWorkOrderNo
	,S.strComment
	,ISNULL(ito1.intOwnerId, ito2.intOwnerId) AS intEntityId
	,S1.strSampleNumber AS strParentSampleNo
	,CD.strItemSpecification
	,SL.strName AS strStorageLocationName
	,B.strBook
	,SB.strSubBook
	,S.strChildLotNumber
	,S.strCourier
	,S.strCourierRef
	,S.strForwardingAgentRef
	,S.strSentBy
	,E1.strName AS strForwardingAgentName
	,CASE 
		WHEN S.strSentBy = 'Self'
			THEN CL1.strLocationName
		ELSE E2.strName
		END AS strSentByValue
	,NULL AS strSequenceNumber
	,NULL AS dblAssignedQty
	,NULL AS strAssignedQtyUOM
	,S.dtmCreated
	,CE.strName AS strCreatedUserName
	,S.dtmLastModified AS dtmLastUpdated
	,UE.strName AS strUpdatedUserName
	,S.ysnImpactPricing
	,I.strOrigin 
	,I.strProductType
	,I.strGrade,strRegion
	,I.strSeason
	,I.strClass
	,I.strProductLine
	,S.dtmRequestedDate
	,S.dtmSampleSentDate
	,SC.strSamplingCriteria
	,S.strSendSampleTo
	,S.strRepresentLotNumber
	,RS.strSampleNumber AS strRelatedSampleNumber
	,S.intRelatedSampleId
	,S.intTypeId
	,S.intCuppingSessionDetailId
	,strMethodology = '' COLLATE Latin1_General_CI_AS
	,strExtension = EX.strDescription
	,intContractSequence = CD.intContractSeq
	,strContractType = CT.strContractType
	,strPacking = '' COLLATE Latin1_General_CI_AS
	,S.intCompanyLocationId
	,CompanyLocation.strLocationName AS strCompanyLocationName
	-- Auction
	,S.intSaleYearId
	,S.strSaleYear
	,S.strSaleNumber
	,S.strChopNumber
	,S.dtmSaleDate
	,S.intCatalogueTypeId
	,S.strCatalogueType
	,S.dtmPromptDate
	,S.intBrokerId
	,S.strBroker
	,S.intGradeId
	--,S.strGrade
	,S.intLeafCategoryId
	,S.strLeafCategory
	,S.intManufacturingLeafTypeId
	,S.strManufacturingLeafType
	,S.intSeasonId
	--,S.strSeason
	,S.intGardenMarkId
	,S.strGardenMark
	,S.dtmManufacturingDate
	,S.intTotalNumberOfPackageBreakups
	,S.intNetWtPerPackagesUOMId
	,strNetWtPerPackagesUOM = PWUOM1.strUnitMeasure
	,S.intNoOfPackages 
	,S.intNetWtSecondPackageBreakUOMId
	,strNetWtSecondPackageBreakUOM = PWUOM2.strUnitMeasure
	,S.intNoOfPackagesSecondPackageBreak
	,S.intNetWtThirdPackageBreakUOMId
	,strNetWtThirdPackageBreakUOM = PWUOM3.strUnitMeasure
	,S.intNoOfPackagesThirdPackageBreak
	,S.intProductLineId
	--,S.strProductLine
	,S.ysnOrganic
	,S.dblSupplierValuationPrice
	,S.intProducerId
	,S.strProducer
	,S.intPurchaseGroupId
	,S.strPurchaseGroup
	,S.strERPRefNo
	,S.dblGrossWeight
	,S.dblTareWeight
	,S.dblNetWeight
	,S.strBatchNo
	,S.str3PLStatus
	,S.strAdditionalSupplierReference
	,S.intAWBSampleReceived
	,S.strAWBSampleReference
	,S.dblBasePrice
	,S.ysnBoughtAsReserve
	,S.intCurrencyId
	,S.strCurrency
	,S.ysnEuropeanCompliantFlag
	,S.intEvaluatorsCodeAtTBOId
	,S.strEvaluatorsCodeAtTBO
	,S.intFromLocationCodeId
	,S.strFromLocationCode
	,S.strSampleBoxNumber
	,S.intBrandId
	,S.strBrandCode
	,S.intValuationGroupId
	,S.strValuationGroupName
	,S.strMusterLot
	,S.strMissingLot
	,S.intMarketZoneId
	,S.strMarketZoneCode
	,S.intDestinationStorageLocationId
	,S.strDestinationStorageLocationName
	,S.strComments2
	,S.strComments3
	-- Initial Buy
	,S.intOtherBuyerId
	,S.intBuyer1Id
	,S.strBuyer1
	,S.dblB1QtyBought
	,S.intB1QtyUOMId
	,S.strB1QtyUOM
	,S.dblB1Price
	,S.intB1PriceUOMId
	,S.strB1PriceUOM
	,S.intBuyer2Id
	,S.strBuyer2
	,S.dblB2QtyBought
	,S.intB2QtyUOMId
	,S.strB2QtyUOM
	,S.dblB2Price
	,S.intB2PriceUOMId
	,S.strB2PriceUOM
	,S.intBuyer3Id
	,S.strBuyer3
	,S.dblB3QtyBought
	,S.intB3QtyUOMId
	,S.strB3QtyUOM
	,S.dblB3Price
	,S.intB3PriceUOMId
	,S.strB3PriceUOM
	,S.intBuyer4Id
	,S.strBuyer4
	,S.dblB4QtyBought
	,S.intB4QtyUOMId
	,S.strB4QtyUOM
	,S.dblB4Price
	,S.intB4PriceUOMId
	,S.strB4PriceUOM
	,S.intBuyer5Id
	,S.strBuyer5
	,S.dblB5QtyBought
	,S.intB5QtyUOMId
	,S.strB5QtyUOM
	,S.dblB5Price
	,S.intB5PriceUOMId
	,S.strB5PriceUOM
FROM dbo.tblQMSample S
JOIN dbo.tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND S.ysnIsContractCompleted <> 1
JOIN dbo.tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN tblQMSamplingCriteria SC ON SC.intSamplingCriteriaId = S.intSamplingCriteriaId
LEFT JOIN dbo.tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN dbo.tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
LEFT JOIN dbo.tblCTContractHeader CH1 ON CH1.intContractHeaderId = S.intContractHeaderId
LEFT JOIN dbo.tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN dbo.vyuICSearchItem I ON I.intItemId = S.intItemId
LEFT JOIN dbo.tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN dbo.tblLGLoadContainer C ON C.intLoadContainerId = S.intLoadContainerId
LEFT JOIN dbo.tblLGLoad SH ON SH.intLoadId = S.intLoadId
LEFT JOIN dbo.tblEMEntity U ON U.intEntityId = S.intTestedById
LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblICLot L ON L.intLotId = S.intProductValueId
	AND S.intProductTypeId = 6
LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = S.intProductValueId
	AND S.intProductTypeId = 11
LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = L.intItemOwnerId
LEFT JOIN tblICItemOwner ito2 ON ito2.intItemId = S.intItemId
	AND ito2.ysnDefault = 1
LEFT JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = S.intLotStatusId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intSampleUOMId
LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblICInventoryShipment INVS ON INVS.intInventoryShipmentId = S.intInventoryShipmentId
LEFT JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = S.intWorkOrderId
LEFT JOIN tblICCommodity CY ON CY.intCommodityId = ISNULL(CH.intCommodityId, I.intCommodityId)
LEFT JOIN tblQMSample S1 ON S1.intSampleId = S.intParentSampleId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = S.intForwardingAgentId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = S.intSentById
LEFT JOIN tblSMCompanyLocation CL1 ON CL1.intCompanyLocationId = S.intSentById
LEFT JOIN tblEMEntity CE ON CE.intEntityId = S.intCreatedUserId
LEFT JOIN tblEMEntity UE ON UE.intEntityId = S.intLastModifiedUserId
LEFT JOIN vyuCTEntityToContact ETC ON E.intEntityId = ETC.intEntityId AND ETC.ysnDefaultContact = 1
LEFT JOIN tblQMSample RS ON RS.intSampleId = S.intRelatedSampleId
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodityProductLine EX ON I.intProductLineId = EX.intCommodityProductLineId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON S.intCompanyLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblQMSampleOtherBuyers SOB ON SOB.intSampleId = S.intSampleId
LEFT JOIN tblICUnitMeasure PWUOM1 ON PWUOM1.intUnitMeasureId = S.intNetWtPerPackagesUOMId
LEFT JOIN tblICUnitMeasure PWUOM2 ON PWUOM2.intUnitMeasureId = S.intNetWtSecondPackageBreakUOMId
LEFT JOIN tblICUnitMeasure PWUOM3 ON PWUOM3.intUnitMeasureId = S.intNetWtThirdPackageBreakUOMId
WHERE S.intTypeId = 1
