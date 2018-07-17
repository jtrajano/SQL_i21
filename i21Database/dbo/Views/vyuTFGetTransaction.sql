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
	, strProductCodeDescription = PC.strDescription
	, strTaxCode = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxCode ELSE Exception.strTaxCode END
	, strType = RC.strType
	, strItemNo = Item.strItemNo
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
	, dtmLastRun = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.dtmLastRun ELSE Exception.dtmLastRun END
	, Trans.dtmReportingPeriodBegin
	, Trans.dtmReportingPeriodEnd
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
	, strDestinationCounty = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strDestinationCounty ELSE Exception.strDestinationCounty END
	, strDestinationTCN = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strDestinationTCN ELSE Exception.strDestinationTCN END
	, strOriginState = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strOriginState ELSE Exception.strOriginState END
	, strOriginCity = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strOriginCity ELSE Exception.strOriginCity END
	, strOriginCounty = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strOriginCounty ELSE Exception.strOriginCounty END
	, strOriginTCN = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strOriginTCN ELSE Exception.strOriginTCN END
	, strTaxPayerName = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerName ELSE Exception.strTaxPayerName END
	, strTaxPayerIdentificationNumber = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerIdentificationNumber ELSE Exception.strTaxPayerIdentificationNumber END
	, strTaxPayerFEIN = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerFEIN ELSE Exception.strTaxPayerFEIN END
	, strTaxPayerDBA = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerDBA ELSE Exception.strTaxPayerDBA END
	, strTaxPayerAddress = CASE WHEN Exception.intExceptionId IS NULL THEN Trans.strTaxPayerAddress ELSE Exception.strTaxPayerAddress END
	, strTransporterIdType = Trans.strTransporterIdType
	, strVendorIdType = Trans.strVendorIdType
	, strCustomerIdType = Trans.strCustomerIdType
	, strVendorInvoiceNumber = Trans.strVendorInvoiceNumber
	, strCustomerLicenseNumber = Trans.strCustomerLicenseNumber
	, strCustomerAccountStatusCode = Trans.strCustomerAccountStatusCode
	, strCustomerStreetAddress = Trans.strCustomerStreetAddress
	, strCustomerZipCode = Trans.strCustomerZipCode
	, strReportingComponentNote = Trans.strReportingComponentNote
	, strDiversionNumber = Trans.strDiversionNumber
	, strDiversionOriginalDestinationState = Trans.strDiversionOriginalDestinationState
	, Trans.strTransactionType
	, Trans.intTransactionNumberId
	, Trans.intIntegrationError
	, ysnHasException = CASE WHEN Exception.intExceptionId IS NULL THEN CONVERT(bit, 0) ELSE CONVERT(bit, 1) END
	, Exception.strExceptionType
	, Exception.intExceptionId
	, ysnDeleted = ISNULL(Exception.ysnDeleted, 0)
	, Exception.strReason
FROM tblTFTransaction Trans
LEFT JOIN vyuTFGetReportingComponent RC ON RC.intReportingComponentId = Trans.intReportingComponentId
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = Trans.intProductCodeId
LEFT JOIN tblICItem Item ON Item.intItemId = Trans.intItemId
LEFT JOIN tblTFException Exception ON Exception.intReportingComponentId = Trans.intReportingComponentId
	AND Exception.strTransactionType = Trans.strTransactionType
	AND Exception.intTransactionNumberId = Trans.intTransactionNumberId
WHERE ISNULL(Exception.ysnDeleted, 0) != 1

UNION ALL

SELECT intTransactionId = CAST(CAST(Exception.intExceptionId AS NVARCHAR(10)) + CAST((SELECT TOP 1 ISNULL(intTransactionId, '') FROM tblTFTransaction WHERE intReportingComponentId = Exception.intReportingComponentId) AS NVARCHAR(10)) AS INT)
	, uniqTransactionGuid = (SELECT TOP 1 uniqTransactionGuid FROM tblTFTransaction WHERE intReportingComponentId = Exception.intReportingComponentId)
	, Exception.intReportingComponentId
	, RC.intTaxAuthorityId
	, RC.strTaxAuthorityCode
	, strFormCode = RC.strFormCode
	, RC.strFormName
	, RC.strScheduleCode
	, RC.strScheduleName
	, Exception.intProductCodeId
	, PC.strProductCode
	, strProductCodeDescription = PC.strDescription
	, Exception.strTaxCode
	, RC.strType
	, Item.strItemNo
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
	, Exception.dtmLastRun
	, dtmReportingPeriodBegin = NULL
	, dtmReportingPeriodEnd = NULL
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
	, Exception.strDestinationCounty
	, Exception.strDestinationTCN
	, Exception.strOriginState
	, Exception.strOriginCity
	, Exception.strOriginCounty
	, Exception.strOriginTCN
	, Exception.strTaxPayerName
	, Exception.strTaxPayerIdentificationNumber
	, Exception.strTaxPayerFEIN
	, Exception.strTaxPayerDBA
	, Exception.strTaxPayerAddress
	, strTransporterIdType = NULL
	, strVendorIdType = NULL
	, strCustomerIdType = NULL
	, strVendorInvoiceNumber = NULL
	, strCustomerLicenseNumber = NULL
	, strCustomerAccountStatusCode = NULL
	, strCustomerStreetAddress = NULL
	, strCustomerZipCode = NULL
	, strReportingComponentNote = NULL
	, strDiversionNumber = NULL
	, strDiversionOriginalDestinationState = NULL
	, Exception.strTransactionType
	, Exception.intTransactionNumberId
	, intIntegrationError = NULL
	, ysnHasException = CONVERT(bit, 1)
	, Exception.strExceptionType
	, Exception.intExceptionId
	, ysnDeleted = ISNULL(Exception.ysnDeleted, 0)
	, Exception.strReason
FROM tblTFException Exception
LEFT JOIN vyuTFGetReportingComponent RC ON RC.intReportingComponentId = Exception.intReportingComponentId
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = Exception.intProductCodeId
LEFT JOIN tblICItem Item ON Item.intItemId = Exception.intItemId
WHERE ISNULL(Exception.ysnDeleted, 0) != 1
	AND strExceptionType = 'Add'