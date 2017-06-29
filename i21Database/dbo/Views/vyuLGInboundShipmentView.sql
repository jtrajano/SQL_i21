CREATE VIEW vyuLGInboundShipmentView
AS
SELECT 
-- Starts from lower level (Containers)
		LDCL.intLoadDetailContainerLinkId,
		LDCL.intLoadDetailId,
		LDCL.intLoadId,
		LDCL.intLoadContainerId,
		L.strLoadNumber,
		L.strLoadNumber AS strTrackingNumber,
		L.intCompanyLocationId,
		CL.strLocationName,
		CY.strDescription as strCommodity,
		PO.strPosition,
		LD.intVendorEntityId,
		EY.strEntityName as strVendor,
		LD.intCustomerEntityId,
		Customer.strName as strCustomer,
		intWeightUOMId = L.intWeightUnitMeasureId,
		WTUOM.strUnitMeasure as strWeightUOM,
		CASE WHEN L.intSourceType = 3 THEN CAST (1 as Bit) ELSE CAST (0 as Bit) END AS ysnDirectShipment,
		CASE WHEN (IsNull((SELECT SUM (LD1.dblDeliveredQuantity) FROM tblLGLoadDetail LD1 Group By LD1.intLoadId Having LD1.intLoadId = LD.intLoadId), 0) > 0) THEN CAST (1 as Bit) ELSE CAST (0 as Bit) END AS ysnReceived,

---- Shipment details
		L.strOriginPort,
		L.strDestinationPort,
		L.strDestinationCity,
		L.intTerminalEntityId,
		Terminal.strName as strTerminal,
		L.intShippingLineEntityId,
		L.strMVessel,
		L.strMVoyageNumber,
		L.strFVessel,
		L.strFVoyageNumber,
		L.strPackingDescription,
		LW.intSubLocationId,
		SubLocation.strSubLocationName,
		L.strTruckNo,
		L.intForwardingAgentEntityId,
		FwdAgent.strName as strForwardingAgent,
		L.strForwardingAgentRef,
		L.dblInsuranceValue,
		L.intInsuranceCurrencyId,
		InsCur.strCurrency as strInsuranceCurrency,
		L.dtmDocsToBroker,
		L.dtmScheduledDate,
		CASE WHEN L.ysnPosted = 1 THEN CAST (1 as Bit) ELSE CAST (0 as Bit) END AS ysnInventorized,
		L.dtmPostedDate,
		L.dtmDocsReceivedDate,
		L.dtmETAPOL,
		L.dtmETSPOL,
		L.dtmETAPOD,
		L.dtmDispatchedDate,
		L.strComments,

---- Purchase Contract Details
		PCT.intContractDetailId,
		PCT.intContractHeaderId,
		PCH.strContractNumber,
		PCT.intContractSeq,
		strPContractNumber = CAST(PCH.strContractNumber as VARCHAR(100)) + '/' + CAST(PCT.intContractSeq AS VARCHAR(100)),
		PCT.dblCashPrice,
		dblCashPriceInQtyUOM = dbo.fnCTConvertQtyToTargetItemUOM(PCT.intItemUOMId,PCT.intPriceItemUOMId,PCT.dblCashPrice),
		CU.strCurrency,
		strPriceUOM = U2.strUnitMeasure,
		PCT.intItemId,
		PCT.intItemUOMId,
		IM.strItemNo,
		strItemDescription = IM.strDescription,
		IM.strLotTracking,
		strItemUOM = U1.strUnitMeasure,
		LD.dblQuantity as dblPurchaseContractShippedQty,
		LD.dblGross as dblPurchaseContractShippedGrossWt,
		LD.dblTare as dblPurchaseContractShippedTareWt,
		LD.dblNet as dblPurchaseContractShippedNetWt,
		IsNull(LD.dblDeliveredQuantity, 0) as dblPurchaseContractReceivedQty,
		PCH.intWeightId,
		IsNull(WG.dblFranchise, 0) as dblFranchise,
		PCT.dtmStartDate,
		PCT.dtmEndDate,
		CASE WHEN DATEDIFF (day, L.dtmPostedDate, PCT.dtmEndDate) >= 0 THEN
				CAST(1 as Bit)
			ELSE
				CAST (0 as Bit)
			END as ysnOnTime,

---- Sales Contract Details
		SCT.intContractDetailId AS intSContractDetailId,
		SCT.intContractHeaderId AS intSContractHeaderId,
		SCH.strContractNumber AS strSalesContractNumber,
		SCT.intContractSeq AS intSContractSeq,
		strSContractNumber = CAST(SCH.strContractNumber as VARCHAR(100)) + '/' + CAST(SCT.intContractSeq AS VARCHAR(100)),
		SCT.dblCashPrice AS dblSCashPrice,
		dblSCashPriceInQtyUOM = dbo.fnCTConvertQtyToTargetItemUOM(SCT.intItemUOMId,SCT.intPriceItemUOMId,SCT.dblCashPrice),
		CUS.strCurrency AS strSCurrency,
		SU2.strUnitMeasure AS strSPriceUOM,
		SCT.intItemId AS intSItemId,
		SCT.intItemUOMId AS intSItemUOMId,
		IMS.strItemNo AS strSItemNo,
		IMS.strDescription AS strSItemDescription,
		IMS.strLotTracking AS strSLotTracking,
		SU1.strUnitMeasure AS strSItemUOM ,
		LD.dblQuantity as dblSPurchaseContractShippedQty,
		LD.dblGross as dblSPurchaseContractShippedGrossWt,
		LD.dblTare as dblSPurchaseContractShippedTareWt,
		LD.dblNet as dblSPurchaseContractShippedNetWt,
		IsNull(LD.dblDeliveredQuantity, 0) as dblSPurchaseContractReceivedQty,
		SCH.intWeightId AS intSWeightId,
		IsNull(WG.dblFranchise, 0) as dblSFranchise,
		SCT.dtmStartDate AS dtmSStartDate,
		SCT.dtmEndDate AS dtmSEndDate,
		CASE WHEN DATEDIFF (day, L.dtmPostedDate, SCT.dtmEndDate) >= 0 THEN
				CAST(1 as Bit)
			ELSE
				CAST (0 as Bit)
			END as ysnSOnTime,

---- BL details
		L.strBLNumber,
		L.dtmBLDate,
		L.dblQuantity as dblBLQuantity,
		LD.dblGross as dblBLGrossWt,
		LD.dblTare as dblBLTareWt,
		LD.dblNet as dblBLNetWt,
		L.intUnitMeasureId as intBLUnitMeasureId,
		BLUOM.strUnitMeasure as strBLUnitMeasure,

---- Container details
		LC.strContainerNumber,
		LC.dblQuantity as dblContainerQty,
		LC.dblGrossWt as dblContainerGrossWt,
		LC.dblTareWt as dblContainerTareWt,
		LC.dblNetWt as dblContainerNetWt,
		CONTUOM.strUnitMeasure as strContainerUnitMeasure,
		LC.strLotNumber,
		LC.strMarks,
		LC.strOtherMarks,
		LC.strSealNumber,
		ContType.strContainerType,
		LC.dtmCustoms,
		LC.ysnCustomsHold,
		LC.strCustomsComments,
		LC.dtmFDA,
		LC.ysnFDAHold,
		LC.strFDAComments,
		LC.dtmFreight,
		LC.ysnDutyPaid,
		LC.strFreightComments,
		LC.dtmUSDA,
		LC.ysnUSDAHold,
		LC.strUSDAComments,

---- Container Contract Association Details
		ISNULL(LDCL.dblQuantity,LD.dblQuantity) as dblContainerContractQty,
		dblContainerContractGrossWt = (LC.dblGrossWt / LC.dblQuantity) * LDCL.dblQuantity,
		dblContainerContractTareWt = (LC.dblTareWt / LC.dblQuantity) * LDCL.dblQuantity,
		dblContainerContractlNetWt = (LC.dblNetWt / LC.dblQuantity) * LDCL.dblQuantity,	
		dblContainerWeightPerQty = (LC.dblNetWt / LC.dblQuantity),
		ISNULL(LDCL.dblReceivedQty,LD.dblDeliveredQuantity) as dblContainerContractReceivedQty,
		dblReceivedGrossWt = IsNull((SELECT sum(ICItem.dblGross) from tblICInventoryReceiptItem ICItem Group by ICItem.intSourceId, ICItem.intContainerId HAVING ICItem.intSourceId=LD.intLoadDetailId AND ICItem.intContainerId=LC.intLoadContainerId), 0),
		dblReceivedNetWt = IsNull((SELECT sum(ICItem.dblNet) from tblICInventoryReceiptItem ICItem Group by ICItem.intSourceId, ICItem.intContainerId HAVING ICItem.intSourceId=LD.intLoadDetailId AND ICItem.intContainerId=LC.intLoadContainerId), 0), 
		PCT.dblFutures, 
		PCT.dblBasis, 
		PCT.intPriceItemUOMId, 
		PCT.dblTotalCost

FROM tblLGLoad  L  --  tblLGShipmentBLContainerContract SC
JOIN tblLGLoadDetail LD ON  L.intLoadId = LD.intLoadId  --tblLGShipmentContractQty SCQ ON SCQ.intShipmentContractQtyId = SC.intShipmentContractQtyId
JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCT.intContractHeaderId
JOIN tblSMCompanyLocation CL ON	CL.intCompanyLocationId	= PCT.intCompanyLocationId
JOIN vyuCTEntity EY ON EY.intEntityId = PCH.intEntityId AND EY.strEntityType = (CASE WHEN PCH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
LEFT JOIN  tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId -- tblLGShipment S ON S.intShipmentId = SC.intShipmentId
LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = PCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = PCT.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem	IM ON IM.intItemId = PCT.intItemId
LEFT JOIN tblICCommodity CY ON CY.intCommodityId = PCH.intCommodityId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = PCH.intPositionId
LEFT JOIN tblSMCurrency	CU ON CU.intCurrencyID = PCT.intCurrencyId
LEFT JOIN tblCTContractDetail SCT ON SCT.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCT.intContractHeaderId
LEFT JOIN tblSMCurrency	CUS ON CUS.intCurrencyID = SCT.intCurrencyId
LEFT JOIN tblICItemUOM PUS ON PUS.intItemUOMId = SCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure SU2 ON SU2.intUnitMeasureId = PUS.intUnitMeasureId
LEFT JOIN tblICItem	IMS ON IMS.intItemId = SCT.intItemId
LEFT JOIN tblICItemUOM IUS ON IUS.intItemUOMId = SCT.intItemUOMId
LEFT JOIN tblICUnitMeasure SU1 ON SU1.intUnitMeasureId = IUS.intUnitMeasureId
LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId 
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