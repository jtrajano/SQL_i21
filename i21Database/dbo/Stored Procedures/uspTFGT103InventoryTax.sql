CREATE PROCEDURE [dbo].[uspTFGT103InventoryTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(MAX),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@IsEdi NVARCHAR(10),
@Refresh NVARCHAR(5)

AS

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
		DELETE FROM tblTFTransactions --WHERE uniqTransactionGuid = @Guid
	END
	DELETE FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'
	
DECLARE @tblTempReportingComponent TABLE (
			intId INT IDENTITY(1,1),
			intReportingComponentId INT
		 )

DECLARE @tblTempTaxCategory TABLE (
			intId INT,
			intTaxCodeId INT,
			strCriteria NVARCHAR(50)
		 )
DECLARE @tblTempReceiptItem TABLE (
			intId INT IDENTITY(1,1),
			intInventoryReceiptItemId INT
		 )
DECLARE @tblTempTransaction TABLE (
			intId INT,
			intInventoryReceiptItemId INT,
			intTaxAuthorityId INT,
			strFormCode NVARCHAR(20),
			intReportingComponentDetailId INT,
			strScheduleCode NVARCHAR(20),
			strType NVARCHAR(150),
			intProductCode INT,
            strProductCode NVARCHAR(20),
			strBillOfLading NVARCHAR(100),
			dblReceived NUMERIC(18, 2),
            dblNet NUMERIC(18, 2),
			dblGross NUMERIC(18, 2),
			dblBillQty NUMERIC(18, 2),
			dblTax NUMERIC(18, 2),
			dtmReceiptDate DATETIME,
			strShipVia NVARCHAR(100),
			strTransporterLicense NVARCHAR(50),
			strTransportationMode NVARCHAR(200),
			strVendorName NVARCHAR(250),
			strTransporterName NVARCHAR(250),
			strVendorFEIN NVARCHAR(50),
			strTransporterFEIN NVARCHAR(50),
			strTaxCategory NVARCHAR(200),
			--HEADER
			strHeaderCompanyName NVARCHAR(250),
			strHeaderAddress NVARCHAR(MAX),
			strHeaderCity NVARCHAR(50),
			strHeaderState NVARCHAR(50),
			strHeaderZip NVARCHAR(10),
			strHeaderPhone NVARCHAR(50),
			strHeaderStateTaxID NVARCHAR(50),
			strHeaderFederalTaxID NVARCHAR(50),
			strOriginState NVARCHAR(250),
			strDestinationState NVARCHAR(250),
			strTerminalControlNumber NVARCHAR(30)
		 )

		
	SELECT @QueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempReportingComponent (intReportingComponentId)
	EXEC(@QueryRC)

	SET @CountRC = (select count(intId) from @tblTempReportingComponent) 
	WHILE(@CountRC > 0)
	BEGIN
	SET @RCId = (SELECT intReportingComponentId FROM @tblTempReportingComponent WHERE intId = @CountRC)

		-- ORIGIN
		DECLARE @IncludeValidOriginState NVARCHAR(MAX) = NULL
		SELECT @IncludeValidOriginState = COALESCE(@IncludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentDetailId = @RCId AND strFilter = 'Include'
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
		SELECT @ExcludeValidOriginState = COALESCE(@ExcludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentDetailId = @RCId AND strFilter = 'Exclude'
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
		SELECT @IncludeValidDestinationState = COALESCE(@IncludeValidDestinationState + ',', '') + strDestinationState FROM tblTFValidDestinationState WHERE intReportingComponentDetailId = @RCId AND strStatus = 'Include'
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
		SELECT @ExcludeValidDestinationState = COALESCE(@ExcludeValidDestinationState + ',', '') + strDestinationState FROM tblTFValidDestinationState WHERE intReportingComponentDetailId = @RCId AND strStatus = 'Exclude'
		IF(@ExcludeValidDestinationState IS NOT NULL)
			BEGIN
				SET @ExcludeValidDestinationState = REPLACE(@ExcludeValidDestinationState,',',''',''')
				SET @ExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND tblSMCompanyLocation.strStateProvince NOT IN (''' + @ExcludeValidDestinationState + ''')'
			END
		ELSE
			BEGIN
				SET @ExcludeDestinationState = ''
			END

	     SET @QueryInvReceiptRecord = 'SELECT DISTINCT 0,tblICInventoryReceiptItem.intInventoryReceiptItemId,tblTFReportingComponent.intTaxAuthorityId,tblTFReportingComponent.strFormCode, 
                         tblTFReportingComponentDetail.intReportingComponentDetailId,tblTFReportingComponent.strScheduleCode,tblTFReportingComponent.strType,tblTFValidProductCode.intProductCode, 
                         tblTFValidProductCode.strProductCode,tblICInventoryReceipt.strBillOfLading,tblICInventoryReceiptItem.dblReceived,tblICInventoryReceiptItem.dblGross,tblICInventoryReceiptItem.dblNet, 
                         tblICInventoryReceiptItem.dblBillQty, 0, tblICInventoryReceipt.dtmReceiptDate,tblSMShipVia.strShipVia,tblSMShipVia.strTransporterLicense,tblSMShipVia.strTransportationMode, 
                         tblEMEntity.strName AS strVendorName,tblEMEntity_Transporter.strName AS strTransporterName,tblEMEntity.strFederalTaxId AS strVendorFEIN,tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN, 
                         '''',tblSMCompanySetup.strCompanyName,tblSMCompanySetup.strAddress,tblSMCompanySetup.strCity,tblSMCompanySetup.strState,tblSMCompanySetup.strZip,tblSMCompanySetup.strPhone, 
                         tblSMCompanySetup.strStateTaxID,tblSMCompanySetup.strFederalTaxID,tblEMEntityLocation.strState AS strOriginState,
						 tblSMCompanyLocation.strStateProvince AS strDestinationState,tblTFTerminalControlNumber.strTerminalControlNumber
					FROM tblTRSupplyPoint INNER JOIN tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId=tblTFTerminalControlNumber.intTerminalControlNumberId RIGHT OUTER JOIN tblAPVendor INNER JOIN
                         tblSMTaxCode INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId=tblTFTaxCategory.intTaxCategoryId INNER JOIN
                         tblICInventoryReceiptItem INNER JOIN tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId=tblICInventoryReceipt.intInventoryReceiptId INNER JOIN
                         tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId=tblICInventoryReceiptItemTax.intInventoryReceiptItemId INNER JOIN
                         tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId=tblSMCompanyLocation.intCompanyLocationId INNER JOIN
                         tblICItemMotorFuelTax INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId=tblTFValidProductCode.intProductCode INNER JOIN
                         tblTFReportingComponentDetail ON tblTFValidProductCode.intReportingComponentDetailId=tblTFReportingComponentDetail.intReportingComponentDetailId ON 
                         tblICInventoryReceiptItem.intItemId=tblICItemMotorFuelTax.intItemId ON tblSMTaxCode.intTaxCodeId=tblICInventoryReceiptItemTax.intTaxCodeId INNER JOIN
                         tblTFReportingComponent ON tblTFReportingComponentDetail.intReportingComponentId=tblTFReportingComponent.intReportingComponentId ON 
                         tblAPVendor.intEntityVendorId=tblICInventoryReceipt.intEntityVendorId INNER JOIN
                         tblEMEntity ON tblEMEntity.intEntityId=tblAPVendor.intEntityVendorId INNER JOIN
                         tblEMEntityLocation ON tblEMEntity.intEntityId=tblEMEntityLocation.intEntityId ON tblTRSupplyPoint.intEntityLocationId=tblICInventoryReceipt.intShipFromId FULL OUTER JOIN
                         tblSMShipVia FULL OUTER JOIN tblEMEntity AS tblEMEntity_Transporter ON tblSMShipVia.intEntityShipViaId=tblEMEntity_Transporter.intEntityId ON tblICInventoryReceipt.intShipViaId=tblSMShipVia.intEntityShipViaId CROSS JOIN
                         tblSMCompanySetup 
						 WHERE tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ') 
						 AND tblICInventoryReceipt.dtmReceiptDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
						 ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
						 ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND (tblEMEntityLocation.ysnDefaultLocation=''True'') AND tblICInventoryReceipt.ysnPosted = 1'
			
		DELETE FROM @tblTempTransaction
		INSERT INTO @tblTempTransaction
		EXEC(@QueryInvReceiptRecord)

		-- SET INCREMENT PRIMARY ID FOR TEMP @tblTempTransaction
		DECLARE @tblTempTransaction_intId INT
		SET @tblTempTransaction_intId = 0 UPDATE @tblTempTransaction SET @tblTempTransaction_intId = intId = @tblTempTransaction_intId + 1

		SET @Count = (SELECT count(intId) FROM @tblTempTransaction)
				WHILE(@Count > 0) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
					BEGIN
					SET @InventoryReceiptItemId = (SELECT intInventoryReceiptItemId FROM @tblTempTransaction WHERE intId = @Count)
					SET @TaxAmount = (SELECT tblICInventoryReceiptItemTax.dblTax
						FROM tblICInventoryReceiptItemTax INNER JOIN tblSMTaxCode ON tblICInventoryReceiptItemTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId
						WHERE (tblICInventoryReceiptItemTax.intInventoryReceiptItemId IN(@InventoryReceiptItemId)) AND (tblTFTaxCategory.strTaxCategory = @TaxCategory))
						UPDATE @tblTempTransaction SET dblTax = ISNULL(@TaxAmount, 0), strTaxCategory = @TaxCategory WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
			
						SET @Count = @Count - 1
				END

				IF (@ReportingComponentId <> '')
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, 
																	   intItemId, 
																	   strBillOfLading,
																	   intTaxAuthorityId,
																	   strTaxAuthority,
																	   strFormCode, 
																	   intReportingComponentDetailId, 
																	   strScheduleCode,
																	   strProductCode, 
																	   dblGross,
																	   dblTax,
																	   dtmDate, 
																	   strVendorName, 
																	   strVendorFederalTaxId, 
																	   strType,
																	   strTerminalControlNumber,
																	   dtmReportingPeriodBegin,
																	   dtmReportingPeriodEnd,
																	   strTaxPayerName,
																	   strTaxPayerAddress,
																	   strCity,
																	   strState,
																	   strZipCode,
																	   strTelephoneNumber,
																	   strTaxPayerIdentificationNumber,
																	   strTaxPayerFEIN,
																	   strOriginState, 
																	   strDestinationState,
																	   leaf)

																	   SELECT DISTINCT @Guid,
																	   intInventoryReceiptItemId, 
																	   strBillOfLading,
																	   intTaxAuthorityId,
																	   (SELECT strTaxAuthorityCode FROM tblTFTaxAuthority WHERE intTaxAuthorityId = (SELECT DISTINCT TOP 1 intTaxAuthorityId FROM @tblTempTransaction)),
																	   strFormCode, 
																	   intReportingComponentDetailId, 
																	   strScheduleCode,
																	   strProductCode, 
																	   dblGross,
																	   dblTax,
																		dtmReceiptDate, 
																		strVendorName, 
																		strVendorFEIN, 
																		strType,
																		strTerminalControlNumber,
																		@DateFrom,
																		@DateTo,
																		--HEADER
																		strHeaderCompanyName,
																		strHeaderAddress,
																		strHeaderCity,
																		strHeaderState,
																		strHeaderZip,
																		strHeaderPhone,
																		strHeaderStateTaxID,
																		strHeaderFederalTaxID,
																		strOriginState, 
																		strDestinationState,
																		1
																		FROM @tblTempTransaction
						
					END
				ELSE
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, '', 0, 1)
					END
			SET @CountRC = @CountRC - 1
		END

		DECLARE @HasResult INT
		SELECT TOP 1 @HasResult = intId from @tblTempTransaction
		IF(@HasResult IS NULL AND @IsEdi = 'false')
			BEGIN
				INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)
				VALUES(@Guid, 0, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId), 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
			END