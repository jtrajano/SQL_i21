﻿CREATE VIEW [dbo].[vyuTRSupplyPointView]
	AS 

SELECT SupplyPoint.intSupplyPointId
	, SupplyPoint.intEntityVendorId
	, strFuelSupplier = Supplier.strName
	, SupplyPoint.intEntityLocationId
	, strSupplyPoint = EntityLocation.strLocationName
	, strZipCode = EntityLocation.strZipCode
	, strState = EntityLocation.strState
	, SupplyPoint.intTerminalControlNumberId
	, strTerminalNumber = Terminal.strTerminalControlNumber
	, SupplyPoint.strGrossOrNet
	, SupplyPoint.strFuelDealerId1
	, SupplyPoint.strFuelDealerId2
	, SupplyPoint.strDefaultOrigin
	, EntityLocation.intTaxGroupId
	, TaxGroup.strTaxGroup
	, SupplyPoint.ysnMultipleDueDates
	, SupplyPoint.ysnMultipleBolInvoiced
	, SupplyPoint.intRackPriceSupplyPointId
	, EntityLocation.ysnActive
FROM tblTRSupplyPoint SupplyPoint
LEFT JOIN vyuEMEntity Supplier ON Supplier.intEntityId = SupplyPoint.intEntityVendorId AND Supplier.strType = 'Vendor'
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = SupplyPoint.intEntityLocationId
LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = EntityLocation.intTaxGroupId
LEFT JOIN tblTFTerminalControlNumber Terminal ON Terminal.intTerminalControlNumberId = SupplyPoint.intTerminalControlNumberId