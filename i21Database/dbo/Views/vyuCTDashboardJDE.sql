CREATE VIEW [dbo].[vyuCTDashboardJDE]
AS
with lgLoad1 as
(
    SELECT
      LD.intPContractDetailId, 
	  LO.strLoadNumber,
	  LO.strOriginPort,
      LO.strDestinationPort, 
      LO.strMVessel, 
      LO.strMVoyageNumber, 
      LO.strFVessel, 
      LO.strFVoyageNumber, 
      LO.strBLNumber,
	  strLoadShippingLine = SL.strName,
	  LO.intShipmentType,
	  strShipmentType = 'Shipment' COLLATE Latin1_General_CI_AS,
	  strContainerNumber = LD.strContainerNumbers,
	  LO.dtmStuffingDate,
      LO.dtmETAPOL, 
      LO.dtmETAPOD, 
      LO.dtmETSPOL, 
	  LO.strBookingReference,
	  LO.intLoadId,
	  LO.dtmDeadlineCargo,
	  strETAPOLReasonCode = EA.strReasonCode,
	  strETSPOLReasonCode = ES.strReasonCode,
	  strETAPODReasonCode = PD.strReasonCode,
	  strETAPOLReasonCodeDescription = EA.strReasonCodeDescription, 
      strETSPOLReasonCodeDescription = ES.strReasonCodeDescription, 
      strETAPODReasonCodeDescription = PD.strReasonCodeDescription,
	  ysnDocsReceived = LO.ysnDocumentsReceived,
      SUM(LD.dblQuantity) dblQuantity
    FROM 
      tblLGLoad LO WITH (NOLOCK) 
      JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LO.intLoadId = LD.intLoadId
	  LEFT JOIN tblEMEntity SL ON SL.intEntityId = LO.intShippingLineEntityId
	  LEFT JOIN tblLGReasonCode EA ON EA.intReasonCodeId = LO.intETAPOLReasonCodeId
	  LEFT JOIN tblLGReasonCode ES ON ES.intReasonCodeId = LO.intETSPOLReasonCodeId
	  LEFT JOIN tblLGReasonCode PD ON PD.intReasonCodeId = LO.intETAPODReasonCodeId 
    WHERE
      LO.intShipmentType = 1
	  AND LO.intShipmentStatus <> 10
    GROUP BY 
      LD.intPContractDetailId
	  ,LO.strLoadNumber
	  ,SL.strName
	  ,LO.strOriginPort
	  ,LO.strDestinationPort
	  ,LO.strMVessel
	  ,LO.strMVoyageNumber
	  ,LO.strFVessel
	  ,LO.strFVoyageNumber
	  ,LO.strBLNumber
	  ,LO.intShipmentType
	  ,LD.strContainerNumbers
	  ,LO.dtmStuffingDate
      ,LO.dtmETAPOL 
      ,LO.dtmETAPOD 
      ,LO.dtmETSPOL
	  ,LO.strBookingReference
	  ,LO.intLoadId
	  ,LO.dtmDeadlineCargo
	  ,EA.strReasonCode
	  ,ES.strReasonCode
	  ,PD.strReasonCode
	  ,EA.strReasonCodeDescription
	  ,ES.strReasonCodeDescription
	  ,PD.strReasonCodeDescription
	  ,LO.ysnDocumentsReceived
),
lgLoad as
(
    SELECT
      LD.intPContractDetailId, 
	  LO.strLoadNumber,
	  LO.strOriginPort,
      LO.strDestinationPort, 
      LO.strMVessel, 
      LO.strMVoyageNumber, 
      LO.strFVessel, 
      LO.strFVoyageNumber, 
      LO.strBLNumber,
	  strLoadShippingLine = SL.strName,
	  LO.intShipmentType,
	  strShipmentType = 'Shipping Instructions',
	  strContainerNumber = null,
	  LO.dtmStuffingDate,
      LO.dtmETAPOL, 
      LO.dtmETAPOD, 
      LO.dtmETSPOL, 
	  LO.strBookingReference,
	  LO.intLoadId,
	  LO.dtmDeadlineCargo,
	  strETAPOLReasonCode = EA.strReasonCode,
	  strETSPOLReasonCode = ES.strReasonCode,
	  strETAPODReasonCode = PD.strReasonCode,
	  strETAPOLReasonCodeDescription = EA.strReasonCodeDescription, 
      strETSPOLReasonCodeDescription = ES.strReasonCodeDescription, 
      strETAPODReasonCodeDescription = PD.strReasonCodeDescription,
	  ysnDocsReceived = LO.ysnDocumentsReceived,
      SUM(LD.dblQuantity) dblQuantity
    FROM 
      tblLGLoad LO WITH (NOLOCK) 
      JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LO.intLoadId = LD.intLoadId
	  LEFT JOIN tblEMEntity SL ON SL.intEntityId = LO.intShippingLineEntityId
	  LEFT JOIN tblLGReasonCode EA ON EA.intReasonCodeId = LO.intETAPOLReasonCodeId
	  LEFT JOIN tblLGReasonCode ES ON ES.intReasonCodeId = LO.intETSPOLReasonCodeId
	  LEFT JOIN tblLGReasonCode PD ON PD.intReasonCodeId = LO.intETAPODReasonCodeId 
    WHERE
      LO.intShipmentType = 2
	  AND LO.intShipmentStatus <> 10
	  --and LD.intPContractDetailId not in (select intContractDetailId from lgLoad1)
    GROUP BY 
      LD.intPContractDetailId
	  ,LO.strLoadNumber
	  ,SL.strName
	  ,LO.strOriginPort
	  ,LO.strDestinationPort
	  ,LO.strMVessel
	  ,LO.strMVoyageNumber
	  ,LO.strFVessel
	  ,LO.strFVoyageNumber
	  ,LO.strBLNumber
	  ,LO.intShipmentType
	  ,LD.strContainerNumbers
	  ,LO.dtmStuffingDate
      ,LO.dtmETAPOL 
      ,LO.dtmETAPOD 
      ,LO.dtmETSPOL
	  ,LO.strBookingReference
	  ,LO.intLoadId
	  ,LO.dtmDeadlineCargo
	  ,EA.strReasonCode
	  ,ES.strReasonCode
	  ,PD.strReasonCode
	  ,EA.strReasonCodeDescription
	  ,ES.strReasonCodeDescription
	  ,PD.strReasonCodeDescription
	  ,LO.ysnDocumentsReceived
)
SELECT
  CD.intContractDetailId, 
  CH.strContractNumber, 
  CD.intContractSeq, 
  EY.strName AS strSupplier, 
  PR.strName AS strProducer, 
  CD.dtmStartDate, 
  CD.dtmEndDate, 
  CD.strLoadingPointType, 
  LP.strCity AS strLoadingPoint, 
  CD.strDestinationPointType, 
  DP.strCity AS strDestinationPoint, 
  DC.strCity AS strDestinationCity, 
  CD.strShippingTerm, 
  ES.strName AS strShippingLine, 
  CD.strVessel, 
  EP.strName AS strShipper, 
  SB.strSubLocationName, 
  SL.strName AS strStorageLocationName, 
  CD.dblQuantity, 
  strItemUOM = QM.strUnitMeasure, 
  CD.dblNetWeight, 
  dbo.fnCTConvertQuantityToTargetItemUOM(
    CD.intItemId, U7.intUnitMeasureId, 
    U8.intUnitMeasureId, CD.dblNetWeight
  ) AS dblNetWeightMT, 
  strNetWeightUOM = U7.strUnitMeasure, 
  CD.strFixationBy, 
  DPT.strPricingType, 
  CU.strCurrency, 
  FM.strFutMarketName,
  LEFT(
    CONVERT(DATE, '01 ' + MO.strFutureMonth), 
    7
  ) + ' (' + MO.strFutureMonth + ')' AS strFutureMonth, 
  CD.dblFutures, 
  CD.dblBasis, 
  CD.dblCashPrice, 
  CD.dblTotalCost, 
  ISNULL(RY.strCountry, OG.strCountry) AS strOrigin, 
  PG.strName COLLATE Latin1_General_CI_AS AS strPurchasingGroup, 
  CT.strContainerType, 
  CD.intNumberOfContainers, 
  IM.strItemNo, 
  strItemDescription = IM.strDescription, 
  IM.strShortName AS strItemShortName, 
  PT.strDescription AS strProductType, 
  CS.strContractStatus, 
  (CD.dblQuantity - CD.dblBalance) AS dblQtyShortClosed, 
  FT.strFreightTerm, 
  SV.strShipVia, 
  BK.strBook, 
  SK.strSubBook, 
  CD.strInvoiceNo, 
  CD.strCertifications AS strCertificationName, 
  CH.intContractHeaderId, 
  ISNULL(CD.dblScheduleQty, 0) AS dblScheduleQty, 
  CASE WHEN ISNULL(CD.ysnInvoice, 0) = 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS AS ysnInvoice, 
  CASE WHEN ISNULL(CD.ysnProvisionalInvoice, 0) = 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS AS ysnProvisionalInvoice, 
  CASE WHEN ISNULL(CD.ysnQuantityFinal, 0) = 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS AS ysnQuantityFinal, 
  CH.strInternalComment, 
  CASE WHEN ISNULL(CD.ysnRiskToProducer, 0) = 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS AS ysnRiskToProducer, 
  CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 0 THEN 'N' ELSE 'Y' END COLLATE Latin1_General_CI_AS AS ysnClaimsToProducer, 
  CD.strERPPONumber, 
  CD.strERPItemNumber, 
  CD.strERPBatchNumber, 
  CD.strGarden, 
  CH.strCustomerContract, 
  CB.strContractBasis, 
  CD.dtmPlannedAvailabilityDate, 
  dtmPlannedAvailabilityDateYM = CD.dtmPlannedAvailabilityDate, 
  strCommodityCode = CO.strCommodityCode, 
  QA.strSampleStatus, 
  QA.dblApprovedQty, 
dblShippingInsQty = isnull(LG1.dblQuantity,LG.dblQuantity)
,strLoadNumber = isnull(LG1.strLoadNumber,LG.strLoadNumber)
,strLoadShippingLine = isnull(LG1.strLoadShippingLine,LG.strLoadShippingLine)
,strOriginPort = isnull(LG1.strOriginPort,LG.strOriginPort)
,strDestinationPort = isnull(LG1.strDestinationPort,LG.strDestinationPort)
,strMVessel = isnull(LG1.strMVessel,LG.strMVessel)
,strMVoyageNumber = isnull(LG1.strMVoyageNumber,LG.strMVoyageNumber)
,strFVessel = isnull(LG1.strFVessel,LG.strFVessel)
,strFVoyageNumber = isnull(LG1.strFVoyageNumber,LG.strFVoyageNumber)
,strBLNumber = isnull(LG1.strBLNumber,LG.strBLNumber)
,dblLoadQuantity = isnull(LG1.dblQuantity,LG.dblQuantity)
,intShipmentType = isnull(LG1.intShipmentType,LG.intShipmentType)
,strShipmentType = isnull(LG1.strShipmentType,LG.strShipmentType)
,strContainerNumber = isnull(LG1.strContainerNumber,LG.strContainerNumber)
,dtmStuffingDate = isnull(LG1.dtmStuffingDate,LG.dtmStuffingDate)
,dtmETSPOL = isnull(LG1.dtmETSPOL,LG.dtmETSPOL)
,dtmETAPOL = isnull(LG1.dtmETAPOL,LG.dtmETAPOL)
,dtmETAPOD = isnull(LG1.dtmETAPOD,LG.dtmETAPOD)
,strBookingReference = isnull(LG1.strBookingReference,LG.strBookingReference)
,intLoadId = isnull(LG1.intLoadId,LG.intLoadId)
,dtmDeadlineCargo = isnull(LG1.dtmDeadlineCargo,LG.dtmDeadlineCargo)
,strETAPOLReasonCode = isnull(LG1.strETAPOLReasonCode,LG.strETAPOLReasonCode)
,strETSPOLReasonCode = isnull(LG1.strETSPOLReasonCode,LG.strETSPOLReasonCode)
,strETAPODReasonCode = isnull(LG1.strETAPODReasonCode,LG.strETAPODReasonCode)
,strETAPOLReasonCodeDescription = isnull(LG1.strETAPOLReasonCodeDescription,LG.strETAPOLReasonCodeDescription)
,strETSPOLReasonCodeDescription = isnull(LG1.strETSPOLReasonCodeDescription,LG.strETSPOLReasonCodeDescription)
,strETAPODReasonCodeDescription = isnull(LG1.strETAPODReasonCodeDescription,LG.strETAPODReasonCodeDescription)
,ysnDocsReceived = (CASE WHEN ISNULL(isnull(LG1.ysnDocsReceived,LG.ysnDocsReceived), 0) = 0 THEN 'N' ELSE 'Y' END) COLLATE Latin1_General_CI_AS

  ,CD.strVendorLotID, 
  IC.strContractItemName, 
  IC.strContractItemNo, 
  IC.strGrade AS strQualityApproval, 
  CASE WHEN CD.dblBalance <> CD.dblQuantity THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS AS ysnQtyReceived, 
  CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0) ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0) END AS dblAppliedQty,
  CD.strRemark, 
  CH.dtmCreated, 
  CD.dtmUpdatedAvailabilityDate, 
  CL.strLocationName, 
  CH.dtmContractDate, 
  BIM.strItemNo AS strBundleItemNo 
FROM 
  tblCTContractDetail CD WITH (NOLOCK) 
  JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId 
  JOIN tblEMEntity EY WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId 
  LEFT JOIN tblCTContractBasis CB WITH (NOLOCK) ON CB.intContractBasisId = CH.intContractBasisId 
  LEFT JOIN tblICItem IM WITH (NOLOCK) ON IM.intItemId = CD.intItemId 
  LEFT JOIN tblEMEntity PR WITH (NOLOCK) ON PR.intEntityId = ISNULL(
    CD.intProducerId, CH.intProducerId
  ) 
  LEFT JOIN tblSMCity LP WITH (NOLOCK) ON LP.intCityId = CD.intLoadingPortId 
  LEFT JOIN tblSMCity DP WITH (NOLOCK) ON DP.intCityId = CD.intDestinationPortId 
  LEFT JOIN tblSMCity DC WITH (NOLOCK) ON DC.intCityId = CD.intDestinationCityId 
  LEFT JOIN tblICItemContract IC WITH (NOLOCK) ON IC.intItemContractId = CD.intItemContractId 
  LEFT JOIN tblSMCountry RY WITH (NOLOCK) ON RY.intCountryID = IC.intCountryId 
  LEFT JOIN tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = IM.intOriginId 
  AND CA.strType = 'Origin' 
  LEFT JOIN tblSMCountry OG WITH (NOLOCK) ON OG.intCountryID = CA.intCountryID 
  LEFT JOIN tblLGContainerType CT WITH (NOLOCK) ON CT.intContainerTypeId = CD.intContainerTypeId 
  LEFT JOIN tblSMCompanyLocationSubLocation SB WITH (NOLOCK) ON SB.intCompanyLocationSubLocationId = CD.intSubLocationId 
  LEFT JOIN tblICStorageLocation SL WITH (NOLOCK) ON SL.intStorageLocationId = CD.intStorageLocationId 
  LEFT JOIN tblCTContractStatus CS WITH (NOLOCK) ON CS.intContractStatusId = CD.intContractStatusId 
  LEFT JOIN tblSMFreightTerms FT WITH (NOLOCK) ON FT.intFreightTermId = CD.intFreightTermId 
  LEFT JOIN tblSMShipVia SV WITH (NOLOCK) ON SV.intEntityId = CD.intShipViaId 
  LEFT JOIN tblEMEntity ES WITH (NOLOCK) ON ES.intEntityId = CD.intShippingLineId 
  LEFT JOIN tblEMEntity EP WITH (NOLOCK) ON EP.intEntityId = CD.intShipperId 
  LEFT JOIN tblSMPurchasingGroup PG WITH (NOLOCK) ON PG.intPurchasingGroupId = CD.intPurchasingGroupId 
  LEFT JOIN tblICCommodityAttribute PT WITH (NOLOCK) ON PT.intCommodityAttributeId = IM.intProductTypeId 
  LEFT JOIN tblCTBook BK WITH (NOLOCK) ON BK.intBookId = CD.intBookId 
  LEFT JOIN tblCTSubBook SK WITH (NOLOCK) ON SK.intSubBookId = CD.intSubBookId 
  LEFT JOIN tblICItemUOM WU WITH (NOLOCK) ON WU.intItemUOMId = CD.intNetWeightUOMId 
  LEFT JOIN tblICUnitMeasure U7 WITH (NOLOCK) ON U7.intUnitMeasureId = WU.intUnitMeasureId 
  LEFT JOIN tblICUnitMeasure U8 WITH (NOLOCK) ON 1 = 1 
  AND U8.strUnitMeasure = 'Ton' 
  LEFT JOIN lgLoad LG ON LG.intPContractDetailId = CD.intContractDetailId 
  LEFT JOIN lgLoad1 LG1 ON LG1.intPContractDetailId = CD.intContractDetailId 
  LEFT JOIN vyuCTQualityApprovedRejected QA WITH (NOLOCK) ON QA.intContractDetailId = CD.intContractDetailId 
  LEFT JOIN tblICItem BIM WITH (NOLOCK) ON BIM.intItemId = CD.intItemBundleId 
  LEFT JOIN tblICItemUOM QU ON QU.intItemUOMId = CD.intItemUOMId 
  LEFT JOIN tblICUnitMeasure QM ON QM.intUnitMeasureId = QU.intUnitMeasureId 

  LEFT JOIN tblCTPricingType AS DPT ON DPT.intPricingTypeId = CD.intPricingTypeId 
  LEFT JOIN tblSMCurrency AS CU ON CU.intCurrencyID = CD.intCurrencyId 
  LEFT JOIN tblRKFutureMarket AS FM ON FM.intFutureMarketId = CD.intFutureMarketId 
  LEFT JOIN tblRKFuturesMonth AS MO ON MO.intFutureMonthId = CD.intFutureMonthId 
  LEFT JOIN tblICCommodity AS CO ON CO.intCommodityId = CH.intCommodityId
  LEFT JOIN tblSMCompanyLocation AS CL ON CL.intCompanyLocationId = CD.intCompanyLocationId 

where 
  CD.intContractStatusId IN (1, 2, 4)
/*
SELECT 	 SQ.intContractDetailId			
		,SQ.strContractNumber				
		,SQ.intContractSeq					
		,SQ.strEntityName						AS strSupplier
		,PR.strName								AS strProducer
		,SQ.dtmStartDate					
		,SQ.dtmEndDate						
		,CD.strLoadingPointType				
		,LP.strCity								AS strLoadingPoint
		,CD.strDestinationPointType			
		,DP.strCity								AS strDestinationPoint
		,DC.strCity								AS strDestinationCity
		,CD.strShippingTerm					
		,ES.strName								AS strShippingLine
		,CD.strVessel						
		,EP.strName								AS strShipper
		,SB.strSubLocationName				
		,SL.strName								AS strStorageLocationName
		,SQ.dblQuantity					
		,SQ.strItemUOM						
		,SQ.dblNetWeight					
		,dbo.fnCTConvertQuantityToTargetItemUOM(SQ.intItemId, U7.intUnitMeasureId, U8.intUnitMeasureId, SQ.dblNetWeight)	 	[dblNetWeightMT]
		,SQ.strNetWeightUOM				
		,CD.strFixationBy					
		,SQ.strPricingType					
		,SQ.strCurrency					
		,SQ.strFutMarketName				
		,SQ.strFutureMonthYear AS strFutureMonth					
		,SQ.dblFutures						
		,SQ.dblBasis						
		,SQ.dblCashPrice					
		,CD.dblTotalCost						
		,ISNULL(RY.strCountry, OG.strCountry)	AS strOrigin
		,PG.strName	COLLATE Latin1_General_CI_AS AS strPurchasingGroup
		,CT.strContainerType		
		,CD.intNumberOfContainers			
		,SQ.strItemNo									
		,SQ.strItemDescription	
		,IM.strShortName AS strItemShortName
		,PT.strDescription						AS strProductType
		,CS.strContractStatus				
		,(SQ.dblQuantity - SQ.dblBalance)		AS dblQtyShortClosed
		,FT.strFreightTerm					
		,SV.strShipVia						
		,BK.strBook						
		,SK.strSubBook					
		,CD.strInvoiceNo						
		,CD.strCertifications AS strCertificationName	
		,CH.intContractHeaderId				
		,ISNULL(CD.dblScheduleQty, 0)			AS dblScheduleQty
		,CASE 	WHEN ISNULL(CD.ysnInvoice, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnInvoice
		,CASE 	WHEN ISNULL(CD.ysnProvisionalInvoice, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnProvisionalInvoice
		,CASE 	WHEN ISNULL(CD.ysnQuantityFinal, 0) = 0 
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnQuantityFinal
		,CH.strInternalComment
		,LG.dblQuantity							AS dblShippingInsQty
		,CASE 	WHEN ISNULL(CD.ysnRiskToProducer, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnRiskToProducer
		,CASE 	WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 0 	
						THEN 'N'
						ELSE 'Y' 
				END		COLLATE Latin1_General_CI_AS AS ysnClaimsToProducer

		,CD.strERPPONumber
		,CD.strERPItemNumber
		,CD.strERPBatchNumber
		,CD.strGarden
		,CH.strCustomerContract
		,CB.strContractBasis
		,CD.dtmPlannedAvailabilityDate
		,dtmPlannedAvailabilityDateYM = CD.dtmPlannedAvailabilityDate
		,SQ.strCommodityCode
		,QA.strSampleStatus
		,QA.dblApprovedQty
		
		,LV.strLoadNumber
		,LV.strLoadShippingLine
		,LV.strOriginPort
		,LV.strDestinationPort
		,LV.strMVessel
		,LV.strMVoyageNumber
		,LV.strFVessel
		,LV.strFVoyageNumber
		,LV.strBLNumber
		,LV.dblLoadQuantity
		,LV.intShipmentType
		,LV.strShipmentType
		,LV.strContainerNumber
		,LV.dtmStuffingDate
		,LV.dtmETSPOL
		,LV.dtmETAPOL
		,LV.dtmETAPOD
		,LV.strBookingReference
		,LV.intLoadId
		,LV.dtmDeadlineCargo
		,LV.strETAPOLReasonCode 
		,LV.strETSPOLReasonCode
		,LV.strETAPODReasonCode
		,LV.strETAPOLReasonCodeDescription
		,LV.strETSPOLReasonCodeDescription
		,LV.strETAPODReasonCodeDescription
		,CASE 	WHEN ISNULL(LV.ysnDocsReceived, 0) = 0 	
				THEN 'N'
				ELSE 'Y' 
		 END	COLLATE Latin1_General_CI_AS AS ysnDocsReceived
		,CD.strVendorLotID
		,SQ.strContractItemName
		,SQ.strContractItemNo
		,IC.strGrade  AS strQualityApproval
		,CASE 	WHEN CD.dblBalance <> CD.dblQuantity	
				THEN 'Y'
				ELSE 'N' 
		 END	COLLATE Latin1_General_CI_AS AS ysnQtyReceived
		,SQ.dblAppliedQty
		,CD.strRemark
		,CH.dtmCreated
		,CD.dtmUpdatedAvailabilityDate
		,SQ.strLocationName
		,CH.dtmContractDate
		,BIM.strItemNo AS strBundleItemNo

	FROM 		vyuCTContractSequence			 	SQ	WITH (NOLOCK)		
	JOIN 		tblCTContractDetail				 	CD	WITH (NOLOCK) ON	CD.intContractDetailId				=	SQ.intContractDetailId AND SQ.intContractStatusId IN(1,2,4)
	JOIN 		tblCTContractHeader				 	CH	WITH (NOLOCK) ON	CH.intContractHeaderId				=	SQ.intContractHeaderId
	LEFT JOIN	tblCTContractBasis					CB	WITH (NOLOCK) ON	CB.intContractBasisId				=	CH.intContractBasisId
	LEFT JOIN	tblICItem						 	IM	WITH (NOLOCK) ON	IM.intItemId						=	SQ.intItemId
	LEFT JOIN 	tblEMEntity						 	PR	WITH (NOLOCK) ON	PR.intEntityId						=	ISNULL(CD.intProducerId,CH.intProducerId)
	LEFT JOIN 	tblSMCity						 	LP	WITH (NOLOCK) ON	LP.intCityId						=	CD.intLoadingPortId
	LEFT JOIN 	tblSMCity						 	DP	WITH (NOLOCK) ON	DP.intCityId						=	CD.intDestinationPortId
	LEFT JOIN 	tblSMCity						 	DC	WITH (NOLOCK) ON	DC.intCityId						=	CD.intDestinationCityId
	LEFT JOIN 	tblICItemContract				 	IC	WITH (NOLOCK) ON	IC.intItemContractId				=	CD.intItemContractId
	LEFT JOIN 	tblSMCountry					 	RY	WITH (NOLOCK) ON	RY.intCountryID						=	IC.intCountryId
	LEFT JOIN 	tblICCommodityAttribute			 	CA	WITH (NOLOCK) ON	CA.intCommodityAttributeId			=	IM.intOriginId
														AND	CA.strType							=	'Origin'
	LEFT JOIN 	tblSMCountry					 	OG	WITH (NOLOCK) ON	OG.intCountryID						=	CA.intCountryID
	LEFT JOIN 	tblLGContainerType				 	CT	WITH (NOLOCK) ON	CT.intContainerTypeId				=	CD.intContainerTypeId
	LEFT JOIN 	tblSMCompanyLocationSubLocation	 	SB	WITH (NOLOCK) ON	SB.intCompanyLocationSubLocationId	=	CD.intSubLocationId
	LEFT JOIN 	tblICStorageLocation			 	SL	WITH (NOLOCK) ON	SL.intStorageLocationId				=	CD.intStorageLocationId
	LEFT JOIN 	tblCTContractStatus				 	CS	WITH (NOLOCK) ON	CS.intContractStatusId				=	SQ.intContractStatusId
	LEFT JOIN 	tblSMFreightTerms				 	FT	WITH (NOLOCK) ON	FT.intFreightTermId					=	CD.intFreightTermId
	LEFT JOIN 	tblSMShipVia					 	SV	WITH (NOLOCK) ON	SV.intEntityId						=	CD.intShipViaId
	LEFT JOIN 	tblEMEntity						 	ES	WITH (NOLOCK) ON	ES.intEntityId						=	CD.intShippingLineId
	LEFT JOIN 	tblEMEntity						 	EP	WITH (NOLOCK) ON	EP.intEntityId						=	CD.intShipperId
	LEFT JOIN 	tblSMPurchasingGroup			 	PG	WITH (NOLOCK) ON	PG.intPurchasingGroupId				=	CD.intPurchasingGroupId
	LEFT JOIN 	tblICCommodityAttribute			 	PT	WITH (NOLOCK) ON	PT.intCommodityAttributeId			=	IM.intProductTypeId
	LEFT JOIN 	tblCTBook						 	BK	WITH (NOLOCK) ON	BK.intBookId						=	SQ.intBookId
	LEFT JOIN 	tblCTSubBook					 	SK	WITH (NOLOCK) ON	SK.intSubBookId						=	SQ.intSubBookId
	LEFT JOIN 	tblICItemUOM					 	WU	WITH (NOLOCK) ON	WU.intItemUOMId						=	SQ.intNetWeightUOMId
	LEFT JOIN 	tblICUnitMeasure				 	U7	WITH (NOLOCK) ON	U7.intUnitMeasureId					=	WU.intUnitMeasureId

	 LEFT JOIN
		(
			select intItemId, intUnitMeasureId from
			(
				select intFirstPriority = convert(int,1), a1.intItemId, a2.intUnitMeasureId from tblICItemUOM a1, tblICUnitMeasure a2
				where a2.intUnitMeasureId = a1.intUnitMeasureId and a2.strUnitMeasure = 'Ton'
				union all
				select intFirstPriority = convert(int,1), a1.intItemId, a2.intUnitMeasureId from tblICItemUOM a1, tblICUnitMeasure a2
				where a2.intUnitMeasureId = a1.intUnitMeasureId and a2.strUnitMeasure = 'Metric Ton'
				and a1.intItemId not in
					(
						select a1.intItemId from tblICItemUOM a1, tblICUnitMeasure a2
						where a2.intUnitMeasureId = a1.intUnitMeasureId and a2.strUnitMeasure = 'Ton'
					)
			) as a3
		) U8 ON U8.intItemId = CD.intItemId
	
	LEFT JOIN 	
	(
		SELECT 	intPContractDetailId,
				SUM(LD.dblQuantity)	 dblQuantity
		FROM 	tblLGLoad		 	LO	 WITH (NOLOCK)
		JOIN 	tblLGLoadDetail	 	LD	 WITH (NOLOCK) ON LO.intLoadId = LD.intLoadId
		WHERE	LO.intShipmentType = 2
		GROUP BY intPContractDetailId
	)										 		LG				  ON	LG.intPContractDetailId				=	CD.intContractDetailId
	LEFT JOIN	vyuCTLoadView						LV	WITH (NOLOCK) ON	LV.intContractDetailId				=	CD.intContractDetailId
	LEFT JOIN	vyuCTQualityApprovedRejected		QA	WITH (NOLOCK) ON	QA.intContractDetailId				=	CD.intContractDetailId
	LEFT JOIN	tblICItem							BIM WITH (NOLOCK) ON	BIM.intItemId						=	CD.intItemBundleId
	*/