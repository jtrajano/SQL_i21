CREATE VIEW [dbo].[vyuTFGetTransaction]
	AS
	
SELECT Trans.intTransactionId
	, Trans.uniqTransactionGuid
	, Trans.intReportingComponentId
	, RC.intTaxAuthorityId
	, RC.strTaxAuthorityCode
	, strFormCode = RC.strFormCode
	, RC.strFormName
	, RC.strScheduleCode
	, RC.strScheduleName
	, intProductCodeId = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.intProductCodeId ELSE Exception.intProductCodeId END
	, strProductCode = CASE WHEN Exception.intExceptionId IS NULL THEN (CASE WHEN Trans.intProductCodeId = NULL THEN 'No record found.' ELSE Trans.strProductCode END) ELSE Exception.strProductCode END
	, strProductCodeDescription = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strDescription ELSE Exception.strProductCodeDescription END
	, strTaxCode = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxCode ELSE Exception.strTaxCode END
	, strType = RC.strType
	, strDescription = ISNULL(Trans.strDescription, '')
	, strItemNo = CASE WHEN Exception.intExceptionId IS NULL THEN Item.strItemNo ELSE Exception.strItemNo END
	, strBillOfLading = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strBillOfLading ELSE Exception.strBillOfLading END
	, intItemId = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.intItemId ELSE ISNULL(Exception.intItemId, Trans.intItemId) END
	, dblReceived = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dblReceived ELSE Exception.dblReceived END
	, dblGross = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dblGross ELSE Exception.dblGross END
	, dblNet = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dblNet ELSE Exception.dblNet END
	, dblBillQty = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dblBillQty ELSE Exception.dblBillQty END
	, dblTax = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dblTax ELSE Exception.dblTax END
	, dblTaxExempt = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dblTaxExempt ELSE Exception.dblTaxExempt END
	, strInvoiceNumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strInvoiceNumber ELSE Exception.strInvoiceNumber END
	, dblQtyShipped = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dblQtyShipped ELSE Exception.dblQtyShipped END
	, strPONumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strPONumber ELSE Exception.strPONumber END
	, strTerminalControlNumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTerminalControlNumber ELSE Exception.strTerminalControlNumber END
	, dtmDate = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dtmDate ELSE Exception.dtmDate END
	, strShipToCity = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strShipToCity ELSE Exception.strShipToCity END
	, strShipToState = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strShipToState ELSE Exception.strShipToState END
	, strSupplierName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strSupplierName ELSE Exception.strSupplierName END
	, dtmLastRun = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dtmLastRun ELSE Exception.dtmLastRun END
	, Trans.dtmReportingPeriodBegin
	, Trans.dtmReportingPeriodEnd
	, strLicenseNumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strLicenseNumber ELSE Exception.strLicenseNumber END
	, strEmail = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strEmail ELSE Exception.strEmail END
	, strFEINSSN = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strFEINSSN ELSE Exception.strFEINSSN END
	, strCity = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strCity ELSE Exception.strCity END
	, strState = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strState ELSE Exception.strState END
	, strZipCode = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strZipCode ELSE Exception.strZipCode END
	, strTelephoneNumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTelephoneNumber ELSE Exception.strTelephoneNumber END
	, strContactName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strContactName ELSE Exception.strContactName END
	, strShipVia = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strShipVia ELSE Exception.strShipVia END
	, strTransporterName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTransporterName ELSE Exception.strTransporterName END
	, strTransportationMode = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTransportationMode ELSE Exception.strTransportationMode END
	, strTransporterFederalTaxId = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTransporterFederalTaxId ELSE Exception.strTransporterFederalTaxId END
	, strTransporterLicense = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTransporterLicense ELSE Exception.strTransporterLicense END
	, strCustomerName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strCustomerName ELSE Exception.strCustomerName END
	, strCustomerFederalTaxId = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strCustomerFederalTaxId ELSE Exception.strCustomerFederalTaxId END
	, strVendorName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strVendorName ELSE Exception.strVendorName END
	, strVendorFederalTaxId = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strVendorFederalTaxId ELSE Exception.strVendorFederalTaxId END
	, strVendorLicenseNumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strVendorLicenseNumber ELSE Exception.strVendorLicenseNumber END
	, strConsignorName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strConsignorName ELSE Exception.strConsignorName END
	, strConsignorFederalTaxId = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strConsignorFederalTaxId ELSE Exception.strConsignorFederalTaxId END
	, strDestinationState = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strDestinationState ELSE Exception.strDestinationState END
	, strDestinationCity = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strDestinationCity ELSE Exception.strDestinationCity END
	, strDestinationTCN = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strDestinationTCN ELSE Exception.strDestinationTCN END
	, strOriginState = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strOriginState ELSE Exception.strOriginState END
	, strOriginCity = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strOriginCity ELSE Exception.strOriginCity END
	, strOriginTCN = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strOriginTCN ELSE Exception.strOriginTCN END
	, strFuelType = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strFuelType ELSE Exception.strFuelType END
	, strTaxPayerName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerName ELSE Exception.strTaxPayerName END
	, strTaxPayerIdentificationNumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerIdentificationNumber ELSE Exception.strTaxPayerIdentificationNumber END
	, strTaxPayerFEIN = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerFEIN ELSE Exception.strTaxPayerFEIN END
	, strTaxPayerDBA = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerDBA ELSE Exception.strTaxPayerDBA END
	, strTaxPayerAddress = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerAddress ELSE Exception.strTaxPayerAddress END
	, Trans.strTransactionType
	, Trans.intTransactionNumberId
	, Trans.intIntegrationError
	, ysnHasException = CASE WHEN Exception.intExceptionId IS NULL THEN 0 ELSE 1 END
	, Exception.strExceptionType
	, Exception.intExceptionId
	, ysnDeleted = ISNULL(Exception.ysnDeleted, 0)
FROM tblTFTransaction Trans
LEFT JOIN vyuTFGetReportingComponent RC ON RC.intReportingComponentId = Trans.intReportingComponentId
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = Trans.intProductCodeId
LEFT JOIN tblICItem Item ON Item.intItemId = Trans.intItemId
LEFT JOIN tblTFException Exception ON Exception.intReportingComponentId = Trans.intReportingComponentId
	AND Exception.strTransactionType = Trans.strTransactionType
	AND Exception.intTransactionNumberId = Trans.intTransactionNumberId
WHERE ISNULL(Exception.ysnDeleted, 0) != 1

UNION ALL

SELECT intTransactionId = NULL
	, uniqTransactionGuid = NULL
	, Exception.intReportingComponentId
	, RC.intTaxAuthorityId
	, RC.strTaxAuthorityCode
	, strFormCode = RC.strFormCode
	, RC.strFormName
	, RC.strScheduleCode
	, RC.strScheduleName
	, Exception.intProductCodeId
	, Exception.strProductCode
	, Exception.strProductCodeDescription
	, Exception.strTaxCode
	, RC.strType
	, strDescription = ''
	, Exception.strItemNo
	, Exception.strBillOfLading
	, Exception.intItemId
	, Exception.dblReceived
	, Exception.dblGross
	, Exception.dblNet
	, Exception.dblBillQty
	, Exception.dblTax
	, Exception.dblTaxExempt
	, Exception.strInvoiceNumber
	, Exception.dblQtyShipped
	, Exception.strPONumber
	, Exception.strTerminalControlNumber
	, Exception.dtmDate
	, Exception.strShipToCity
	, Exception.strShipToState
	, Exception.strSupplierName
	, Exception.dtmLastRun
	, dtmReportingPeriodBegin = NULL
	, dtmReportingPeriodEnd = NULL
	, Exception.strLicenseNumber
	, Exception.strEmail
	, Exception.strFEINSSN
	, Exception.strCity
	, Exception.strState
	, Exception.strZipCode
	, Exception.strTelephoneNumber
	, Exception.strContactName
	, Exception.strShipVia
	, Exception.strTransporterName
	, Exception.strTransportationMode
	, Exception.strTransporterFederalTaxId
	, Exception.strTransporterLicense
	, Exception.strCustomerName
	, Exception.strCustomerFederalTaxId
	, Exception.strVendorName
	, Exception.strVendorFederalTaxId
	, Exception.strVendorLicenseNumber
	, Exception.strConsignorName
	, Exception.strConsignorFederalTaxId
	, Exception.strDestinationState
	, Exception.strDestinationCity
	, Exception.strDestinationTCN
	, Exception.strOriginState
	, Exception.strOriginCity
	, Exception.strOriginTCN
	, Exception.strFuelType
	, Exception.strTaxPayerName
	, Exception.strTaxPayerIdentificationNumber
	, Exception.strTaxPayerFEIN
	, Exception.strTaxPayerDBA
	, Exception.strTaxPayerAddress
	, Exception.strTransactionType
	, Exception.intTransactionNumberId
	, intIntegrationError = NULL
	, ysnHasException = 1
	, Exception.strExceptionType
	, Exception.intExceptionId
	, ysnDeleted = ISNULL(Exception.ysnDeleted, 0)
FROM tblTFException Exception
LEFT JOIN vyuTFGetReportingComponent RC ON RC.intReportingComponentId = Exception.intReportingComponentId
WHERE ISNULL(Exception.ysnDeleted, 0) != 1
	AND strExceptionType = 'Add'