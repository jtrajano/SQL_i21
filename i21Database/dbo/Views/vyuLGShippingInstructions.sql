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
FROM tblLGShippingInstruction SI
LEFT JOIN tblLGShipment SH ON SH.intShippingInstructionId = SI.intShippingInstructionId
LEFT JOIN tblEntity VEN ON VEN.intEntityId = SI.intVendorEntityId
LEFT JOIN tblEntity CEN ON CEN.intEntityId = SI.intCustomerEntityId
