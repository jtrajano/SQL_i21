CREATE PROCEDURE [dbo].[uspTFGT103InvoiceTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(MAX),
@DateFrom DATETIME,
@DateTo DATETIME,
@IsEdi NVARCHAR(10),
@Refresh NVARCHAR(5)

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

	IF (@Refresh = 'true')
	BEGIN
		DELETE FROM tblTFTransaction
	END
	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'

	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC
		DELETE FROM @TFTransaction
		INSERT INTO @TFTransaction(intId
			, intInvoiceDetailId
			, intTaxAuthorityId
			, strFormCode
			, intReportingComponentId
			, strScheduleCode
			, strType
			, intProductCode
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
			, strDestinationState
			, strOriginCity
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
			, strHeaderFederalTaxID)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId, intProductCodeId DESC) AS intId
			, *
		FROM (
		SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId
			, tblTFReportingComponent.intTaxAuthorityId
			, tblTFReportingComponent.strFormCode
			, tblTFReportingComponent.intReportingComponentId
			, tblTFReportingComponent.strScheduleCode
			, tblTFReportingComponent.strType
			, tblTFReportingComponentProductCode.intProductCodeId
			, tblTFProductCode.strProductCode
			, tblARInvoiceDetail.intItemId
			, tblARInvoiceDetail.dblQtyShipped
			, tblARInvoiceDetail.dblQtyShipped AS dblGross
			, tblARInvoiceDetail.dblQtyShipped AS dblNet
			, tblARInvoiceDetail.dblQtyShipped AS dblBillQty
			, 0 AS dblTax
			, 0 AS dblTaxExempt
			, tblARInvoice.strInvoiceNumber
			, tblARInvoice.strPONumber
			, tblARInvoice.strBOLNumber
			, tblARInvoice.dtmDate
			, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity
			, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState
			, tblSMCompanyLocation.strCity AS strOriginCity
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
			, tblSMCompanySetup.strFederalTaxID
		FROM tblTFProductCode
		INNER JOIN tblSMTaxCode
		INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
		INNER JOIN tblARInvoiceDetail
		INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
		INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
			ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
		INNER JOIN tblICItemMotorFuelTax
		INNER JOIN tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId
		INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
		INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId
		INNER JOIN tblEMEntity ON tblARCustomer.intEntityId = tblEMEntity.intEntityId
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
			SELECT @InvoiceDetailId = intInvoiceDetailId FROM @TFTransaction WHERE intId = @Count
			DECLARE @TaxAmount NUMERIC(18, 6)
			DECLARE @TaxExempt NUMERIC(18, 6)

			-- GASOLINE USE TAX COLLECTED
			SELECT @TaxAmount = tblARInvoiceDetailTax.dblTax
			FROM tblSMTaxCode
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblARInvoiceDetailTax ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetailTax.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId
			INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
			WHERE tblARInvoiceDetailTax.intInvoiceDetailId = @InvoiceDetailId
				AND (tblTFTaxCategory.strTaxCategory = @GasolineUseTax)

			UPDATE @TFTransaction
			SET dblTax = ISNULL(@TaxAmount, 0)
				, strTaxCode = @GasolineUseTax
			WHERE intInvoiceDetailId = @InvoiceDetailId
						
			--EXEMPT GALLONS SOLD
			SELECT @TaxExempt = tblARInvoiceDetail.dblQtyShipped
			FROM tblSMTaxCode
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblARInvoiceDetailTax ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId
			INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetailTax.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId
			INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
			WHERE tblARInvoiceDetailTax.intInvoiceDetailId = @InvoiceDetailId
				AND (tblTFTaxCategory.strTaxCategory = 'IN Gasoline Use Tax (GUT)')
				AND tblARInvoiceDetailTax.dblTax = 0

			UPDATE @TFTransaction SET dblTaxExempt = ISNULL(@TaxExempt, 0), strTaxCode = @ExemptGallSold WHERE intInvoiceDetailId = @InvoiceDetailId
			SET @Count = @Count - 1
		END

		-- INVENTORY TRANSFERS --

		DECLARE @ConfigGUTRate NUMERIC(18, 6)
		SELECT TOP 1 @ConfigGUTRate = ISNULL(strConfiguration, 0) FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'GT-103-2DGasoline'	

		INSERT INTO @TFTransaction(intId
			, intInvoiceDetailId
			, intTaxAuthorityId
			, strFormCode
			, intReportingComponentId
			, strScheduleCode
			, strType
			, intProductCode
			, strProductCode
			, intItemId
			, dblQtyShipped
			, dblGross
			, dblNet
			, dblBillQty
			, strBillOfLading
			, dtmDate
			, strDestinationCity
			, strDestinationState
			, strOriginCity
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
			, dblTaxExempt)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intTaxAuthorityId, intProductCodeId DESC) AS intId
			, *
		FROM (
		SELECT DISTINCT tblICInventoryTransferDetail.intInventoryTransferDetailId
			, tblTFReportingComponent.intTaxAuthorityId
			, tblTFReportingComponent.strFormCode
			, tblTFReportingComponent.intReportingComponentId
			, tblTFReportingComponent.strScheduleCode
			, tblTFReportingComponent.strType
			, tblTFReportingComponentProductCode.intProductCodeId
			, tblTFProductCode.strProductCode
			, tblICInventoryTransferDetail.intItemId
			, tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped
			, tblICInventoryTransferDetail.dblQuantity AS dblGross
			, tblICInventoryTransferDetail.dblQuantity AS dblNet
			, tblICInventoryTransferDetail.dblQuantity
			, tblTRLoadReceipt.strBillOfLading AS strBOLNumber
			, tblICInventoryTransfer.dtmTransferDate AS dtmDate
			, tblSMCompanyLocation.strCity AS strDestinationCity
			, tblSMCompanyLocation.strStateProvince AS strDestinationState
			, tblEMEntityLocation.strCity AS strOriginCity
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
			, tblSMCompanySetup.strFederalTaxID
			, (ISNULL(tblICInventoryTransferDetail.dblQuantity, 0) * @ConfigGUTRate) AS dblTax
			, 0.000000 AS dblTaxExempt
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
		INNER JOIN tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
			ON tblTFProductCode.intProductCodeId = tblICItemMotorFuelTax.intProductCodeId
		LEFT OUTER JOIN tblTFTaxCategory
		INNER JOIN tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
			ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentCriteria.intReportingComponentId
		LEFT OUTER JOIN tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId
		LEFT OUTER JOIN tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId
		CROSS JOIN tblSMCompanySetup
		WHERE tblICInventoryTransfer.intSourceType = 3
			AND tblTFReportingComponent.intReportingComponentId = @RCId
			AND (tblSMCompanyLocation.ysnTrackMFTActivity = 1)
			AND (tblARInvoice.strBOLNumber IS NULL)
			AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(tblTRLoadHeader.dtmLoadDateTime AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND (tblICInventoryTransfer.ysnPosted = 1)
			AND (tblTFReportingComponentCriteria.strCriteria <> '= 0' 
			OR tblTFReportingComponentCriteria.strCriteria IS NULL)
		)tblTransactions
				
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intTaxAuthorityId
				, strTaxAuthority
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
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
				, strDestinationState
				, strOriginCity
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
				, leaf)
			SELECT DISTINCT @Guid
				, TRANS.intTaxAuthorityId
				, strTaxAuthorityCode
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
				, intProductCode
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
				, strDestinationState
				, strOriginCity
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
				, @DateFrom
				, @DateTo
				, 1
			FROM @TFTransaction TRANS
			LEFT JOIN tblTFTaxAuthority ON tblTFTaxAuthority.intTaxAuthorityId = TRANS.intTaxAuthorityId

		END
		ELSE
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, '', 0, 1)
		END

		DELETE FROM #tmpRC WHERE intReportingComponentId = @RCId
	END

	DROP TABLE #tmpRC

	IF (NOT EXISTS(SELECT TOP 1 1 from @TFTransaction) AND @IsEdi = 'false')
	BEGIN
		INSERT INTO tblTFTransaction(uniqTransactionGuid
			, intTaxAuthorityId
			, strFormCode
			, strProductCode
			, dtmDate
			, dtmReportingPeriodBegin
			, dtmReportingPeriodEnd
			, leaf)
		VALUES(@Guid
			, 0
			, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId)
			, 'No record found.'
			, GETDATE()
			, @DateFrom
			, @DateTo
			, 1)
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