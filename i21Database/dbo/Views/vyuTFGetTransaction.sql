CREATE VIEW [dbo].[vyuTFGetTransaction]
	AS
	
SELECT Trans.intTransactionId
	, Trans.uniqTransactionGuid
	, Trans.intReportingComponentId
	, RC.intTaxAuthorityId
	, RC.strTaxAuthorityCode
	, RC.strFormCode
	, RC.strFormName
	, RC.strScheduleCode
	, RC.strScheduleName
	, Trans.intProductCodeId
	, PC.strProductCode
	, strProductCodeDescription = PC.strDescription
	, Trans.strTaxCode
	, Trans.strType
	, Trans.strDescription
	, Item.strItemNo
	, Trans.strBillOfLading
	, Trans.intItemId
	, Trans.dblReceived
	, Trans.dblGross
	, Trans.dblNet
	, Trans.dblBillQty
	, Trans.dblTax
	, Trans.dblTaxExempt
	, Trans.strInvoiceNumber
	, Trans.dblQtyShipped
	, Trans.strPONumber
	, Trans.strBOLNumber
	, Trans.strTerminalControlNumber
	, Trans.dtmDate
	, Trans.strShipToCity
	, Trans.strShipToState
	, Trans.strSupplierName
	, Trans.strItem
	, Trans.dtmLastRun
	, Trans.dtmReportingPeriodBegin
	, Trans.dtmReportingPeriodEnd
	, Trans.strLicenseNumber
	, Trans.strEmail
	, Trans.strFEINSSN
	, Trans.strCity
	, Trans.strState
	, Trans.strZipCode
	, Trans.strTelephoneNumber
	, Trans.strContactName
	, Trans.strShipVia
	, Trans.strTransporterName
	, Trans.strTransportationMode
	, Trans.strTransporterFederalTaxId
	, Trans.strTransporterLicense
	, Trans.strCustomerName
	, Trans.strCustomerFederalTaxId
	, Trans.strVendorName
	, Trans.strVendorFederalTaxId
	, Trans.strVendorLicenseNumber
	, Trans.strConsignorName
	, Trans.strConsignorFederalTaxId
	, Trans.strDestinationState
	, Trans.strDestinationCity
	, Trans.strDestinationTCN
	, Trans.strOriginState
	, Trans.strOriginCity
	, Trans.strOriginTCN
	, Trans.strFuelType
	, Trans.strTaxPayerName
	, Trans.strTaxPayerIdentificationNumber
	, Trans.strTaxPayerFEIN
	, Trans.strTaxPayerDBA
	, Trans.strTaxPayerAddress
	, Trans.intIntegrationError
	, Trans.leaf
FROM tblTFTransaction Trans
LEFT JOIN vyuTFGetReportingComponent RC ON RC.intReportingComponentId = Trans.intReportingComponentId
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = Trans.intProductCodeId
LEFT JOIN tblICItem Item ON Item.intItemId = Trans.intItemId