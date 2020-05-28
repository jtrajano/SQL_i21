CREATE VIEW vyuLGInboundShipmentView
AS
SELECT 
	-- Starts from lower level (Containers)
	intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId,
	intLoadDetailId = LDCL.intLoadDetailId,
	intLoadId = L.intLoadId,
	intLoadContainerId = LDCL.intLoadContainerId,
	strLoadNumber = L.strLoadNumber,
	strTrackingNumber = L.strLoadNumber,
	intCompanyLocationId = L.intCompanyLocationId,
	strLocationName = CL.strLocationName,
	strCommodity = CY.strDescription,
	strPosition = PO.strPosition,
	intVendorEntityId = LD.intVendorEntityId,
	strVendor = V.strName,
	intCustomerEntityId = LD.intCustomerEntityId,
	strCustomer = Customer.strName,
	intWeightUOMId = L.intWeightUnitMeasureId,
	strWeightUOM = WTUOM.strUnitMeasure,
	ysnDirectShipment = CAST(CASE WHEN L.intSourceType = 3 THEN 1 ELSE 0 END AS BIT),
	ysnReceived = CAST(CASE WHEN EXISTS(SELECT TOP 1 LD1.dblDeliveredQuantity FROM tblLGLoadDetail LD1 
									WHERE LD1.intLoadId = LD.intLoadId AND LD1.dblDeliveredQuantity > 0) THEN 1 ELSE 0 END AS BIT),

	---- Shipment details
	strOriginPort = L.strOriginPort,
	strDestinationPort = L.strDestinationPort,
	strDestinationCity = L.strDestinationCity,
	intTerminalEntityId = L.intTerminalEntityId,
	strTerminal = Terminal.strName,
	intShippingLineEntityId = L.intShippingLineEntityId,
	strShippingLine = ShipLine.strName,
	strMVessel = L.strMVessel,
	strMVoyageNumber = L.strMVoyageNumber,
	strFVessel = L.strFVessel,
	strFVoyageNumber = L.strFVoyageNumber,
	strPackingDescription = L.strPackingDescription,
	intStorageLocationId = LW.intStorageLocationId,
	intSubLocationId = LW.intSubLocationId,
	strSubLocationName = SubLocation.strSubLocationName,
	dtmLastFreeDate = LW.dtmLastFreeDate,
	dtmEmptyContainerReturn = LW.dtmEmptyContainerReturn,
	strTruckNo = L.strTruckNo,
	intForwardingAgentEntityId = L.intForwardingAgentEntityId,
	strForwardingAgent = FwdAgent.strName,
	strForwardingAgentRef = L.strForwardingAgentRef,
	dblInsuranceValue = L.dblInsuranceValue,
	intInsuranceCurrencyId = L.intInsuranceCurrencyId,
	strInsuranceCurrency = InsCur.strCurrency,
	dtmDocsToBroker = L.dtmDocsToBroker,
	dtmScheduledDate = L.dtmScheduledDate,
	ysnInventorized = L.ysnPosted,
	dtmPostedDate = L.dtmPostedDate,
	dtmDocsReceivedDate = L.dtmDocsReceivedDate,
	dtmETAPOL = L.dtmETAPOL,
	dtmETSPOL = L.dtmETSPOL,
	dtmETAPOD = L.dtmETAPOD,
	dtmDispatchedDate = L.dtmDispatchedDate,
	strComments = L.strComments,

	---- Purchase Contract Details
	intContractDetailId = PCT.intContractDetailId,
	intContractHeaderId = PCT.intContractHeaderId,
	strContractNumber = PCH.strContractNumber,
	strContractBasis = CB.strContractBasis,
	strTerm = TRM.strTerm,
	strPricingType = PT.strPricingType,
	intContractSeq = PCT.intContractSeq,
	strPContractNumber = CAST(PCH.strContractNumber as VARCHAR(100)) + '/' + CAST(PCT.intContractSeq AS VARCHAR(100)),
	dblCashPrice = CASE WHEN (PCT.dblCashPrice IS NOT NULL) THEN PCT.dblCashPrice ELSE dbo.fnCTGetSequencePrice(PCT.intContractDetailId,NULL) END,
	dblCashPriceInQtyUOM = dbo.fnCTConvertQtyToTargetItemUOM(PCT.intItemUOMId,PCT.intPriceItemUOMId,PCT.dblCashPrice),
	strCurrency = CUR.strCurrency,
	strPriceUOM = U2.strUnitMeasure,
	intItemId = PCT.intItemId,
	intItemUOMId = PCT.intItemUOMId,
	strItemNo = IM.strItemNo,
	strItemDescription = IM.strDescription,
	strItemSpecification = PCT.strItemSpecification,
	strType = IM.strType,
	strOrigin = CYO.strDescription,
	strGrade = CYG.strDescription,
	strLotTracking = IM.strLotTracking,
	strBundleItemNo = BNDL.strItemNo,
	strItemUOM = U1.strUnitMeasure,
	dblPurchaseContractOriginalQty = PCT.dblQuantity,
	strPurchaseContractOriginalUOM = U3.strUnitMeasure,
	dblPurchaseContractShippedQty = LD.dblQuantity,
	dblPurchaseContractShippedGrossWt = LD.dblGross,
	dblPurchaseContractShippedTareWt = LD.dblTare,
	dblPurchaseContractShippedNetWt = LD.dblNet,
	dblPurchaseContractReceivedQty = IsNull(LD.dblDeliveredQuantity, 0),
	intWeightId = PCH.intWeightId,
	dblFranchise = IsNull(WG.dblFranchise, 0),
	dtmStartDate = PCT.dtmStartDate,
	dtmEndDate = PCT.dtmEndDate,
	ysnOnTime = CAST(CASE WHEN DATEDIFF (DAY, L.dtmPostedDate, PCT.dtmEndDate) >= 0 THEN 1 ELSE 0 END as Bit),

	---- Sales Contract Details
	intSContractDetailId = SCT.intContractDetailId,
	intSContractHeaderId = SCT.intContractHeaderId,
	strSalesContractNumber = SCH.strContractNumber,
	strSalesContractBasis = SCB.strContractBasis,
	strSalesPricingType = SPT.strPricingType,
	intSContractSeq = SCT.intContractSeq,
	strSContractNumber = CAST(SCH.strContractNumber as VARCHAR(100)) + '/' + CAST(SCT.intContractSeq AS VARCHAR(100)),
	dblSCashPrice = CASE WHEN (SCT.dblCashPrice IS NOT NULL) THEN SCT.dblCashPrice ELSE dbo.fnCTGetSequencePrice(SCT.intContractDetailId,NULL) END,
	dblSCashPriceInQtyUOM = dbo.fnCTConvertQtyToTargetItemUOM(SCT.intItemUOMId,SCT.intPriceItemUOMId,SCT.dblCashPrice),
	strSCurrency = SCUR.strCurrency,
	strSPriceUOM = SU2.strUnitMeasure,
	intSItemId = SCT.intItemId,
	intSItemUOMId = SCT.intItemUOMId,
	strSItemNo = IMS.strItemNo,
	strSItemDescription = IMS.strDescription,
	strSType = IMS.strType,
	strSOrigin = SCO.strDescription,
	strSGrade = SCG.strDescription,
	strSLotTracking = IMS.strLotTracking,
	strSItemUOM = SU1.strUnitMeasure,
	dblSPurchaseContractOriginalQty = SCT.dblQuantity,
	strSPurchaseContractOriginalUOM = SU3.strUnitMeasure,
	dblSPurchaseContractShippedQty = LD.dblQuantity,
	dblSPurchaseContractShippedGrossWt = LD.dblGross,
	dblSPurchaseContractShippedTareWt = LD.dblTare,
	dblSPurchaseContractShippedNetWt = LD.dblNet,
	dblSPurchaseContractReceivedQty = IsNull(LD.dblDeliveredQuantity, 0),
	intSWeightId = SCH.intWeightId,
	dblSFranchise = IsNull(WG.dblFranchise, 0),
	dtmSStartDate = SCT.dtmStartDate,
	dtmSEndDate = SCT.dtmEndDate,
	ysnSOnTime = CAST(CASE WHEN DATEDIFF (day, L.dtmPostedDate, SCT.dtmEndDate) >= 0 THEN 1 ELSE 0 END as Bit),

	---- BL details
	strBLNumber = L.strBLNumber,
	dtmBLDate = L.dtmBLDate,
	dblBLQuantity = LD.dblQuantity,
	dblBLGrossWt = LD.dblGross,
	dblBLTareWt = LD.dblTare,
	dblBLNetWt = LD.dblNet,
	intBLUnitMeasureId = L.intUnitMeasureId,
	strBLUnitMeasure = BLUOM.strUnitMeasure,

	-- IR Details
	strReceiptNumber = IR.strReceiptNumber,
	dtmReceiptDate = IR.dtmReceiptDate,
	strReceiptLocationName = IR.strLocationName,

	-- Container details
	strContainerNumber = LC.strContainerNumber,
	dblContainerQty = LC.dblQuantity,
	dblContainerGrossWt = LC.dblGrossWt,
	dblContainerTareWt = LC.dblTareWt,
	dblContainerNetWt = LC.dblNetWt,
	strContainerUnitMeasure = CONTUOM.strUnitMeasure,
	strLotNumber = LC.strLotNumber,
	strMarks = LC.strMarks,
	strOtherMarks = LC.strOtherMarks,
	strSealNumber = LC.strSealNumber,
	strContainerType = ContType.strContainerType,
	dtmCustoms = LC.dtmCustoms,
	ysnCustomsHold = LC.ysnCustomsHold,
	strCustomsComments = LC.strCustomsComments,
	dtmFDA = LC.dtmFDA,
	ysnFDAHold = LC.ysnFDAHold,
	strFDAComments = LC.strFDAComments,
	dtmFreight = LC.dtmFreight,
	ysnDutyPaid = LC.ysnDutyPaid,
	strFreightComments = LC.strFreightComments,
	dtmUSDA = LC.dtmUSDA,
	ysnUSDAHold = LC.ysnUSDAHold,
	strUSDAComments = LC.strUSDAComments,

	---- Container Contract Association Details
	dblContainerContractQty = ISNULL(LDCL.dblQuantity,LD.dblQuantity),
	dblContainerContractGrossWt = (LC.dblGrossWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END) * LDCL.dblQuantity,
	dblContainerContractTareWt = (LC.dblTareWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END) * LDCL.dblQuantity,
	dblContainerContractlNetWt = (LC.dblNetWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END) * LDCL.dblQuantity,	
	dblContainerWeightPerQty = (LC.dblNetWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END),
	dblContainerContractReceivedQty = CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(LDCL.dblReceivedQty, 0) ELSE LD.dblDeliveredQuantity END,
	dblReceivedGrossWt = IsNull(IRW.dblReceivedGrossWt, 0),
	dblReceivedNetWt = IsNull(IRW.dblReceivedNetWt, 0),
	
	dblFutures = PCT.dblFutures, 
	dblBasis = PCT.dblBasis, 
	strPriceBasis = CAST(BCUR.strCurrency as VARCHAR(100)) + '/' + CAST(U4.strUnitMeasure as VARCHAR(100)),

	intPriceItemUOMId = PCT.intPriceItemUOMId, 
	dblTotalCost = PCT.dblTotalCost,
	intWeightItemUOMId = LD.intWeightItemUOMId,
	intBookId = L.intBookId, 
	strBook = BO.strBook,
	intSubBookId = L.intSubBookId, 
	strSubBook = SB.strSubBook,
	intCropYear = PCH.intCropYearId,
	strCropYear = CRY.strCropYear,
	strProducer = PRO.strName,
	strCertification = CER.strCertificationName, 
	strCertificationId = '' COLLATE Latin1_General_CI_AS

FROM tblLGLoad L
INNER JOIN tblLGLoadDetail LD ON  L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1 AND ISNULL(L.ysnCancelled, 0) <> 1
INNER JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId
INNER JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCT.intContractHeaderId
INNER JOIN tblSMCompanyLocation CL ON	CL.intCompanyLocationId	= PCT.intCompanyLocationId
INNER JOIN tblEMEntity V ON V.intEntityId = PCH.intEntityId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
LEFT JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityUnitMeasureId = PCH.intCommodityUOMId
LEFT JOIN tblICUnitMeasure U3 ON U3.intUnitMeasureId = CU.intUnitMeasureId
LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = PCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = PCT.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem	IM ON IM.intItemId = PCT.intItemId
LEFT JOIN tblICCommodity CY ON CY.intCommodityId = PCH.intCommodityId
LEFT JOIN tblICCommodityAttribute CYO ON CYO.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblICCommodityAttribute CYG ON CYG.intCommodityAttributeId = IM.intGradeId
LEFT JOIN tblICItem BNDL ON BNDL.intItemId = PCT.intItemBundleId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = PCH.intPositionId
LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = PCH.intFreightTermId
LEFT JOIN tblSMTerm TRM ON TRM.intTermID = PCH.intTermId
LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = PCH.intPricingTypeId
LEFT JOIN tblSMCurrency	CUR ON CUR.intCurrencyID = PCT.intCurrencyId
LEFT JOIN tblSMCurrency	BCUR ON BCUR.intCurrencyID = PCT.intBasisCurrencyId
LEFT JOIN tblICItemUOM BU ON BU.intItemUOMId = PCT.intBasisUOMId
LEFT JOIN tblICUnitMeasure U4 ON U4.intUnitMeasureId = BU.intUnitMeasureId
LEFT JOIN tblCTContractDetail SCT ON SCT.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCT.intContractHeaderId
LEFT JOIN tblSMCurrency	SCUR ON SCUR.intCurrencyID = SCT.intCurrencyId
LEFT JOIN tblICCommodityUnitMeasure SCU ON SCU.intCommodityUnitMeasureId = SCH.intCommodityUOMId
LEFT JOIN tblICUnitMeasure SU3 ON SU3.intUnitMeasureId = SCU.intUnitMeasureId
LEFT JOIN tblICItemUOM PUS ON PUS.intItemUOMId = SCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure SU2 ON SU2.intUnitMeasureId = PUS.intUnitMeasureId
LEFT JOIN tblICItem	IMS ON IMS.intItemId = SCT.intItemId
LEFT JOIN tblICCommodityAttribute SCO ON SCO.intCommodityAttributeId = IMS.intOriginId
LEFT JOIN tblICCommodityAttribute SCG ON SCG.intCommodityAttributeId = IMS.intGradeId
LEFT JOIN tblICItemUOM IUS ON IUS.intItemUOMId = SCT.intItemUOMId
LEFT JOIN tblICUnitMeasure SU1 ON SU1.intUnitMeasureId = IUS.intUnitMeasureId
LEFT JOIN tblSMFreightTerms SCB ON SCB.intFreightTermId = SCH.intFreightTermId
LEFT JOIN tblCTPricingType SPT ON SPT.intPricingTypeId = SCH.intPricingTypeId
LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId AND ISNULL(LC.ysnRejected, 0) <> 1
LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = PCH.intWeightId
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity ShipLine ON ShipLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity FwdAgent ON FwdAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblSMCurrency InsCur ON InsCur.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblICUnitMeasure BLUOM ON BLUOM.intUnitMeasureId = L.intUnitMeasureId
LEFT JOIN tblICUnitMeasure CONTUOM ON CONTUOM.intUnitMeasureId = L.intUnitMeasureId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblEMEntity PRO ON PRO.intEntityId = PCT.intProducerId
LEFT JOIN tblCTCropYear CRY ON CRY.intCropYearId = PCH.intCropYearId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
OUTER APPLY (SELECT TOP 1 CER.strCertificationName 
				FROM tblCTContractCertification CC JOIN tblICCertification CER ON CER.intCertificationId = CC.intCertificationId 
				WHERE CC.intContractDetailId = PCT.intContractDetailId) CER
OUTER APPLY (SELECT TOP 1 R.strReceiptNumber, R.dtmReceiptDate, RL.strLocationName 
			FROM tblICInventoryReceiptItem RI
				INNER JOIN tblICInventoryReceipt R ON RI.intInventoryReceiptId = R.intInventoryReceiptId
				LEFT JOIN tblSMCompanyLocation RL ON RL.intCompanyLocationId = R.intLocationId 
			WHERE intSourceId = LD.intLoadDetailId AND intSourceType = 2 
			AND (LDCL.intLoadDetailContainerLinkId IS NULL 
				OR (LDCL.intLoadDetailContainerLinkId IS NOT NULL AND RI.intContainerId = LC.intLoadContainerId))) IR
OUTER APPLY (SELECT dblReceivedGrossWt = SUM(ICItem.dblGross), dblReceivedNetWt = SUM(ICItem.dblNet) FROM tblICInventoryReceiptItem ICItem 
			WHERE ICItem.intSourceId=LD.intLoadDetailId AND ICItem.intContainerId=LC.intLoadContainerId) IRW

GO