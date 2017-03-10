CREATE PROCEDURE [dbo].[uspTFGT103InventoryTax]
	@Guid NVARCHAR(50)
	, @ReportingComponentId NVARCHAR(MAX)
	, @DateFrom DATETIME
	, @DateTo DATETIME
	, @IsEdi NVARCHAR(10)
	, @Refresh NVARCHAR(5)

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
	DECLARE @RCId NVARCHAR(50)
	DECLARE @TaxAmount NUMERIC(18, 6)

	IF @Refresh = 'true'
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
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
			, intInventoryReceiptItemId
			, intTaxAuthorityId
			, strFormCode
			, intReportingComponentId
			, strScheduleCode
			, strType
			, strProductCode
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
			, strDestinationState
			, strTerminalControlNumber)
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId
			, *
		FROM (
		SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId
			, tblTFReportingComponent.intTaxAuthorityId
			, tblTFReportingComponent.strFormCode
			, tblTFReportingComponent.intReportingComponentId
			, tblTFReportingComponent.strScheduleCode
			, tblTFReportingComponent.strType
			, tblTFProductCode.strProductCode
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
			, tblEMEntity.strName AS strVendorName
			, tblEMEntity_Transporter.strName AS strTransporterName
			, tblEMEntity.strFederalTaxId AS strVendorFEIN
			, tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN
			, tblSMCompanySetup.strCompanyName
			, tblSMCompanySetup.strAddress
			, tblSMCompanySetup.strCity
			, tblSMCompanySetup.strState
			, tblSMCompanySetup.strZip
			, tblSMCompanySetup.strPhone
			, tblSMCompanySetup.strStateTaxID
			, tblSMCompanySetup.strFederalTaxID
			, tblEMEntityLocation.strState AS strOriginState
			, tblSMCompanyLocation.strStateProvince AS strDestinationState
			, tblTFTerminalControlNumber.strTerminalControlNumber
		FROM tblTFProductCode
		INNER JOIN tblEMEntityLocation
		INNER JOIN tblEMEntity
		INNER JOIN tblSMTaxCode
		INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
		INNER JOIN tblICItemMotorFuelTax
		INNER JOIN tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId
		INNER JOIN tblICInventoryReceiptItem
		INNER JOIN tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId
		INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId
		INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId
			ON tblICItemMotorFuelTax.intItemId = tblICInventoryReceiptItem.intItemId
			ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
			ON tblEMEntity.intEntityId = tblICInventoryReceipt.intEntityVendorId
			ON tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId
		INNER JOIN tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			ON tblTFProductCode.intProductCodeId = tblICItemMotorFuelTax.intProductCodeId
		LEFT OUTER JOIN tblTRSupplyPoint
		INNER JOIN tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId
			ON tblICInventoryReceipt.intShipFromId = tblTRSupplyPoint.intEntityLocationId
		FULL OUTER JOIN tblSMShipVia
		FULL OUTER JOIN tblEMEntity AS tblEMEntity_Transporter ON tblSMShipVia.intEntityShipViaId = tblEMEntity_Transporter.intEntityId
			ON tblICInventoryReceipt.intShipViaId = tblSMShipVia.intEntityShipViaId
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
				OR tblEMEntity.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR tblEMEntity.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
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
				, intTaxAuthorityId
				, strTaxAuthority
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strProductCode
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, dtmDate
				, strVendorName
				, strVendorFederalTaxId
				, strType
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
				, strDestinationState
				, leaf)
			SELECT DISTINCT @Guid
				, intInventoryReceiptItemId
				, strBillOfLading
				, TRANS.intTaxAuthorityId
				, strTaxAuthorityCode
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strProductCode
				, dblGross
				, dblNet
				, dblBillQty
				, dblTax
				, dtmReceiptDate
				, strVendorName
				, strVendorFEIN
				, strType
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
				, strDestinationState
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