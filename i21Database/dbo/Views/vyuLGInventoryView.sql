CREATE VIEW vyuLGInventoryView
AS 
SELECT TOP 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY strStatus)) as intKeyColumn,*  
FROM (
	SELECT
		strStatus = CASE WHEN (CP.ysnIncludeStrippingInstructionStatus = 1 AND Shipment.intStorageLocationId IS NOT NULL) 
							THEN 'Stripping Instruction Created' 
						 WHEN (CP.ysnIncludeArrivedInPortStatus = 1 AND Shipment.ysnArrivedInPort = 1) 
							THEN 'Arrived in Port'
						ELSE 'In-transit' END COLLATE Latin1_General_CI_AS
		,strContractNumber = Shipment.strContractNumber
		,intContractSeq = Shipment.intContractSeq
		,intContractDetailId = Shipment.intContractDetailId
		,dtmStartDate = Shipment.dtmStartDate
		,dtmEndDate = Shipment.dtmEndDate
		,dblOriginalQty = Shipment.dblPurchaseContractOriginalQty
		,strOriginalQtyUOM = Shipment.strPurchaseContractOriginalUOM
		,dblStockQty = Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)
		,strStockUOM = Shipment.strItemUOM
		,dblNetWeight = CASE WHEN IsNull(Shipment.dblContainerContractReceivedQty, 0) > 0
							THEN CASE 
									WHEN ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0) = 0
										THEN Shipment.dblBLNetWt
									ELSE ((ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)) / ISNULL(Shipment.dblContainerContractQty, 1)) * (ISNULL(Shipment.dblContainerContractQty, 0) - ISNULL(Shipment.dblContainerContractReceivedQty, 0))
									END
							ELSE CASE 
									WHEN ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0) = 0
										THEN Shipment.dblBLNetWt
									ELSE ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)
									END
							END
		,strWeightUOM = Shipment.strWeightUOM
		,intVendorEntityId = Shipment.intVendorEntityId
		,strVendor = Shipment.strVendor
		,intCustomerEntityId = Shipment.intCustomerEntityId
		,strCustomer = Shipment.strCustomer
		,strCommodity = Shipment.strCommodity
		,strItemNo = Shipment.strItemNo
		,strItemDescription = Shipment.strItemDescription
		,strItemType = Shipment.strType
		,strItemSpecification = Shipment.strItemSpecification
		,strBundleItemNo = Shipment.strBundleItemNo
		,strGrade = Shipment.strGrade
		,strOrigin = Shipment.strOrigin
		,strVessel = Shipment.strMVessel
		,strDestinationCity = Shipment.strDestinationCity
		,dtmETAPOL = Shipment.dtmETAPOL
		,dtmETSPOL = Shipment.dtmETSPOL
		,dtmETAPOD = Shipment.dtmETAPOD
		,dtmUpdatedAvailabilityDate = Shipment.dtmUpdatedAvailabilityDate
		,strTrackingNumber = '' COLLATE Latin1_General_CI_AS
		,strBLNumber = Shipment.strBLNumber
		,dtmBLDate = Shipment.dtmBLDate
		,strContainerNumber = Shipment.strContainerNumber
		,strMarks = Shipment.strMarks
		,strLotNumber = '' COLLATE Latin1_General_CI_AS
		,strLotAlias = '' COLLATE Latin1_General_CI_AS
		,strWarrantNo = '' COLLATE Latin1_General_CI_AS
		,strWarrantStatus = '' COLLATE Latin1_General_CI_AS
		,strWarehouse = Shipment.strSubLocationName
		,strLocationName = Shipment.strLocationName
		,strCondition = '' COLLATE Latin1_General_CI_AS
		,dtmPostedDate = Shipment.dtmPostedDate
		,dblQtyInStockUOM = (Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)) * dbo.fnICConvertUOMtoStockUnit (Shipment.intItemId, Shipment.intItemUOMId, 1)
		,intItemId = Shipment.intItemId
		,intWeightItemUOMId = (SELECT U.intItemUOMId FROM tblICItemUOM U WHERE U.intItemId = Shipment.intItemId AND U.intUnitMeasureId=Shipment.intWeightUOMId)
		,strWarehouseRefNo = '' COLLATE Latin1_General_CI_AS
		,dtmReceiptDate = CAST(NULL AS DATETIME)
		,dblTotalCost = CAST(ISNULL(((dbo.fnCTConvertQtyToTargetItemUOM(Shipment.intWeightItemUOMId, 
												Shipment.intPriceItemUOMId, 
												CASE 
												WHEN ISNULL(Shipment.dblContainerContractReceivedQty, 0) > 0
													THEN ((ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)) / ISNULL(Shipment.dblContainerContractQty, 1)) * (ISNULL(Shipment.dblContainerContractQty, 0) - ISNULL(Shipment.dblContainerContractReceivedQty, 0))
												ELSE ISNULL(Shipment.dblContainerContractGrossWt, 0) - ISNULL(Shipment.dblContainerContractTareWt, 0)
												END)
						) * Shipment.dblCashPrice)/ (CASE WHEN ISNULL(Shipment.ysnSubCurrency,0) = 1 THEN 100 ELSE 1 END),0) AS NUMERIC(18,6))
		,dblFutures = Shipment.dblFutures
		,dblCashPrice = Shipment.dblCashPrice
		,dblBasis = Shipment.dblBasis
		,strPricingType = Shipment.strPricingType
		,strPriceBasis = Shipment.strPriceBasis
		,strINCOTerm = Shipment.strContractBasis
		,strTerm = Shipment.strTerm
		,strExternalShipmentNumber = Shipment.strExternalShipmentNumber
		,strERPPONumber = Shipment.strERPPONumber
		,strPosition = Shipment.strPosition
		,intLoadId = Shipment.intLoadId
		,intCompanyLocationId = Shipment.intCompanyLocationId
		,intBookId = Shipment.intBookId
		,strBook = Shipment.strBook
		,intSubBookId = Shipment.intSubBookId
		,strSubBook = Shipment.strSubBook
		,intCropYear = Shipment.intCropYear
		,strCropYear = Shipment.strCropYear
		,strProducer = Shipment.strProducer
		,strCertification = Shipment.strCertification
		,strCertificationId = Shipment.strCertificationId
		,strCertificateName = CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
		,strIRCropYear = CAST(NULL AS NVARCHAR(30)) COLLATE Latin1_General_CI_AS
	FROM vyuLGInboundShipmentView Shipment
		OUTER APPLY (SELECT ysnIncludeArrivedInPortStatus, ysnIncludeStrippingInstructionStatus FROM tblLGCompanyPreference) CP
	WHERE (Shipment.dblContainerContractQty - IsNull(Shipment.dblContainerContractReceivedQty, 0.0)) > 0.0 
	   AND Shipment.ysnInventorized = 1

	UNION ALL

	SELECT 
		'Spot' COLLATE Latin1_General_CI_AS AS strStatus
		,strContractNumber = Spot.strContractNumber
		,intContractSeq = Spot.intContractSeq
		,intContractDetailId = Spot.intContractDetailId
		,dtmStartDate = Spot.dtmStartDate
		,dtmEndDate = Spot.dtmEndDate
		,dblOriginalQty = Spot.dblOriginalQty
		,strOriginalQtyUOM = Spot.strOriginalQtyUOM
		,dblStockQty = Spot.dblQty
		,strStockUOM = Spot.strItemUOM
		,dblNetWeightFull = Spot.dblNetWeightFull
		,strWeightUOM = Spot.strWeightUOM
		,intEntityVendorId = Spot.intEntityVendorId
		,strVendor = Spot.strVendor
		,intCustomerEntityId = Spot.intCustomerEntityId
		,strCustomer = Spot.strCustomer
		,strCommodity = Spot.strCommodity
		,strItemNo = Spot.strItemNo
		,strItemDescription = Spot.strItemDescription
		,strItemType = Spot.strItemType
		,strItemSpecification = Spot.strItemSpecification
		,strBundleItemNo = Spot.strBundleItemNo
		,strGrade = Spot.strGrade
		,strOrigin = Spot.strOrigin
		,strVessel = '' COLLATE Latin1_General_CI_AS
		,strDestinationCity = '' COLLATE Latin1_General_CI_AS
		,dtmETAPOL = CAST(NULL AS DATETIME)
		,dtmETSPOL = CAST(NULL AS DATETIME)
		,dtmETAPOD = CAST(NULL AS DATETIME)
		,dtmUpdatedAvailabilityDate = CAST(NULL AS DATETIME)
		,strTrackingNumber = Spot.strLoadNumber
		,strBLNumber = Spot.strBLNumber
		,dtmBLDate = Spot.dtmBLDate
		,strContainerNumber = Spot.strContainerNumber
		,strMarks = Spot.strMarkings
		,strLotNumber = Spot.strLotNumber
		,strLotAlias = Spot.strLotAlias
		,strWarrantNo = Spot.strWarrantNo
		,strWarrantStatus = Spot.strWarrantStatus
		,strWarehouse = Spot.strSubLocationName
		,strLocationName = Spot.strLocationName
		,strCondition = Spot.strCondition
		,dtmPostedDate = Spot.dtmPostedDate
		,dblQtyInStockUOM = Spot.dblQty * dbo.fnICConvertUOMtoStockUnit (Spot.intItemId, Spot.intItemUOMId, 1)
		,intItemId = Spot.intItemId
		,intWeightItemUOMId = Spot.intItemWeightUOMId
		,strWarehouseRefNo = Spot.strWarehouseRefNo
		,dtmReceiptDate = Spot.dtmReceiptDate
		,dblTotalCost = CAST(ISNULL(((dbo.fnCTConvertQtyToTargetItemUOM(Spot.intWeightItemUOMId, 
												Spot.intPriceItemUOMId, Spot.dblNetWeight )
						) * Spot.dblCashPrice)/ (CASE WHEN CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) = 0 THEN 1 ELSE 100 END),0) AS NUMERIC(18,6))
		,dblFutures = Spot.dblFutures
		,dblCashPrice = Spot.dblCashPrice
		,dblBasis = Spot.dblBasis
		,strPricingType = Spot.strPricingType
		,strPriceBasis = Spot.strPriceBasis
		,strINCOTerm = Spot.strContractBasis
		,strTerm = Spot.strTerm
		,strExternalShipmentNumber = Spot.strExternalShipmentNumber
		,strERPPONumber = CD.strERPPONumber
		,strPosition = Spot.strPosition
		,intLoadId = Spot.intLoadId
		,intCompanyLocationId = CD.intCompanyLocationId
		,intBookId = Spot.intBookId
		,strBook = Spot.strBook
		,intSubBookId = Spot.intSubBookId
		,strSubBook = Spot.strSubBook
		,intCropYear = Spot.intCropYear
		,strCropYear = Spot.strCropYear
		,strProducer = Spot.strProducer
		,strCertification = Spot.strCertification
		,strCertificationId = Spot.strCertificationId
		,strCertificateName = IRIL.strCertificate
		,strIRCropYear = CRY.strCropYear
	FROM vyuLGPickOpenInventoryLots Spot
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = Spot.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId			
	LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId
	LEFT JOIN tblCTCropYear CRY ON CRY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemLotId = Spot.intInventoryReceiptItemLotId
	WHERE Spot.dblQty > 0.0

	UNION ALL

	--Drop Ship
	SELECT 
		'In-transit' COLLATE Latin1_General_CI_AS AS strStatus
		,strContractNumber = PCH.strContractNumber
		,intContractSeq = PCD.intContractSeq
		,intContractDetailId = PCD.intContractDetailId
		,dtmStartDate = PCD.dtmStartDate
		,dtmEndDate = PCD.dtmEndDate
		,dblOriginalQty = PCD.dblOriginalQty
		,strOriginalQtyUOM = PUM.strUnitMeasure
		,dblStockQty = ISNULL(LDCL.dblQuantity, LD.dblQuantity)
		,strStockUOM = LDUM.strUnitMeasure
		,dblNetWeight = ISNULL(LDCL.dblLinkNetWt, LD.dblNet)
		,strWeightUOM = LDWUM.strUnitMeasure
		,intEntityVendorId = LD.intVendorEntityId
		,strVendor = V.strName
		,intCustomerEntityId = LD.intCustomerEntityId
		,strCustomer = C.strName
		,strCommodity = CMDT.strCommodityCode
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,strItemType = I.strType
		,strItemSpecification = PCD.strItemSpecification
		,strBundleItemNo = PBun.strItemNo
		,strGrade = GRADE.strDescription
		,strOrigin = ORIGIN.strDescription
		,strVessel = L.strMVessel
		,strDestinationCity = L.strDestinationCity
		,dtmETAPOL = L.dtmETAPOL
		,dtmETSPOL = L.dtmETSPOL
		,dtmETAPOD = L.dtmETAPOD
		,dtmUpdatedAvailabilityDate = PCD.dtmUpdatedAvailabilityDate
		,strTrackingNumber = L.strLoadNumber
		,strBLNumber = L.strBLNumber
		,dtmBLDate = L.dtmBLDate
		,strContainerNumber = LC.strContainerNumber
		,strMarks = LC.strMarks
		,strLotNumber = LC.strLotNumber
		,strLotAlias = '' COLLATE Latin1_General_CI_AS
		,strWarrantNo = '' COLLATE Latin1_General_CI_AS
		,strWarrantStatus = '' COLLATE Latin1_General_CI_AS
		,strWarehouse = '' COLLATE Latin1_General_CI_AS
		,strLocationName = '' COLLATE Latin1_General_CI_AS
		,strCondition = '' COLLATE Latin1_General_CI_AS
		,dtmPostedDate = L.dtmPostedDate
		,dblQtyInStockUOM = ISNULL(LDCL.dblLinkNetWt, LD.dblNet) * dbo.fnICConvertUOMtoStockUnit (I.intItemId, LD.intItemUOMId, 1)
		,intItemId = I.intItemId
		,intWeightItemUOMId = LD.intWeightItemUOMId
		,strWarehouseRefNo = '' COLLATE Latin1_General_CI_AS
		,dtmReceiptDate = CAST(NULL AS DATETIME)
		,dblTotalCost = CAST(ISNULL((dbo.fnCTConvertQtyToTargetItemUOM(ISNULL(LCWUM.intWeightItemUOMId, LD.intWeightItemUOMId), PCD.intPriceItemUOMId, ISNULL(LDCL.dblLinkNetWt, LD.dblNet))) 
										* ISNULL(AD.dblSeqPrice, AD.dblSeqPartialPrice),0) AS NUMERIC(18,6)) / CASE WHEN (BC.ysnSubCurrency = 1) THEN BC.intCent ELSE 1 END
		,dblFutures = PCD.dblFutures
		,dblCashPrice = ISNULL(AD.dblSeqPrice, AD.dblSeqPartialPrice)
		,dblBasis = PCD.dblBasis
		,strPricingType = CASE WHEN PCH.intPricingTypeId = 2 
							THEN  CASE WHEN ISNULL(PF.dblTotalLots,0) > 0 AND ISNULL(PF.dblLotsFixed,0) = 0 THEN 'Unfixed'
										WHEN ISNULL(PF.dblTotalLots,0) = ISNULL(PF.dblLotsFixed,0) THEN 'Fully Fixed'
										ELSE 'Partially Fixed' END
							WHEN PCH.intPricingTypeId = 1 THEN 'Priced'
							ELSE '' END COLLATE Latin1_General_CI_AS
		,strPriceBasis = CAST(BC.strCurrency as VARCHAR(100)) + '/' + CAST(BUM.strUnitMeasure as VARCHAR(100))
		,strINCOTerm = CB.strContractBasis
		,strTerm = Term.strTerm
		,strExternalShipmentNumber = L.strExternalShipmentNumber
		,strERPPONumber = PCD.strERPPONumber
		,strPosition = PO.strPosition
		,intLoadId = L.intLoadId
		,intCompanyLocationId = PCD.intCompanyLocationId
		,intBookId = L.intBookId
		,strBook = BK.strBook
		,intSubBookId = L.intSubBookId
		,strSubBook = SBK.strBook
		,intCropYear = PCH.intCropYearId
		,strCropYear = CRY.strCropYear
		,strProducer = PRO.strName
		,strCertification = CER.strCertificationName
		,strCertificationId = '' COLLATE Latin1_General_CI_AS
		,strCertificateName = NULL
		,strIRCropYear = NULL
	FROM tblLGLoadDetail LD
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		OUTER APPLY (SELECT TOP 1 strContainerNumber, strMarks, strLotNumber, intWeightUnitMeasureId FROM tblLGLoadContainer WHERE intLoadContainerId = LDCL.intLoadContainerId) LC
		OUTER APPLY (SELECT TOP 1 intWeightItemUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = I.intItemId AND intUnitMeasureId = LC.intWeightUnitMeasureId) LCWUM
		LEFT JOIN tblICItemUOM LDUOM ON LDUOM.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICUnitMeasure LDUM ON LDUM.intUnitMeasureId = LDUOM.intUnitMeasureId 
		LEFT JOIN tblICItemUOM LDWUOM ON LDWUOM.intItemUOMId = LD.intWeightItemUOMId
		LEFT JOIN tblICUnitMeasure LDWUM ON LDWUM.intUnitMeasureId = LDWUOM.intUnitMeasureId
		LEFT JOIN tblICCommodity CMDT ON CMDT.intCommodityId = I.intCommodityId
		LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = I.intGradeId
		LEFT JOIN tblICCommodityAttribute ORIGIN ON ORIGIN.intCommodityAttributeId = I.intOriginId
		LEFT JOIN tblCTPosition PO ON PO.intPositionId = L.intPositionId
		LEFT JOIN tblCTBook BK ON BK.intBookId = L.intBookId
		LEFT JOIN tblCTBook SBK ON SBK.intBookId = L.intSubBookId
		--Purchase
		INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
		INNER JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		INNER JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = PCD.intContractDetailId
		LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = PCD.intUnitMeasureId
		LEFT JOIN tblEMEntity V ON V.intEntityId = LD.intVendorEntityId
		LEFT JOIN tblSMCurrency BC ON BC.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM BIU ON BIU.intItemUOMId = PCD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure BUM ON BUM.intUnitMeasureId = BIU.intUnitMeasureId
		LEFT JOIN tblICItem PBun ON PBun.intItemId = PCD.intItemBundleId
		LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = PCH.intContractBasisId
		LEFT JOIN tblCTCropYear CRY ON CRY.intCropYearId = PCH.intCropYearId
		LEFT JOIN tblEMEntity PRO ON PRO.intEntityId = PCH.intProducerId
		LEFT JOIN tblSMTerm Term ON Term.intTermID = PCH.intTermId
		OUTER APPLY fnCTGetSeqPriceFixationInfo(PCD.intContractDetailId) PF
		OUTER APPLY (SELECT TOP 1 CER.strCertificationName FROM tblCTContractCertification CC 
					JOIN tblICCertification CER ON CER.intCertificationId = CC.intCertificationId 
					WHERE CC.intContractDetailId = PCD.intContractDetailId) CER
		--Sales
		INNER JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
		INNER JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblEMEntity C ON C.intEntityId = LD.intCustomerEntityId
		LEFT JOIN tblARInvoiceDetail ID ON SCD.intContractDetailId = ID.intContractDetailId AND LD.intLoadDetailId = ID.intLoadDetailId
		LEFT JOIN tblARInvoice IV ON IV.intInvoiceId = ID.intInvoiceId

	WHERE L.intPurchaseSale = 3 AND L.ysnPosted = 1
		AND IV.strInvoiceNumber IS NULL
		AND LD.intPickLotDetailId IS NULL

	UNION ALL

	--Open
	SELECT 
		'Open' COLLATE Latin1_General_CI_AS AS strStatus
		,strContractNumber = PCH.strContractNumber
		,intContractSeq = PCD.intContractSeq
		,intContractDetailId = PCD.intContractDetailId
		,dtmStartDate = PCD.dtmStartDate
		,dtmEndDate = PCD.dtmEndDate
		,dblOriginalQty = PCD.dblOriginalQty
		,strOriginalQtyUOM = PUM.strUnitMeasure
		,dblStockQty = (ISNULL(PCD.dblBalance,0) - ISNULL(InTrans.dblInTransitQty, 0))
		,strStockUOM = IUM.strUnitMeasure
		,dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(PCD.intItemUOMId, ISNULL(PCD.intNetWeightUOMId, PCD.intItemUOMId), (ISNULL(PCD.dblBalance,0) - ISNULL(InTrans.dblInTransitQty, 0)))
		,strWeightUOM = WUM.strUnitMeasure
		,intEntityVendorId = PCH.intEntityId
		,strVendor = V.strName
		,intCustomerEntityId = NULL
		,strCustomer = NULL
		,strCommodity = CMDT.strCommodityCode
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,strItemType = I.strType
		,strItemSpecification = PCD.strItemSpecification
		,strBundleItemNo = PBun.strItemNo
		,strGrade = GRADE.strDescription
		,strOrigin = ORIGIN.strDescription
		,strVessel = PCD.strVessel
		,strDestinationCity = DC.strCity
		,dtmETAPOL = NULL
		,dtmETSPOL = NULL
		,dtmETAPOD = PCD.dtmUpdatedAvailabilityDate
		,dtmUpdatedAvailabilityDate = PCD.dtmUpdatedAvailabilityDate
		,strTrackingNumber = NULL
		,strBLNumber = NULL
		,dtmBLDate = NULL
		,strContainerNumber = NULL
		,strMarks = NULL
		,strLotNumber = NULL
		,strLotAlias = NULL
		,strWarrantNo = NULL
		,strWarrantStatus = NULL
		,strWarehouse = WH.strSubLocationName
		,strLocationName = WHU.strName
		,strCondition = '' COLLATE Latin1_General_CI_AS
		,dtmPostedDate = NULL
		,dblQtyInStockUOM = (ISNULL(PCD.dblBalance,0) - ISNULL(InTrans.dblInTransitQty, 0)) * dbo.fnICConvertUOMtoStockUnit (I.intItemId, PCD.intItemUOMId, 1)
		,intItemId = I.intItemId
		,intWeightItemUOMId = PCD.intNetWeightUOMId
		,strWarehouseRefNo = '' COLLATE Latin1_General_CI_AS
		,dtmReceiptDate = CAST(NULL AS DATETIME)
		,dblTotalCost = CAST(ISNULL((dbo.fnCTConvertQtyToTargetItemUOM(ISNULL(PCD.intNetWeightUOMId, PCD.intItemUOMId), PCD.intPriceItemUOMId, (ISNULL(PCD.dblBalance,0) - ISNULL(InTrans.dblInTransitQty, 0)))) 
										* dbo.fnCTGetSequencePrice(PCD.intContractDetailId,NULL),0) AS NUMERIC(18,6)) / CASE WHEN (BC.ysnSubCurrency = 1) THEN BC.intCent ELSE 1 END
		,dblFutures = PCD.dblFutures
		,dblCashPrice = PCD.dblCashPrice
		,dblBasis = PCD.dblBasis
		,strPricingType = CASE WHEN PCH.intPricingTypeId = 2 
							THEN  CASE WHEN ISNULL(PF.dblTotalLots,0) > 0 AND ISNULL(PF.dblLotsFixed,0) = 0 THEN 'Unfixed'
										WHEN ISNULL(PF.dblTotalLots,0) = ISNULL(PF.dblLotsFixed,0) THEN 'Fully Fixed'
										ELSE 'Partially Fixed' END
							WHEN PCH.intPricingTypeId = 1 THEN 'Priced'
							ELSE '' END COLLATE Latin1_General_CI_AS
		,strPriceBasis = CAST(BC.strCurrency as VARCHAR(100)) + '/' + CAST(BUM.strUnitMeasure as VARCHAR(100))
		,strINCOTerm = CB.strContractBasis
		,strTerm = Term.strTerm
		,strExternalShipmentNumber = NULL
		,strERPPONumber = PCD.strERPPONumber
		,strPosition = PO.strPosition
		,intLoadId = NULL
		,intCompanyLocationId = PCD.intCompanyLocationId
		,intBookId = PCH.intBookId
		,strBook = BK.strBook
		,intSubBookId = PCH.intSubBookId
		,strSubBook = SBK.strSubBook
		,intCropYear = PCH.intCropYearId
		,strCropYear = CRY.strCropYear
		,strProducer = PRO.strName
		,strCertification = CER.strCertificationName
		,strCertificationId = '' COLLATE Latin1_General_CI_AS
		,strCertificateName = NULL
		,strIRCropYear = NULL
	FROM 
		tblCTContractDetail PCD
		INNER JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		LEFT JOIN tblICItem I ON I.intItemId = PCD.intItemId
		LEFT JOIN tblICCommodity CMDT ON CMDT.intCommodityId = I.intCommodityId
		LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = I.intGradeId
		LEFT JOIN tblICCommodityAttribute ORIGIN ON ORIGIN.intCommodityAttributeId = I.intOriginId
		LEFT JOIN tblCTPosition PO ON PO.intPositionId = PCH.intPositionId
		LEFT JOIN tblSMCity DC ON DC.intCityId = PCH.intINCOLocationTypeId
		LEFT JOIN tblSMCompanyLocationSubLocation WH ON WH.intCompanyLocationSubLocationId = PCD.intSubLocationId
		LEFT JOIN tblICStorageLocation WHU ON WHU.intStorageLocationId = PCD.intStorageLocationId
		LEFT JOIN tblCTBook BK ON BK.intBookId = PCH.intBookId
		LEFT JOIN tblCTSubBook SBK ON SBK.intSubBookId = PCH.intSubBookId
		LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = PCD.intUnitMeasureId
		LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = PCD.intItemUOMId 
		LEFT JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = PCD.intNetWeightUOMId
		LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity V ON V.intEntityId = PCH.intEntityId
		LEFT JOIN tblSMCurrency BC ON BC.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM BIU ON BIU.intItemUOMId = PCD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure BUM ON BUM.intUnitMeasureId = BIU.intUnitMeasureId
		LEFT JOIN tblICItem PBun ON PBun.intItemId = PCD.intItemBundleId
		LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = PCH.intFreightTermId
		LEFT JOIN tblCTCropYear CRY ON CRY.intCropYearId = PCH.intCropYearId
		LEFT JOIN tblEMEntity PRO ON PRO.intEntityId = PCH.intProducerId
		LEFT JOIN tblSMTerm Term ON Term.intTermID = PCH.intTermId
		OUTER APPLY fnCTGetSeqPriceFixationInfo(PCD.intContractDetailId) PF
		OUTER APPLY (SELECT TOP 1 CER.strCertificationName FROM tblCTContractCertification CC 
					JOIN tblICCertification CER ON CER.intCertificationId = CC.intCertificationId 
					WHERE CC.intContractDetailId = PCD.intContractDetailId) CER
		OUTER APPLY (SELECT dblInTransitQty = SUM(LD.dblQuantity - ISNULL(LD.dblDeliveredQuantity, 0))
						FROM tblLGLoadDetail LD
						INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
						INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
					WHERE L.ysnPosted = 1 AND ISNULL(L.ysnCancelled, 0) = 0
						AND LD.intPContractDetailId = PCD.intContractDetailId
						AND L.intPurchaseSale = 1
						AND LD.dblQuantity - ISNULL(LD.dblDeliveredQuantity, 0) > 0) InTrans
	WHERE (ISNULL(PCD.dblBalance,0) - ISNULL(InTrans.dblInTransitQty, 0)) > 0
		AND PCH.intContractTypeId = 1 AND PCD.intContractStatusId IN (1, 4)
		AND EXISTS (SELECT 1 FROM tblLGCompanyPreference WHERE ysnIncludeOpenContractsOnInventoryView = 1)
	) t1