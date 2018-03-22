CREATE PROCEDURE [dbo].[uspTFGT103InventoryTax]
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

	DECLARE @TFTransaction TFTransaction
	DECLARE @Count INT	
	DECLARE @InventoryReceiptItemId INT
	DECLARE @TaxCategory NVARCHAR(100) = 'IN Gasoline Use Tax (GUT)'
	DECLARE @RCId INT
		, @TaxAmount NUMERIC(18, 6)
		, @CompanyName NVARCHAR(250)
		, @CompanyEIN NVARCHAR(100)

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	END
	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
	
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	DELETE #tmpRC WHERE intReportingComponentId = ''

	SELECT TOP 1 @CompanyName = strCompanyName, @CompanyEIN = strEin FROM tblSMCompanySetup

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC
		DELETE FROM @TFTransaction
		INSERT INTO @TFTransaction(intId
			, intInventoryReceiptItemId
			, intTaxAuthorityId
			, strFormCode
			, intReportingComponentId
			, strScheduleCode
			, strType
			, intProductCodeId
			, strProductCode
			, intItemId
			, strBillOfLading
			, dblReceived
			, strTaxCategory
			, dblGross
			, dblNet
			, dblBillQty
			, dblTax
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
			, strReportingComponentNote
			, strDiversionNumber
			, strDiversionOriginalDestinationState
			, strTransactionType
			, intTransactionNumberId
			, strContactName)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId
			, *
		FROM (
		SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
			, tblTFReportingComponent.intTaxAuthorityId
			, tblTFReportingComponent.strFormCode
			, tblTFReportingComponent.intReportingComponentId
			, tblTFReportingComponent.strScheduleCode
			, tblTFReportingComponent.strType
			, tblTFProductCode.intProductCodeId
			, tblTFProductCode.strProductCode
			, tblICInventoryReceiptItem.intItemId
			, tblICInventoryReceipt.strBillOfLading
			, tblICInventoryReceiptItem.dblReceived
			, strTaxCategory = ''
			, tblICInventoryReceiptItem.dblGross
			, tblICInventoryReceiptItem.dblNet
			, tblICInventoryReceiptItem.dblBillQty
			, dblTax = 0
			, tblICInventoryReceipt.dtmReceiptDate
			, tblSMShipVia.strShipVia
			, tblSMShipVia.strTransporterLicense
			, tblSMShipVia.strTransportationMode
			, Vendor.strName AS strVendorName
			, Transporter.strName AS strTransporterName
			, Vendor.strFederalTaxId AS strVendorFEIN
			, Transporter.strFederalTaxId AS strTransporterFEIN
			, tblSMCompanySetup.strCompanyName
			, tblSMCompanySetup.strAddress
			, tblSMCompanySetup.strCity
			, tblSMCompanySetup.strState
			, tblSMCompanySetup.strZip
			, tblSMCompanySetup.strPhone
			, tblSMCompanySetup.strStateTaxID
			, tblSMCompanySetup.strEin
			, tblEMEntityLocation.strState AS strOriginState
			, tblEMEntityLocation.strCity AS strOriginCity
			, CountyTaxCode.strCounty AS strOriginCounty
			, tblSMCompanyLocation.strStateProvince AS strDestinationState
			, tblSMCompanyLocation.strCity AS strDestinationCity
			, NULL AS strDestinationCounty
			, tblTFTerminalControlNumber.strTerminalControlNumber
			, strTransporterIdType = 'FEIN'
			, strVendorIdType = 'FEIN'
			, strCustomerIdType = 'FEIN'
			, strVendorInvoiceNumber = NULL
			, strCustomerLicenseNumber = NULL
			, strCustomerAccountStatusCode = NULL
			, strCustomerStreetAddress = NULL
			, strCustomerZipCode = NULL
			, strReportingComponentNote = tblTFReportingComponent.strNote
			, strDiversionNumber = tblTRLoadHeader.strDiversionNumber
			, strDiversionOriginalDestinationState = tblTRState.strStateAbbreviation
			, strTransactionType = 'Receipt'
			, intTransactionNumberId = tblICInventoryReceiptItem.intInventoryReceiptItemId
			, strContactName = tblSMCompanySetup.strContactName
		FROM tblTFReportingComponent 
		INNER JOIN tblTFReportingComponentProductCode ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
		INNER JOIN tblICItemMotorFuelTax ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
			INNER JOIN tblTFProductCode ON tblTFProductCode.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
		INNER JOIN tblICInventoryReceiptItem  ON tblICInventoryReceiptItem.intItemId =  tblICItemMotorFuelTax.intItemId
			INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItemTax.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId 
			INNER JOIN tblEMEntity AS Vendor ON Vendor.intEntityId = tblICInventoryReceipt.intEntityVendorId
			INNER JOIN tblEMEntityLocation ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
			LEFT JOIN tblSMTaxCode AS CountyTaxCode ON CountyTaxCode.intTaxCodeId = tblEMEntityLocation.intCountyTaxCodeId
			INNER JOIN tblSMShipVia ON tblSMShipVia.intEntityId = tblICInventoryReceipt.intShipViaId
				INNER JOIN tblEMEntity AS Transporter ON Transporter.intEntityId = tblSMShipVia.intEntityId 
			INNER JOIN tblTRSupplyPoint ON tblTRSupplyPoint.intEntityLocationId = tblICInventoryReceipt.intShipFromId 
				LEFT JOIN tblTFTerminalControlNumber ON tblTFTerminalControlNumber.intTerminalControlNumberId = tblTRSupplyPoint.intTerminalControlNumberId
			INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
		INNER JOIN tblTRLoadReceipt ON  tblTRLoadReceipt.intInventoryReceiptId  = tblICInventoryReceipt.intInventoryReceiptId
		INNER JOIN tblTRLoadHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadReceipt.intLoadHeaderId
		LEFT JOIN tblTRState ON tblTRState.intStateId = tblTRLoadHeader.intStateId
		CROSS JOIN tblSMCompanySetup
		WHERE tblTFReportingComponent.intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR tblSMCompanyLocation.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR tblSMCompanyLocation.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR tblEMEntityLocation.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR tblEMEntityLocation.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
			AND tblICInventoryReceipt.ysnPosted = 1
		)tblTransactions
		
		SET @Count = (SELECT count(intId) FROM @TFTransaction)
		WHILE(@Count > 0) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN
			SELECT @InventoryReceiptItemId = intInventoryReceiptItemId FROM @TFTransaction WHERE intId = @Count

			SELECT @TaxAmount = tblICInventoryReceiptItemTax.dblTax
			FROM tblICInventoryReceiptItemTax
			INNER JOIN tblSMTaxCode ON tblICInventoryReceiptItemTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			WHERE tblICInventoryReceiptItemTax.intInventoryReceiptItemId = @InventoryReceiptItemId
				AND tblTFTaxCategory.strTaxCategory = @TaxCategory

			UPDATE @TFTransaction
			SET dblTax = ISNULL(@TaxAmount, 0)
				, strTaxCategory = @TaxCategory
			WHERE intInventoryReceiptItemId = @InventoryReceiptItemId

			SET @Count = @Count - 1
		END
			
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intItemId
				, strBillOfLading
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, dtmDate
				, strVendorName
				, strVendorFederalTaxId
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
				, strContactName)
			SELECT DISTINCT @Guid
				, intItemId
				, strBillOfLading
				, intReportingComponentId
				, intProductCodeId
				, strProductCode
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, dtmReceiptDate
				, strVendorName
				, strVendorFEIN
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
				, strHeaderFederalTaxID
				, strOriginState
				, strOriginCity
				, strOriginCounty
				, strDestinationState
				, strDestinationCity
				, strDestinationCounty
				, @CompanyName
				, @CompanyEIN
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
			LEFT JOIN tblTFTaxAuthority ON tblTFTaxAuthority.intTaxAuthorityId = TRANS.intTaxAuthorityId
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
			, 'Receipt')
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