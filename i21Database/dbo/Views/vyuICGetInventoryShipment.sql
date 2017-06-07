CREATE VIEW [dbo].[vyuICGetInventoryShipment]
AS 

SELECT 
	Shipment.intInventoryShipmentId
	, Shipment.strShipmentNumber
	, Shipment.dtmShipDate
	, Shipment.intOrderType
	, ShipmentLookUp.strOrderType 
	, Shipment.intSourceType
	, ShipmentLookUp.strSourceType 
	, Shipment.strReferenceNumber
	, Shipment.dtmRequestedArrivalDate

	-- Ship From Name and Address
	, Shipment.intShipFromLocationId
	, ShipmentLookUp.strShipFromLocation 
	, ShipmentLookUp.strShipFromStreet 
	, ShipmentLookUp.strShipFromCity 
	, ShipmentLookUp.strShipFromState 
	, ShipmentLookUp.strShipFromZipPostalCode 
	, ShipmentLookUp.strShipFromCountry 
	, ShipmentLookUp.strShipFromAddress 

	-- Ship To Name and Address
	, Shipment.intShipToCompanyLocationId
	, ShipmentLookUp.strShipToLocation 
	, ShipmentLookUp.strShipToStreet 
	, ShipmentLookUp.strShipToCity 
	, ShipmentLookUp.strShipToState 
	, ShipmentLookUp.strShipToZipPostalCode 
	, ShipmentLookUp.strShipToCountry 
	, ShipmentLookUp.strShipToAddress 

	, Shipment.intEntityCustomerId
	, ShipmentLookUp.strCustomerNumber
	, ShipmentLookUp.strCustomerName 
	, Shipment.intShipToLocationId
	, Shipment.intFreightTermId
	, ShipmentLookUp.strFreightTerm
	, ShipmentLookUp.strFobPoint
	, Shipment.strBOLNumber
	, Shipment.intShipViaId
	, ShipmentLookUp.strShipVia
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
	, ShipmentLookUp.intWarehouseInstructionHeaderId
	, Shipment.intCurrencyId
	, ShipmentLookUp.strCurrency

FROM	tblICInventoryShipment Shipment 
		INNER JOIN vyuICGetInventoryShipmentLookUp ShipmentLookUp
			ON Shipment.intInventoryShipmentId = ShipmentLookUp.intInventoryShipmentId
GO