﻿PRINT 'START TF Schedule Field Template'

IF NOT EXISTS(SELECT TOP 1 1 FROM [tblTFScheduleFieldTemplate])
BEGIN
	PRINT 'START TF tblTFScheduleFieldTemplate'

		INSERT INTO [tblTFScheduleFieldTemplate]
		(
			[intReportingComponentDetailId],[strColumn],[intConcurrencyId]
		)
		VALUES
		 (0, N'strCustomerName', 0)
		,(0, N'strCustomerFederalTaxId', 0)
		,(0, N'strVendorName', 0)
		,(0, N'strVendorFederalTaxId', 0)
		,(0, N'strVendorName', 0)
		,(0, N'strVendorFederalTaxId', 0)
		,(0, N'strVendorLicenseNumber', 0)
		,(0, N'strTransporterName', 0)
		,(0, N'strTransporterFederalTaxId', 0)
		,(0, N'strTransporterLicense', 0)
		,(0, N'strTransportationMode', 0)
		,(0, N'strOriginState', 0)
		,(0, N'strOriginCity', 0)
		,(0, N'strOriginTCN', 0)
		,(0, N'strDestinationState', 0)
		,(0, N'strDestinationCity', 0)
		,(0, N'strDestinationTCN', 0)
		,(0, N'strShipVia', 0)
		,(0, N'strZipCode', 0)
		,(0, N'strTaxPayerName', 0)
		,(0, N'strEmail', 0)
		,(0, N'strFEINSSN', 0)
		,(0, N'strContactName', 0)
		,(0, N'strTelephoneNumber', 0)
		,(0, N'strProductCode', 0)
		,(0, N'strProductCodeDescription', 0)
		,(0, N'strItemNo', 0)
		,(0, N'strItem', 0)
		,(0, N'strType', 0)
		,(0, N'strDescription', 0)
		,(0, N'intItemId', 0)
		,(0, N'strBillOfLading', 0)
		,(0, N'strFuelType', 0)
		,(0, N'dblReceived', 0)
		,(0, N'dblNet', 0)
		,(0, N'dblGross', 0)
		,(0, N'dblTax', 0)
		,(0, N'dblBillQty', 0)
		,(0, N'strInvoiceNumber', 0)
		,(0, N'strPONumber', 0)
		,(0, N'strBOLNumber', 0)
		,(0, N'strSupplierName', 0)
		,(0, N'strTaxCode', 0)
		,(0, N'dtmDate', 0)
		,(0, N'dtmDateReceived', 0)
		,(0, N'dtmReportingPeriodBegin', 0)
		,(0, N'dtmReportingPeriodEnd', 0)
		,(0, N'dblQtyShipped', 0)
		,(0, N'strScheduleCode', 0)
		,(0, N'strScheduleName', 0)
		,(0, N'dblTaxExempt', 0)
	
	PRINT 'START TF tblTFScheduleFieldTemplate'
END
PRINT 'END TF Schedule Field Template'