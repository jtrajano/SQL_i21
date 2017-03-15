CREATE VIEW [dbo].[vyuTFGetTransaction]
	AS
	
SELECT Trans.intTransactionId
	, Trans.uniqTransactionGuid
	, Trans.intReportingComponentId
	, RC.intTaxAuthorityId
	, RC.strTaxAuthorityCode
	, strFormCode = CASE WHEN RC.strFormCode IS NULL THEN Trans.strFormCode ELSE RC.strFormCode END
	, RC.strFormName
	, RC.strScheduleCode
	, RC.strScheduleName
	, intProductCodeId = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.intProductCodeId ELSE Exception.intProductCodeId END
	, strProductCode = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strProductCode ELSE Exception.strProductCode END
	, strProductCodeDescription = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strDescription ELSE Exception.strProductCodeDescription END
	, strTaxCode = Trans.strTaxCode --CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTaxCode ELSE Exception.strTaxCode END
	, strType = Trans.strType --CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strType ELSE Exception.strType END
	, strDescription = Trans.strDescription --CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strDescription ELSE Exception.strDescription END
	, strItemNo = Item.strItemNo --CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Item.strItemNo ELSE Exception.strItemNo END
	, strBillOfLading = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strBillOfLading ELSE Exception.strBillOfLading END
	, intItemId = Trans.intItemId --CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.intItemId ELSE Exception.intItemId END
	, dblReceived = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dblReceived ELSE Exception.dblReceived END
	, dblGross = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dblGross ELSE Exception.dblGross END
	, dblNet = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dblNet ELSE Exception.dblNet END
	, dblBillQty = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dblBillQty ELSE Exception.dblBillQty END
	, dblTax = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dblTax ELSE Exception.dblTax END
	, dblTaxExempt = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dblTaxExempt ELSE Exception.dblTaxExempt END
	, strInvoiceNumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strInvoiceNumber ELSE Exception.strInvoiceNumber END
	, dblQtyShipped = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dblQtyShipped ELSE Exception.dblQtyShipped END
	, strPONumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strPONumber ELSE Exception.strPONumber END
	, strBOLNumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strBOLNumber ELSE Exception.strBOLNumber END
	, strTerminalControlNumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTerminalControlNumber ELSE Exception.strTerminalControlNumber END
	, dtmDate = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dtmDate ELSE Exception.dtmDate END
	, strShipToCity = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strShipToCity ELSE Exception.strShipToCity END
	, strShipToState = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strShipToState ELSE Exception.strShipToState END
	, strSupplierName = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strSupplierName ELSE Exception.strSupplierName END
	, strItem = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strItem ELSE Exception.strItem END
	, dtmLastRun = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dtmLastRun ELSE Exception.dtmLastRun END
	, dtmReportingPeriodBegin = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dtmReportingPeriodBegin ELSE Exception.dtmReportingPeriodBegin END
	, dtmReportingPeriodEnd = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.dtmReportingPeriodEnd ELSE Exception.dtmReportingPeriodEnd END
	, strLicenseNumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strLicenseNumber ELSE Exception.strLicenseNumber END
	, strEmail = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strEmail ELSE Exception.strEmail END
	, strFEINSSN = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strFEINSSN ELSE Exception.strFEINSSN END
	, strCity = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strCity ELSE Exception.strCity END
	, strState = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strState ELSE Exception.strState END
	, strZipCode = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strZipCode ELSE Exception.strZipCode END
	, strTelephoneNumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTelephoneNumber ELSE Exception.strTelephoneNumber END
	, strContactName = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strContactName ELSE Exception.strContactName END
	, strShipVia = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strShipVia ELSE Exception.strShipVia END
	, strTransporterName = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTransporterName ELSE Exception.strTransporterName END
	, strTransportationMode = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTransportationMode ELSE Exception.strTransportationMode END
	, strTransporterFederalTaxId = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTransporterFederalTaxId ELSE Exception.strTransporterFederalTaxId END
	, strTransporterLicense = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTransporterLicense ELSE Exception.strTransporterLicense END
	, strCustomerName = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strCustomerName ELSE Exception.strCustomerName END
	, strCustomerFederalTaxId = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strCustomerFederalTaxId ELSE Exception.strCustomerFederalTaxId END
	, strVendorName = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strVendorName ELSE Exception.strVendorName END
	, strVendorFederalTaxId = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strVendorFederalTaxId ELSE Exception.strVendorFederalTaxId END
	, strVendorLicenseNumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strVendorLicenseNumber ELSE Exception.strVendorLicenseNumber END
	, strConsignorName = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strConsignorName ELSE Exception.strConsignorName END
	, strConsignorFederalTaxId = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strConsignorFederalTaxId ELSE Exception.strConsignorFederalTaxId END
	, strDestinationState = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strDestinationState ELSE Exception.strDestinationState END
	, strDestinationCity = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strDestinationCity ELSE Exception.strDestinationCity END
	, strDestinationTCN = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strDestinationTCN ELSE Exception.strDestinationTCN END
	, strOriginState = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strOriginState ELSE Exception.strOriginState END
	, strOriginCity = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strOriginCity ELSE Exception.strOriginCity END
	, strOriginTCN = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strOriginTCN ELSE Exception.strOriginTCN END
	, strFuelType = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strFuelType ELSE Exception.strFuelType END
	, strTaxPayerName = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTaxPayerName ELSE Exception.strTaxPayerName END
	, strTaxPayerIdentificationNumber = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTaxPayerIdentificationNumber ELSE Exception.strTaxPayerIdentificationNumber END
	, strTaxPayerFEIN = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTaxPayerFEIN ELSE Exception.strTaxPayerFEIN END
	, strTaxPayerDBA = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTaxPayerDBA ELSE Exception.strTaxPayerDBA END
	, strTaxPayerAddress = CASE WHEN Exception.intTransactionExceptionId IS NULL THEN Trans.strTaxPayerAddress ELSE Exception.strTaxPayerAddress END
	, Trans.intIntegrationError
	, Trans.leaf
	, Exception.intTransactionExceptionId
	, Exception.ysnDeleted
FROM tblTFTransaction Trans
LEFT JOIN vyuTFGetReportingComponent RC ON RC.intReportingComponentId = Trans.intReportingComponentId
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = Trans.intProductCodeId
LEFT JOIN tblICItem Item ON Item.intItemId = Trans.intItemId
LEFT JOIN vyuTFGetTransactionException Exception ON Exception.intTransactionId = Trans.intTransactionId
WHERE ISNULL(Exception.ysnDeleted, 0) != 1