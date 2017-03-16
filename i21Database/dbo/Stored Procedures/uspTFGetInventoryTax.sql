CREATE PROCEDURE [dbo].[uspTFGetInventoryTax]
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

	DECLARE @InventoryReceiptItemId NVARCHAR(50)
	DECLARE @TaxCodeId NVARCHAR(50)
	DECLARE @TaxCriteria NVARCHAR(10)
	DECLARE @QueryrReceiptItem NVARCHAR(MAX)
	DECLARE @RCId INT
		, @CompanyName NVARCHAR(250)
		, @CompanyEIN NVARCHAR(100)
		, @intReceiptTransactionId INT
		, @intTaxCategoryId INT

	-- USER DEFINED TABLES
	DECLARE @TFReceiptItem TFReceiptItem
	DECLARE @TFTransaction TFTransaction
	--

	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction
	END

	DELETE FROM tblTFTransaction
	WHERE uniqTransactionGuid = @Guid 
		AND strProductCode = 'No record found.'	
	
	SELECT intReportingComponentId = Item COLLATE Latin1_General_CI_AS
	INTO #tmpRC
	FROM dbo.fnSplitStringWithTrim(@ReportingComponentId, ',')

	SELECT TOP 1 @CompanyName = strCompanyName, @CompanyEIN = strEin FROM tblSMCompanySetup

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpRC)
	BEGIN
		SELECT TOP 1 @RCId = intReportingComponentId FROM #tmpRC

		-- GET INVENTORY RECEIPT/S
		
		SELECT ROW_NUMBER() OVER(ORDER BY RC.intReportingComponentId, ReceiptItem.intInventoryReceiptItemId DESC) AS intId
			, ReceiptItem.intInventoryReceiptItemId
			, Receipt.strBillOfLading
		INTO #tmpReceiptTransaction
		FROM tblICInventoryReceiptItem ReceiptItem
		LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN tblICItemMotorFuelTax ItemTax ON ItemTax.intItemId = ReceiptItem.intItemId
		INNER JOIN tblTFReportingComponentProductCode RCPC ON RCPC.intProductCodeId = ItemTax.intProductCodeId
		INNER JOIN tblTFReportingComponent RC ON RCPC.intReportingComponentId = RC.intReportingComponentId
		INNER JOIN tblSMCompanyLocation Destination ON Receipt.intLocationId = Destination.intCompanyLocationId
		INNER JOIN tblEMEntity Vendor ON Receipt.intEntityVendorId = Vendor.intEntityId
		INNER JOIN tblEMEntityLocation Origin ON Origin.intEntityLocationId = Receipt.intShipFromId
		WHERE Receipt.ysnPosted = 1
			AND RC.intReportingComponentId = @RCId
			AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR Origin.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR Origin.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
				OR Destination.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
			AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
				OR Destination.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
				OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
			AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
				OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))

		IF EXISTS(SELECT TOP 1 1 FROM tblTFReportingComponentCriteria WHERE intReportingComponentId = @RCId)
		BEGIN
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
				, strDestinationState
				, strTerminalControlNumber)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId
				, *
			FROM (
			SELECT DISTINCT ReceiptItem.intInventoryReceiptItemId
				, RCPC.intTaxAuthorityId
				, RCPC.strFormCode
				, RCPC.intReportingComponentId
				, RCPC.strScheduleCode
				, strType = RCPC.strReportingComponentType
				, RCPC.strProductCode
				, Receipt.strBillOfLading
				, ReceiptItem.dblReceived
				, ReceiptItem.dblGross
				, ReceiptItem.dblNet
				, ReceiptItem.dblBillQty
				, Receipt.dtmReceiptDate
				, ShipVia.strShipVia
				, ShipVia.strTransporterLicense
				, ShipVia.strTransportationMode
				, Vendor.strName AS strVendorName
				, Transporter.strName AS strTransporterName
				, Vendor.strFederalTaxId AS strVendorFEIN
				, Transporter.strFederalTaxId AS strTransporterFEIN
				, CompanySetup.strCompanyName
				, CompanySetup.strAddress
				, CompanySetup.strCity
				, CompanySetup.strState
				, CompanySetup.strZip
				, CompanySetup.strPhone
				, CompanySetup.strStateTaxID
				, CompanySetup.strFederalTaxID
				, Origin.strState AS strOriginState
				, Destination.strStateProvince
				, TCN.strTerminalControlNumber
			FROM tblTRSupplyPoint
			INNER JOIN tblTFTerminalControlNumber TCN ON tblTRSupplyPoint.intTerminalControlNumberId = TCN.intTerminalControlNumberId
			FULL OUTER JOIN tblEMEntityLocation Origin
			INNER JOIN tblICInventoryReceiptItem ReceiptItem
			INNER JOIN tblICInventoryReceipt Receipt ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
			INNER JOIN tblICInventoryReceiptItemTax ReceiptItemTax ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemTax.intInventoryReceiptItemId
			INNER JOIN tblSMCompanyLocation Destination ON Receipt.intLocationId = Destination.intCompanyLocationId
			INNER JOIN tblICItemMotorFuelTax
			INNER JOIN vyuTFGetReportingComponentProductCode RCPC ON tblICItemMotorFuelTax.intProductCodeId = RCPC.intProductCodeId
			INNER JOIN tblTFReportingComponent ON RCPC.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON ReceiptItem.intItemId = tblICItemMotorFuelTax.intItemId
			INNER JOIN tblTFReportingComponentCriteria ON tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId
			INNER JOIN tblTFTaxCategory ON tblTFReportingComponentCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblEMEntity Vendor ON Receipt.intEntityVendorId = Vendor.intEntityId ON Origin.intEntityLocationId = Receipt.intShipFromId
			LEFT OUTER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId AND tblSMTaxCode.intTaxCodeId = ReceiptItemTax.intTaxCodeId ON tblTRSupplyPoint.intEntityVendorId = Receipt.intShipFromId
			FULL OUTER JOIN tblSMShipVia ShipVia
			FULL OUTER JOIN tblEMEntity AS Transporter ON ShipVia.intEntityShipViaId = Transporter.intEntityId ON Receipt.intShipViaId = ShipVia.intEntityShipViaId
			CROSS JOIN (SELECT TOP 1 * FROM tblSMCompanySetup) CompanySetup
			WHERE Receipt.ysnPosted = 1
				AND RCPC.intReportingComponentId = @RCId
				AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR Origin.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR Origin.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR Destination.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR Destination.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				)tblTFTransaction
		END
		ELSE
		BEGIN
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
				, strDestinationState
				, strTerminalControlNumber)
			SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intTaxAuthorityId DESC) AS intId
				, *
			FROM (
			SELECT DISTINCT ReceiptItem.intInventoryReceiptItemId
				, RCPC.intTaxAuthorityId
				, RCPC.strFormCode
				, RCPC.intReportingComponentId
				, RCPC.strScheduleCode
				, strType = RCPC.strReportingComponentType
				, RCPC.strProductCode
				, Receipt.strBillOfLading
				, ReceiptItem.dblReceived
				, ReceiptItem.dblGross
				, ReceiptItem.dblNet
				, ReceiptItem.dblBillQty
				, Receipt.dtmReceiptDate
				, ShipVia.strShipVia
				, ShipVia.strTransporterLicense
				, ShipVia.strTransportationMode
				, Vendor.strName AS strVendorName
				, Transporter.strName AS strTransporterName
				, Vendor.strFederalTaxId AS strVendorFEIN
				, Transporter.strFederalTaxId AS strTransporterFEIN
				, CompanySetup.strCompanyName
				, CompanySetup.strAddress
				, CompanySetup.strCity
				, CompanySetup.strState
				, CompanySetup.strZip
				, CompanySetup.strPhone
				, CompanySetup.strStateTaxID
				, CompanySetup.strFederalTaxID
				, Origin.strState AS strOriginState
				, Destination.strStateProvince
				, TCN.strTerminalControlNumber
			FROM tblTRSupplyPoint
			INNER JOIN tblTFTerminalControlNumber TCN ON tblTRSupplyPoint.intTerminalControlNumberId = TCN.intTerminalControlNumberId
			RIGHT OUTER JOIN tblSMTaxCode
			INNER JOIN tblTFTaxCategory TaxCategory ON tblSMTaxCode.intTaxCategoryId = TaxCategory.intTaxCategoryId
			INNER JOIN tblICInventoryReceiptItem ReceiptItem
			INNER JOIN tblICInventoryReceipt Receipt ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
			INNER JOIN tblICInventoryReceiptItemTax ReceiptItemTax ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemTax.intInventoryReceiptItemId
			INNER JOIN tblSMCompanyLocation Destination ON Receipt.intLocationId = Destination.intCompanyLocationId
			INNER JOIN tblICItemMotorFuelTax
			INNER JOIN vyuTFGetReportingComponentProductCode RCPC ON tblICItemMotorFuelTax.intProductCodeId = RCPC.intProductCodeId
			INNER JOIN tblTFReportingComponent ON RCPC.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON ReceiptItem.intItemId = tblICItemMotorFuelTax.intItemId ON tblSMTaxCode.intTaxCodeId = ReceiptItemTax.intTaxCodeId
			INNER JOIN tblEMEntityLocation Origin ON Receipt.intShipFromId = Origin.intEntityLocationId
			INNER JOIN tblEMEntity Vendor ON Receipt.intEntityVendorId = Vendor.intEntityId ON tblTRSupplyPoint.intEntityLocationId = Receipt.intShipFromId
			FULL OUTER JOIN tblSMShipVia ShipVia
			FULL OUTER JOIN tblEMEntity AS Transporter ON ShipVia.intEntityShipViaId = Transporter.intEntityId ON Receipt.intShipViaId = ShipVia.intEntityShipViaId
			CROSS JOIN (SELECT TOP 1 * FROM tblSMCompanySetup) CompanySetup
			WHERE Receipt.ysnPosted = 1
				AND RCPC.intReportingComponentId = @RCId
				AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
				AND CAST(FLOOR(CAST(Receipt.dtmReceiptDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR Origin.strState IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR Origin.strState NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include') = 0
					OR Destination.strStateProvince IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'))
				AND ((SELECT COUNT(*) FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude') = 0
					OR Destination.strStateProvince NOT IN (SELECT strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1) = 0
					OR Vendor.intEntityId IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 1))
				AND ((SELECT COUNT(*) FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0) = 0
					OR Vendor.intEntityId NOT IN (SELECT intVendorId FROM tblTFReportingComponentVendor WHERE intReportingComponentId = @RCId AND ysnInclude = 0))
				)tblTransactions
		END
		
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpReceiptTransaction) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN
			-- RETRIEVE TAX CATEGORY BASED ON RECEIPT ITEM ID/S
			SELECT ROW_NUMBER() OVER(ORDER BY tblSMTaxCode.intTaxCodeId, tblTFReportingComponentCriteria.strCriteria DESC) AS intId
				, tblSMTaxCode.intTaxCodeId
				, tblTFReportingComponentCriteria.strCriteria
			INTO #tmpTaxCategory
			FROM tblSMTaxCode
			INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
			INNER JOIN tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId
			WHERE tblTFReportingComponentCriteria.intReportingComponentId = @RCId

			SELECT TOP 1 @intReceiptTransactionId = intId, @InventoryReceiptItemId = intInventoryReceiptItemId FROM #tmpReceiptTransaction

			WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTaxCategory) -- LOOP ON TAX CATEGORY
			BEGIN
				SELECT TOP 1 @intTaxCategoryId = intId, @TaxCodeId = intTaxCodeId, @TaxCriteria = strCriteria FROM #tmpTaxCategory

				SET @QueryrReceiptItem = 'SELECT  DISTINCT tblICInventoryReceiptItemTax.intInventoryReceiptItemId FROM
												tblICInventoryReceiptItem INNER JOIN
												tblICInventoryReceiptItemTax 
												ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId 
										WHERE  (tblICInventoryReceiptItem.intInventoryReceiptItemId IN(''' + @InventoryReceiptItemId + '''))
												AND (tblICInventoryReceiptItemTax.intTaxCodeId = ''' + @TaxCodeId + ''')
												AND (tblICInventoryReceiptItemTax.dblTax ' + @TaxCriteria + ')'
				DELETE FROM @TFReceiptItem
				INSERT INTO @TFReceiptItem
				EXEC(@QueryrReceiptItem)
	
				IF NOT EXISTS(SELECT TOP 1 1 FROM @TFReceiptItem) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
				BEGIN
					SELECT DISTINCT tblICInventoryReceiptItemTax.intInventoryReceiptItemId
					INTO #tmpReceiptItem
					FROM tblICInventoryReceiptItem
					INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId
					WHERE tblICInventoryReceiptItem.intInventoryReceiptItemId = @InventoryReceiptItemId
						AND tblICInventoryReceiptItemTax.intTaxCodeId = @TaxCodeId
																
					IF EXISTS(SELECT TOP 1 1  FROM #tmpReceiptItem)
					BEGIN
						DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
						DROP TABLE #tmpReceiptItem
						BREAK
					END
					ELSE
					BEGIN
						IF(@TaxCriteria = '<> 0')
						BEGIN
							DELETE FROM @TFTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
							DROP TABLE #tmpReceiptItem
							BREAK
						END
					END

					DROP TABLE #tmpReceiptItem
				END
				DELETE FROM #tmpTaxCategory WHERE intId = @intTaxCategoryId
			END			
			DELETE FROM #tmpReceiptTransaction WHERE intId = @intReceiptTransactionId

			DROP TABLE #tmpTaxCategory
		END
		
		DROP TABLE #tmpReceiptTransaction
			
		IF (@ReportingComponentId <> '')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid
				, intItemId
				, intTaxAuthorityId
				, strTaxAuthority
				, strFormCode
				, intReportingComponentId
				, strScheduleCode
				, strType
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
				, strDestinationState
				, strCustomerName
				, strCustomerFederalTaxId
				, leaf)
			SELECT DISTINCT @Guid
				, intInventoryReceiptItemId
				, intTaxAuthorityId
				, (SELECT strTaxAuthorityCode FROM tblTFTaxAuthority WHERE intTaxAuthorityId = (SELECT DISTINCT TOP 1 intTaxAuthorityId FROM @TFTransaction))
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
				, @CompanyName
				, @CompanyEIN
				, 1
			FROM @TFTransaction
		END
		ELSE
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, '', 0, 1)
		END

		DELETE FROM @TFTransaction
		DELETE FROM #tmpRC WHERE @RCId = intReportingComponentId
	END

	DROP TABLE #tmpRC
	
	IF (NOT EXISTS(SELECT TOP 1 1 FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid) AND @IsEdi = 0)
	BEGIN
		INSERT INTO tblTFTransaction (uniqTransactionGuid
			, strFormCode
			, strProductCode
			, dtmDate
			, dtmReportingPeriodBegin
			, dtmReportingPeriodEnd
			, leaf)
		VALUES(@Guid
			, (SELECT TOP 1 strFormCode FROM tblTFReportingComponent WHERE intReportingComponentId = @RCId)
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