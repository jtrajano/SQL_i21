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
				END) COLLATE Latin1_General_CI_AS
, Shipment.intSourceType
, strSourceType = (CASE WHEN Shipment.intSourceType = 1 THEN 'Scale'
					WHEN Shipment.intSourceType = 2 THEN 'Inbound Shipment'
					WHEN Shipment.intSourceType = 3 THEN 'Pick Lot'
					WHEN Shipment.intSourceType = 0 THEN 'None'
				END) COLLATE Latin1_General_CI_AS
, Shipment.strReferenceNumber
, Shipment.dtmRequestedArrivalDate

-- Ship From Name and Address
, Shipment.intShipFromLocationId
, strShipFromLocation = ShipFromLocation.strLocationName
, strShipFromStreet = ShipFromLocation.strAddress
, strShipFromCity = ShipFromLocation.strCity
, strShipFromState = ShipFromLocation.strStateProvince
, strShipFromZipPostalCode = ShipFromLocation.strZipPostalCode
, strShipFromCountry = ShipFromLocation.strCountry
-- Ship From Complete Address
, strShipFromAddress = [dbo].[fnARFormatCustomerAddress](
			DEFAULT
			,DEFAULT 
			,DEFAULT 
			,ShipFromLocation.strAddress
			,ShipFromLocation.strCity
			,ShipFromLocation.strStateProvince
			,ShipFromLocation.strZipPostalCode
			,ShipFromLocation.strCountry
			,DEFAULT 
			,DEFAULT 
		)
-- Ship To Name and Address
, Shipment.intShipToCompanyLocationId
, strShipToLocation = CASE WHEN Shipment.intOrderType = 3  THEN ShipToCompanyLocation.strLocationName ELSE ShipToLocation.strLocationName END 
, strShipToStreet = CASE WHEN Shipment.intOrderType = 3  THEN ShipToCompanyLocation.strAddress ELSE ShipToLocation.strAddress END 
, strShipToCity = CASE WHEN Shipment.intOrderType = 3  THEN ShipToCompanyLocation.strCity ELSE ShipToLocation.strCity END
, strShipToState = CASE WHEN Shipment.intOrderType = 3  THEN ShipToCompanyLocation.strStateProvince ELSE ShipToLocation.strState END
, strShipToZipPostalCode = CASE WHEN Shipment.intOrderType = 3  THEN ShipToCompanyLocation.strZipPostalCode ELSE ShipToLocation.strZipCode END
, strShipToCountry = CASE WHEN Shipment.intOrderType = 3  THEN ShipToCompanyLocation.strCountry ELSE ShipToLocation.strCountry END
-- Ship To Complete Address
, strShipToAddress = 
		CASE	WHEN Shipment.intOrderType = 3 THEN -- Transfer Order
					[dbo].[fnARFormatCustomerAddress](
						DEFAULT
						,DEFAULT 
						,DEFAULT 
						,ShipToCompanyLocation.strAddress
						,ShipToCompanyLocation.strCity
						,ShipToCompanyLocation.strStateProvince
						,ShipToCompanyLocation.strZipPostalCode
						,ShipToCompanyLocation.strCountry
						,DEFAULT 
						,DEFAULT 
					)
				ELSE 

					[dbo].[fnARFormatCustomerAddress](
						DEFAULT
						,DEFAULT 
						,DEFAULT 
						,ShipToLocation.strAddress
						,ShipToLocation.strCity
						,ShipToLocation.strState
						,ShipToLocation.strZipCode
						,ShipToLocation.strCountry
						,DEFAULT 
						,DEFAULT 
					)
				END 
, Shipment.intEntityCustomerId
, Customer.strCustomerNumber
, strCustomerName = Customer.strName
, Shipment.intShipToLocationId
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
, WarehouseInstruction.intWarehouseInstructionHeaderId
, strCompanyName = CASE WHEN Location.strUseLocationAddress = 'Letterhead' THEN '' ELSE (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup) END
, CASE WHEN Location.strUseLocationAddress IS NULL OR
          Location.strUseLocationAddress = 'No' OR
          Location.strUseLocationAddress = '' OR
          Location.strUseLocationAddress = 'Always' 
	 THEN 
          (SELECT
				CASE 
					WHEN strAddress IS NULL OR strAddress = ' '
					THEN ''
					ELSE strAddress 
				 END + 
				 CASE 
					WHEN strCity IS NULL OR strCity = ' '
					THEN ''
					WHEN strAddress IS NULL OR strAddress = ' '
					THEN strCity
					ELSE', ' + strCity 
				 END + 
				 CASE 
					WHEN strState IS NULL OR strState = ' '
					THEN ''
					ELSE ', ' + strState 
				 END + 
				 CASE
					WHEN strZip IS NULL OR strZip = ' '
					THEN ''
					ELSE ', ' + strZip 
				 END + 
				 CASE 
					WHEN strCountry IS NULL OR strCountry = ' '
					THEN ''
					ELSE ', ' + strCountry
				 END
		   FROM    tblSMCompanySetup) 
	WHEN Location.strUseLocationAddress = 'Yes' 
	THEN 
	CASE 
					WHEN Location.strAddress IS NULL OR Location.strAddress = ' '
					THEN ''
					ELSE Location.strAddress 
				 END + 
				 CASE 
					WHEN Location.strCity IS NULL OR Location.strCity = ' '
					THEN ''
					WHEN Location.strAddress IS NULL OR Location.strAddress = ' '
					THEN Location.strCity
					ELSE', ' + Location.strCity 
				 END + 
				 CASE 
					WHEN Location.strStateProvince IS NULL OR Location.strStateProvince = ' '
					THEN ''
					ELSE ', ' + Location.strStateProvince 
				 END + 
				 CASE
					WHEN Location.strZipPostalCode IS NULL OR Location.strZipPostalCode = ' '
					THEN ''
					ELSE ', ' + Location.strZipPostalCode 
				 END + 
				 CASE 
					WHEN Location.strCountry IS NULL OR Location.strCountry = ' '
					THEN ''
					ELSE ', ' + Location.strCountry
				 END
	
	WHEN Location.strUseLocationAddress = 'Letterhead' 
	THEN '' END AS strCompanyAddress
	, Shipment.intCurrencyId
	, Currency.strCurrency
FROM tblICInventoryShipment Shipment
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Shipment.intShipFromLocationId
	LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = Shipment.intEntityCustomerId	
	LEFT JOIN [tblEMEntityLocation] ShipToLocation ON ShipToLocation.intEntityLocationId = Shipment.intShipToLocationId
	LEFT JOIN tblSMCompanyLocation ShipToCompanyLocation ON ShipToCompanyLocation.intCompanyLocationId = Shipment.intShipToCompanyLocationId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.[intEntityId] = Shipment.intShipViaId
	LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Shipment.intFreightTermId
	LEFT JOIN tblLGWarehouseInstructionHeader WarehouseInstruction ON WarehouseInstruction.intInventoryShipmentId = Shipment.intInventoryShipmentId
	LEFT JOIN tblSMCompanyLocation ShipFromLocation ON ShipFromLocation.intCompanyLocationId = Shipment.intShipFromLocationId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Shipment.intCurrencyId
GO