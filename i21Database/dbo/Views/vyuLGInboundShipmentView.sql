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
		PCT.strLocationName,
		PCT.strCommodityDescription as strCommodity,
		PCT.strPosition,
		LD.intVendorEntityId,
		PCT.strEntityName as strVendor,
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
		CASE WHEN L.ysnInventorized = 1 THEN CAST (1 as Bit) ELSE CAST (0 as Bit) END AS ysnInventorized,
		L.dtmInventorizedDate,
		L.dtmDocsReceivedDate,
		L.dtmETAPOL,
		L.dtmETSPOL,
		L.dtmETAPOD,
		L.dtmDispatchedDate,
		L.strComments,

---- Purchase Contract Details
		PCT.intContractDetailId,
		PCT.intContractHeaderId,
		PCT.strContractNumber,
		PCT.intContractSeq,
		strPContractNumber = CAST(PCT.strContractNumber as VARCHAR(100)) + '/' + CAST(PCT.intContractSeq AS VARCHAR(100)),
		PCT.dblCashPrice,
		PCT.dblCashPriceInQtyUOM,
		PCT.strCurrency,
		PCT.strPriceUOM,
		PCT.intItemId,
		PCT.intItemUOMId,
		PCT.strItemNo,
		PCT.strItemDescription,
		PCT.strLotTracking,
		PCT.strItemUOM,
		LD.dblQuantity as dblPurchaseContractShippedQty,
		LD.dblGross as dblPurchaseContractShippedGrossWt,
		LD.dblTare as dblPurchaseContractShippedTareWt,
		LD.dblNet as dblPurchaseContractShippedNetWt,
		IsNull(LD.dblDeliveredQuantity, 0) as dblPurchaseContractReceivedQty,
		PCT.intWeightId,
		IsNull(WG.dblFranchise, 0) as dblFranchise,
		PCT.dtmStartDate,
		PCT.dtmEndDate,
		CASE WHEN DATEDIFF (day, L.dtmInventorizedDate, PCT.dtmEndDate) >= 0 THEN
				CAST(1 as Bit)
			ELSE
				CAST (0 as Bit)
			END as ysnOnTime,

---- Sales Contract Details
		SCT.intContractDetailId AS intSContractDetailId,
		SCT.intContractHeaderId AS intSContractHeaderId,
		SCT.strContractNumber AS strSalesContractNumber,
		SCT.intContractSeq AS intSContractSeq,
		strSContractNumber = CAST(SCT.strContractNumber as VARCHAR(100)) + '/' + CAST(SCT.intContractSeq AS VARCHAR(100)),
		SCT.dblCashPrice AS dblSCashPrice,
		SCT.dblCashPriceInQtyUOM AS dblSCashPriceInQtyUOM,
		SCT.strCurrency AS strSCurrency,
		SCT.strPriceUOM AS strSPriceUOM,
		SCT.intItemId AS intSItemId,
		SCT.intItemUOMId AS intSItemUOMId,
		SCT.strItemNo AS strSItemNo,
		SCT.strItemDescription AS strSItemDescription,
		SCT.strLotTracking AS strSLotTracking,
		SCT.strItemUOM AS strSItemUOM ,
		LD.dblQuantity as dblSPurchaseContractShippedQty,
		LD.dblGross as dblSPurchaseContractShippedGrossWt,
		LD.dblTare as dblSPurchaseContractShippedTareWt,
		LD.dblNet as dblSPurchaseContractShippedNetWt,
		IsNull(LD.dblDeliveredQuantity, 0) as dblSPurchaseContractReceivedQty,
		SCT.intWeightId AS intSWeightId,
		IsNull(WG.dblFranchise, 0) as dblSFranchise,
		SCT.dtmStartDate AS dtmSStartDate,
		SCT.dtmEndDate AS dtmSEndDate,
		CASE WHEN DATEDIFF (day, L.dtmInventorizedDate, SCT.dtmEndDate) >= 0 THEN
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
		LDCL.dblQuantity as dblContainerContractQty,
		dblContainerContractGrossWt = (LC.dblGrossWt / LC.dblQuantity) * LDCL.dblQuantity,
		dblContainerContractTareWt = (LC.dblTareWt / LC.dblQuantity) * LDCL.dblQuantity,
		dblContainerContractlNetWt = (LC.dblNetWt / LC.dblQuantity) * LDCL.dblQuantity,	
		dblContainerWeightPerQty = (LC.dblNetWt / LC.dblQuantity),
		LDCL.dblReceivedQty as dblContainerContractReceivedQty,
		dblReceivedGrossWt = IsNull((SELECT sum(ICItem.dblGross) from tblICInventoryReceiptItem ICItem Group by ICItem.intSourceId, ICItem.intContainerId HAVING ICItem.intSourceId=LD.intLoadDetailId AND ICItem.intContainerId=LC.intLoadContainerId), 0),
		dblReceivedNetWt = IsNull((SELECT sum(ICItem.dblNet) from tblICInventoryReceiptItem ICItem Group by ICItem.intSourceId, ICItem.intContainerId HAVING ICItem.intSourceId=LD.intLoadDetailId AND ICItem.intContainerId=LC.intLoadContainerId), 0)
FROM tblLGLoadDetailContainerLink LDCL --  tblLGShipmentBLContainerContract SC
JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId--tblLGShipmentContractQty SCQ ON SCQ.intShipmentContractQtyId = SC.intShipmentContractQtyId
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId -- tblLGShipment S ON S.intShipmentId = SC.intShipmentId
JOIN vyuCTContractDetailView PCT ON PCT.intContractDetailId = LD.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SCT ON SCT.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId --tblLGShipmentBLContainer Container ON Container.intShipmentBLContainerId = SC.intShipmentBLContainerId
LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = PCT.intWeightId
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