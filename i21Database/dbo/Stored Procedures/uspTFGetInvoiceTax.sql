CREATE PROCEDURE [dbo].[uspTFGetInvoiceTax]
	@Guid NVARCHAR(50)
	, @ReportingComponentId NVARCHAR(MAX)
	, @DateFrom DATETIME
	, @DateTo DATETIME
	, @IsEdi BIT
	, @Refresh BIT

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
		DELETE FROM tblTFTransaction
	END

	INSERT INTO @tmpRC
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE @tmpRC where intReportingComponentId = ''
	
	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpRC)
	BEGIN

		DECLARE @RCId INT = NULL
		, @FormCode NVARCHAR(50) = NULL
		, @ScheduleCode NVARCHAR(50) = NULL
		, @TaxAuthorityCode NVARCHAR(50) = NULL
		, @Type NVARCHAR(100) = NULL
		, @intMaxId INT = 0

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC

		SELECT TOP 1 @FormCode = strFormCode
			, @ScheduleCode = strScheduleCode
			, @TaxAuthorityCode = strTaxAuthorityCode
			, @Type = strType
		FROM tblTFReportingComponent
		LEFT JOIN tblTFTaxAuthority ON tblTFTaxAuthority.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
		WHERE intReportingComponentId = @RCId

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
				, dblTax
				, dblTaxExempt
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
					, 0.000000 AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, CASE WHEN tblARInvoice.strType = 'Transport Delivery' THEN tblARInvoice.strBOLNumber ELSE tblARInvoice.strInvoiceNumber END AS strBillOfLading
					, tblARInvoice.dtmDate
					, CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoiceDetail.intSiteId IS NOT NULL THEN tblTMSite.strCity ELSE tblARInvoice.strShipToCity END AS strDestinationCity
					, CASE WHEN tblARInvoice.intFreightTermId = 3 THEN NULL WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoiceDetail.intSiteId IS NOT NULL THEN NULL ELSE DestinationCounty.strCounty END AS strDestinationCounty
					, CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoiceDetail.intSiteId IS NOT NULL THEN tblTMSite.strState ELSE tblARInvoice.strShipToState END AS strDestinationState
					, CASE WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strSiteCity ELSE tblSMCompanyLocation.strCity END AS strOriginCity
					, NULL AS strOriginCounty
					, CASE WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strTaxState ELSE tblSMCompanyLocation.strStateProvince END AS strOriginState
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
					, tblSMCompanySetup.strCompanyName AS strVendorName
					, tblSMCompanySetup.strEin AS strVendorFederalTaxId
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
					--LEFT JOIN tblTMDeliveryHistoryDetail ON tblTMDeliveryHistoryDetail.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId
					--LEFT JOIN tblTMDeliveryHistory ON tblTMDeliveryHistory.intDeliveryHistoryID = tblTMDeliveryHistoryDetail.intDeliveryHistoryID
					LEFT JOIN tblTMSite ON tblTMSite.intSiteID = tblARInvoiceDetail.intSiteId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
					LEFT JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
						LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
							LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
						LEFT JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
							LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
							--LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
							LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					LEFT JOIN tblCFTransaction ON tblCFTransaction.intInvoiceId = tblARInvoice.intInvoiceId
						LEFT JOIN tblCFSite ON tblCFSite.intSiteId = tblCFTransaction.intSiteId
					INNER JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblARInvoice.intCompanyLocationId
					INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
						INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARCustomer.intEntityId
						LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
							LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId
					LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblARInvoice.intShipToLocationId
						LEFT JOIN tblSMTaxCode AS DestinationCounty ON DestinationCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = tblARInvoice.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE tblARInvoice.ysnPosted = 1 
					AND tblTFReportingComponent.intReportingComponentId = @RCId
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)				
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblCFSite.intSiteId IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblCFSite.intSiteId IS NOT NULL AND tblCFSite.strTaxState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblCFSite.intSiteId IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblCFSite.intSiteId IS NOT NULL AND tblCFSite.strTaxState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')) 
							OR (tblARInvoice.strType != 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblTMSite.strState IS NOT NULL AND tblTMSite.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoiceDetail.intSiteId IS NULL AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblARInvoice.strType != 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblTMSite.strState IS NOT NULL AND tblTMSite.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoiceDetail.intSiteId IS NULL AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					--	OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					--	OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND ((tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Customer') 
						OR (tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer') 
						OR (tblTRLoadReceipt.strOrigin IS NULL OR tblTRLoadDistributionHeader.strDestination IS NULL)
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARInvoice.strType IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARInvoice.strType NOT IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
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
				, dblTax
				, dblTaxExempt
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
					, 0.000000 AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, CASE WHEN tblARInvoice.strType = 'Transport Delivery' THEN tblARInvoice.strBOLNumber ELSE tblARInvoice.strInvoiceNumber END AS strBillOfLading
					, tblARInvoice.dtmDate
					, CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoiceDetail.intSiteId IS NOT NULL THEN tblTMSite.strCity ELSE tblARInvoice.strShipToCity END AS strDestinationCity
					, CASE WHEN tblARInvoice.intFreightTermId = 3 THEN NULL WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoiceDetail.intSiteId IS NOT NULL THEN NULL ELSE DestinationCounty.strCounty END AS strDestinationCounty
					, CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoiceDetail.intSiteId IS NOT NULL THEN tblTMSite.strState ELSE tblARInvoice.strShipToState END AS strDestinationState
					, CASE WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strSiteCity ELSE tblSMCompanyLocation.strCity END AS strOriginCity
					, NULL AS strOriginCounty
					, CASE WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strTaxState ELSE tblSMCompanyLocation.strStateProvince END AS strOriginState
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
					, tblSMCompanySetup.strCompanyName AS strVendorName
					, tblSMCompanySetup.strEin AS strVendorFederalTaxId
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
					--LEFT JOIN tblTMDeliveryHistoryDetail ON tblTMDeliveryHistoryDetail.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId
					--LEFT JOIN tblTMDeliveryHistory ON tblTMDeliveryHistory.intDeliveryHistoryID = tblTMDeliveryHistoryDetail.intDeliveryHistoryID
					LEFT JOIN tblTMSite ON tblTMSite.intSiteID = tblARInvoiceDetail.intSiteId
				INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
					LEFT JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
						LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
							LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
						LEFT JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
							LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
							--LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
							LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					LEFT JOIN tblCFTransaction ON tblCFTransaction.intInvoiceId = tblARInvoice.intInvoiceId
						LEFT JOIN tblCFSite ON tblCFSite.intSiteId = tblCFTransaction.intSiteId
					INNER JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblARInvoice.intCompanyLocationId
					INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
						INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARCustomer.intEntityId
						LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
							LEFT JOIN tblARAccountStatus ON tblARAccountStatus.intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId
					LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblARInvoice.intShipToLocationId
						LEFT JOIN tblSMTaxCode AS DestinationCounty ON DestinationCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = tblARInvoice.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE tblARInvoice.ysnPosted = 1 
					AND tblTFReportingComponent.intReportingComponentId = @RCId
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)				
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblCFSite.intSiteId IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblCFSite.intSiteId IS NOT NULL AND tblCFSite.strTaxState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblCFSite.intSiteId IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblCFSite.intSiteId IS NOT NULL AND tblCFSite.strTaxState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')) 
							OR (tblARInvoice.strType != 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblTMSite.strState IS NOT NULL AND tblTMSite.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoiceDetail.intSiteId IS NULL AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblARInvoice.strType != 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblTMSite.strState IS NOT NULL AND tblTMSite.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblARInvoice.strType = 'Tank Delivery' AND ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoiceDetail.intSiteId IS NULL AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					--	OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					--AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					--	OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND ((tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Customer') 
						OR (tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer') 
						OR (tblTRLoadReceipt.strOrigin IS NULL OR tblTRLoadDistributionHeader.strDestination IS NULL)
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARInvoice.strType IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARInvoice.strType NOT IN (SELECT strTransactionSource FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				) Transactions
		END

		IF(@TaxAuthorityCode = 'OR')
		BEGIN
			IF (@ScheduleCode = '5CRD')
			BEGIN
				-- Include CF Trans only
				DELETE @tmpTransaction WHERE intId IN (
					SELECT Trans.intId
					FROM @tmpTransaction Trans
					LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionDetailId
					LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
					LEFT JOIN tblCFTransaction ON tblCFTransaction.intInvoiceId = Invoice.intInvoiceId
					WHERE Trans.strTransactionType = 'Invoice'
					AND Trans.intReportingComponentId = @RCId
					AND Invoice.strType <> 'CF Tran'
					OR (Invoice.strType = 'CF Tran' AND tblCFTransaction.strTransactionType = 'Extended Remote')
				)
			END
			ELSE IF (@ScheduleCode = '6CRD')
			BEGIN
				-- Include CF Trans only
				DELETE @tmpTransaction WHERE intId IN (
					SELECT Trans.intId
					FROM @tmpTransaction Trans
					LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionDetailId
					LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
					LEFT JOIN tblCFTransaction ON tblCFTransaction.intInvoiceId = Invoice.intInvoiceId
					LEFT JOIN tblCFSite ON tblCFSite.intSiteId = tblCFTransaction.intSiteId
					WHERE Trans.strTransactionType = 'Invoice'
					AND Trans.intReportingComponentId = @RCId
					AND Invoice.strType <> 'CF Tran' 
					OR (Invoice.strType = 'CF Tran' AND tblCFSite.ysnCaptiveSite = 1)
					OR (Invoice.strType = 'CF Tran' AND tblCFTransaction.strTransactionType = 'Extended Remote')
				)
			END
			ELSE IF (@ScheduleCode IN ('5BLK', '6BLK', '5LO', '6', '7', '7E', '8', '10', '10AC', '10AD', '10D'))
			BEGIN
				-- Exclude non CF Trans
				DELETE @tmpTransaction WHERE intId IN (
					SELECT Trans.intId
					FROM @tmpTransaction Trans
					LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionDetailId
					LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
					WHERE Trans.strTransactionType = 'Invoice'
					AND Trans.intReportingComponentId = @RCId
					AND Invoice.strType = 'CF Tran'
				)
			END
			ELSE IF (@ScheduleCode IN ('5'))
			BEGIN
				-- Exclude non CF Trans AND Tank Delivery
				DELETE @tmpTransaction WHERE intId IN (
					SELECT Trans.intId
					FROM @tmpTransaction Trans
					LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionDetailId
					LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
					WHERE Trans.strTransactionType = 'Invoice'
					AND Trans.intReportingComponentId = @RCId
					AND Invoice.strType = 'CF Tran' OR Invoice.strType = 'Tank Delivery'
				)
			END
			ELSE IF (@ScheduleCode IN ('1') AND @Type IN ('Gasoline (Exports to WA)', 'Aviation (Exports to WA)', 'Jet Fuel (Exports to WA)'))
			BEGIN
				-- Include Tank Delivery SI only
				DELETE @tmpTransaction WHERE intId IN (
					SELECT Trans.intId
					FROM @tmpTransaction Trans
					LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intTransactionDetailId
					LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
					WHERE Trans.strTransactionType = 'Invoice'
					AND Trans.intReportingComponentId = @RCId
					AND Invoice.strType <> 'Tank Delivery'
				)
			END
		END

		-- Diversion
		UPDATE @tmpTransaction SET dblQtyShipped = (dblQtyShipped * -1), dblGross = (dblGross * -1), dblNet = (dblNet * -1), dblBillQty = (dblBillQty * -1) WHERE ysnDiversion = 1 AND strFormCode = 'SF-900' AND strScheduleCode = '11' AND (strDiversionOriginalDestinationState = 'IN' AND strDestinationState <> 'IN')

		-- MFT-1219 - To Distinct the Account Status Code
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

			DELETE FROM @tmpInvoiceDetailUniqueAccountStatusCode WHERE intId = @intIdUASC --AND intInvoiceDetailId = @intDetailInvoiceUASC
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
			
		-- GET MAX intId
		SELECT @intMaxId = ISNULL(MAX(intId), 0) FROM @tmpTransaction	

		--INVENTORY TRANSFER - Track MFT Activity
		IF NOT EXISTS(SELECT TOP 1 1 FROM vyuTFGetReportingComponentTransactionSource WHERE intReportingComponentId = @RCId)
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
				, dblTax
				, dblTaxExempt
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
				, strContactName
				, strEmail
				, strTransportNumber)
			SELECT DISTINCT (ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId) + @intMaxId) AS intId, *
			FROM (SELECT DISTINCT NULL AS intTransactionDetailId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, tblTFReportingComponent.strType
					, tblICInventoryTransferDetail.intItemId
					, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
					, tblICInventoryTransferDetail.dblQuantity AS dblGross
					, tblICInventoryTransferDetail.dblQuantity AS dblNet
					, tblICInventoryTransferDetail.dblQuantity
					, NULL AS dblTax
					, NULL AS dblTaxExempt
					, NULL AS strInvoiceNumber
					, NULL AS strPONumber
					, CASE WHEN ISNULL(tblTRLoadReceipt.strBillOfLading, '') = '' THEN tblICInventoryTransfer.strTransferNo ELSE tblTRLoadReceipt.strBillOfLading END AS strBOLNumber
					, CASE WHEN tblTRLoadHeader.dtmLoadDateTime IS NULL THEN tblICInventoryTransfer.dtmTransferDate ELSE tblTRLoadHeader.dtmLoadDateTime END AS dtmDate
					, tblSMCompanyLocation.strCity AS strDestinationCity
					, NULL AS strDestinationCounty
					, tblSMCompanyLocation.strStateProvince AS strDestinationState
					, ShipFromLoc.strCity AS strOriginCity
					, ShipFromLoc.strCountry AS strOriginCounty
					, ShipFromLoc.strStateProvince AS strOriginState
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, tblEMEntity.strName AS strTransporterName
					, tblEMEntity.strFederalTaxId AS strTransporterFederalTaxId
					, tblEMEntity.strName AS strConsignorName
					, tblEMEntity.strFederalTaxId AS strConsignorFederalTaxId
					, EntityAPVendor.strName AS strVendorName
					, EntityAPVendor.strFederalTaxId AS strVendorFederalTaxId
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
					, strCustomerLicenseNumber = NULL
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strDiversionNumber = NULL
					, strDiversionOriginalDestinationState = NULL
					, strTransactionType = 'Transfer'
					, intTransactionNumberId = tblICInventoryTransferDetail.intInventoryTransferDetailId
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
					, strTransportNumber = tblTRLoadHeader.strTransaction
				FROM tblTFReportingComponent
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICInventoryTransferDetail ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId 	
					INNER JOIN tblICItem ON tblICItem.intItemId = tblICInventoryTransferDetail.intItemId
					INNER JOIN tblICCategoryTax ON tblICCategoryTax.intCategoryId = tblICItem.intCategoryId 
						INNER JOIN tblSMTaxClass ON tblSMTaxClass.intTaxClassId = tblICCategoryTax.intTaxClassId
							INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxClassId = tblSMTaxClass.intTaxClassId
				INNER JOIN tblICInventoryTransfer ON tblICInventoryTransfer.intInventoryTransferId = tblICInventoryTransferDetail.intInventoryTransferId
					INNER JOIN tblSMCompanyLocation ShipFromLoc ON ShipFromLoc.intCompanyLocationId = tblICInventoryTransfer.intFromLocationId -- MFT-1220
				LEFT JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadReceiptId = tblICInventoryTransferDetail.intSourceId
					LEFT JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
					LEFT JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityId = EntityAPVendor.intEntityId
					LEFT JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblICInventoryTransfer.intToLocationId
				LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
					LEFT JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
					LEFT JOIN tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityId 
					LEFT JOIN tblEMEntity ON tblSMShipVia.intEntityId = tblEMEntity.intEntityId 
					LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode	
				LEFT JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					LEFT JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
					LEFT JOIN tblSMTaxCode AS TaxCodeCategory ON TaxCodeCategory.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblSMCompanyLocation.ysnTrackMFTActivity = 1
					AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND tblICInventoryTransfer.ysnPosted = 1
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR (ShipFromLoc.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR (ShipFromLoc.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
							OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
							OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
							OR EntityAPVendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
							OR EntityAPVendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (tblTFReportingComponentCriteria.strCriteria IS NULL 
							OR (tblTFReportingComponentCriteria.strCriteria = '<> 0' AND tblSMTaxCode.intTaxCodeId = TaxCodeCategory.intTaxCodeId) -- FOR TRACK MFT ACTIVITY
							OR (TaxCodeCategory.intTaxCodeId IS NULL AND tblTFReportingComponentCriteria.strCriteria = '= 0') -- FOR NO TAX CODE MAPPED TO MFT CATEGORY
						)
					AND ((tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Location') OR 
						(tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Location') OR
						(tblTRLoadReceipt.strOrigin IS NULL OR tblTRLoadDistributionHeader.strDestination IS NULL))
			) tblTransactions
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
				, CASE WHEN @TaxAuthorityCode = 'OR' AND @ScheduleCode IN ('5CRD', '6CRD') THEN CONVERT(DECIMAL(18, 3), dblQtyShipped) ELSE CONVERT(DECIMAL(18), dblQtyShipped) END
				, CASE WHEN @TaxAuthorityCode = 'OR' AND @ScheduleCode IN ('5CRD', '6CRD') THEN CONVERT(DECIMAL(18, 3), dblGross) ELSE CONVERT(DECIMAL(18), dblGross) END
				, CASE WHEN @TaxAuthorityCode = 'OR' AND @ScheduleCode IN ('5CRD', '6CRD') THEN CONVERT(DECIMAL(18, 3), dblNet) ELSE CONVERT(DECIMAL(18), dblNet) END
				, CASE WHEN @TaxAuthorityCode = 'OR' AND @ScheduleCode IN ('5CRD', '6CRD') THEN CONVERT(DECIMAL(18, 3), dblBillQty) ELSE CONVERT(DECIMAL(18), dblBillQty) END
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