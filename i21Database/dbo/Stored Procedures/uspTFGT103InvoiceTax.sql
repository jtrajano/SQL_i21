﻿CREATE PROCEDURE [dbo].[uspTFGT103InvoiceTax]

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

	DECLARE @TFTransaction TFInvoiceTransaction

	DECLARE @Count INT
	DECLARE @CountRC INT
	DECLARE @InvoiceDetailId NVARCHAR(50)
	DECLARE @QueryInvoice1 NVARCHAR(MAX)
	DECLARE @QueryInvoice2 NVARCHAR(MAX)
	DECLARE @QueryInvoice NVARCHAR(MAX)
	DECLARE @QueryReceipt NVARCHAR(MAX)
	DECLARE @QueryTaxCategory NVARCHAR(MAX)

	DECLARE @ExemptGallSold NVARCHAR(MAX) = 'IN Excise Tax'
	DECLARE @GasolineUseTax NVARCHAR(MAX) = 'IN Gasoline Use Tax (GUT)'
	DECLARE @TaxCodeId NVARCHAR(50)
	DECLARE @TaxCategoryCount INT
	DECLARE @TaxCriteria NVARCHAR(10)
	DECLARE @QueryrInvoiceDetailId NVARCHAR(MAX)
	DECLARE @IsValidCategory INT
	DECLARE @QueryInvoiceNumber NVARCHAR(MAX)
	DECLARE @QueryRC NVARCHAR(MAX)
	DECLARE @RCId NVARCHAR(50)

	-- ORIGIN/DESTINATION
	DECLARE @IncludeOriginState NVARCHAR(250)
	DECLARE @ExcludeOriginState NVARCHAR(250)
	DECLARE @IncludeDestinationState NVARCHAR(250)
	DECLARE @ExcludeDestinationState NVARCHAR(250)
	DECLARE @IncludeLocationState NVARCHAR(250)
	DECLARE @ExcludeLocationState NVARCHAR(250)

	IF (@Refresh = 1)
	BEGIN
		DELETE FROM tblTFTransaction
	END
	--DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'

	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE #tmpRC WHERE intReportingComponentId = ''
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN

		DECLARE @intMaxId INT = 0

		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC
		DELETE FROM @TFTransaction
		INSERT INTO @TFTransaction(intId
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
			, strAccountStatusCode
			, strShipVia
			, strTransporterLicense
			, strTransportationMode
			, strTransporterName
			, strTransporterFEIN
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
			, strContactName)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInvoiceDetailId, intTaxAuthorityId DESC) AS intId
			, *
		FROM (
		SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId
			, tblTFReportingComponent.intTaxAuthorityId
			, tblTFReportingComponent.strFormCode
			, tblTFReportingComponent.intReportingComponentId
			, tblTFReportingComponent.strScheduleCode
			, tblTFReportingComponent.strType
			--, tblTFReportingComponentProductCode.intProductCodeId
			--, tblTFProductCode.strProductCode
			, tblARInvoiceDetail.intItemId
			, tblARInvoiceDetail.dblQtyShipped
			, tblARInvoiceDetail.dblQtyShipped AS dblGross
			, tblARInvoiceDetail.dblQtyShipped AS dblNet
			, tblARInvoiceDetail.dblQtyShipped AS dblBillQty
			, 0 AS dblTax
			, 0 AS dblTaxExempt
			, tblARInvoice.strInvoiceNumber
			, tblARInvoice.strPONumber
			, CASE WHEN tblARInvoice.strType = 'Transport Delivery' THEN tblARInvoice.strBOLNumber ELSE tblARInvoice.strInvoiceNumber END AS strBillOfLading
			, tblARInvoice.dtmDate
			, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
			, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN NULL ELSE Destination.strCounty END) AS strDestinationCounty 
			, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
			, tblSMCompanyLocation.strCity AS strOriginCity
			, NULL AS strOriginCounty
			, tblSMCompanyLocation.strStateProvince AS strOriginState
			, tblEMEntity.strName AS strCustomerName
			, tblEMEntity.strFederalTaxId AS strCustomerFEIN
			, tblARAccountStatus.strAccountStatusCode
			, tblSMShipVia.strShipVia
			, tblSMShipVia.strTransporterLicense
			, tblSMShipVia.strTransportationMode
			, tblEMEntity_Transporter.strName AS strTransporterName
			, tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN
			, tblSMCompanySetup.strCompanyName
			, tblSMCompanySetup.strAddress
			, tblSMCompanySetup.strCity
			, tblSMCompanySetup.strState
			, tblSMCompanySetup.strZip
			, tblSMCompanySetup.strPhone
			, tblSMCompanySetup.strStateTaxID
			, tblSMCompanySetup.strEin
			, strTransporterIdType = 'FEIN'
			, strVendorIdType = 'FEIN'
			, strCustomerIdType = 'FEIN'
			, strVendorInvoiceNumber = NULL
			, strCustomerLicenseNumber = NULL
			, strCustomerAccountStatusCode = tblARAccountStatus.strAccountStatusCode
			, strCustomerStreetAddress = tblEMEntityLocation.strAddress
			, strCustomerZipCode = tblEMEntityLocation.strZipCode
			, strReportingComponentNote = tblTFReportingComponent.strNote
			, strDiversionNumber = NULL
			, strDiversionOriginalDestinationState = NULL
			, strTransactionType = 'Invoice'
			, intTransactionNumberId = tblARInvoiceDetail.intInvoiceDetailId
			, strContactName = tblSMCompanySetup.strContactName
		FROM tblTFProductCode
		INNER JOIN tblARInvoiceDetail
		INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
		INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
		INNER JOIN tblICItemMotorFuelTax
		INNER JOIN tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
		INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
		INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
		INNER JOIN tblEMEntity ON tblARCustomer.intEntityId = tblEMEntity.intEntityId
		LEFT JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblARInvoice.intShipToLocationId
		LEFT JOIN tblSMTaxCode Destination ON Destination.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
		INNER JOIN tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			ON tblTFProductCode.intProductCodeId = tblICItemMotorFuelTax.intProductCodeId
		FULL OUTER JOIN tblEMEntity AS tblEMEntity_Transporter
		INNER JOIN tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityId
			ON tblARInvoice.intShipViaId = tblSMShipVia.intEntityId
		FULL OUTER JOIN tblARAccountStatus ON tblARCustomer.intAccountStatusId = tblARAccountStatus.intAccountStatusId
		CROSS JOIN tblSMCompanySetup
		WHERE tblTFReportingComponent.intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(tblARInvoice.dtmDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR tblARInvoice.strShipToState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR tblARInvoice.strShipToState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				OR tblARCustomer.intEntityId IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR tblARCustomer.intEntityId NOT IN (SELECT intEntityCustomerId FROM tblTFReportingComponentCustomer WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				OR tblARAccountStatus.intAccountStatusId IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR tblARAccountStatus.intAccountStatusId NOT IN (SELECT intAccountStatusId FROM tblTFReportingComponentAccountStatusCode WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			AND tblARInvoice.ysnPosted = 1
		)tblTransactions

		SET @Count = (SELECT COUNT(intId) FROM @TFTransaction)			
		WHILE(@Count > 0) -- LOOP ON INVOICE ID/S
		BEGIN
			SET @InvoiceDetailId = NULL
			DECLARE @TaxAmount NUMERIC(18, 6) = NULL
			DECLARE @TaxExempt NUMERIC(18, 6) = NULL
			SELECT @InvoiceDetailId = intInvoiceDetailId FROM @TFTransaction WHERE intId = @Count
			
			
			SELECT @TaxAmount = tblARInvoiceDetailTax.dblTax, @TaxExempt = CASE WHEN tblARInvoiceDetailTax.dblTax > 0 THEN 0 ELSE tblARInvoiceDetail.dblQtyShipped END
			FROM tblSMTaxCode
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblARInvoiceDetailTax ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetailTax.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId
			INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
			WHERE tblARInvoiceDetailTax.intInvoiceDetailId = @InvoiceDetailId
				AND (tblTFTaxCategory.strTaxCategory = @GasolineUseTax)
	
			IF(@TaxAmount IS NULL)
			BEGIN
				SELECT @TaxExempt = dblQtyShipped FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @InvoiceDetailId
			END

			--EXEMPT GALLONS SOLD
			UPDATE @TFTransaction SET dblTaxExempt = ISNULL(@TaxExempt, 0), strTaxCode = @ExemptGallSold WHERE intInvoiceDetailId = @InvoiceDetailId			
			
			-- GASOLINE USE TAX COLLECTED
			UPDATE @TFTransaction SET dblTax = ISNULL(@TaxAmount, 0), strTaxCode = @GasolineUseTax WHERE intInvoiceDetailId = @InvoiceDetailId
	
			--UPDATE @TFTransaction SET dblTaxExempt = CASE WHEN @TaxExempt IS NULL THEN dblQtyShipped ELSE 0 END, strTaxCode = @ExemptGallSold WHERE intInvoiceDetailId = @InvoiceDetailId

			SET @Count = @Count - 1
		END

		-- INVENTORY TRANSFERS --

		DECLARE @ConfigGUTRate NUMERIC(18, 6)
			
		SELECT TOP 1 @ConfigGUTRate = ISNULL(strConfiguration, 0) FROM tblTFReportingComponentConfiguration 
		INNER JOIN tblTFReportingComponent ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentConfiguration.intReportingComponentId 
		WHERE strTemplateItemId IN ('GT-103-2DGasohol', 'GT-103-2DGasoline') AND tblTFReportingComponent.intReportingComponentId = @RCId

		-- GET MAX intId
		SELECT @intMaxId = MAX(ISNULL(intId,0)) FROM @TFTransaction	

		INSERT INTO @TFTransaction(intId
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
			, strAccountStatusCode
			, strShipVia
			, strTransporterLicense
			, strTransportationMode
			, strTransporterName
			, strTransporterFEIN
			, strConsignorName
			, strConsignorFEIN
			, strTaxCode
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
			, dblTax
			, dblTaxExempt
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
			, strContactName)
		SELECT DISTINCT (ROW_NUMBER() OVER(ORDER BY intInventoryTransferDetailId, intTaxAuthorityId DESC) + @intMaxId) AS intId
			, *
		FROM (
		SELECT DISTINCT tblICInventoryTransferDetail.intInventoryTransferDetailId
			, tblTFReportingComponent.intTaxAuthorityId
			, tblTFReportingComponent.strFormCode
			, tblTFReportingComponent.intReportingComponentId
			, tblTFReportingComponent.strScheduleCode
			, tblTFReportingComponent.strType
			--, tblTFReportingComponentProductCode.intProductCodeId
			--, tblTFProductCode.strProductCode
			, tblICInventoryTransferDetail.intItemId
			, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
			, tblICInventoryTransferDetail.dblQuantity AS dblGross
			, tblICInventoryTransferDetail.dblQuantity AS dblNet
			, tblICInventoryTransferDetail.dblQuantity
			, tblTRLoadReceipt.strBillOfLading AS strBOLNumber
			, tblICInventoryTransfer.dtmTransferDate AS dtmDate
			, tblSMCompanyLocation.strCity AS strDestinationCity
			, NULL AS strDestinationCounty
			, tblSMCompanyLocation.strStateProvince AS strDestinationState
			, tblEMEntityLocation.strCity AS strOriginCity
			, CountyTaxCode.strCounty AS strOriginCounty
			, tblEMEntityLocation.strState AS strOriginState
			, tblSMCompanyLocation.strLocationName AS strCustomerName
			, tblSMCompanySetup.strEin AS strCustomerFEIN
			, NULL AS strAccountStatusCode
			, tblSMShipVia.strShipVia
			, tblSMShipVia.strTransporterLicense
			, tblSMShipVia.strTransportationMode
			, tblEMEntity.strName AS strTransporterName
			, tblEMEntity.strFederalTaxId AS strTransporterFEIN
			, tblEMEntity.strName AS strConsignorName
			, tblEMEntity.strFederalTaxId AS strConsignorFEIN
			, @ExemptGallSold AS strTaxCode
			, tblTFTerminalControlNumber.strTerminalControlNumber
			, EntityAPVendor.strName AS strVendorName
			, EntityAPVendor.strFederalTaxId AS strVendorFEIN
			, tblSMCompanySetup.strCompanyName
			, tblSMCompanySetup.strAddress
			, tblSMCompanySetup.strCity
			, tblSMCompanySetup.strState
			, tblSMCompanySetup.strZip
			, tblSMCompanySetup.strPhone
			, tblSMCompanySetup.strStateTaxID
			, tblSMCompanySetup.strEin
			, (ISNULL(tblICInventoryTransferDetail.dblQuantity, 0) * @ConfigGUTRate) AS dblTax
			, 0.000000 AS dblTaxExempt
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
			, strContactName = tblSMCompanySetup.strContactName
		FROM tblTFProductCode
		INNER JOIN tblICInventoryTransferDetail
		INNER JOIN tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId
		INNER JOIN tblICItemMotorFuelTax
		INNER JOIN tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
		INNER JOIN tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId
		INNER JOIN tblTRLoadReceipt ON tblICInventoryTransferDetail.intSourceId = tblTRLoadReceipt.intLoadReceiptId
		INNER JOIN tblTRLoadHeader ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId
		INNER JOIN tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId
			AND tblTRLoadDistributionHeader.intCompanyLocationId = tblICInventoryTransfer.intToLocationId
		INNER JOIN tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityId
		INNER JOIN tblEMEntity ON tblSMShipVia.intEntityId = tblEMEntity.intEntityId
		INNER JOIN tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityId
		INNER JOIN tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityId = EntityAPVendor.intEntityId
		INNER JOIN tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId
		INNER JOIN tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId
		LEFT JOIN tblSMTaxCode AS CountyTaxCode ON CountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
		INNER JOIN tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
			ON tblTFProductCode.intProductCodeId = tblICItemMotorFuelTax.intProductCodeId
		LEFT JOIN tblTFReportingComponentCriteria ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentCriteria.intReportingComponentId
			LEFT JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
				LEFT JOIN tblSMTaxCode AS TaxCodeCategory ON TaxCodeCategory.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
		LEFT OUTER JOIN tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId
		LEFT OUTER JOIN tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId
		CROSS JOIN tblSMCompanySetup
		CROSS JOIN tblSMTaxCode
		WHERE tblICInventoryTransfer.intSourceType = 3
			AND tblTFReportingComponent.intReportingComponentId = @RCId
			AND tblSMTaxCode.intTaxCategoryId IS NOT NULL
			AND (tblSMCompanyLocation.ysnTrackMFTActivity = 1)
			AND (tblARInvoice.strBOLNumber IS NULL)
			AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND (tblICInventoryTransfer.ysnPosted = 1)
			AND (tblTFReportingComponentCriteria.strCriteria IS NULL 
				OR (tblTFReportingComponentCriteria.strCriteria = '<> 0' AND tblSMTaxCode.intTaxCodeId = TaxCodeCategory.intTaxCodeId ))
		)tblTransactions

		-- INVENTORY TRANSFERS USING IC SCREEN --
		SELECT @intMaxId = MAX(ISNULL(intId,0)) FROM @TFTransaction	

		INSERT INTO @TFTransaction(intId
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
			, dtmDate
			, strDestinationCity
			, strDestinationState
			, strOriginCity
			, strOriginState
			, strCustomerName
			, strCustomerFEIN
			, strAccountStatusCode	
			, strTaxCode	
			, strHeaderCompanyName
			, strHeaderAddress
			, strHeaderCity
			, strHeaderState
			, strHeaderZip
			, strHeaderPhone
			, strHeaderStateTaxID
			, strHeaderFederalTaxID
			, dblTax
			, dblTaxExempt
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
			, strContactName)
		SELECT DISTINCT (ROW_NUMBER() OVER(ORDER BY intInventoryTransferDetailId, intTaxAuthorityId DESC) + @intMaxId) AS intId
			, *
		FROM (
			SELECT DISTINCT tblICInventoryTransferDetail.intInventoryTransferDetailId
				, tblTFReportingComponent.intTaxAuthorityId
				, tblTFReportingComponent.strFormCode
				, tblTFReportingComponent.intReportingComponentId
				, tblTFReportingComponent.strScheduleCode
				, tblTFReportingComponent.strType
				--, tblTFReportingComponentProductCode.intProductCodeId
				--, tblTFProductCode.strProductCode
				, tblICInventoryTransferDetail.intItemId
				, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
				, tblICInventoryTransferDetail.dblQuantity AS dblGross
				, tblICInventoryTransferDetail.dblQuantity AS dblNet
				, tblICInventoryTransferDetail.dblQuantity
				, tblICInventoryTransfer.dtmTransferDate AS dtmDate
				, tblSMCompanyLocation.strCity AS strDestinationCity
				, tblSMCompanyLocation.strStateProvince AS strDestinationState
				, tblSMCompanyLocationFrom.strCity AS strOriginCity
				, tblSMCompanyLocationFrom.strStateProvince AS strOriginState
				, tblSMCompanyLocation.strLocationName AS strCustomerName
				, tblSMCompanySetup.strEin AS strCustomerFEIN
				, NULL AS strAccountStatusCode
				, @ExemptGallSold AS strTaxCode
				, tblSMCompanySetup.strCompanyName
				, tblSMCompanySetup.strAddress
				, tblSMCompanySetup.strCity
				, tblSMCompanySetup.strState
				, tblSMCompanySetup.strZip
				, tblSMCompanySetup.strPhone
				, tblSMCompanySetup.strStateTaxID
				, tblSMCompanySetup.strEin
				, (ISNULL(tblICInventoryTransferDetail.dblQuantity, 0) * @ConfigGUTRate) AS dblTax
				, 0.000000 AS dblTaxExempt
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
				, strContactName = tblSMCompanySetup.strContactName
			FROM tblTFProductCode
			INNER JOIN tblICInventoryTransferDetail 
				INNER JOIN tblICItem ON tblICItem.intItemId = tblICInventoryTransferDetail.intItemId
					INNER JOIN tblICCategoryTax ON tblICCategoryTax.intCategoryId = tblICItem.intCategoryId 
						INNER JOIN tblSMTaxClass ON tblSMTaxClass.intTaxClassId = tblICCategoryTax.intTaxClassId
							INNER JOIN tblSMTaxCode ON tblSMTaxCode.intTaxClassId = tblSMTaxClass.intTaxClassId
			INNER JOIN tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId
			INNER JOIN tblICItemMotorFuelTax
			INNER JOIN tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
				ON tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId
			ON tblTFProductCode.intProductCodeId = tblICItemMotorFuelTax.intProductCodeId
			INNER JOIN tblSMCompanyLocation ON tblICInventoryTransfer.intToLocationId = tblSMCompanyLocation.intCompanyLocationId
			INNER JOIN tblSMCompanyLocation AS tblSMCompanyLocationFrom ON tblICInventoryTransfer.intFromLocationId = tblSMCompanyLocationFrom.intCompanyLocationId
			LEFT JOIN tblTFReportingComponentCriteria ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentCriteria.intReportingComponentId
				LEFT JOIN tblTFTaxCategory ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
					LEFT JOIN tblSMTaxCode AS TaxCodeCategory ON TaxCodeCategory.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			CROSS JOIN tblSMCompanySetup
			WHERE  tblICInventoryTransfer.intSourceType IN (0,1,2)
				AND tblTFReportingComponent.intReportingComponentId = @RCId
				AND (tblSMCompanyLocation.ysnTrackMFTActivity = 1)
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(tblICInventoryTransfer.dtmTransferDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND (tblICInventoryTransfer.ysnPosted = 1)
				AND (tblTFReportingComponentCriteria.strCriteria IS NULL 
						OR (tblTFReportingComponentCriteria.strCriteria = '<> 0' AND tblSMTaxCode.intTaxCodeId = TaxCodeCategory.intTaxCodeId) -- FOR TRACK MFT ACTIVITY
						OR (TaxCodeCategory.intTaxCodeId IS NULL AND tblTFReportingComponentCriteria.strCriteria = '= 0') -- FOR NO TAX CODE MAPPED TO MFT CATEGORY
					)
		)tblTransactions
				
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
				, strContactName)
			SELECT DISTINCT @Guid
				, intReportingComponentId
				, intProductCodeId = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.intProductCodeId 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = TRANS.intReportingComponentId and tblICItemMotorFuelTax.intItemId = TRANS.intItemId)
				, strProductCode = (SELECT TOP 1 vyuTFGetReportingComponentProductCode.strProductCode 
					FROM vyuTFGetReportingComponentProductCode INNER JOIN tblICItemMotorFuelTax 
					ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentProductCode.intProductCodeId 
					WHERE intReportingComponentId = TRANS.intReportingComponentId and tblICItemMotorFuelTax.intItemId = TRANS.intItemId)
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
			FROM @TFTransaction TRANS
		END
		
		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId
	END

	DROP TABLE #tmpRC

	IF (NOT EXISTS(SELECT TOP 1 1 from @TFTransaction) AND @IsEdi = 0)
	BEGIN
		INSERT INTO tblTFTransaction(uniqTransactionGuid
			, intReportingComponentId
			, strProductCode
			, dtmDate
			, dtmReportingPeriodBegin
			, dtmReportingPeriodEnd
			, strTransactionType)
		VALUES(@Guid
			, @RCId
			, 'No record found.'
			, GETDATE()
			, @DateFrom
			, @DateTo
			, 'Invoice')
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