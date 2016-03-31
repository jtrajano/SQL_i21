CREATE VIEW vyuLGShippingInstructions
AS   
SELECT
	SI.intShippingInstructionId
	, SI.intReferenceNumber
	, SI.dtmSIDate
	, SI.dtmShipmentDate
	, SI.strBookingNumber
	, SI.dtmBookingDate
	, SI.intVendorEntityId
	, SI.intCustomerEntityId
	, VEN.strName as strVendor
	, CEN.strName as strCustomer
	, IsNull(SH.intShipmentId, -1) as intShipmentId
	, SH.intTrackingNumber
	, SI.strPackingDescription
	, SI.strOriginPort
	, SI.strDestinationPort
	, SI.intNumberOfContainers
	, SI.intContainerTypeId
	, SI.intShippingLineEntityId
	, SI.strMarks
	, SI.dtmETAPOL
	, SI.dtmETAPOD
	, SI.dtmETSPOL
	, SI.intForwardingAgentEntityId
	, SI.strVessel
	, SI.strVoyageNumber

FROM tblLGShippingInstruction SI
LEFT JOIN tblLGShipment SH ON SH.intShippingInstructionId = SI.intShippingInstructionId
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = SI.intVendorEntityId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = SI.intCustomerEntityId
