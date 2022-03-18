CREATE PROCEDURE [dbo].[uspTFGetTransporterCustomerInvoiceTax]
	@Guid NVARCHAR(50),
	@ReportingComponentId NVARCHAR(MAX),
	@DateFrom DATETIME,
	@DateTo DATETIME,
	@IsEdi BIT,
	@Refresh BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @tmpTransaction TFCommonTransaction
	DECLARE @tmpRC TABLE (intReportingComponentId INT)
	DECLARE @tmpDetailTax TFCommonDetailTax

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	END

	INSERT INTO @tmpRC
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE @tmpRC where intReportingComponentId = ''
	
	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpRC)
	BEGIN

		DECLARE @RCId INT = NULL
			, @intMaxId INT = 0

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC

		IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId)) 
		BEGIN
			INSERT INTO @tmpTransaction(intId
				, intTransactionDetailId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				, dblQtyShipped
				, dblGross
				, dblNet
				, dblBillQty
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
				, strOriginState
				, strCustomerName
				, strCustomerFederalTaxId
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFederalTaxId
				, strConsignorName
				, strConsignorFederalTaxId
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, strHeaderFederalTaxId
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, ysnDiversion
				, strContactName
				, strEmail
				, strTransactionSource
				, strTransportNumber
				, intAccountStatusId
				, strImportVerificationNumber)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId) AS intId, *
				FROM (SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId
						, tblTFReportingComponent.intTaxAuthorityId
						, tblTFReportingComponent.strFormCode
						, tblTFReportingComponent.intReportingComponentId
						, tblTFReportingComponent.strScheduleCode
						, tblTFReportingComponent.strType
						, tblARInvoiceDetail.intItemId
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblQtyShipped
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblNet
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblGross
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblBillQty
						, tblARInvoice.strInvoiceNumber
						, tblARInvoice.strPONumber
						, CASE WHEN tblARInvoice.strType = 'Transport Delivery' THEN tblARInvoice.strBOLNumber ELSE tblARInvoice.strInvoiceNumber END AS strBillOfLading
						, tblARInvoice.dtmDate
						, tblARInvoice.strShipToCity AS strDestinationCity
						, DestinationCounty.strCounty AS strDestinationCounty
						, tblARInvoice.strShipToState AS strDestinationState
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strCity ELSE OriginBulkLoc.strCity END AS strOriginCity
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strCountry ELSE OriginBulkLoc.strCountry END AS strOriginCounty
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strState ELSE OriginBulkLoc.strStateProvince END AS strOriginState
						, tblEMEntity.strName
						, tblEMEntity.strFederalTaxId AS strCustomerFederalTaxId
						, tblSMShipVia.strShipVia
						, tblSMShipVia.strTransporterLicense
						, tblSMTransportationMode.strCode
						, Transporter.strName AS strTransporterName
						, Transporter.strFederalTaxId AS strTransporterFederalTaxId
						, NULL AS strConsignorName
						, NULL AS strConsignorFederalTaxId
						, tblTFTerminalControlNumber.strTerminalControlNumber AS strTerminalControlNumber
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN Vendor.strName ELSE tblTFCompanyPreference.strCompanyName END AS strVendorName
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN Vendor.strFederalTaxId ELSE tblSMCompanySetup.strFederalTaxID END AS strVendorFederalTaxId
						, tblTFCompanyPreference.strCompanyName
						, tblTFCompanyPreference.strTaxAddress
						, tblTFCompanyPreference.strCity
						, tblTFCompanyPreference.strState
						, tblTFCompanyPreference.strZipCode
						, tblTFCompanyPreference.strContactPhone
						, tblSMCompanySetup.strStateTaxID
						, tblSMCompanySetup.strEin
						, strTransporterIdType = 'FEIN'
						, strVendorIdType = 'FEIN'
						, strCustomerIdType = 'FEIN'
						, strVendorInvoiceNumber = NULL
						, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
						, strCustomerAccountStatusCode = tblARAccountStatus.strAccountStatusCode
						, strCustomerStreetAddress = tblEMEntityLocation.strAddress
						, strCustomerZipCode = tblEMEntityLocation.strZipCode
						, strReportingComponentNote = tblTFReportingComponent.strNote
						, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
						, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
						, strTransactionType = 'Invoice'
						, intTransactionNumberId = tblARInvoiceDetail.intInvoiceDetailId
						, ysnDiversion = tblTRLoadHeader.ysnDiversion
						, strContactName = tblTFCompanyPreference.strContactName
						, strEmail = tblTFCompanyPreference.strContactEmail
						, strTransactionSource = tblARInvoice.strType
						, tblTRLoadHeader.strTransaction
						, intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId
						, strImportVerificationNumber = tblTRLoadHeader.strImportVerificationNumber
					FROM tblTFReportingComponent
					INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
						INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
					INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
						LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
							LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
							LEFT JOIN tblSMTransportationMode ON tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
						LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblARInvoice.intShipToLocationId
							LEFT JOIN tblSMTaxCode AS DestinationCounty ON DestinationCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
						LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = tblARInvoice.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
						LEFT JOIN tblCFTransaction ON tblCFTransaction.intInvoiceId = tblARInvoice.intInvoiceId
							LEFT JOIN tblCFSite ON tblCFSite.intSiteId = tblCFTransaction.intSiteId
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
					INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
						LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId 
					INNER JOIN tblSMShipVia SellerShipVia ON SellerShipVia.intEntityId = tblTRLoadHeader.intSellerId
						INNER JOIN tblEMEntity Seller ON Seller.intEntityId = SellerShipVia.intEntityId
					INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
						LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
						LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
						LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
						LEFT JOIN tblSMCompanyLocation OriginBulkLoc ON OriginBulkLoc.intCompanyLocationId = tblTRLoadReceipt.intCompanyLocationId
						LEFT JOIN tblAPVendor ON tblAPVendor.intEntityId = tblTRLoadReceipt.intTerminalId
							LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = tblAPVendor.intEntityId
					INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
					INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARCustomer.intEntityId
						LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
							LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId
					CROSS JOIN tblSMCompanySetup
					CROSS JOIN tblTFCompanyPreference
					WHERE tblARInvoice.ysnPosted = 1 
						AND tblTFReportingComponent.intReportingComponentId = @RCId
						AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
						AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR ((tblTRLoadReceipt.strOrigin = 'Terminal' AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
								OR (tblTRLoadReceipt.strOrigin != 'Terminal' AND OriginBulkLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
							)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR ((tblTRLoadReceipt.strOrigin = 'Terminal' AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
								OR (tblTRLoadReceipt.strOrigin != 'Terminal' AND OriginBulkLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
							)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR ((tblARInvoice.intFreightTermId = 3 AND tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')) 
								OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
							)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR ((tblARInvoice.intFreightTermId = 3 AND tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
								OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
							)
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
						--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						--	OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
						--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						--	OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))					
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR (tblTRLoadReceipt.strOrigin = 'Terminal' AND tblAPVendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1)))
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR (tblTRLoadReceipt.strOrigin = 'Terminal' AND ISNULL(tblAPVendor.intEntityId, 0) NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0)))
						AND ((tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Customer') OR
							(tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer'))	
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR tblARInvoice.strType IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR tblARInvoice.strType NOT IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0)
							)
						AND ((
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0 AND
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0 AND
							(NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0))))
							OR ((
								tblCFSite.strSiteNumber IN (SELECT strSiteNumber FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 1) OR 
								tblCFTransaction.strTransactionType IN (SELECT strTransactionType FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 1)) 
								AND (NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0))))
						)
						AND ((
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0 AND
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0 AND
							(NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0))))
							OR ((
								tblCFSite.strSiteNumber NOT IN (SELECT strSiteNumber FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 0) OR 
								tblCFTransaction.strTransactionType NOT IN (SELECT strTransactionType FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 0)) 
								AND (NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0)))
							)
						)
				) Transactions
		END
		ELSE
		BEGIN
			INSERT INTO @tmpTransaction(intId
				, intTransactionDetailId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				, dblQtyShipped
				, dblGross
				, dblNet
				, dblBillQty
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
				, strOriginState
				, strCustomerName
				, strCustomerFederalTaxId
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFederalTaxId
				, strConsignorName
				, strConsignorFederalTaxId
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, strHeaderFederalTaxId
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, ysnDiversion
				, strContactName
				, strEmail
				, strTransactionSource
				, strTransportNumber
				, intAccountStatusId
				, strImportVerificationNumber)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId) AS intId, *
			FROM (SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId
						, tblTFReportingComponent.intTaxAuthorityId
						, tblTFReportingComponent.strFormCode
						, tblTFReportingComponent.intReportingComponentId
						, tblTFReportingComponent.strScheduleCode
						, tblTFReportingComponent.strType
						, tblARInvoiceDetail.intItemId
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblQtyShipped
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblNet
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblGross
						, (CASE WHEN tblARInvoice.strTransactionType = 'Credit Memo' OR tblARInvoice.strTransactionType = 'Cash Refund' THEN tblARInvoiceDetail.dblQtyShipped * -1 ELSE tblARInvoiceDetail.dblQtyShipped END) AS dblBillQty
						, tblARInvoice.strInvoiceNumber
						, tblARInvoice.strPONumber
						, CASE WHEN tblARInvoice.strType = 'Transport Delivery' THEN tblARInvoice.strBOLNumber ELSE tblARInvoice.strInvoiceNumber END AS strBillOfLading
						, tblARInvoice.dtmDate
						, tblARInvoice.strShipToCity AS strDestinationCity
						, DestinationCounty.strCounty AS strDestinationCounty
						, tblARInvoice.strShipToState AS strDestinationState
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strCity ELSE OriginBulkLoc.strCity END AS strOriginCity
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strCountry ELSE OriginBulkLoc.strCountry END AS strOriginCounty
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN SupplyPointLoc.strState ELSE OriginBulkLoc.strStateProvince END AS strOriginState
						, tblEMEntity.strName
						, tblEMEntity.strFederalTaxId AS strCustomerFederalTaxId
						, tblSMShipVia.strShipVia
						, tblSMShipVia.strTransporterLicense
						, tblSMTransportationMode.strCode
						, Transporter.strName AS strTransporterName
						, Transporter.strFederalTaxId AS strTransporterFederalTaxId
						, NULL AS strConsignorName
						, NULL AS strConsignorFederalTaxId
						, tblTFTerminalControlNumber.strTerminalControlNumber AS strTerminalControlNumber
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN Vendor.strName ELSE tblTFCompanyPreference.strCompanyName END AS strVendorName
						, CASE WHEN tblTRLoadReceipt.strOrigin = 'Terminal' THEN Vendor.strFederalTaxId ELSE tblSMCompanySetup.strFederalTaxID END AS strVendorFederalTaxId
						, tblTFCompanyPreference.strCompanyName
						, tblTFCompanyPreference.strTaxAddress
						, tblTFCompanyPreference.strCity
						, tblTFCompanyPreference.strState
						, tblTFCompanyPreference.strZipCode
						, tblTFCompanyPreference.strContactPhone
						, tblSMCompanySetup.strStateTaxID
						, tblSMCompanySetup.strEin
						, strTransporterIdType = 'FEIN'
						, strVendorIdType = 'FEIN'
						, strCustomerIdType = 'FEIN'
						, strVendorInvoiceNumber = NULL
						, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
						, strCustomerAccountStatusCode = tblARAccountStatus.strAccountStatusCode
						, strCustomerStreetAddress = tblEMEntityLocation.strAddress
						, strCustomerZipCode = tblEMEntityLocation.strZipCode
						, strReportingComponentNote = tblTFReportingComponent.strNote
						, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
						, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
						, strTransactionType = 'Invoice'
						, intTransactionNumberId = tblARInvoiceDetail.intInvoiceDetailId
						, ysnDiversion = tblTRLoadHeader.ysnDiversion
						, strContactName = tblTFCompanyPreference.strContactName
						, strEmail = tblTFCompanyPreference.strContactEmail
						, strTransactionSource = tblARInvoice.strType
						, strTransportNumber = tblTRLoadHeader.strTransaction
						, intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId
						, strImportVerificationNumber = tblTRLoadHeader.strImportVerificationNumber
					FROM tblTFReportingComponent
					INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
						INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
					INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
						LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
							LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
							LEFT JOIN tblSMTransportationMode ON tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
						LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblARInvoice.intShipToLocationId
							LEFT JOIN tblSMTaxCode AS DestinationCounty ON DestinationCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
						LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = tblARInvoice.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
						LEFT JOIN tblCFTransaction ON tblCFTransaction.intInvoiceId = tblARInvoice.intInvoiceId
							LEFT JOIN tblCFSite ON tblCFSite.intSiteId = tblCFTransaction.intSiteId
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
					INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
						LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId 
					INNER JOIN tblSMShipVia SellerShipVia ON SellerShipVia.intEntityId = tblTRLoadHeader.intSellerId
						INNER JOIN tblEMEntity Seller ON Seller.intEntityId = SellerShipVia.intEntityId
					INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
						LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
						LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
						LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
						LEFT JOIN tblSMCompanyLocation OriginBulkLoc ON OriginBulkLoc.intCompanyLocationId = tblTRLoadReceipt.intCompanyLocationId
						LEFT JOIN tblAPVendor ON tblAPVendor.intEntityId = tblTRLoadReceipt.intTerminalId
							LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = tblAPVendor.intEntityId
					INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
					INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARCustomer.intEntityId
						LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
							LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId
					CROSS JOIN tblSMCompanySetup
					CROSS JOIN tblTFCompanyPreference
					WHERE tblARInvoice.ysnPosted = 1 
						AND tblTFReportingComponent.intReportingComponentId = @RCId
						AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
						AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR ((tblTRLoadReceipt.strOrigin = 'Terminal' AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
								OR (tblTRLoadReceipt.strOrigin != 'Terminal' AND OriginBulkLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
							)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR ((tblTRLoadReceipt.strOrigin = 'Terminal' AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
								OR (tblTRLoadReceipt.strOrigin != 'Terminal' AND OriginBulkLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
							)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR ((tblARInvoice.intFreightTermId = 3 AND tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')) 
								OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
							)
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR ((tblARInvoice.intFreightTermId = 3 AND tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
								OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
							)
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
						--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						--	OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
						--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						--	OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))					
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR (tblTRLoadReceipt.strOrigin = 'Terminal' AND tblAPVendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1)))
						AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR (tblTRLoadReceipt.strOrigin = 'Terminal' AND ISNULL(tblAPVendor.intEntityId, 0) NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0)))
						AND ((tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Customer') OR
							(tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer'))
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR tblARInvoice.strType IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR tblARInvoice.strType NOT IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0)
							)
						AND ((
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0 AND
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0 AND
							(NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0))))
							OR ((
								tblCFSite.strSiteNumber IN (SELECT strSiteNumber FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 1) OR 
								tblCFTransaction.strTransactionType IN (SELECT strTransactionType FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 1)) 
								AND (NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0))))
						)
						AND ((
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0 AND
							(SELECT COUNT(*) FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0 AND
							(NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0))))
							OR ((
								tblCFSite.strSiteNumber NOT IN (SELECT strSiteNumber FROM vyuTFGetReportingComponentCardFuelingSite WHERE intReportingComponentId = @RCId AND ysnInclude = 0) OR 
								tblCFTransaction.strTransactionType NOT IN (SELECT strTransactionType FROM vyuTFGetReportingComponentCardFuelingSiteType WHERE intReportingComponentId = @RCId AND ysnInclude = 0)) 
								AND (NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE (strTransactionSource = 'CF Tran'AND ysnInclude = 0) OR (strTransactionSource = 'CF Invoice' AND ysnInclude = 0)))
							)
						)
				) Transactions
		END

		-- Distinct the Account Status Code
		DECLARE @tmpInvoiceDetailUniqueAccountStatusCode TABLE(
			intId INT, 
			intInvoiceDetailId INT,
			PRIMARY KEY CLUSTERED ([intId] ASC) WITH (IGNORE_DUP_KEY = OFF),
			UNIQUE NONCLUSTERED ([intId] ASC, [intInvoiceDetailId] ASC))
		
		-- Account Status Filtering
        IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1)
        BEGIN
            -- Check 1st to optimize the looping if has include setup -- This remove all no account status setup
            DELETE FROM @tmpTransaction WHERE intAccountStatusId IS NULL
        END

		-- Has excluded account status code 
		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0)
        BEGIN      
            DELETE FROM @tmpTransaction WHERE intTransactionDetailId IN (
				SELECT A.intTransactionDetailId FROM @tmpTransaction A 
				INNER JOIN tblTFReportingComponentAccountStatusCode B ON B.intAccountStatusId = A.intAccountStatusId 
				WHERE B.ysnInclude = 0 AND B.intReportingComponentId = @RCId)
        END

		-- Has included account status code
		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1)
        BEGIN
            DELETE FROM @tmpTransaction WHERE intId NOT IN (
				SELECT A.intId FROM @tmpTransaction A 
				INNER JOIN tblTFReportingComponentAccountStatusCode B ON B.intAccountStatusId = A.intAccountStatusId 
				WHERE B.ysnInclude = 1 AND B.intReportingComponentId = @RCId)
        END

		INSERT INTO @tmpInvoiceDetailUniqueAccountStatusCode
			SELECT MIN(intId) intId, intTransactionDetailId FROM @tmpTransaction 
			GROUP BY intTransactionDetailId HAVING (COUNT(intTransactionDetailId) > 1)

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInvoiceDetailUniqueAccountStatusCode)
		BEGIN
			DECLARE @intIdUASC NVARCHAR(30) = NULL, @intDetailInvoiceUASC INT = NULL

			SELECT TOP 1 @intIdUASC = intId, @intDetailInvoiceUASC = intInvoiceDetailId FROM @tmpInvoiceDetailUniqueAccountStatusCode

			DELETE FROM @tmpTransaction WHERE intId <> @intIdUASC AND intTransactionDetailId = @intDetailInvoiceUASC

			DELETE FROM @tmpInvoiceDetailUniqueAccountStatusCode WHERE intId = @intIdUASC
		END

		-- HAS TAX CRITERIA
		IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId))
		BEGIN

			-- TRANSACTION WITHOUT TAX CODE
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN	
				DELETE @tmpTransaction WHERE intTransactionDetailId IN (
					SELECT DISTINCT InvTran.intTransactionDetailId 
					FROM @tmpTransaction InvTran
					LEFT JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId = InvTran.intTransactionDetailId
					WHERE tblARInvoiceDetailTax.intTaxCodeId IS NULL	
				)
			END

			-- TRANSACTION WITH TAX CODE
			INSERT INTO @tmpDetailTax (intTransactionDetailId, intTaxCodeId, strCriteria, dblTax)
			SELECT InvTran.intTransactionDetailId, tblARInvoiceDetailTax.intTaxCodeId, tblTFReportingComponentCriteria.strCriteria, tblARInvoiceDetailTax.dblAdjustedTax
			FROM @tmpTransaction InvTran
				INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId = InvTran.intTransactionDetailId
				INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
				INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId

			WHILE EXISTS(SELECT TOP 1 1 FROM @tmpDetailTax)
			BEGIN		
				DECLARE @InvoiceDetailId INT = NULL, @intTaxCodeId INT = NULL, @strCriteria NVARCHAR(100) = NULL,  @dblTax NUMERIC(18,8) = NULL

				SELECT TOP 1 @InvoiceDetailId = intTransactionDetailId, @intTaxCodeId = intTaxCodeId, @strCriteria = strCriteria, @dblTax = dblTax FROM @tmpDetailTax

				IF(@strCriteria = '<> 0' AND @dblTax = 0)	
				BEGIN
					DELETE FROM @tmpTransaction WHERE intTransactionDetailId = @InvoiceDetailId										 
				END
				ELSE IF (@strCriteria = '= 0' AND @dblTax > 0)
				BEGIN
					DELETE FROM @tmpTransaction WHERE intTransactionDetailId = @InvoiceDetailId										 
				END

				DELETE @tmpDetailTax WHERE intTransactionDetailId = @InvoiceDetailId AND intTaxCodeId = @intTaxCodeId

			END

			DELETE @tmpDetailTax

			-- TRANSACTION NOT MAPPED ON MFT TAX CATEGORY
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN 	
				DELETE @tmpTransaction WHERE intTransactionDetailId NOT IN (
					SELECT DISTINCT InvTran.intTransactionDetailId
					FROM @tmpTransaction InvTran
						INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId = InvTran.intTransactionDetailId 
						INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
						INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
						INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
						WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId AND ISNULL(tblARInvoiceDetailTax.dblTax, 0) <> 0
					)
			END

		END
			
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, intItemId
				, dblQtyShipped
				, dblGross
				, dblNet
				, dblBillQty
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
				, strOriginState
				, strCustomerName
				, strCustomerFederalTaxId
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFederalTaxId
				, strConsignorName
				, strConsignorFederalTaxId
				, strTaxCode
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strTaxPayerName
				, strTaxPayerAddress
				, strCity
				, strState
				, strZipCode
				, strTelephoneNumber
				, strTaxPayerIdentificationNumber
				, strTaxPayerFEIN
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strContactName
				, strEmail
				, strTransactionSource
				, strTransportNumber
				, strImportVerificationNumber)
			SELECT DISTINCT @Guid
				, intReportingComponentId
				, intProductCodeId = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.intProductCodeId 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, strProductCode = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.strProductCode 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, intItemId
				, CONVERT(DECIMAL(18), dblQtyShipped)
				, CONVERT(DECIMAL(18), dblGross)
				, CONVERT(DECIMAL(18), dblNet)
				, CONVERT(DECIMAL(18), dblBillQty)
				, strInvoiceNumber
				, strPONumber
				, strBillOfLading
				, dtmDate
				, strDestinationCity
				, strDestinationCounty
				, strDestinationState
				, strOriginCity
				, strOriginCounty
				, strOriginState
				, strCustomerName
				, REPLACE(strCustomerFederalTaxId, '-', '')
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, REPLACE(strTransporterFederalTaxId, '-', '')
				, strConsignorName
				, REPLACE(strConsignorFederalTaxId, '-', '')
				, strTaxCode
				, strTerminalControlNumber
				, strVendorName
				, REPLACE(strVendorFederalTaxId, '-', '')
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxId
				, REPLACE(strHeaderFederalTaxId, '-', '')
				, @DateFrom
				, @DateTo
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strContactName
				, strEmail
				, strTransactionSource
				, strTransportNumber
				, strImportVerificationNumber
			FROM @tmpTransaction Trans
		END
		
		IF(NOT EXISTS (SELECT TOP 1 1 FROM @tmpTransaction WHERE intReportingComponentId = @RCId))
		BEGIN
		
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, strProductCode
				, dtmDate
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTransactionType
				, strEmail
				, strContactName
				, strTaxPayerName
				, strTaxPayerAddress
				, strCity
				, strState
				, strZipCode
				, strTelephoneNumber)
			SELECT @Guid
				, @RCId
				, 'No record found.'
				, @DateFrom
				, @DateFrom
				, @DateTo
				, 'Invoice'
				, strContactEmail
				, strContactName
				, strCompanyName
				, strTaxAddress
				, strCity
				, strState
				, strZipCode
				, strContactPhone
			FROM tblTFCompanyPreference

		END

		DELETE FROM @tmpTransaction
		DELETE FROM @tmpRC WHERE intReportingComponentId = @RCId

		EXEC uspTFProcessBeforePreview @Guid = @Guid
		, @ReportingComponentId = @ReportingComponentId
		, @DateFrom = @DateFrom
		, @DateTo = @DateTo

	END

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH