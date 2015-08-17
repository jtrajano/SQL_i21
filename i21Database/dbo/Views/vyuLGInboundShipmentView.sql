CREATE VIEW vyuLGInboundShipmentView
AS
SELECT 
-- Starts from lower level (Containers)
		SC.intShipmentBLContainerContractId,
		SC.intShipmentContractQtyId,
		SC.intShipmentId,
		SC.intShipmentBLId,
		SC.intShipmentBLContainerId,
		S.intTrackingNumber,
		S.intCompanyLocationId,
		CT.strLocationName,
		S.intCommodityId,
		CT.strCommodityDescription as strCommodity,
		CT.strPosition,
		S.intVendorEntityId,
		CT.strEntityName as strVendor,
		S.intCustomerEntityId,
		Customer.strName as strCustomer,
		intWeightUOMId = S.intWeightUnitMeasureId,
		WTUOM.strUnitMeasure as strWeightUOM,
		CASE WHEN S.ysnDirectShipment = 1 THEN 'Yes' ELSE 'No' END AS strDropShip,
		S.intShippingInstructionId,

-- Shipment details
		S.strOriginPort,
		S.strDestinationPort,
		S.strDestinationCity,
		S.intTerminalEntityId,
		Terminal.strName as strTerminal,
		S.intShippingLineEntityId,
		ShipLine.strName as strShippingLine,
		S.strMVessel,
		S.strMVoyageNumber,
		S.strFVessel,
		S.strFVoyageNumber,
		S.strPackingDescription,
		S.intSubLocationId,
		SubLocation.strSubLocationName,
		S.strTruckNumber,
		S.intForwardingAgentEntityId,
		FwdAgent.strName as strForwardingAgent,
		S.strForwardingAgentRef,
		S.dblInsuranceValue,
		S.intInsuranceCurrencyId,
		InsCur.strCurrency,
		S.dtmDocsToBroker,
		S.dtmShipmentDate,
		CASE WHEN S.ysnInventorized = 1 THEN 'Yes' ELSE 'No' END AS strInventorized,
		S.dtmInventorizedDate,
		S.dtmDocsReceivedDate,
		S.dtmETAPOL,
		S.dtmETSPOL,
		S.dtmETAPOD,
		S.dtmActualArrivalDate,
		S.dtmActualDischargeDate,
		S.strComments,

-- Purchase Contract Details
		CT.intContractDetailId,
		CT.intContractHeaderId,
		CT.strContractNumber,
		CT.intContractSeq,
		strPContractNumber = CAST(CT.strContractNumber as VARCHAR(100)) + '/' + CAST(CT.intContractSeq AS VARCHAR(100)),
		CT.intItemId,
		CT.intItemUOMId,
		CT.strItemNo,
		CT.strItemDescription,
		CT.strLotTracking,
		CT.strItemUOM,
		SCQ.dblQuantity as dblPurchaseContractShippedQty,
		SCQ.dblGrossWt as dblPurchaseContractShippedGrossWt,
		SCQ.dblTareWt as dblPurchaseContractShippedTareWt,
		SCQ.dblNetWt as dblPurchaseContractShippedNetWt,
		IsNull(SCQ.dblReceivedQty, 0) as dblPurchaseContractReceivedQty,

-- BL details
		BL.strBLNumber,
		BL.dtmBLDate,
		BL.dblQuantity as dblBLQuantity,
		BL.dblGrossWt as dblBLGrossWt,
		BL.dblTareWt as dblBLTareWt,
		BL.dblNetWt as dblBLNetWt,
		BL.intUnitMeasureId as intBLUnitMeasureId,
		BLUOM.strUnitMeasure as strBLUnitMeasure,

-- Container details
		Container.strContainerNumber,
		Container.dblQuantity as dblContainerQty,
		Container.dblGrossWt as dblContainerGrossWt,
		Container.dblTareWt as dblContainerTareWt,
		Container.dblNetWt as dblContainerNetWt,
		Container.intUnitMeasureId as intContUnitMeasureId,
		CONTUOM.strUnitMeasure as strContainerUnitMeasure,
		Container.strLotNumber,
		Container.strMarks,
		Container.strOtherMarks,
		Container.strSealNumber,
		ContType.strContainerType,
		Container.dtmCustoms,
		Container.ysnCustomsHold,
		Container.strCustomsComments,
		Container.dtmFDA,
		Container.ysnFDAHold,
		Container.strFDAComments,
		Container.dtmFreight,
		Container.ysnDutyPaid,
		Container.strFreightComments,
		Container.dtmUSDA,
		Container.ysnUSDAHold,
		Container.strUSDAComments,

-- Container Contract Association Details
		SC.dblQuantity as dblContainerContractQty,
		dblContainerContractGrossWt = (Container.dblGrossWt / Container.dblQuantity) * SC.dblQuantity,
		dblContainerContractTareWt = (Container.dblTareWt / Container.dblQuantity) * SC.dblQuantity,
		dbContainerContractlNetWt = (Container.dblNetWt / Container.dblQuantity) * SC.dblQuantity,	
		SC.dblReceivedQty as dblContainerContractReceivedQty

FROM tblLGShipmentBLContainerContract SC
JOIN tblLGShipmentContractQty SCQ ON SCQ.intShipmentContractQtyId = SC.intShipmentContractQtyId
JOIN tblLGShipment S ON S.intShipmentId = SC.intShipmentId
JOIN tblLGShipmentBL BL ON BL.intShipmentBLId = SC.intShipmentBLId
LEFT JOIN tblLGShipmentBLContainer Container ON Container.intShipmentBLContainerId = SC.intShipmentBLContainerId
LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = Container.intContainerTypeId
JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = SCQ.intContractDetailId
JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = S.intWeightUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = S.intSubLocationId
LEFT JOIN tblEntity Customer ON Customer.intEntityId = S.intCustomerEntityId
LEFT JOIN tblEntity Terminal ON Terminal.intEntityId = S.intTerminalEntityId
LEFT JOIN tblEntity ShipLine ON ShipLine.intEntityId = S.intShippingLineEntityId
LEFT JOIN tblEntity FwdAgent ON FwdAgent.intEntityId = S.intForwardingAgentEntityId
LEFT JOIN tblSMCurrency InsCur ON InsCur.intCurrencyID = S.intInsuranceCurrencyId
LEFT JOIN tblICUnitMeasure BLUOM ON BLUOM.intUnitMeasureId = BL.intUnitMeasureId
LEFT JOIN tblICUnitMeasure CONTUOM ON CONTUOM.intUnitMeasureId = Container.intUnitMeasureId

