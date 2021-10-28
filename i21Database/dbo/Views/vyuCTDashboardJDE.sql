CREATE VIEW [dbo].[vyuCTDashboardJDE]

AS

WITH lgLoad AS (
	SELECT LD.intPContractDetailId
		, LO.strLoadNumber
		, LO.strOriginPort
		, LO.strDestinationPort
		, LO.strMVessel
		, LO.strMVoyageNumber
		, LO.strFVessel
		, LO.strFVoyageNumber
		, LO.strBLNumber
		, strLoadShippingLine = SL.strName
		, LO.intShipmentType
		, strShipmentType = (case when LO.intShipmentType = 2 then 'Shipping Instructions' else 'Shipment' end) COLLATE Latin1_General_CI_AS
		, strContainerNumber = NULL
		, LO.dtmStuffingDate
		, LO.dtmETAPOL
		, LO.dtmETAPOD
		, LO.dtmETSPOL
		, LO.strBookingReference
		, LO.intLoadId
		, LO.dtmDeadlineCargo
		, strETAPOLReasonCode = EA.strReasonCode
		, strETSPOLReasonCode = ES.strReasonCode
		, strETAPODReasonCode = PD.strReasonCode
		, strETAPOLReasonCodeDescription = EA.strReasonCodeDescription
		, strETSPOLReasonCodeDescription = ES.strReasonCodeDescription
		, strETAPODReasonCodeDescription = PD.strReasonCodeDescription
		, ysnDocsReceived = LO.ysnDocumentsReceived
		, dblQuantity = SUM(LD.dblQuantity)
	FROM tblLGLoad LO WITH(NOLOCK)
	JOIN tblLGLoadDetail LD WITH(NOLOCK) ON LO.intLoadId = LD.intLoadId
	LEFT JOIN tblEMEntity SL ON SL.intEntityId = LO.intShippingLineEntityId
	LEFT JOIN tblLGReasonCode EA ON EA.intReasonCodeId = LO.intETAPOLReasonCodeId
	LEFT JOIN tblLGReasonCode ES ON ES.intReasonCodeId = LO.intETSPOLReasonCodeId
	LEFT JOIN tblLGReasonCode PD ON PD.intReasonCodeId = LO.intETAPODReasonCodeId
	WHERE (LO.intShipmentType = 2 or LO.intShipmentType = 1)
		AND LO.intShipmentStatus <> 10
	GROUP BY LD.intPContractDetailId
		, LO.strLoadNumber
		, SL.strName
		, LO.strOriginPort
		, LO.strDestinationPort
		, LO.strMVessel
		, LO.strMVoyageNumber
		, LO.strFVessel
		, LO.strFVoyageNumber
		, LO.strBLNumber
		, LO.intShipmentType
		, LD.strContainerNumbers
		, LO.dtmStuffingDate
		, LO.dtmETAPOL
		, LO.dtmETAPOD
		, LO.dtmETSPOL
		, LO.strBookingReference
		, LO.intLoadId
		, LO.dtmDeadlineCargo
		, EA.strReasonCode
		, ES.strReasonCode
		, PD.strReasonCode
		, EA.strReasonCodeDescription
		, ES.strReasonCodeDescription
		, PD.strReasonCodeDescription
		, LO.ysnDocumentsReceived)
, cer AS (
	SELECT cr.intContractDetailId
		, cr.intContractCertificationId
		, ce.strCertificationName	
	FROM tblCTContractCertification cr
	JOIN tblICCertification ce ON ce.intCertificationId = cr.intCertificationId
)

SELECT CD.intContractDetailId
	, CH.strContractNumber
	, CD.intContractSeq
	, EY.strName AS strSupplier
	, PR.strName AS strProducer
	, CD.dtmStartDate
	, CD.dtmEndDate
	, CD.strLoadingPointType
	, LP.strCity AS strLoadingPoint
	, CD.strDestinationPointType
	, DP.strCity AS strDestinationPoint
	, DC.strCity AS strDestinationCity
	, CD.strShippingTerm
	, ES.strName AS strShippingLine
	, CD.strVessel
	, EP.strName AS strShipper
	, SB.strSubLocationName
	, SL.strName AS strStorageLocationName
	, CD.dblQuantity
	, strItemUOM = QM.strUnitMeasure
	, CD.dblNetWeight
	, dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, U7.intUnitMeasureId, U8.intUnitMeasureId, CD.dblNetWeight) AS dblNetWeightMT
	, strNetWeightUOM = U7.strUnitMeasure
	, CD.strFixationBy
	, DPT.strPricingType
	, CU.strCurrency
	, FM.strFutMarketName
	, LEFT(CONVERT(DATE, '01 ' + MO.strFutureMonth), 7) + ' (' + MO.strFutureMonth + ')' AS strFutureMonth
	, CD.dblFutures
	, CD.dblBasis
	, CD.dblCashPrice
	, CD.dblTotalCost
	, ISNULL(RY.strCountry, OG.strCountry) AS strOrigin
	, PG.strName COLLATE Latin1_General_CI_AS AS strPurchasingGroup
	, CT.strContainerType
	, CD.intNumberOfContainers
	, IM.strItemNo
	, strItemDescription = IM.strDescription
	, IM.strShortName AS strItemShortName
	, PT.strDescription AS strProductType
	, CS.strContractStatus
	, (CD.dblQuantity - CD.dblBalance) AS dblQtyShortClosed
	, FT.strFreightTerm
	, SV.strShipVia
	, BK.strBook
	, SK.strSubBook
	, CD.strInvoiceNo
	, cc.strCertifications AS strCertificationName
	, CH.intContractHeaderId
	, ISNULL(CD.dblScheduleQty, 0) AS dblScheduleQty
	, ysnInvoice = CASE WHEN ISNULL(CD.ysnInvoice, 0) = 0 THEN 'N'
						ELSE 'Y' END COLLATE Latin1_General_CI_AS
	, ysnProvisionalInvoice = CASE WHEN ISNULL(CD.ysnProvisionalInvoice, 0) = 0 THEN 'N'
									ELSE 'Y' END COLLATE Latin1_General_CI_AS
	, ysnQuantityFinal = CASE WHEN ISNULL(CD.ysnQuantityFinal, 0) = 0 THEN 'N'
							ELSE 'Y' END COLLATE Latin1_General_CI_AS
	, CH.strInternalComment
	, ysnRiskToProducer = CASE WHEN ISNULL(CD.ysnRiskToProducer, 0) = 0 THEN 'N'
								ELSE 'Y' END COLLATE Latin1_General_CI_AS
	, ysnClaimsToProducer = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 0 THEN 'N'
								ELSE 'Y' END COLLATE Latin1_General_CI_AS
	, CD.strERPPONumber
	, CD.strERPItemNumber
	, CD.strERPBatchNumber
	, CD.strGarden
	, CH.strCustomerContract
	, strContractBasis = NULL
	, CD.dtmPlannedAvailabilityDate
	, dtmPlannedAvailabilityDateYM = CD.dtmPlannedAvailabilityDate
	, strCommodityCode = CO.strCommodityCode
	, QA.strSampleStatus
	, QA.dblApprovedQty
	, dblShippingInsQty = ISNULL(LG1.dblQuantity, LG.dblQuantity)
	, strLoadNumber = ISNULL(LG1.strLoadNumber, LG.strLoadNumber)
	, strLoadShippingLine = ISNULL(LG1.strLoadShippingLine, LG.strLoadShippingLine)
	, strOriginPort = ISNULL(LG1.strOriginPort, LG.strOriginPort)
	, strDestinationPort = ISNULL(LG1.strDestinationPort, LG.strDestinationPort)
	, strMVessel = ISNULL(LG1.strMVessel, LG.strMVessel)
	, strMVoyageNumber = ISNULL(LG1.strMVoyageNumber, LG.strMVoyageNumber)
	, strFVessel = ISNULL(LG1.strFVessel, LG.strFVessel)
	, strFVoyageNumber = ISNULL(LG1.strFVoyageNumber, LG.strFVoyageNumber)
	, strBLNumber = ISNULL(LG1.strBLNumber, LG.strBLNumber)
	, dblLoadQuantity = ISNULL(LG1.dblQuantity, LG.dblQuantity)
	, intShipmentType = ISNULL(LG1.intShipmentType, LG.intShipmentType)
	, strShipmentType = ISNULL(LG1.strShipmentType, LG.strShipmentType)
	, strContainerNumber = ISNULL(LG1.strContainerNumber, LG.strContainerNumber)
	, dtmStuffingDate = ISNULL(LG1.dtmStuffingDate, LG.dtmStuffingDate)
	, dtmETSPOL = ISNULL(LG1.dtmETSPOL, LG.dtmETSPOL)
	, dtmETAPOL = ISNULL(LG1.dtmETAPOL, LG.dtmETAPOL)
	, dtmETAPOD = ISNULL(LG1.dtmETAPOD, LG.dtmETAPOD)
	, strBookingReference = ISNULL(LG1.strBookingReference, LG.strBookingReference)
	, intLoadId = ISNULL(LG1.intLoadId, LG.intLoadId)
	, dtmDeadlineCargo = ISNULL(LG1.dtmDeadlineCargo, LG.dtmDeadlineCargo)
	, strETAPOLReasonCode = ISNULL(LG1.strETAPOLReasonCode, LG.strETAPOLReasonCode)
	, strETSPOLReasonCode = ISNULL(LG1.strETSPOLReasonCode, LG.strETSPOLReasonCode)
	, strETAPODReasonCode = ISNULL(LG1.strETAPODReasonCode, LG.strETAPODReasonCode)
	, strETAPOLReasonCodeDescription = ISNULL(LG1.strETAPOLReasonCodeDescription, LG.strETAPOLReasonCodeDescription)
	, strETSPOLReasonCodeDescription = ISNULL(LG1.strETSPOLReasonCodeDescription, LG.strETSPOLReasonCodeDescription)
	, strETAPODReasonCodeDescription = ISNULL(LG1.strETAPODReasonCodeDescription, LG.strETAPODReasonCodeDescription)
	, ysnDocsReceived = (CASE WHEN ISNULL(ISNULL(LG1.ysnDocsReceived, LG.ysnDocsReceived), 0) = 0 THEN 'N'
							ELSE 'Y' END) COLLATE Latin1_General_CI_AS
	, CD.strVendorLotID
	, IC.strContractItemName
	, IC.strContractItemNo
	, IC.strGrade AS strQualityApproval
	, ysnQtyReceived = CASE WHEN CD.dblBalance <> CD.dblQuantity THEN 'Y'
							ELSE 'N' END COLLATE Latin1_General_CI_AS
	, dblAppliedQty = CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0)
							ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0) END
	, CD.strRemark
	, CH.dtmCreated
	, CD.dtmUpdatedAvailabilityDate
	, CL.strLocationName
	, CH.dtmContractDate
	, BIM.strItemNo AS strBundleItemNo
	, CH.intBookId AS intHeaderBookId
	, CH.intSubBookId AS intHeaderSubBookId
	, CD.intBookId AS intDetailBookId
	, CD.intSubBookId AS intDetailSubBookId
FROM tblCTContractDetail CD WITH(NOLOCK)
JOIN tblCTContractHeader CH WITH(NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblEMEntity EY WITH(NOLOCK) ON EY.intEntityId = CH.intEntityId
LEFT JOIN (
	SELECT DISTINCT c1.intContractDetailId
		, strCertifications = SUBSTRING((SELECT ',' + c2.strCertificationName  AS [text()]
										FROM cer c2
										WHERE c2.intContractDetailId = c1.intContractDetailId
										ORDER BY c2.intContractDetailId
										FOR XML PATH ('')), 2, 1000)

	FROM cer c1
	) cc ON cc.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblICItem IM WITH(NOLOCK) ON IM.intItemId = CD.intItemId
LEFT JOIN tblEMEntity PR WITH(NOLOCK) ON PR.intEntityId = ISNULL(CD.intProducerId, CH.intProducerId)
LEFT JOIN tblSMCity LP WITH(NOLOCK) ON LP.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DP WITH(NOLOCK) ON DP.intCityId = CD.intDestinationPortId
LEFT JOIN tblSMCity DC WITH(NOLOCK) ON DC.intCityId = CD.intDestinationCityId
LEFT JOIN tblICItemContract IC WITH(NOLOCK) ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblSMCountry RY WITH(NOLOCK) ON RY.intCountryID = IC.intCountryId
LEFT JOIN tblICCommodityAttribute CA WITH(NOLOCK) ON CA.intCommodityAttributeId = IM.intOriginId
	AND CA.strType = 'Origin'
LEFT JOIN tblSMCountry OG WITH(NOLOCK) ON OG.intCountryID = CA.intCountryID
LEFT JOIN tblLGContainerType CT WITH(NOLOCK) ON CT.intContainerTypeId = CD.intContainerTypeId
LEFT JOIN tblSMCompanyLocationSubLocation SB WITH(NOLOCK) ON SB.intCompanyLocationSubLocationId = CD.intSubLocationId
LEFT JOIN tblICStorageLocation SL WITH(NOLOCK) ON SL.intStorageLocationId = CD.intStorageLocationId
LEFT JOIN tblCTContractStatus CS WITH(NOLOCK) ON CS.intContractStatusId = CD.intContractStatusId
LEFT JOIN tblSMFreightTerms FT WITH(NOLOCK) ON FT.intFreightTermId = CD.intFreightTermId
LEFT JOIN tblSMShipVia SV WITH(NOLOCK) ON SV.intEntityId = CD.intShipViaId
LEFT JOIN tblEMEntity ES WITH(NOLOCK) ON ES.intEntityId = CD.intShippingLineId
LEFT JOIN tblEMEntity EP WITH(NOLOCK) ON EP.intEntityId = CD.intShipperId
LEFT JOIN tblSMPurchasingGroup PG WITH(NOLOCK) ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
LEFT JOIN tblICCommodityAttribute PT WITH(NOLOCK) ON PT.intCommodityAttributeId = IM.intProductTypeId
LEFT JOIN tblCTBook BK WITH(NOLOCK) ON BK.intBookId = CD.intBookId
LEFT JOIN tblCTSubBook SK WITH(NOLOCK) ON SK.intSubBookId = CD.intSubBookId
LEFT JOIN tblICItemUOM WU WITH(NOLOCK) ON WU.intItemUOMId = CD.intNetWeightUOMId
LEFT JOIN tblICUnitMeasure U7 WITH(NOLOCK) ON U7.intUnitMeasureId = WU.intUnitMeasureId
LEFT JOIN tblICUnitMeasure U8 WITH(NOLOCK) ON 1 = 1
	AND U8.strUnitMeasure = 'Ton'
LEFT JOIN lgLoad LG ON LG.intPContractDetailId = CD.intContractDetailId and LG.intShipmentType = 2
LEFT JOIN lgLoad LG1 ON LG1.intPContractDetailId = CD.intContractDetailId and LG1.intShipmentType = 1
LEFT JOIN vyuCTQualityApprovedRejected QA WITH(NOLOCK) ON QA.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblICItem BIM WITH(NOLOCK) ON BIM.intItemId = CD.intItemBundleId
LEFT JOIN tblICItemUOM QU ON QU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure QM ON QM.intUnitMeasureId = QU.intUnitMeasureId
LEFT JOIN tblCTPricingType AS DPT ON DPT.intPricingTypeId = CD.intPricingTypeId
LEFT JOIN tblSMCurrency AS CU ON CU.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblRKFutureMarket AS FM ON FM.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth AS MO ON MO.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblICCommodity AS CO ON CO.intCommodityId = CH.intCommodityId
LEFT JOIN tblSMCompanyLocation AS CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
WHERE CD.intContractStatusId IN(1, 2, 4);