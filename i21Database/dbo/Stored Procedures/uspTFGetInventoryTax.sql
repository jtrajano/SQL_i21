CREATE PROCEDURE [dbo].[uspTFGetInventoryTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(20),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@FormReport NVARCHAR(50) = ''

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
DECLARE @TaxCategory NVARCHAR(MAX)
DECLARE @IsValidCategory INT
DECLARE @QueryrReceiptItem NVARCHAR(MAX)
DECLARE @QueryRC NVARCHAR(MAX)
DECLARE @RCId NVARCHAR(50)

-- ORIGIN/DESTINATION
DECLARE @IncludeOriginState NVARCHAR(250)
DECLARE @ExcludeOriginState NVARCHAR(250)
DECLARE @IncludeDestinationState NVARCHAR(250)
DECLARE @ExcludeDestinationState NVARCHAR(250)

DELETE FROM tblTFTransactions

DECLARE @tblTempReportingComponent TABLE (
			intId INT IDENTITY(1,1),
			intReportingComponentId INT
		 )
DECLARE @tblTempReceiptTransation TABLE (
			intId INT,
			intInventoryReceiptItemId INT,
			strBillOfLading NVARCHAR(MAX)
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
			intId INT IDENTITY(1,1),
			intInventoryReceiptItemId INT,
			intTaxAuthorityId INT,
			strFormCode NVARCHAR(20),
			intReportingComponentDetailId INT,
			strScheduleCode NVARCHAR(20),
			strType NVARCHAR(150),
			--intProductCode INT,
            strProductCode NVARCHAR(20),
			strBillOfLading NVARCHAR(100),
			dblReceived NUMERIC(18, 2),
			dblGross NUMERIC(18, 2),
            dblNet NUMERIC(18, 2),
			dblBillQty NUMERIC(18, 2),
			dtmReceiptDate DATETIME,
			strShipVia NVARCHAR(100),
			strTransporterLicense NVARCHAR(50),
			strTransportationMode NVARCHAR(200),
			strVendorName NVARCHAR(250),
			strTransporterName NVARCHAR(250),
			strVendorFEIN NVARCHAR(50),
			strTransporterFEIN NVARCHAR(50),
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
			strDestinationState NVARCHAR(250)
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
					SET @IncludeOriginState = ' AND tblEMEntityLocation.strState IN (''' + @IncludeValidOriginState + ''')'
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
					SET @ExcludeOriginState = ' AND tblEMEntityLocation.strState NOT IN (''' + @ExcludeValidOriginState + ''')'
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
					SET @IncludeDestinationState = ' AND tblSMCompanyLocation.strStateProvince IN (''' + @IncludeValidDestinationState + ''')'
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
					SET @ExcludeDestinationState = ' AND tblSMCompanyLocation.strStateProvince NOT IN (''' + @ExcludeValidDestinationState + ''')'
				END
			ELSE
				BEGIN
					SET @ExcludeDestinationState = ''
				END

		 -- GET INVENTORY RECEIPT/S
		 SET @QueryInvReceiptItemId = 'SELECT DISTINCT 0,tblICInventoryReceiptItem.intInventoryReceiptItemId,tblICInventoryReceipt.strBillOfLading FROM tblEMEntity 
									INNER JOIN tblICInventoryReceiptItem INNER JOIN tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId 
									INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId=tblSMCompanyLocation.intCompanyLocationId 
									INNER JOIN tblICItemMotorFuelTax INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId=tblTFValidProductCode.intProductCode ON tblICInventoryReceiptItem.intItemId = tblICItemMotorFuelTax.intItemId 
									INNER JOIN tblAPVendor ON tblICInventoryReceipt.intEntityVendorId = tblAPVendor.intEntityVendorId ON tblEMEntity.intEntityId=tblAPVendor.intEntityVendorId 
									INNER JOIN tblEMEntityLocation ON tblEMEntity.intEntityId=tblEMEntityLocation.intEntityId 
									INNER JOIN tblTFReportingComponent ON tblTFValidProductCode.intReportingComponentDetailId=tblTFReportingComponent.intReportingComponentId 
									WHERE tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ') 
									AND tblICInventoryReceipt.dtmReceiptDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''' 
									' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
									' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND (tblEMEntityLocation.ysnDefaultLocation = ''True'')'

	     DECLARE @HasCriteria INT = (SELECT TOP 1 tblTFTaxCriteria.intTaxCategoryId FROM tblTFTaxCriteria INNER JOIN tblTFReportingComponentDetail ON tblTFTaxCriteria.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId WHERE (tblTFTaxCriteria.intReportingComponentDetailId = @RCId))
		 IF(@HasCriteria IS NOT NULL)
			BEGIN
				SET @QueryInvReceiptRecord = 'SELECT DISTINCT 
							 tblICInventoryReceiptItem.intInventoryReceiptItemId,tblTFReportingComponent.intTaxAuthorityId,tblTFReportingComponent.strFormCode,tblTFReportingComponentDetail.intReportingComponentDetailId, 
							 tblTFReportingComponent.strScheduleCode,tblTFReportingComponent.strType,tblTFValidProductCode.strProductCode,tblICInventoryReceipt.strBillOfLading,tblICInventoryReceiptItem.dblReceived, 
							 tblICInventoryReceiptItem.dblGross,tblICInventoryReceiptItem.dblNet,tblICInventoryReceiptItem.dblBillQty,tblICInventoryReceipt.dtmReceiptDate,tblSMShipVia.strShipVia,tblSMShipVia.strTransporterLicense, 
							 tblSMShipVia.strTransportationMode,tblEMEntity.strName AS strVendorName,tblEMEntity_Transporter.strName AS strTransporterName,tblEMEntity.strFederalTaxId AS strVendorFEIN, 
							 tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN,tblSMCompanySetup.strCompanyName,tblSMCompanySetup.strAddress,tblSMCompanySetup.strCity,tblSMCompanySetup.strState, 
							 tblSMCompanySetup.strZip,tblSMCompanySetup.strPhone,tblSMCompanySetup.strStateTaxID,tblSMCompanySetup.strFederalTaxID,
							 tblEMEntityLocation.strState AS strOriginState,tblSMCompanyLocation.strStateProvince
						FROM tblSMShipVia FULL OUTER JOIN tblEMEntity AS tblEMEntity_Transporter ON tblSMShipVia.intEntityShipViaId=tblEMEntity_Transporter.intEntityId FULL OUTER JOIN
							 tblAPVendor INNER JOIN tblICInventoryReceiptItem INNER JOIN
							 tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId=tblICInventoryReceipt.intInventoryReceiptId INNER JOIN
							 tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId=tblICInventoryReceiptItemTax.intInventoryReceiptItemId INNER JOIN
							 tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId=tblSMCompanyLocation.intCompanyLocationId INNER JOIN
							 tblICItemMotorFuelTax INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId=tblTFValidProductCode.intProductCode INNER JOIN
							 tblTFReportingComponentDetail ON tblTFValidProductCode.intReportingComponentDetailId=tblTFReportingComponentDetail.intReportingComponentDetailId ON 
							 tblICInventoryReceiptItem.intItemId=tblICItemMotorFuelTax.intItemId INNER JOIN
							 tblTFTaxCriteria ON tblTFTaxCriteria.intReportingComponentDetailId=tblTFReportingComponentDetail.intReportingComponentDetailId INNER JOIN
							 tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId=tblTFTaxCategory.intTaxCategoryId INNER JOIN
							 tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId=tblSMTaxCode.intTaxCategoryId AND tblSMTaxCode.intTaxCodeId=tblICInventoryReceiptItemTax.intTaxCodeId INNER JOIN
							 tblTFReportingComponent ON tblTFReportingComponentDetail.intReportingComponentId=tblTFReportingComponent.intReportingComponentId ON 
							 tblAPVendor.intEntityVendorId=tblICInventoryReceipt.intEntityVendorId INNER JOIN
							 tblEMEntity ON tblEMEntity.intEntityId=tblAPVendor.intEntityVendorId INNER JOIN
							 tblEMEntityLocation ON tblEMEntity.intEntityId=tblEMEntityLocation.intEntityId ON tblSMShipVia.intEntityShipViaId=tblICInventoryReceipt.intShipViaId CROSS JOIN
							 tblSMCompanySetup
					   WHERE tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ') 
							 AND tblICInventoryReceipt.dtmReceiptDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							 ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
							 ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND (tblEMEntityLocation.ysnDefaultLocation=''True'')'
			END
		ELSE
			BEGIN
				SET @QueryInvReceiptRecord = 'SELECT DISTINCT 
							 tblICInventoryReceiptItem.intInventoryReceiptItemId,tblTFReportingComponent.intTaxAuthorityId,tblTFReportingComponent.strFormCode,tblTFReportingComponentDetail.intReportingComponentDetailId, 
							 tblTFReportingComponent.strScheduleCode,tblTFReportingComponent.strType,tblTFValidProductCode.strProductCode,tblICInventoryReceipt.strBillOfLading,tblICInventoryReceiptItem.dblReceived, 
							 tblICInventoryReceiptItem.dblGross,tblICInventoryReceiptItem.dblNet,tblICInventoryReceiptItem.dblBillQty,tblICInventoryReceipt.dtmReceiptDate,tblSMShipVia.strShipVia,tblSMShipVia.strTransporterLicense, 
							 tblSMShipVia.strTransportationMode,tblEMEntity.strName AS strVendorName,tblEMEntity_Transporter.strName AS strTransporterName,tblEMEntity.strFederalTaxId AS strVendorFEIN, 
							 tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN,tblSMCompanySetup.strCompanyName,tblSMCompanySetup.strAddress,tblSMCompanySetup.strCity,tblSMCompanySetup.strState, 
							 tblSMCompanySetup.strZip,tblSMCompanySetup.strPhone,tblSMCompanySetup.strStateTaxID,tblSMCompanySetup.strFederalTaxID,
							 tblEMEntityLocation.strState AS strOriginState,tblSMCompanyLocation.strStateProvince
						FROM tblSMShipVia FULL OUTER JOIN
							 tblEMEntity AS tblEMEntity_Transporter ON tblSMShipVia.intEntityShipViaId=tblEMEntity_Transporter.intEntityId FULL OUTER JOIN
							 tblAPVendor INNER JOIN
							 tblSMTaxCode INNER JOIN
							 tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId=tblTFTaxCategory.intTaxCategoryId INNER JOIN
							 tblICInventoryReceiptItem INNER JOIN
							 tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId=tblICInventoryReceipt.intInventoryReceiptId INNER JOIN
							 tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId=tblICInventoryReceiptItemTax.intInventoryReceiptItemId INNER JOIN
							 tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId=tblSMCompanyLocation.intCompanyLocationId INNER JOIN
							 tblICItemMotorFuelTax INNER JOIN
							 tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId=tblTFValidProductCode.intProductCode INNER JOIN
							 tblTFReportingComponentDetail ON tblTFValidProductCode.intReportingComponentDetailId=tblTFReportingComponentDetail.intReportingComponentDetailId ON 
							 tblICInventoryReceiptItem.intItemId=tblICItemMotorFuelTax.intItemId ON tblSMTaxCode.intTaxCodeId=tblICInventoryReceiptItemTax.intTaxCodeId INNER JOIN
							 tblTFReportingComponent ON tblTFReportingComponentDetail.intReportingComponentId=tblTFReportingComponent.intReportingComponentId ON 
							 tblAPVendor.intEntityVendorId=tblICInventoryReceipt.intEntityVendorId INNER JOIN
							 tblEMEntity ON tblEMEntity.intEntityId=tblAPVendor.intEntityVendorId INNER JOIN
							 tblEMEntityLocation ON tblEMEntity.intEntityId=tblEMEntityLocation.intEntityId ON tblSMShipVia.intEntityShipViaId=tblICInventoryReceipt.intShipViaId CROSS JOIN
							 tblSMCompanySetup
					   WHERE tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ') 
							 AND tblICInventoryReceipt.dtmReceiptDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							 ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
							 ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND (tblEMEntityLocation.ysnDefaultLocation=''True'')'
			END
			
		DELETE FROM @tblTempTransaction
		INSERT INTO @tblTempTransaction
		EXEC(@QueryInvReceiptRecord)

		DELETE FROM @tblTempReceiptTransation
		INSERT INTO @tblTempReceiptTransation
		EXEC(@QueryInvReceiptItemId)

		-- SET INCREMENT ID TEMP TRANSACTION
		DECLARE @tblTempReceiptTransation_intId INT
		SET @tblTempReceiptTransation_intId = 0 UPDATE @tblTempReceiptTransation SET @tblTempReceiptTransation_intId = intId = @tblTempReceiptTransation_intId + 1

		-- RETRIEVE TAX CATEGORY BASED ON RECEIPT ITEM ID/S
		SET @QueryTaxCategory = 'SELECT 0, tblSMTaxCode.intTaxCodeId, tblTFTaxCriteria.strCriteria
								 FROM   tblSMTaxCode INNER JOIN
										tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId INNER JOIN
										tblTFTaxCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFTaxCriteria.intTaxCategoryId
								 WHERE  (tblTFTaxCriteria.intReportingComponentDetailId IN(' + @RCId + '))'
						
		DELETE FROM @tblTempTaxCategory			 
		INSERT INTO @tblTempTaxCategory
		EXEC(@QueryTaxCategory)

		-- SET INCREMENT ID TEMP CATEGORY
		DECLARE @tblTempTaxCategory_intId int
		SET @tblTempTaxCategory_intId = 0 UPDATE @tblTempTaxCategory SET @tblTempTaxCategory_intId = intId = @tblTempTaxCategory_intId + 1

		SET @Count = (select count(intId) from @tblTempReceiptTransation) 				
				WHILE(@Count > 0) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
					BEGIN
						SET @InventoryReceiptItemId = (SELECT intInventoryReceiptItemId FROM @tblTempReceiptTransation WHERE intId = @Count)
						 SET @TaxCategoryCount = (select count(intId) from @tblTempTaxCategory)
								 WHILE(@TaxCategoryCount > 0) -- LOOP ON TAX CATEGORY
								 BEGIN
									
									SET @TaxCodeId = (SELECT intTaxCodeId FROM @tblTempTaxCategory WHERE intId = @TaxCategoryCount)
									SET @TaxCriteria = (SELECT strCriteria FROM @tblTempTaxCategory WHERE intId = @TaxCategoryCount)
									SET @QueryrReceiptItem = 'SELECT  DISTINCT tblICInventoryReceiptItemTax.intInventoryReceiptItemId FROM
																	-- tblSMTaxCode INNER JOIN
																	 tblICInventoryReceiptItem INNER JOIN
																	 tblICInventoryReceiptItemTax 
																	 ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId 
																	 --ON tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId
															  WHERE  (tblICInventoryReceiptItem.intInventoryReceiptItemId IN(''' + @InventoryReceiptItemId + '''))
																	 AND (tblICInventoryReceiptItemTax.intTaxCodeId = ''' + @TaxCodeId + ''')
																	 AND (tblICInventoryReceiptItemTax.dblTax ' + @TaxCriteria + ')'
									DELETE FROM @tblTempReceiptItem
									INSERT INTO @tblTempReceiptItem
									EXEC(@QueryrReceiptItem)
	
									SET @IsValidCategory = (SELECT intInventoryReceiptItemId FROM @tblTempReceiptItem)
											 IF (@IsValidCategory IS NULL) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
												 BEGIN
													 DELETE FROM @tblTempTransaction WHERE intInventoryReceiptItemId = @InventoryReceiptItemId
													 
													BREAK
												 END
									SET @TaxCategoryCount = @TaxCategoryCount - 1
								 END
						SET @Count = @Count - 1
				END
			
				IF (@ReportingComponentId <> '' AND @FormReport = '')
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, 
																	   intItemId, 
																	   intTaxAuthorityId, 
																	   strFormCode, 
																	   intReportingComponentDetailId, 
																	   strScheduleCode,
																	   strType,
																	   --intProductCodeId, 
																	   strProductCode, 
																	   strBillOfLading, 
																	   dblReceived, 
																	   dblGross, 
																	   dblNet, 
																	   dblBillQty, 
																	   dtmDate, 
																	   strShipVia, 
																	   strTransporterLicense, 
																	   strTransportationMode, 
																	   strVendorName, 
																	   strTransporterName, 
																	   strVendorFederalTaxId, 
																	   strTransporterFederalTaxId, 
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
																	   intTaxAuthorityId, 
																	   strFormCode, 
																	   intReportingComponentDetailId, 
																	   strScheduleCode,
																	   strType,
																	   --intProductCode,
																	   strProductCode, 
																	   strBillOfLading, 
																	   dblReceived, 
																	   dblGross, 
																		dblNet, 
																		dblBillQty, 
																		@DateFrom, 
																		strShipVia, 
																		strTransporterLicense, 
																		strTransportationMode, 
																		strVendorName, 
																		strTransporterName, 
																		strVendorFEIN, 
																		strTransporterFEIN, 
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
						INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, @FormReport, 0, 1)
					END
			SET @CountRC = @CountRC - 1
		END

		DECLARE @HasResult INT
		SELECT TOP 1 @HasResult = intId from @tblTempTransaction
		IF(@HasResult IS NULL)
			BEGIN
				INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId), 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
			END


	