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

	DECLARE @tmpInvoiceTransaction TFInvoiceTransaction
	--DECLARE @tmpInvoiceDetail TFInvoiceDetailTransaction
	DECLARE @tmpRC TABLE (intReportingComponentId INT)
	DECLARE @tmpInvoiceDetailTax TFInvoiceDetailTax

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	END

	--DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
		
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

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC

		SELECT TOP 1 @FormCode = strFormCode
			, @ScheduleCode = strScheduleCode
			, @TaxAuthorityCode = strTaxAuthorityCode
		FROM tblTFReportingComponent
		LEFT JOIN tblTFTaxAuthority ON tblTFTaxAuthority.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
		WHERE intReportingComponentId = @RCId

		IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId)) 
		BEGIN
			INSERT INTO @tmpInvoiceTransaction(intId
				, intInvoiceDetailId
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
				, strCustomerFEIN
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFEIN
				, strConsignorName
				, strConsignorFEIN
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, strHeaderFederalTaxID
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
				, strEmail)
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
					--, ISNULL(tblARInvoiceDetailTax.dblTax, 0.000000) AS dblTax
					, 0.000000 AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, CASE WHEN tblARInvoice.strType = 'Transport Delivery' THEN tblARInvoice.strBOLNumber ELSE tblARInvoice.strInvoiceNumber END AS strBillOfLading
					, tblARInvoice.dtmDate
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN NULL ELSE DestinationCounty.strCounty END) AS strDestinationCounty
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
					, CASE WHEN SupplyPointLoc.strCity IS NOT NULL THEN SupplyPointLoc.strCity WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strSiteCity ELSE tblSMCompanyLocation.strCity END AS strOriginCity
					, NULL AS strOriginCounty
					, CASE WHEN SupplyPointLoc.strState IS NOT NULL THEN SupplyPointLoc.strState WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strTaxState ELSE tblSMCompanyLocation.strStateProvince END AS strOriginState
					, tblEMEntity.strName
					, tblEMEntity.strFederalTaxId AS strCustomerFEIN
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, Transporter.strName AS strTransporterName
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, NULL AS strConsignorName
					, NULL AS strConsignorFEIN
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
				FROM tblTFReportingComponent
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
					LEFT JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
						LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
							LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
						LEFT JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
							LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
							LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
							LEFT JOIN tblTFTerminalControlNumber ON  tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
						LEFT JOIN  tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
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
						OR ((SupplyPointLoc.strState IS NULL AND tblCFSite.strTaxState IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblCFSite.strTaxState IS NOT NULL AND tblCFSite.strTaxState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((SupplyPointLoc.strState IS NULL AND tblCFSite.strTaxState IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblCFSite.strTaxState IS NOT NULL AND tblCFSite.strTaxState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')) 
							OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND ((tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Customer') OR
						(tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer') OR
						(tblTRLoadReceipt.strOrigin IS NULL OR tblTRLoadDistributionHeader.strDestination IS NULL))
					AND ( 
						((SELECT COUNT(*) FROM tblTFReportingComponent WHERE intReportingComponentId = @RCId AND strScheduleCode IN ('5CRD', '6CRD')) > 0 AND tblARInvoice.strType = 'CF Tran' ) 
						OR 
						((SELECT COUNT(*) FROM tblTFReportingComponent WHERE intReportingComponentId = @RCId AND strScheduleCode IN ('5CRD', '6CRD')) = 0) 
					)
				) Transactions
		END
		ELSE
		BEGIN
			INSERT INTO @tmpInvoiceTransaction(intId
				, intInvoiceDetailId
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
				, strCustomerFEIN
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, strTransporterFEIN
				, strConsignorName
				, strConsignorFEIN
				, strTerminalControlNumber
				, strVendorName
				, strVendorFederalTaxId
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, strHeaderFederalTaxID
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
				, strEmail)
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
					--, ISNULL(tblARInvoiceDetailTax.dblTax, 0.000000) AS dblTax
					, 0.000000 AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, CASE WHEN tblARInvoice.strType = 'Transport Delivery' THEN tblARInvoice.strBOLNumber ELSE tblARInvoice.strInvoiceNumber END AS strBillOfLading
					, tblARInvoice.dtmDate
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN NULL ELSE DestinationCounty.strCounty END) AS strDestinationCounty
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
					, CASE WHEN SupplyPointLoc.strCity IS NOT NULL THEN SupplyPointLoc.strCity WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strSiteCity ELSE tblSMCompanyLocation.strCity END AS strOriginCity
					, NULL AS strOriginCounty
					, CASE WHEN SupplyPointLoc.strState IS NOT NULL THEN SupplyPointLoc.strState WHEN tblCFTransaction.intInvoiceId IS NOT NULL AND tblARInvoice.strType = 'CF Tran' THEN tblCFSite.strTaxState ELSE tblSMCompanyLocation.strStateProvince END AS strOriginState
					, tblEMEntity.strName
					, tblEMEntity.strFederalTaxId AS strCustomerFEIN
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, Transporter.strName AS strTransporterName
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, NULL AS strConsignorName
					, NULL AS strConsignorFEIN
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
				FROM tblTFReportingComponent
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
				INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
					LEFT JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
						LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
							LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
						LEFT JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
							LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
							LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
							LEFT JOIN tblTFTerminalControlNumber ON  tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
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
						OR ((SupplyPointLoc.strState IS NULL AND tblCFSite.strTaxState IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (tblCFSite.strTaxState IS NOT NULL AND tblCFSite.strTaxState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((SupplyPointLoc.strState IS NULL AND tblCFSite.strTaxState IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (tblCFSite.strTaxState IS NOT NULL AND tblCFSite.strTaxState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')) 
							OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((tblARInvoice.intFreightTermId = 3 AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (ISNULL(tblARInvoice.intFreightTermId, 0) != 3 AND tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
						)
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR tblARCustomerAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND ((tblTRLoadReceipt.strOrigin = 'Terminal' AND tblTRLoadDistributionHeader.strDestination = 'Customer') OR
						(tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer') OR
						(tblTRLoadReceipt.strOrigin IS NULL OR tblTRLoadDistributionHeader.strDestination IS NULL))
					AND ( 
						((SELECT COUNT(*) FROM tblTFReportingComponent WHERE intReportingComponentId = @RCId AND strScheduleCode IN ('5CRD', '6CRD')) > 0 AND tblARInvoice.strType = 'CF Tran' ) 
						OR 
						((SELECT COUNT(*) FROM tblTFReportingComponent WHERE intReportingComponentId = @RCId AND strScheduleCode IN ('5CRD', '6CRD')) = 0) 
					)
				) Transactions
		END

		-- Diversion
		UPDATE @tmpInvoiceTransaction SET dblQtyShipped = (dblQtyShipped * -1), dblGross = (dblGross * -1), dblNet = (dblNet * -1), dblBillQty = (dblBillQty * -1) WHERE ysnDiversion = 1 AND strFormCode = 'SF-900' AND strScheduleCode = '11' AND (strDiversionOriginalDestinationState = 'IN' AND strDestinationState <> 'IN')

		-- MFT-1219 - To Distinct the Account Status Code
		DECLARE @tmpInvoiceDetailUniqueAccountStatusCode TABLE(
			intId INT, 
			intInvoiceDetailId INT,
			PRIMARY KEY CLUSTERED ([intId] ASC) WITH (IGNORE_DUP_KEY = OFF),
			UNIQUE NONCLUSTERED ([intId] ASC, [intInvoiceDetailId] ASC))
		
		INSERT INTO @tmpInvoiceDetailUniqueAccountStatusCode
			SELECT MIN(intId) intId, intInvoiceDetailId FROM @tmpInvoiceTransaction 
			GROUP BY intInvoiceDetailId HAVING (COUNT(intInvoiceDetailId) > 1)

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInvoiceDetailUniqueAccountStatusCode)
		BEGIN
			DECLARE @intIdUASC NVARCHAR(30) = NULL, @intDetailInvoiceUASC INT = NULL

			SELECT TOP 1 @intIdUASC = intId, @intDetailInvoiceUASC = intInvoiceDetailId FROM @tmpInvoiceDetailUniqueAccountStatusCode

			DELETE FROM @tmpInvoiceTransaction WHERE intId <> @intIdUASC AND intInvoiceDetailId = @intDetailInvoiceUASC

			DELETE FROM @tmpInvoiceDetailUniqueAccountStatusCode WHERE intId = @intIdUASC --AND intInvoiceDetailId = @intDetailInvoiceUASC
		END

		-- HAS TAX CRITERIA
		IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId))
		BEGIN

			-- TRANSACTION WITHOUT TAX CODE
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN	
				DELETE @tmpInvoiceTransaction WHERE intInvoiceDetailId IN (
					SELECT DISTINCT InvTran.intInvoiceDetailId 
					FROM @tmpInvoiceTransaction InvTran
					INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId = InvTran.intInvoiceDetailId
					WHERE tblARInvoiceDetailTax.intTaxCodeId IS NULL	
				)
			END

			-- TRANSACTION WITH TAX CODE
			INSERT INTO @tmpInvoiceDetailTax (intInvoiceDetailId, intTaxCodeId, strCriteria, dblTax)
			SELECT InvTran.intInvoiceDetailId, tblARInvoiceDetailTax.intTaxCodeId, tblTFReportingComponentCriteria.strCriteria, tblARInvoiceDetailTax.dblTax
			FROM @tmpInvoiceTransaction InvTran
				INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId = InvTran.intInvoiceDetailId
				INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
				INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId

			WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInvoiceDetailTax)
			BEGIN		
				DECLARE @InvoiceDetailId INT = NULL, @intTaxCodeId INT = NULL, @strCriteria NVARCHAR(100) = NULL,  @dblTax NUMERIC(18,8) = NULL

				SELECT TOP 1 @InvoiceDetailId = intInvoiceDetailId, @intTaxCodeId = intTaxCodeId, @strCriteria = strCriteria, @dblTax = dblTax FROM @tmpInvoiceDetailTax

				IF(@strCriteria = '<> 0' AND @dblTax = 0)	
				BEGIN
					DELETE FROM @tmpInvoiceTransaction WHERE intInvoiceDetailId = @InvoiceDetailId										 
				END
				ELSE IF (@strCriteria = '= 0' AND @dblTax > 0)
				BEGIN
					DELETE FROM @tmpInvoiceTransaction WHERE intInvoiceDetailId = @InvoiceDetailId										 
				END

				DELETE @tmpInvoiceDetailTax WHERE intInvoiceDetailId = @InvoiceDetailId AND intTaxCodeId = @intTaxCodeId

			END

			DELETE @tmpInvoiceDetailTax

			-- TRANSACTION NOT MAPPED ON MFT TAX CATEGORY
			IF (EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId AND strCriteria = '<> 0'))
			BEGIN 	
				DELETE @tmpInvoiceTransaction WHERE intInvoiceDetailId IN (
					SELECT DISTINCT InvTran.intInvoiceDetailId
					FROM @tmpInvoiceTransaction InvTran
						INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId = InvTran.intInvoiceDetailId 
						INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
						INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
						INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
						INNER JOIN tblTFReportingComponent ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentCriteria.intReportingComponentId
						WHERE tblTFReportingComponent.intReportingComponentId = @RCId AND ISNULL(tblARInvoiceDetailTax.dblTax, 0) = 0
					)
			END

		END
		ELSE
		BEGIN
			-- NO TAX CRITERIA SETUP
			-- REMOVE ALL INVOICE WITH ZERO TAX
			DELETE @tmpInvoiceTransaction WHERE intInvoiceDetailId IN (
				SELECT DISTINCT InvTran.intInvoiceDetailId 
				FROM @tmpInvoiceTransaction InvTran
					INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId = InvTran.intInvoiceDetailId 
				WHERE ISNULL(tblARInvoiceDetailTax.dblTax, 0) = 0
			)
		END
				
		--INVENTORY TRANSFER - Track MFT Activity
		INSERT INTO @tmpInvoiceTransaction(intId
			, intInvoiceDetailId
			, intTaxAuthorityId
			, strFormCode
			, intReportingComponentId
			, strScheduleCode
			, strType
			--, intProductCode
			--, strProductCode
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
			, strCustomerFEIN
			--, strAccountStatusCode
			, strShipVia
			, strTransporterLicense
			, strTransportationMode
			, strTransporterName
			, strTransporterFEIN
			, strConsignorName
			, strConsignorFEIN
			--, strTerminalControlNumber
			, strVendorName
			, strVendorFederalTaxId
			, strHeaderCompanyName
			, strHeaderAddress
			, strHeaderCity
			, strHeaderState
			, strHeaderZip
			, strHeaderPhone
			, strHeaderStateTaxID
			, strHeaderFederalTaxID
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
			, strEmail)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId) AS intId, *
		FROM (SELECT DISTINCT NULL AS intInvoiceDetailId
				, tblTFReportingComponent.intTaxAuthorityId
				, tblTFReportingComponent.strFormCode
				, tblTFReportingComponent.intReportingComponentId
				, tblTFReportingComponent.strScheduleCode
				, tblTFReportingComponent.strType
				--, tblTFProductCode.intProductCodeId
				--, tblTFProductCode.strProductCode
				, tblICInventoryTransferDetail.intItemId
				, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
				, tblICInventoryTransferDetail.dblQuantity AS dblGross
				, tblICInventoryTransferDetail.dblQuantity AS dblNet
				, tblICInventoryTransferDetail.dblQuantity
				, NULL AS dblTax
				, NULL AS dblTaxExempt
				, NULL AS strInvoiceNumber
				, NULL AS strPONumber
				, tblTRLoadReceipt.strBillOfLading AS strBOLNumber
				, CASE WHEN tblTRLoadHeader.dtmLoadDateTime IS NULL THEN tblICInventoryTransfer.dtmTransferDate ELSE tblTRLoadHeader.dtmLoadDateTime END AS dtmDate
				, tblSMCompanyLocation.strCity AS strDestinationCity
				, NULL AS strDestinationCounty
				, tblSMCompanyLocation.strStateProvince AS strDestinationState
				, ShipFromLoc.strCity AS strOriginCity
				, ShipFromLoc.strCountry AS strOriginCounty
				, ShipFromLoc.strStateProvince AS strOriginState
				, tblSMCompanySetup.strCompanyName AS strCustomerName
				, tblSMCompanySetup.strEin AS strCustomerFEIN
				--, NULL AS strAccountStatusCode
				, tblSMShipVia.strShipVia
				, tblSMShipVia.strTransporterLicense
				, tblSMTransportationMode.strCode
				, tblEMEntity.strName AS strTransporterName
				, tblEMEntity.strFederalTaxId AS strTransporterFEIN
				, tblEMEntity.strName AS strConsignorName
				, tblEMEntity.strFederalTaxId AS strConsignorFEIN
				--, tblTFTerminalControlNumber.strTerminalControlNumber
				, EntityAPVendor.strName AS strVendorName
				, EntityAPVendor.strFederalTaxId AS strVendorFEIN
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
			--	LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
			--	LEFT JOIN tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId
			--	LEFT JOIN tblSMTaxCode OriginCounty ON OriginCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
			--	LEFT JOIN tblTFTerminalControlNumber ON  tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
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
					(tblTRLoadReceipt.strOrigin IS NULL OR tblTRLoadDistributionHeader.strDestination IS NULL))
		) tblTransactions

		-- MFT-1228
		IF(@TaxAuthorityCode = 'OR')
		BEGIN
			IF (@ScheduleCode = '5CRD' OR @ScheduleCode = '6CRD')
			BEGIN
				-- Include all CF Trans for schedule 5CRD and 6CRD 
				DELETE @tmpInvoiceTransaction WHERE intId IN (
					SELECT Trans.intId
					FROM @tmpInvoiceTransaction Trans
					LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intInvoiceDetailId
					LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
					WHERE Trans.strTransactionType = 'Invoice'
					AND Trans.intReportingComponentId = @RCId
					AND Invoice.strType <> 'CF Tran'
				)
			END
			ELSE IF (@ScheduleCode IN ('5BLK', '6BLK', '5', '5LO', '6', '7', '7E', '8', '10', '10AC', '10AD', '10D'))
			BEGIN
				-- Exclude all non CF Trans for schedule 5BLK and 6BLK
				DELETE @tmpInvoiceTransaction WHERE intId IN (
					SELECT Trans.intId
					FROM @tmpInvoiceTransaction Trans
					LEFT JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceDetailId = Trans.intInvoiceDetailId
					LEFT JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
					WHERE Trans.strTransactionType = 'Invoice'
					AND Trans.intReportingComponentId = @RCId
					AND Invoice.strType = 'CF Tran'
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
				, strEmail)
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
				, REPLACE(strCustomerFEIN, '-', '')
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strTransporterName
				, REPLACE(strTransporterFEIN, '-', '')
				, strConsignorName
				, REPLACE(strConsignorFEIN, '-', '')
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
				, strHeaderStateTaxID
				, REPLACE(strHeaderFederalTaxID, '-', '')
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
			FROM @tmpInvoiceTransaction Trans
		END
		
		IF(NOT EXISTS (SELECT TOP 1 1 FROM @tmpInvoiceTransaction WHERE intReportingComponentId = @RCId) AND @IsEdi = 0)
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intReportingComponentId
				, strProductCode
				, dtmDate
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTransactionType)
			VALUES (@Guid
				, @RCId
				, 'No record found.'
				, GETDATE()
				, @DateFrom
				, @DateTo
				, 'Invoice')
		END

		DELETE FROM @tmpInvoiceTransaction
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