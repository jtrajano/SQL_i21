CREATE VIEW [dbo].[vyuICGetInventoryShipment]
	AS 

SELECT Shipment.intInventoryShipmentId
, Shipment.strShipmentNumber
, Shipment.dtmShipDate
, Shipment.intOrderType
, strOrderType = (CASE WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
					WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
					WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
					WHEN Shipment.intOrderType = 4 THEN 'Direct'
				END)
, Shipment.intSourceType
, strSourceType = (CASE WHEN Shipment.intSourceType = 1 THEN 'Scale'
					WHEN Shipment.intSourceType = 2 THEN 'Inbound Shipment'
					WHEN Shipment.intSourceType = 3 THEN 'Pick Lot'
					WHEN Shipment.intSourceType = 0 THEN 'None'
				END)
, Shipment.strReferenceNumber
, Shipment.dtmRequestedArrivalDate
, Shipment.intShipFromLocationId
, strShipFromLocation = Location.strLocationName
, strShipFromAddress = Location.strAddress
, Shipment.intEntityCustomerId
, Customer.strCustomerNumber
, strCustomerName = Customer.strName
, Shipment.intShipToLocationId
, strShipToLocation = ShipToLocation.strLocationName
, strShipToAddress = ShipToLocation.strAddress
, Shipment.intFreightTermId
, FreightTerm.strFreightTerm
, FreightTerm.strFobPoint
, Shipment.strBOLNumber
, Shipment.intShipViaId
, ShipVia.strShipVia
, Shipment.strVessel
, Shipment.strProNumber
, Shipment.strDriverId
, Shipment.strSealNumber
, Shipment.strDeliveryInstruction
, Shipment.dtmAppointmentTime
, Shipment.dtmDepartureTime
, Shipment.dtmArrivalTime
, Shipment.dtmDeliveredDate
, Shipment.dtmFreeTime
, Shipment.strReceivedBy
, Shipment.strComment
, Shipment.ysnPosted

FROM tblICInventoryShipment Shipment
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Shipment.intShipFromLocationId
	LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = Shipment.intEntityCustomerId
	LEFT JOIN tblEntityLocation ShipToLocation ON ShipToLocation.intEntityLocationId = Shipment.intShipToLocationId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.intEntityShipViaId = Shipment.intShipViaId
	LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Shipment.intFreightTermId