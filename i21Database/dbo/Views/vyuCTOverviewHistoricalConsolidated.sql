CREATE VIEW [dbo].[vyuCTOverviewHistoricalConsolidated]

AS
SELECT 
	intContractDetailId
	,strContractNumber
	,intContractSeq
	,strSupplier
	,strProducer
	,dtmStartDate
	,dtmEndDate
	,strLoadingPointType
	,strLoadingPoint
	,strDestinationPointType
	,strDestinationPoint
	,strDestinationCity
	,strShippingTerm
	,strShippingLine
	,strVessel
	,strShipper
	,strSubLocationName
	,strStorageLocationName
	,dblQuantity
	,strItemUOM
	,dblNetWeight
	,dblNetWeightMT
	,strNetWeightUOM
	,strFixationBy
	,strPricingType
	,strCurrency
	,strFutMarketName
	,strFutureMonth
	,dblFutures
	,dblBasis
	,dblCashPrice
	,dblTotalCost
	,strOrigin
	,strPurchasingGroup
	,strContainerType
	,intNumberOfContainers
	,strItemNo
	,strItemDescription
	,strItemShortName
	,strProductType
	,strContractStatus
	,dblQtyShortClosed
	,strFreightTerm
	,strShipVia
	,strBook
	,strSubBook
	,strInvoiceNo
	,strCertificationName
	,intContractHeaderId
	,dblScheduleQty
	,ysnInvoice
	,ysnProvisionalInvoice
	,ysnQuantityFinal
	,strInternalComment
	,dblShippingInsQty
	,ysnRiskToProducer
	,ysnClaimsToProducer
	,strPrimeCustomer
	,strERPPONumber
	,strERPItemNumber
	,strERPBatchNumber
	,strGarden
	,strCustomerContract
	,strContractBasis
	,dtmPlannedAvailabilityDate
	,dtmPlannedAvailabilityDateYM
	,strCommodityCode
	,strSampleStatus
	,dblApprovedQty
	,strLoadNumber
	,strLoadShippingLine
	,strOriginPort
	,strDestinationPort
	,strMVessel
	,strMVoyageNumber
	,strFVessel
	,strFVoyageNumber
	,strBLNumber
	,dblLoadQuantity
	,intShipmentType
	,strShipmentType
	,strContainerNumber
	,dtmStuffingDate
	,dtmETSPOL
	,dtmETAPOL
	,intWeekActETD
	,dtmETAPOD
	,intWeekActETA
	,strBookingReference
	,intLoadId
	,dtmDeadlineCargo
	,strETAPOLReasonCode
	,strETSPOLReasonCode
	,strETAPODReasonCode
	,strETAPOLReasonCodeDescription
	,strETSPOLReasonCodeDescription
	,strETAPODReasonCodeDescription
	,ysnDocsReceived
	,strVendorLotID
	,strContractItemName
	,strContractItemNo
	,strQualityApproval
	,ysnQtyReceived
	,dblAppliedQty
	,strRemark
	,dtmCreated
	,dtmUpdatedAvailabilityDate
	,strLocationName
	,dtmContractDate
	,strBundleItemNo
	,intHeaderBookId
	,intHeaderSubBookId
	,intDetailBookId
	,intDetailSubBookId
FROM [vyuCTDashboardJDEHistorical]

UNION ALL

SELECT 
	intContractDetailId
	,strContractNumber
	,intContractSeq
	,strSupplier
	,strProducer
	,dtmStartDate
	,dtmEndDate
	,strLoadingPointType
	,strLoadingPoint
	,strDestinationPointType
	,strDestinationPoint
	,strDestinationCity
	,strShippingTerm
	,strShippingLine
	,strVessel
	,strShipper
	,strSubLocationName
	,strStorageLocationName
	,dblQuantity
	,strItemUOM
	,dblNetWeight
	,dblNetWeightMT
	,strNetWeightUOM
	,strFixationBy
	,strPricingType
	,strCurrency
	,strFutMarketName
	,strFutureMonth
	,dblFutures
	,dblBasis
	,dblCashPrice
	,dblTotalCost
	,strOrigin
	,strPurchasingGroup
	,strContainerType
	,intNumberOfContainers
	,strItemNo
	,strItemDescription
	,strItemShortName
	,strProductType
	,strContractStatus
	,dblQtyShortClosed
	,strFreightTerm
	,strShipVia
	,strBook
	,strSubBook
	,strInvoiceNo
	,strCertificationName
	,intContractHeaderId
	,dblScheduleQty
	,ysnInvoice
	,ysnProvisionalInvoice
	,ysnQuantityFinal
	,strInternalComment
	,dblShippingInsQty
	,ysnRiskToProducer
	,ysnClaimsToProducer
	,strPrimeCustomer
	,strERPPONumber
	,strERPItemNumber
	,strERPBatchNumber
	,strGarden
	,strCustomerContract
	,strContractBasis
	,dtmPlannedAvailabilityDate
	,dtmPlannedAvailabilityDateYM
	,strCommodityCode
	,strSampleStatus
	,dblApprovedQty
	,strLoadNumber
	,strLoadShippingLine
	,strOriginPort
	,strDestinationPort
	,strMVessel
	,strMVoyageNumber
	,strFVessel
	,strFVoyageNumber
	,strBLNumber
	,dblLoadQuantity
	,intShipmentType
	,strShipmentType
	,strContainerNumber
	,dtmStuffingDate
	,dtmETSPOL
	,dtmETAPOL
	,intWeekActETD
	,dtmETAPOD
	,intWeekActETA
	,strBookingReference
	,intLoadId
	,dtmDeadlineCargo
	,strETAPOLReasonCode
	,strETSPOLReasonCode
	,strETAPODReasonCode
	,strETAPOLReasonCodeDescription
	,strETSPOLReasonCodeDescription
	,strETAPODReasonCodeDescription
	,ysnDocsReceived
	,strVendorLotID
	,strContractItemName
	,strContractItemNo
	,strQualityApproval
	,ysnQtyReceived
	,dblAppliedQty
	,strRemark
	,dtmCreated
	,dtmUpdatedAvailabilityDate
	,strLocationName
	,dtmContractDate
	,strBundleItemNo
	,intHeaderBookId
	,intHeaderSubBookId
	,intDetailBookId
	,intDetailSubBookId
FROM vyuCTDashboardJDE

