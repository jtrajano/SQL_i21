CREATE VIEW vyuLGShipmentHeader
AS
SELECT 
		S.intShipmentId,
		S.intTrackingNumber,
		S.intCompanyLocationId,
		Comp.strLocationName,
		S.intCommodityId,
		Comm.strDescription as strCommodity,
		Pos.strPosition,
		S.intVendorEntityId,
		Vendor.strName as strVendor,
		S.intCustomerEntityId,
		Customer.strName as strCustomer,
		intWeightUOMId = S.intWeightUnitMeasureId,
		WTUOM.strUnitMeasure as strWeightUOM,
		CASE WHEN S.ysnDirectShipment = 1 THEN CAST (1 as Bit) ELSE CAST (0 as Bit) END AS ysnDirectShipment,
		S.intShippingInstructionId,

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
		CASE WHEN S.ysnInventorized = 1 THEN CAST (1 as Bit) ELSE CAST (0 as Bit) END AS ysnInventorized,
		S.dtmInventorizedDate,
		S.dtmDocsReceivedDate,
		S.dtmETAPOL,
		S.dtmETSPOL,
		S.dtmETAPOD,
		S.dtmActualArrivalDate,
		S.dtmActualDischargeDate,
		S.strComments,
		CASE WHEN (SELECT IsNull(SUM(SC.dblReceivedQty), 0) FROM tblLGShipmentContractQty SC GROUP BY SC.intShipmentId HAVING SC.intShipmentId = S.intShipmentId) > 0 THEN 
					CAST (1 as Bit) 
				ELSE 
					CAST (0 as Bit) 
				END AS ysnReceived


FROM tblLGShipment S 
JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = S.intWeightUnitMeasureId
LEFT JOIN tblSMCompanyLocation Comp ON Comp.intCompanyLocationId = S.intCompanyLocationId
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = S.intCommodityId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = S.intSubLocationId
LEFT JOIN tblCTPosition Pos ON Pos.intPositionId = S.intPositionId
LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = S.intVendorEntityId
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = S.intCustomerEntityId
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = S.intTerminalEntityId
LEFT JOIN tblEMEntity ShipLine ON ShipLine.intEntityId = S.intShippingLineEntityId
LEFT JOIN tblEMEntity FwdAgent ON FwdAgent.intEntityId = S.intForwardingAgentEntityId
LEFT JOIN tblSMCurrency InsCur ON InsCur.intCurrencyID = S.intInsuranceCurrencyId
