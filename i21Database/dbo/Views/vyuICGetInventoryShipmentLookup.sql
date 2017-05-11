CREATE VIEW [dbo].[vyuICGetInventoryShipmentLookUp]
	AS 

SELECT 

Shipment.intInventoryShipmentId
, strOrderType = (CASE WHEN Shipment.intOrderType = 1 THEN 'Sales Contract'
					WHEN Shipment.intOrderType = 2 THEN 'Sales Order'
					WHEN Shipment.intOrderType = 3 THEN 'Transfer Order'
					WHEN Shipment.intOrderType = 4 THEN 'Direct'
				END) COLLATE Latin1_General_CI_AS
, strSourceType = (CASE WHEN Shipment.intSourceType = 1 THEN 'Scale'
					WHEN Shipment.intSourceType = 2 THEN 'Inbound Shipment'
					WHEN Shipment.intSourceType = 3 THEN 'Pick Lot'
					WHEN Shipment.intSourceType = 0 THEN 'None'
				END) COLLATE Latin1_General_CI_AS

-- Ship From Name and Address
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
		COLLATE Latin1_General_CI_AS

-- Ship To Name and Address
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
		COLLATE Latin1_General_CI_AS
, strCustomerNumber = Customer.strCustomerNumber
, strCustomerName = Customer.strName
, FreightTerm.strFreightTerm
, FreightTerm.strFobPoint
, ShipVia.strShipVia
, WarehouseInstruction.intWarehouseInstructionHeaderId
, Currency.strCurrency

FROM 
	tblICInventoryShipment Shipment
	LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = Shipment.intEntityCustomerId
	LEFT JOIN [tblEMEntityLocation] ShipToLocation ON ShipToLocation.intEntityLocationId = Shipment.intShipToLocationId
	LEFT JOIN tblSMCompanyLocation ShipToCompanyLocation ON ShipToCompanyLocation.intCompanyLocationId = Shipment.intShipToCompanyLocationId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.[intEntityId] = Shipment.intShipViaId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Shipment.intCurrencyId
	LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Shipment.intFreightTermId
	LEFT JOIN tblSMCompanyLocation ShipFromLocation ON ShipFromLocation.intCompanyLocationId = Shipment.intShipFromLocationId
	OUTER APPLY (
		SELECT	TOP 1 
				intWarehouseInstructionHeaderId 
		FROM	tblLGWarehouseInstructionHeader 
		WHERE	tblLGWarehouseInstructionHeader.intInventoryShipmentId = Shipment.intInventoryShipmentId
	) WarehouseInstruction


GO