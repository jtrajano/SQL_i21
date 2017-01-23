CREATE PROCEDURE [dbo].[uspTFGT103InventoryTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(MAX),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@IsEdi NVARCHAR(10),
@Refresh NVARCHAR(5)

AS

DECLARE @TFReportingComponent TFReportingComponent
DECLARE @TFTransaction TFTransaction

DECLARE @Count INT
DECLARE @CountRC INT
DECLARE @InventoryReceiptItemId NVARCHAR(50)
DECLARE @QueryInvReceiptRecord NVARCHAR(MAX)
DECLARE @QueryInvReceiptItemId NVARCHAR(MAX)
DECLARE @QueryTaxCategory NVARCHAR(MAX)

DECLARE @TaxCodeId NVARCHAR(50)
DECLARE @TaxCategoryCount INT
DECLARE @TaxCriteria NVARCHAR(10)
DECLARE @TaxCategory NVARCHAR(MAX) = 'IN Gasoline Use Tax (GUT)'
DECLARE @IsValidCategory INT
DECLARE @QueryrReceiptItem NVARCHAR(MAX)
DECLARE @QueryRC NVARCHAR(MAX)
DECLARE @RCId NVARCHAR(50)
DECLARE @TaxAmount NUMERIC(18, 6)

-- ORIGIN/DESTINATION
DECLARE @IncludeOriginState NVARCHAR(250)
DECLARE @ExcludeOriginState NVARCHAR(250)
DECLARE @IncludeDestinationState NVARCHAR(250)
DECLARE @ExcludeDestinationState NVARCHAR(250)

IF @Refresh = 'true'
	BEGIN
		DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	END
	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
	SELECT @QueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
	INSERT INTO @TFReportingComponent (intReportingComponentId)
	EXEC(@QueryRC)
	SET @CountRC = (select count(intId) from @TFReportingComponent) 

	WHILE(@CountRC > 0)
		BEGIN
		SET @RCId = (SELECT intReportingComponentId FROM @TFReportingComponent WHERE intId = @CountRC)

			-- ORIGIN
			DECLARE @IncludeValidOriginState NVARCHAR(MAX) = NULL
			SELECT @IncludeValidOriginState = COALESCE(@IncludeValidOriginState + ',', '') + strOriginDestinationState 
			FROM vyuTFGetReportingComponentOriginState
				WHERE intReportingComponentId = @RCId 
				AND strType = 'Include'
		
			IF(@IncludeValidOriginState IS NOT NULL)
				BEGIN
					SET @IncludeValidOriginState = REPLACE(@IncludeValidOriginState,',',''',''')
					SET @IncludeOriginState = '/*INCLUDE ORIGIN*/ AND tblEMEntityLocation.strState IN (''' + @IncludeValidOriginState + ''')'
				END
			ELSE
				BEGIN
					SET @IncludeOriginState = ''
				END

			DECLARE @ExcludeValidOriginState NVARCHAR(MAX) = NULL
			SELECT @ExcludeValidOriginState = COALESCE(@ExcludeValidOriginState + ',', '') + strOriginDestinationState 
			FROM vyuTFGetReportingComponentOriginState
				WHERE intReportingComponentId = @RCId 
				AND strType = 'Exclude'

			IF(@ExcludeValidOriginState IS NOT NULL)
				BEGIN
					SET @ExcludeValidOriginState = REPLACE(@ExcludeValidOriginState,',',''',''')
					SET @ExcludeOriginState = '/*EXCLUDE ORIGIN*/  AND tblEMEntityLocation.strState NOT IN (''' + @ExcludeValidOriginState + ''')'
				END
			ELSE
				BEGIN
					SET @ExcludeOriginState = ''
				END

			-- DESTINATION
			DECLARE @IncludeValidDestinationState NVARCHAR(MAX) = NULL
			SELECT @IncludeValidDestinationState = COALESCE(@IncludeValidDestinationState + ',', '') + strOriginDestinationState  
				FROM vyuTFGetReportingComponentDestinationState
					WHERE intReportingComponentId = @RCId 
			AND strType = 'Include'
		
			IF(@IncludeValidDestinationState IS NOT NULL)
				BEGIN
					SET @IncludeValidDestinationState = REPLACE(@IncludeValidDestinationState,',',''',''')
					SET @IncludeDestinationState = '/*INCLUDE DESTINATION*/  AND tblSMCompanyLocation.strStateProvince IN (''' + @IncludeValidDestinationState + ''')'
				END
			ELSE
				BEGIN
					SET @IncludeDestinationState = ''
				END

			DECLARE @ExcludeValidDestinationState NVARCHAR(MAX) = NULL
			SELECT @ExcludeValidDestinationState = COALESCE(@ExcludeValidDestinationState + ',', '') + strOriginDestinationState   
			FROM vyuTFGetReportingComponentDestinationState 
					WHERE intReportingComponentId = @RCId 
			AND strType = 'Exclude'

			IF(@ExcludeValidDestinationState IS NOT NULL)
				BEGIN
					SET @ExcludeValidDestinationState = REPLACE(@ExcludeValidDestinationState,',',''',''')
					SET @ExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND tblSMCompanyLocation.strStateProvince NOT IN (''' + @ExcludeValidDestinationState + ''')'
				END
			ELSE
				BEGIN
					SET @ExcludeDestinationState = ''
				END
				DECLARE @QueryInventory1 NVARCHAR(MAX)
				DECLARE @QueryInventory2 NVARCHAR(MAX)
	     
				SET @QueryInventory1 = 'SELECT DISTINCT 
							 tblICInventoryReceiptItem.intInventoryReceiptItemId, 
							 tblTFReportingComponent.intTaxAuthorityId, 
							 tblTFReportingComponent.strFormCode,
							 tblTFReportingComponent.intReportingComponentId,
							 tblTFReportingComponent.strScheduleCode, 
							 tblTFReportingComponent.strType, 
							 tblTFProductCode.strProductCode,  
							 tblICInventoryReceipt.strBillOfLading, 
							 tblICInventoryReceiptItem.dblReceived, 
							 '''' AS strTaxCategory,
							 tblICInventoryReceiptItem.dblGross, 
							 tblICInventoryReceiptItem.dblNet, 
							 tblICInventoryReceiptItem.dblBillQty, 
							 0, 
							 tblICInventoryReceipt.dtmReceiptDate, 
							 tblSMShipVia.strShipVia, 
							 tblSMShipVia.strTransporterLicense, 
							 tblSMShipVia.strTransportationMode, 
							 tblEMEntity.strName AS strVendorName, 
							 tblEMEntity_Transporter.strName AS strTransporterName, 
							 tblEMEntity.strFederalTaxId AS strVendorFEIN, 
							 tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN, 
							 tblSMCompanySetup.strCompanyName, 
							 tblSMCompanySetup.strAddress, 
							 tblSMCompanySetup.strCity, 
							 tblSMCompanySetup.strState, 
							 tblSMCompanySetup.strZip, 
							 tblSMCompanySetup.strPhone, 
							 tblSMCompanySetup.strStateTaxID, 
							 tblSMCompanySetup.strFederalTaxID, 
							 tblEMEntityLocation.strState AS strOriginState, 
							 tblSMCompanyLocation.strStateProvince AS strDestinationState, 
							 tblTFTerminalControlNumber.strTerminalControlNumber
						FROM tblTFProductCode INNER JOIN
							 tblEMEntityLocation INNER JOIN
							 tblEMEntity INNER JOIN
							 tblSMTaxCode INNER JOIN
							 tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId INNER JOIN
							 tblICItemMotorFuelTax INNER JOIN
							 tblTFReportingComponentProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFReportingComponentProductCode.intProductCodeId INNER JOIN
							 tblICInventoryReceiptItem INNER JOIN
							 tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId INNER JOIN
							 tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId INNER JOIN
							 tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId ON tblICItemMotorFuelTax.intItemId = tblICInventoryReceiptItem.intItemId ON 
							 tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId ON tblEMEntity.intEntityId = tblICInventoryReceipt.intEntityVendorId ON 
							 tblEMEntityLocation.intEntityLocationId = tblICInventoryReceipt.intShipFromId INNER JOIN
							 tblTFReportingComponent ON tblTFReportingComponentProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON 
							 tblTFProductCode.intProductCodeId = tblICItemMotorFuelTax.intProductCodeId LEFT OUTER JOIN
							 tblTRSupplyPoint INNER JOIN
							 tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId ON 
							 tblICInventoryReceipt.intShipFromId = tblTRSupplyPoint.intEntityLocationId FULL OUTER JOIN
							 tblSMShipVia FULL OUTER JOIN
							 tblEMEntity AS tblEMEntity_Transporter ON tblSMShipVia.intEntityShipViaId = tblEMEntity_Transporter.intEntityId ON tblICInventoryReceipt.intShipViaId = tblSMShipVia.intEntityShipViaId CROSS JOIN
							 tblSMCompanySetup '
				SET @QueryInventory2 = 'WHERE tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ')
							 AND CAST(FLOOR(CAST(tblICInventoryReceipt.dtmReceiptDate AS FLOAT))AS DATETIME) BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							 ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
							 ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND tblICInventoryReceipt.ysnPosted = 1'

				SET @QueryInvReceiptRecord = @QueryInventory1 + @QueryInventory2

					DELETE FROM @TFTransaction
					INSERT INTO @TFTransaction(
								[intInventoryReceiptItemId],
								[intTaxAuthorityId],
								[strFormCode],
								[intReportingComponentId],
								[strScheduleCode],
								[strType],
								[strProductCode],
								[strBillOfLading],
								[dblReceived],
								[strTaxCategory],
								[dblGross],
								[dblNet],
								[dblBillQty],
								[dblTax],
								[dtmReceiptDate],
								[strShipVia],
								[strTransporterLicense],
								[strTransportationMode],
								[strVendorName],
								[strTransporterName],
								[strVendorFEIN],
								[strTransporterFEIN],
								[strHeaderCompanyName],
								[strHeaderAddress],
								[strHeaderCity],
								[strHeaderState],
								[strHeaderZip],
								[strHeaderPhone],
								[strHeaderStateTaxID],
								[strHeaderFederalTaxID],
								[strOriginState],
								[strDestinationState],
								[strTerminalControlNumber])
							EXEC(@QueryInvReceiptRecord)
			-- SET INCREMENT PRIMARY ID FOR TEMP @TFTransaction
			--DECLARE @tblTempTransaction_intId INT
			--SET @tblTempTransaction_intId = 0 UPDATE @TFTransaction SET @tblTempTransaction_intId = intId = @tblTempTransaction_intId + 1

			SET @Count = (SELECT count(intId) FROM @TFTransaction)
					WHILE(@Count > 0) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
						BEGIN
						SET @InventoryReceiptItemId = (SELECT intInventoryReceiptItemId FROM @TFTransaction WHERE intId = @Count)
						SET @TaxAmount = (SELECT tblICInventoryReceiptItemTax.dblTax
							FROM tblICInventoryReceiptItemTax INNER JOIN tblSMTaxCode ON tblICInventoryReceiptItemTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
							WHERE (tblICInventoryReceiptItemTax.intInventoryReceiptItemId IN(@InventoryReceiptItemId)) AND (tblTFTaxCategory.strTaxCategory = @TaxCategory))
							UPDATE @TFTransaction SET dblTax = ISNULL(@TaxAmount, 0), strTaxCategory = @TaxCategory WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
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
							, intTaxAuthorityId
							, (SELECT strTaxAuthorityCode FROM tblTFTaxAuthority WHERE intTaxAuthorityId = (SELECT DISTINCT TOP 1 intTaxAuthorityId FROM @TFTransaction))
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
						FROM @TFTransaction
					END
					ELSE
					BEGIN
						INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, '', 0, 1)
					END
				SET @CountRC = @CountRC - 1
		END
		DECLARE @HasResult INT
		SELECT TOP 1 @HasResult = intId from @TFTransaction
		IF(@HasResult IS NULL AND @IsEdi = 'false')
			BEGIN
				INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)
				VALUES(@Guid, 0, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId), NULL,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
			END