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
	,S.dblNetWtPerPackages
	,S.intNoOfPackages 
	,S.dblNetWtSecondPackageBreak
	,S.intNoOfPackagesSecondPackageBreak
	,S.dblNetWtThirdPackageBreak
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
	,SOB.intOtherBuyerId
	,SOB.intBuyer1Id
	,SOB.strBuyer1
	,SOB.dblB1QtyBought
	,SOB.intB1QtyUOMId
	,SOB.strB1QtyUOM
	,SOB.dblB1Price
	,SOB.intB1PriceUOMId
	,SOB.strB1PriceUOM
	,SOB.intBuyer2Id
	,SOB.strBuyer2
	,SOB.dblB2QtyBought
	,SOB.intB2QtyUOMId
	,SOB.strB2QtyUOM
	,SOB.dblB2Price
	,SOB.intB2PriceUOMId
	,SOB.strB2PriceUOM
	,SOB.intBuyer3Id
	,SOB.strBuyer3
	,SOB.dblB3QtyBought
	,SOB.intB3QtyUOMId
	,SOB.strB3QtyUOM
	,SOB.dblB3Price
	,SOB.intB3PriceUOMId
	,SOB.strB3PriceUOM
	,SOB.intBuyer4Id
	,SOB.strBuyer4
	,SOB.dblB4QtyBought
	,SOB.intB4QtyUOMId
	,SOB.strB4QtyUOM
	,SOB.dblB4Price
	,SOB.intB4PriceUOMId
	,SOB.strB4PriceUOM
	,SOB.intBuyer5Id
	,SOB.strBuyer5
	,SOB.dblB5QtyBought
	,SOB.intB5QtyUOMId
	,SOB.strB5QtyUOM
	,SOB.dblB5Price
	,SOB.intB5PriceUOMId
	,SOB.strB5PriceUOM
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
WHERE S.intTypeId = 1
