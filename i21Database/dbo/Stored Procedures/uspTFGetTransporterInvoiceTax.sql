CREATE PROCEDURE [dbo].[uspTFGetTransporterInvoiceTax]
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

	DECLARE @tmpInvoiceTransaction TFInvoiceTransaction
	, @tmpInvoiceDetail TFInvoiceDetailTransaction
	, @tmpInventoryTransaction TFTransaction
	, @tmpInventoryDetail TFInventoryReceiptDetailTransaction
	, @tmpDistInventoryDetail TFTransaction

	DECLARE @tmpRC TABLE (intReportingComponentId INT)

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	END

	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
		
	INSERT INTO @tmpRC
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE @tmpRC where intReportingComponentId = ''

	WHILE EXISTS(SELECT TOP 1 1 FROM @tmpRC)
	BEGIN

		DECLARE @RCId INT = NULL
		DECLARE @tblTaxCriteria TABLE (
			intCriteriaId INT,
			intTaxCategoryId INT,
			strTaxCategory NVARCHAR(500),
			strCriteria NVARCHAR(100),
			intTaxCodeId INT)

		DECLARE @intCriteriaId INT = NULL, @strCriteriaTaxCodeId NVARCHAR(10) = NULL, @strCriteria NVARCHAR(10) = NULL, @intTaxCategoryId INT = NULL, @intTransTaxCategoryId INT = NULL
				

		SELECT TOP 1 @RCId = intReportingComponentId FROM @tmpRC
			
		-- INVOICE
		-- GET RECORDS WITH TAX CRITERIA
		INSERT INTO @tmpInvoiceDetail 
			SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId, tblARInvoiceDetailTax.intTaxCodeId
			FROM tblTFReportingComponent
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
					INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
					LEFT JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId= tblARInvoiceDetail.intInvoiceDetailId	
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
					INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
					INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
					LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
							LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
					INNER JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblARInvoice.intCompanyLocationId
					INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
						INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblARCustomer.intEntityId
					LEFT JOIN tblARCustomerAccountStatus ON tblARCustomerAccountStatus.intEntityCustomerId = tblARCustomer.intEntityId
				WHERE tblARInvoice.ysnPosted = 1 
					AND tblTFReportingComponent.intReportingComponentId = @RCId
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR ((SupplyPointLoc.strState IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((SupplyPointLoc.strState IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
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
						(tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer'))

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
					, ISNULL(tblARInvoiceDetailTax.dblTax, 0.000000) AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, tblARInvoice.strBOLNumber
					, tblARInvoice.dtmDate
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN NULL ELSE DestinationCounty.strCounty END) AS strDestinationCounty
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
					, CASE WHEN SupplyPointLoc.strCity IS NULL THEN tblSMCompanyLocation.strCity ELSE SupplyPointLoc.strCity END AS strOriginCity
					, NULL AS strOriginCounty
					, CASE WHEN SupplyPointLoc.strState IS NULL THEN tblSMCompanyLocation.strStateProvince ELSE SupplyPointLoc.strState END AS strOriginState
					, tblEMEntity.strName
					, tblEMEntity.strFederalTaxId AS strCustomerFEIN
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, CASE WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoice.intShipViaId IS NULL THEN (SELECT TOP 1 tblEMEntity.strName from tblSMShipVia INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblSMShipVia.intEntityId WHERE tblSMShipVia.ysnCompanyOwnedCarrier = 1 ORDER BY tblEMEntity.intEntityId) ELSE Transporter.strName END AS strTransporterName
					, CASE WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoice.intShipViaId IS NULL THEN (SELECT TOP 1 tblEMEntity.strFederalTaxId from tblSMShipVia INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblSMShipVia.intEntityId WHERE tblSMShipVia.ysnCompanyOwnedCarrier = 1 ORDER BY tblEMEntity.intEntityId) ELSE Transporter.strFederalTaxId END AS strTransporterFEIN
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
					LEFT JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId= tblARInvoiceDetail.intInvoiceDetailId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
						INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
							LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
						INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
							LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
							LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
							LEFT JOIN tblTFTerminalControlNumber ON  tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
						LEFT JOIN  tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
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
						OR ((SupplyPointLoc.strState IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((SupplyPointLoc.strState IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
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
						(tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer'))
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
					, ISNULL(tblARInvoiceDetailTax.dblTax, 0.000000) AS dblTax
					, NULL AS dblTaxExempt
					, tblARInvoice.strInvoiceNumber
					, tblARInvoice.strPONumber
					, tblARInvoice.strBOLNumber
					, tblARInvoice.dtmDate
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN NULL ELSE DestinationCounty.strCounty END) AS strDestinationCounty
					, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
					, CASE WHEN SupplyPointLoc.strCity IS NULL THEN tblSMCompanyLocation.strCity ELSE SupplyPointLoc.strCity END AS strOriginCity
					, NULL AS strOriginCounty
					, CASE WHEN SupplyPointLoc.strState IS NULL THEN tblSMCompanyLocation.strStateProvince ELSE SupplyPointLoc.strState END AS strOriginState
					, tblEMEntity.strName
					, tblEMEntity.strFederalTaxId AS strCustomerFEIN
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, CASE WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoice.intShipViaId IS NULL THEN (SELECT TOP 1 tblEMEntity.strName from tblSMShipVia INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblSMShipVia.intEntityId WHERE tblSMShipVia.ysnCompanyOwnedCarrier = 1 ORDER BY tblEMEntity.intEntityId) ELSE Transporter.strName END AS strTransporterName
					, CASE WHEN tblARInvoice.strType = 'Tank Delivery' AND tblARInvoice.intShipViaId IS NULL THEN (SELECT TOP 1 tblEMEntity.strFederalTaxId from tblSMShipVia INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblSMShipVia.intEntityId WHERE tblSMShipVia.ysnCompanyOwnedCarrier = 1 ORDER BY tblEMEntity.intEntityId) ELSE Transporter.strFederalTaxId END AS strTransporterFEIN
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
					LEFT JOIN tblARInvoiceDetailTax ON tblARInvoiceDetailTax.intInvoiceDetailId= tblARInvoiceDetail.intInvoiceDetailId
				INNER JOIN tblARInvoice ON tblARInvoice.intInvoiceId = tblARInvoiceDetail.intInvoiceId
					INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadDistributionHeaderId = tblARInvoice.intLoadDistributionHeaderId
						INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
							LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
						INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
							LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
							LEFT JOIN tblEMEntityLocation SupplyPointLoc ON tblTRSupplyPoint.intEntityLocationId = SupplyPointLoc.intEntityLocationId
							LEFT JOIN tblTFTerminalControlNumber ON  tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblARInvoice.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
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
						OR ((SupplyPointLoc.strState IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
						)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR ((SupplyPointLoc.strState IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
							OR (SupplyPointLoc.strState IS NOT NULL AND SupplyPointLoc.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
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
						(tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Customer'))
				) Transactions
		END

		-- Diversion
		UPDATE @tmpInvoiceTransaction SET dblQtyShipped = (dblQtyShipped * -1), dblGross = (dblGross * -1), dblNet = (dblNet * -1), dblBillQty = (dblBillQty * -1) WHERE ysnDiversion = 1 AND strFormCode = 'SF-900' AND strScheduleCode = '11' AND (strDiversionOriginalDestinationState = 'IN' AND strDestinationState <> 'IN')

		-- MFT-1219 - To Distinct the Account Status Code
		DECLARE @tmpInvoiceDetailUniqueAccountStatusCode TABLE(intId INT, intInvoiceDetailId INT)
		
		INSERT INTO @tmpInvoiceDetailUniqueAccountStatusCode
			SELECT MIN(intId) intId, intInvoiceDetailId FROM @tmpInvoiceTransaction 
			GROUP BY intInvoiceDetailId HAVING (COUNT(intInvoiceDetailId) > 1)

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInvoiceDetailUniqueAccountStatusCode)
		BEGIN
			DECLARE @intIdUASC NVARCHAR(30) = NULL, @intDetailInvoiceUASC INT = NULL

			SELECT TOP 1 @intIdUASC = intId, @intDetailInvoiceUASC = intInvoiceDetailId FROM @tmpInvoiceDetailUniqueAccountStatusCode

			DELETE FROM @tmpInvoiceTransaction WHERE intId <> @intIdUASC AND intInvoiceDetailId = @intDetailInvoiceUASC

			DELETE FROM @tmpInvoiceDetailUniqueAccountStatusCode WHERE intId = @intIdUASC AND intInvoiceDetailId = @intDetailInvoiceUASC
		END

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInvoiceDetail) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN

			DECLARE @InvoiceDetailId NVARCHAR(30) = NULL, @intInvoiceDetailTaxCodeId INT = NULL

			SELECT TOP 1 @InvoiceDetailId = intInvoiceDetailId, @intInvoiceDetailTaxCodeId = intTaxCodeId FROM @tmpInvoiceDetail

			DELETE FROM @tblTaxCriteria
			
			-- Get MFT Tax Criteria
			INSERT INTO @tblTaxCriteria
				SELECT ROW_NUMBER() OVER(ORDER BY intTaxCategoryId, strTaxCategory) AS intCriteriaId, *
				FROM (
					SELECT tblTFTaxCategory.intTaxCategoryId , tblTFTaxCategory.strTaxCategory, tblTFReportingComponentCriteria.strCriteria, tblSMTaxCode.intTaxCodeId
					FROM tblTFReportingComponent
					INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
					LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
					WHERE tblTFReportingComponent.intReportingComponentId = @RCId
				) Transactions

			WHILE EXISTS (SELECT TOP 1 1 FROM @tblTaxCriteria) -- LOOP ON TAX CATEGORY
			BEGIN
	
				SET @intCriteriaId = NULL
				SET @strCriteriaTaxCodeId = NULL
				SET @strCriteria = NULL
				SET @intTaxCategoryId = NULL
				SET @intTransTaxCategoryId = NULL

				SELECT TOP 1 @intCriteriaId = intCriteriaId,  @strCriteriaTaxCodeId = intTaxCodeId, @strCriteria = strCriteria, @intTaxCategoryId = intTaxCategoryId FROM @tblTaxCriteria

				-- GET Tax Transaction Detail
				SELECT TOP 1 @intTransTaxCategoryId = tblSMTaxCode.intTaxCategoryId 
				FROM tblARInvoiceDetailTax 
				LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId 
				LEFT JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				WHERE intInvoiceDetailId = @InvoiceDetailId AND tblTFTaxCategory.intTaxCategoryId = @intTaxCategoryId

				IF(@intInvoiceDetailTaxCodeId IS NULL) -- DOES NOT HAVE THE TAX CODE
				BEGIN
					IF(@strCriteria = '<> 0')
					BEGIN
						DELETE FROM @tmpInvoiceTransaction WHERE intInvoiceDetailId = @InvoiceDetailId										 
						BREAK
					END
				END
				ELSE IF (@intInvoiceDetailTaxCodeId IS NOT NULL AND @intTransTaxCategoryId IS NULL) -- NOT MAPPED ON MFT TAX CATEGORY
				BEGIN
					IF(@strCriteria = '<> 0')
					BEGIN
						DELETE FROM @tmpInvoiceTransaction WHERE intInvoiceDetailId = @InvoiceDetailId										 
						BREAK
					END
				END
				ELSE
				BEGIN
					DECLARE @tblTempInvoiceDetail TABLE (intInvoiceDetailId INT)
					DECLARE @QueryrInvoiceDetailId NVARCHAR(MAX) = NULL
					-- Check if satisfy the tax criteria
					SET @QueryrInvoiceDetailId =  'SELECT DISTINCT tblARInvoiceDetailTax.intInvoiceDetailId FROM tblARInvoiceDetail' +
						' INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId' +
						' WHERE tblARInvoiceDetailTax.intInvoiceDetailId IN(''' + @InvoiceDetailId + ''')' +
						' AND (tblARInvoiceDetailTax.intTaxCodeId = ''' + @strCriteriaTaxCodeId + ''') ' +
						' AND (tblARInvoiceDetailTax.dblTax ' + @strCriteria + ')'

					INSERT INTO @tblTempInvoiceDetail

					EXEC(@QueryrInvoiceDetailId)

					IF NOT EXISTS (SELECT TOP 1 1 FROM @tblTempInvoiceDetail) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
					BEGIN
						DELETE FROM @tmpInvoiceTransaction WHERE intInvoiceDetailId = @InvoiceDetailId								 
						BREAK
					END

					DELETE FROM @tblTempInvoiceDetail

				END

				DELETE FROM @tblTaxCriteria WHERE intCriteriaId = @intCriteriaId

			END	

			DELETE FROM @tmpInvoiceDetail WHERE intInvoiceDetailId = @InvoiceDetailId

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
				INNER JOIN tblSMCompanyLocation ShipFromLoc ON ShipFromLoc.intCompanyLocationId = tblICInventoryTransfer.intFromLocationId
			INNER JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intLoadReceiptId = tblICInventoryTransferDetail.intSourceId
				LEFT JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
				LEFT JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityId = EntityAPVendor.intEntityId
				--LEFT JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId 
				--LEFT JOIN tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId
				--LEFT JOIN tblSMTaxCode OriginCounty ON OriginCounty.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
				--LEFT JOIN tblTFTerminalControlNumber ON  tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
				LEFT JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = tblICInventoryTransfer.intToLocationId
			INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
			INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
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
				AND tblTRLoadReceipt.strOrigin = 'Location' AND tblTRLoadDistributionHeader.strDestination = 'Location'
		) tblTransactions

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

		-- INVENTORY
		-- GET RECORDS WITH TAX CRITERIA
		INSERT INTO @tmpInventoryDetail
		SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId, tblICInventoryReceiptItemTax.intTaxCodeId
			FROM tblTFReportingComponent 
			INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId = tblICItemMotorFuelTax.intItemId
				LEFT JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId
					--LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
			INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
				INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
				INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
				LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
				LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId
				INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
			LEFT JOIN tblTRLoadReceipt ON tblTRLoadReceipt.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId
			LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
			LEFT JOIN tblTRLoadDistributionHeader ON tblTRLoadDistributionHeader.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
			LEFT JOIN (
					SELECT  
						tblTRLoadDistributionDetail.intLoadDistributionDetailId,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.intItemId ELSE  vyuTRGetLoadBlendIngredient.intIngredientItemId END intItemId,
						tblTRLoadDistributionHeader.intLoadHeaderId, 
						tblTRLoadDistributionHeader.intCompanyLocationId, 
						tblTRLoadDistributionHeader.intLoadDistributionHeaderId,
						tblTRLoadDistributionHeader.intShipToLocationId,
						tblTRLoadDistributionHeader.intEntityCustomerId,
						tblTRLoadDistributionHeader.strDestination,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.dblUnits ELSE  vyuTRGetLoadBlendIngredient.dblQuantity END dblUnits
					 FROM tblTRLoadDistributionDetail INNER JOIN tblTRLoadDistributionHeader 
					 ON tblTRLoadDistributionDetail.intLoadDistributionHeaderId = tblTRLoadDistributionHeader.intLoadDistributionHeaderId
					 LEFT JOIN vyuTRGetLoadBlendIngredient ON vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId = tblTRLoadDistributionDetail.intLoadDistributionDetailId
				) DistributionDetail ON DistributionDetail.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND DistributionDetail.intItemId = tblTRLoadReceipt.intItemId
				LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = tblTRLoadDistributionHeader.intCompanyLocationId
				LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = tblTRLoadDistributionHeader.intShipToLocationId
		WHERE tblICInventoryReceipt.ysnPosted = 1
			AND tblTFReportingComponent.intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))		
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR (tblTRLoadDistributionHeader.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					OR tblTRLoadDistributionHeader.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
					OR tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
				))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR (tblTRLoadDistributionHeader.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					OR tblTRLoadDistributionHeader.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					OR tblTRLoadDistributionHeader.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
				))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
			AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
			AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
			AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
			AND tblTRLoadReceipt.strOrigin = 'Terminal' AND DistributionDetail.strDestination = 'Location'

		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId)
		BEGIN
			INSERT INTO @tmpInventoryTransaction(intId
				, intInventoryReceiptItemId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				--, intProductCodeId
				--, strProductCode
				, strBillOfLading
				, dblReceived
				, dblGross
				, dblNet
				, dblBillQty
				, dtmReceiptDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFEIN
				, strTransporterFEIN
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, strHeaderFederalTaxID
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, strTerminalControlNumber
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strCustomerName
				, strCustomerFederalTaxId
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName
				, strEmail)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId, *
			FROM (SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, strType = tblTFReportingComponent.strType
					, tblICInventoryReceiptItem.intItemId
					--, tblTFReportingComponentProductCode.intProductCodeId
					--, tblTFProductCode.strProductCode
					, tblICInventoryReceipt.strBillOfLading
					--, tblICInventoryReceiptItem.dblReceived
					--, tblICInventoryReceiptItem.dblGross
					--, tblICInventoryReceiptItem.dblNet
					--, tblICInventoryReceiptItem.dblBillQty
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblReceived END dblReceived
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblGross END dblGross
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblNet END dblNet
					, tblICInventoryReceiptItem.dblBillQty
					--(CASE WHEN tblICInventoryReceiptItem.dblBillQty >= tblTRLoadDistributionDetail.dblUnits THEN tblTRLoadDistributionDetail.dblUnits ELSE 0 END) 
					--ELSE tblICInventoryReceiptItem.dblBillQty END dblBillQty
					, tblICInventoryReceipt.dtmReceiptDate
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode
					, Vendor.strName AS strVendorName
					, Transporter.strName AS strTransporterName
					, Vendor.strFederalTaxId AS strVendorFEIN
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxID = tblSMCompanySetup.strEin
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					--, tblSMCompanyLocation.strStateProvince
					--, tblSMCompanyLocation.strCity
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strStateProvince WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strState ELSE tblSMCompanyLocation.strStateProvince END strDestinationState
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strCity WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strCity ELSE tblSMCompanyLocation.strCity END strDestinationCity
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = tblTRLoadReceipt.strBillOfLading
					, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
					, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
				FROM tblTFReportingComponent 
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFProductCode.intProductCodeId		
				INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
				INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
					INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
					INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
					LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblICInventoryReceipt.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId 
						LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
				LEFT JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId  = tblICInventoryReceipt.intInventoryReceiptId AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
				LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
				LEFT JOIN (
					SELECT  
						tblTRLoadDistributionDetail.intLoadDistributionDetailId,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.intItemId ELSE  vyuTRGetLoadBlendIngredient.intIngredientItemId END intItemId,
						tblTRLoadDistributionHeader.intLoadHeaderId, 
						tblTRLoadDistributionHeader.intCompanyLocationId, 
						tblTRLoadDistributionHeader.intLoadDistributionHeaderId,
						tblTRLoadDistributionHeader.intShipToLocationId,
						tblTRLoadDistributionHeader.intEntityCustomerId,
						tblTRLoadDistributionHeader.strDestination,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.dblUnits ELSE  vyuTRGetLoadBlendIngredient.dblQuantity END dblUnits
					 FROM tblTRLoadDistributionDetail INNER JOIN tblTRLoadDistributionHeader 
					 ON tblTRLoadDistributionDetail.intLoadDistributionHeaderId = tblTRLoadDistributionHeader.intLoadDistributionHeaderId
					 LEFT JOIN vyuTRGetLoadBlendIngredient ON vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId = tblTRLoadDistributionDetail.intLoadDistributionDetailId
				) DistributionDetail ON DistributionDetail.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND DistributionDetail.intItemId = tblTRLoadReceipt.intItemId
					LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = DistributionDetail.intCompanyLocationId
					LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = DistributionDetail.intShipToLocationId
				LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = DistributionDetail.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblICInventoryReceipt.ysnPosted = 1
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					--	OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					--	OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                    ))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					    OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND tblTRLoadReceipt.strOrigin = 'Terminal' AND DistributionDetail.strDestination = 'Location'
				) tblTFTransaction
		END
		ELSE
		BEGIN
			INSERT INTO @tmpInventoryTransaction(intId
				, intInventoryReceiptItemId
				, intTaxAuthorityId
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intItemId
				--, intProductCodeId
				--, strProductCode
				, strBillOfLading
				, dblReceived
				, dblGross
				, dblNet
				, dblBillQty
				, dtmReceiptDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFEIN
				, strTransporterFEIN
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, strHeaderFederalTaxID
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, strTerminalControlNumber
				, strTransporterIdType
				, strVendorIdType
				, strCustomerIdType
				, strVendorInvoiceNumber
				, strCustomerLicenseNumber
				, strCustomerAccountStatusCode
				, strCustomerStreetAddress
				, strCustomerZipCode
				, strCustomerName
				, strCustomerFederalTaxId
				, strReportingComponentNote
				, strDiversionNumber
				, strDiversionOriginalDestinationState
				, strTransactionType
				, intTransactionNumberId
				, strVendorLicenseNumber
				, strContactName
				, strEmail)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId, *
			FROM (SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
					, tblTFReportingComponent.intTaxAuthorityId
					, tblTFReportingComponent.strFormCode
					, tblTFReportingComponent.intReportingComponentId
					, tblTFReportingComponent.strScheduleCode
					, strType = tblTFReportingComponent.strType
					, tblICInventoryReceiptItem.intItemId
					--, tblTFReportingComponentProductCode.intProductCodeId
					--, tblTFProductCode.strProductCode
					, tblICInventoryReceipt.strBillOfLading
					--, tblICInventoryReceiptItem.dblReceived
					--, tblICInventoryReceiptItem.dblGross
					--, tblICInventoryReceiptItem.dblNet
					--, tblICInventoryReceiptItem.dblBillQty
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblReceived END dblReceived
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblGross END dblGross
					, CASE WHEN DistributionDetail.intLoadDistributionDetailId IS NOT NULL THEN DistributionDetail.dblUnits  ELSE tblICInventoryReceiptItem.dblNet END dblNet
					, tblICInventoryReceiptItem.dblBillQty
					, tblICInventoryReceipt.dtmReceiptDate
					, tblSMShipVia.strShipVia
					, tblSMShipVia.strTransporterLicense
					, tblSMTransportationMode.strCode	
					, Vendor.strName AS strVendorName
					, Transporter.strName AS strTransporterName
					, Vendor.strFederalTaxId AS strVendorFEIN
					, Transporter.strFederalTaxId AS strTransporterFEIN
					, tblTFCompanyPreference.strCompanyName
					, tblTFCompanyPreference.strTaxAddress
					, tblTFCompanyPreference.strCity
					, tblTFCompanyPreference.strState
					, tblTFCompanyPreference.strZipCode
					, tblTFCompanyPreference.strContactPhone
					, tblSMCompanySetup.strStateTaxID
					, strHeaderFederalTaxID = tblSMCompanySetup.strEin
					, tblEMEntityLocation.strState AS strOriginState
					, tblEMEntityLocation.strCity AS strOriginCity
					, OriginCountyTaxCode.strCounty AS strOriginCounty
					--, tblSMCompanyLocation.strStateProvince
					--, tblSMCompanyLocation.strCity 
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strStateProvince WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strState ELSE tblSMCompanyLocation.strStateProvince END strDestinationState
					, CASE WHEN DistributionDetail.strDestination = 'Location' THEN BulkLocation.strCity WHEN DistributionDetail.strDestination = 'Customer' THEN CustomerLocation.strCity ELSE tblSMCompanyLocation.strCity END strDestinationCity
					, NULL AS strDestinationCounty
					, tblTFTerminalControlNumber.strTerminalControlNumber
					, strTransporterIdType = 'FEIN'
					, strVendorIdType = 'FEIN'
					, strCustomerIdType = 'FEIN'
					, strVendorInvoiceNumber = tblTRLoadReceipt.strBillOfLading
					, strCustomerLicenseNumber = tblTFTaxAuthorityCustomerLicense.strLicenseNumber
					, strCustomerAccountStatusCode = NULL
					, strCustomerStreetAddress = NULL
					, strCustomerZipCode = NULL
					, tblSMCompanySetup.strCompanyName AS strCustomerName
					, tblSMCompanySetup.strEin AS strCustomerFederalTaxId
					, strReportingComponentNote = tblTFReportingComponent.strNote
					, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
					, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
					, strTransactionType = 'Receipt'
					, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId 
					, tblTRSupplyPoint.strFuelDealerId1
					, strContactName = tblTFCompanyPreference.strContactName
					, strEmail = tblTFCompanyPreference.strContactEmail
				FROM tblTFReportingComponent 
				INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
				INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFProductCode.intProductCodeId
				INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
				--INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
					INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
					INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
					LEFT JOIN tblSMTaxCode AS OriginCountyTaxCode ON OriginCountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
					LEFT JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblICInventoryReceipt.intShipViaId
						LEFT JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
						LEFT JOIN tblSMTransportationMode ON  tblSMTransportationMode.strDescription = tblSMShipVia.strTransportationMode
					LEFT JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId 
						LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
					INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
				LEFT JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId AND tblTRLoadReceipt.intItemId = tblICInventoryReceiptItem.intItemId
				LEFT JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
				LEFT JOIN (
					SELECT  
						tblTRLoadDistributionDetail.intLoadDistributionDetailId,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.intItemId ELSE  vyuTRGetLoadBlendIngredient.intIngredientItemId END intItemId,
						tblTRLoadDistributionHeader.intLoadHeaderId, 
						tblTRLoadDistributionHeader.intCompanyLocationId, 
						tblTRLoadDistributionHeader.intLoadDistributionHeaderId,
						tblTRLoadDistributionHeader.intShipToLocationId,
						tblTRLoadDistributionHeader.intEntityCustomerId,
						tblTRLoadDistributionHeader.strDestination,
						CASE WHEN vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId IS NULL THEN tblTRLoadDistributionDetail.dblUnits ELSE  vyuTRGetLoadBlendIngredient.dblQuantity END dblUnits
					 FROM tblTRLoadDistributionDetail INNER JOIN tblTRLoadDistributionHeader 
					 ON tblTRLoadDistributionDetail.intLoadDistributionHeaderId = tblTRLoadDistributionHeader.intLoadDistributionHeaderId
					 LEFT JOIN vyuTRGetLoadBlendIngredient ON vyuTRGetLoadBlendIngredient.intLoadDistributionDetailId = tblTRLoadDistributionDetail.intLoadDistributionDetailId
				) DistributionDetail ON DistributionDetail.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId AND DistributionDetail.intItemId = tblTRLoadReceipt.intItemId
					LEFT JOIN tblSMCompanyLocation BulkLocation ON BulkLocation.intCompanyLocationId = DistributionDetail.intCompanyLocationId
					LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = DistributionDetail.intShipToLocationId
				LEFT JOIN tblTFTaxAuthorityCustomerLicense ON tblTFTaxAuthorityCustomerLicense.intEntityId = DistributionDetail.intEntityCustomerId AND tblTFTaxAuthorityCustomerLicense.intTaxAuthorityId = tblTFReportingComponent.intTaxAuthorityId
				LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
				CROSS JOIN tblSMCompanySetup
				CROSS JOIN tblTFCompanyPreference
				WHERE  tblTFReportingComponent.intReportingComponentId = @RCId
					AND tblICInventoryReceipt.ysnPosted = 1
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
					AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
						OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					--	OR (tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')))
					--AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					--	OR (tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
						OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include')
                    ))
					AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					    OR (DistributionDetail.strDestination IS NULL AND tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Location' AND BulkLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
                        OR DistributionDetail.strDestination = 'Customer' AND CustomerLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude')
					))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
						OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
					AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
						OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					AND (SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					AND tblTRLoadReceipt.strOrigin = 'Terminal' AND DistributionDetail.strDestination = 'Location'
				) tblTFTransaction
		END
		
		-- TR Billed Qty
		INSERT INTO @tmpDistInventoryDetail (intId, intInventoryReceiptItemId, dblReceived, dblBillQty) 
		SELECT DISTINCT intId, intInventoryReceiptItemId, dblReceived, dblBillQty FROM @tmpInventoryTransaction WHERE intInventoryReceiptItemId IN (SELECT DISTINCT intInventoryReceiptItemId FROM @tmpInventoryDetail)	

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpDistInventoryDetail)
		BEGIN
			DECLARE @ReceiptDetailId INT = NULL, @ReceiptDetailItemId INT = NULL, @ReceiptDetailItemReceived NUMERIC(18,6) = NULL, @ReceiptDetailItemBillQty NUMERIC(18,6) = NULL, @RemainingBillQty NUMERIC(18,6) = NULL
			DECLARE @TRDetail TFTransaction 

			SELECT TOP 1 @ReceiptDetailId = intId, @ReceiptDetailItemId = intInventoryReceiptItemId, @ReceiptDetailItemReceived = dblReceived, @ReceiptDetailItemBillQty = dblBillQty FROM @tmpDistInventoryDetail

			IF(@ReceiptDetailItemBillQty >= @ReceiptDetailItemReceived)
			BEGIN
				UPDATE @tmpInventoryTransaction SET dblBillQty = dblNet WHERE intId = @ReceiptDetailId
				SET @RemainingBillQty =  @ReceiptDetailItemBillQty - @ReceiptDetailItemReceived
				UPDATE @tmpDistInventoryDetail SET dblBillQty = @RemainingBillQty
			END
			ELSE
			BEGIN
				UPDATE @tmpInventoryTransaction SET dblBillQty = 0 WHERE intId = @ReceiptDetailId
			END

			DELETE FROM @tmpDistInventoryDetail WHERE intId = @ReceiptDetailId

		END

		WHILE EXISTS(SELECT TOP 1 1 FROM @tmpInventoryDetail) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN	
			
			DECLARE @InventoryReceiptItemId NVARCHAR(30) = NULL, @intInventoryDetailTaxCodeId INT = NULL

			SELECT TOP 1 @InventoryReceiptItemId = intInventoryReceiptItemId, @intInventoryDetailTaxCodeId = intTaxCodeId FROM @tmpInventoryDetail

			DELETE FROM @tblTaxCriteria

			-- Get MFT Tax Criteria
			INSERT INTO @tblTaxCriteria
				SELECT ROW_NUMBER() OVER(ORDER BY intTaxCategoryId, strTaxCategory) AS intCriteriaId, *
				FROM (
					SELECT tblTFTaxCategory.intTaxCategoryId , tblTFTaxCategory.strTaxCategory, tblTFReportingComponentCriteria.strCriteria, tblSMTaxCode.intTaxCodeId
					FROM tblTFReportingComponent
					INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
					INNER JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
					LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
					WHERE tblTFReportingComponent.intReportingComponentId = @RCId
				) Transactions

			WHILE EXISTS (SELECT TOP 1 1 FROM @tblTaxCriteria) -- LOOP ON TAX CATEGORY
			BEGIN

				SET @intCriteriaId = NULL
				SET @strCriteriaTaxCodeId = NULL
				SET @strCriteria = NULL
				SET @intTaxCategoryId = NULL
				SET @intTransTaxCategoryId = NULL

				SELECT TOP 1 @intCriteriaId = intCriteriaId,  @strCriteriaTaxCodeId = intTaxCodeId, @strCriteria = strCriteria, @intTaxCategoryId = intTaxCategoryId FROM @tblTaxCriteria
				
				-- GET Tax Transaction Detail
				SELECT TOP 1 @intTransTaxCategoryId = tblSMTaxCode.intTaxCategoryId 
				FROM tblICInventoryReceiptItemTax 
				LEFT JOIN tblSMTaxCode ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId 
				LEFT JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId
				WHERE tblICInventoryReceiptItemTax.intInventoryReceiptItemId = @InventoryReceiptItemId AND tblTFTaxCategory.intTaxCategoryId = @intTaxCategoryId

				IF(@intInventoryDetailTaxCodeId IS NULL) -- DOES NOT HAVE THE TAX CODE
				BEGIN
					IF(@strCriteria = '<> 0')
					BEGIN
						DELETE FROM @tmpInventoryTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId								 
						BREAK
					END
				END
				ELSE IF (@intInventoryDetailTaxCodeId IS NOT NULL AND @intTransTaxCategoryId IS NULL) -- NOT MAPPED ON MFT TAX CATEGORY
				BEGIN
					IF(@strCriteria = '<> 0')
					BEGIN
						DELETE FROM @tmpInventoryTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId									 
						BREAK
					END
				END
				ELSE
				BEGIN
					DECLARE @tblTempInventoryReceiptDetail TABLE (intInventoryReceiptItemId INT)
					DECLARE @QueryrReceiptItem NVARCHAR(MAX) = NULL
					-- Check if satisfy the tax criteria
					SET @QueryrReceiptItem = 'SELECT DISTINCT tblICInventoryReceiptItemTax.intInventoryReceiptItemId FROM tblICInventoryReceiptItem' 
							+ ' INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId'
							+ '	WHERE  (tblICInventoryReceiptItem.intInventoryReceiptItemId IN(''' + @InventoryReceiptItemId + '''))' 
							+ '	AND (tblICInventoryReceiptItemTax.intTaxCodeId = ''' + @strCriteriaTaxCodeId + ''')'
							+ '	AND (tblICInventoryReceiptItemTax.dblTax ' + @strCriteria + ')'

					INSERT INTO @tblTempInventoryReceiptDetail
					EXEC(@QueryrReceiptItem)

					IF NOT EXISTS (SELECT TOP 1 1 FROM @tblTempInventoryReceiptDetail) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
					BEGIN
						DELETE FROM @tmpInventoryTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId								 
						BREAK
					END

					DELETE FROM @tblTempInventoryReceiptDetail

				END

				DELETE FROM @tblTaxCriteria WHERE intCriteriaId = @intCriteriaId

			END	

			DELETE FROM @tmpInventoryDetail WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
			
		END
		
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intItemId
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, strBillOfLading
				, dblReceived
				, strTaxCode
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, dtmDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, strVendorFederalTaxId
				, strTransporterFederalTaxId
				, strTerminalControlNumber
				, dtmReportingPeriodBegin
				, dtmReportingPeriodEnd
				, strTaxPayerName
				, strTaxPayerAddress
				, strCity
				, strState
				, strZipCode
				, strTelephoneNumber
				, strTaxPayerIdentificationNumber
				, strTaxPayerFEIN
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, strCustomerName
				, strCustomerFederalTaxId
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
				, strVendorLicenseNumber
				, dblQtyShipped
				, strContactName
				, strEmail)
			SELECT DISTINCT @Guid
				, intItemId
				, intReportingComponentId
				, intProductCodeId = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.intProductCodeId 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, strProductCode = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.strProductCode 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = Trans.intReportingComponentId and tblICItemMotorFuelTax.intItemId = Trans.intItemId)
				, strBillOfLading
				, CONVERT(DECIMAL(18), dblReceived)
				, strTaxCategory
				, CONVERT(DECIMAL(18), dblGross)
				, CONVERT(DECIMAL(18), dblNet)
				, CONVERT(DECIMAL(18), dblBillQty)
				, dblTax
				, dtmReceiptDate
				, strShipVia
				, strTransporterLicense
				, strTransportationMode
				, strVendorName
				, strTransporterName
				, REPLACE(strVendorFEIN, '-', '')
				, REPLACE(strTransporterFEIN, '-', '')
				, strTerminalControlNumber
				, @DateFrom
				, @DateTo
				--HEADER
				, strHeaderCompanyName
				, strHeaderAddress
				, strHeaderCity
				, strHeaderState
				, strHeaderZip
				, strHeaderPhone
				, strHeaderStateTaxID
				, REPLACE(strHeaderFederalTaxID, '-', '')
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, strCustomerName
				, REPLACE(strCustomerFederalTaxId, '-', '')
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
				, strVendorLicenseNumber
				, CONVERT(DECIMAL(18), dblGross)
				, strContactName
				, strEmail
			FROM @tmpInventoryTransaction Trans
		END

		IF(NOT EXISTS (SELECT TOP 1 1 FROM @tmpInvoiceTransaction WHERE intReportingComponentId = @RCId) AND NOT EXISTS (SELECT TOP 1 1 FROM @tmpInventoryTransaction WHERE intReportingComponentId = @RCId)  AND @IsEdi = 0)
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
		DELETE FROM @tmpInventoryTransaction
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