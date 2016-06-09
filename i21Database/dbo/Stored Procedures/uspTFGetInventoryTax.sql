CREATE PROCEDURE [dbo].[uspTFGetInventoryTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(20),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@FormReport NVARCHAR(50)

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
			intProductCode INT,
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
			strOriginState NVARCHAR(250),
			strDestinationState NVARCHAR(250),
			strVendorFEIN NVARCHAR(50),
			strTransporterFEIN NVARCHAR(50)
		 )

		-- ORIGIN

		DECLARE @IncludeValidOriginState nvarchar(MAX)
		
		SELECT @IncludeValidOriginState = COALESCE(@IncludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentDetailId = 1 AND strFilter = 'Include'
		IF(@IncludeValidOriginState IS NOT NULL)
			BEGIN
				SET @IncludeValidOriginState = REPLACE(@IncludeValidOriginState,',',''',''')
				SET @IncludeOriginState = '/*INCLUDE ORIGIN*/ AND tblEMEntityLocation.strState IN (''' + @IncludeValidOriginState + ''')'
			END
		ELSE
			BEGIN
				SET @IncludeOriginState = ''
			END



		DECLARE @ExcludeValidOriginState nvarchar(MAX)
		SELECT @ExcludeValidOriginState = COALESCE(@ExcludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentDetailId = 1 AND strFilter = 'Exclude'
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

		DECLARE @IncludeValidDestinationState nvarchar(MAX)
		SELECT @IncludeValidDestinationState = COALESCE(@IncludeValidDestinationState + ',', '') + strDestinationState FROM tblTFValidDestinationState WHERE intReportingComponentDetailId = 1 AND strStatus = 'Include'
		IF(@IncludeValidDestinationState IS NOT NULL)
			BEGIN
				SET @IncludeValidDestinationState = REPLACE(@IncludeValidDestinationState,',',''',''')
				SET @IncludeDestinationState = '/*INCLUDE DESTINATION*/  AND tblSMCompanyLocation.strStateProvince IN (''' + @IncludeValidDestinationState + ''')'
			END
		ELSE
			BEGIN
				SET @IncludeDestinationState = ''
			END

		DECLARE @ExcludeValidDestinationState nvarchar(MAX)
		SELECT @ExcludeValidDestinationState = COALESCE(@ExcludeValidDestinationState + ',', '') + strDestinationState FROM tblTFValidDestinationState WHERE intReportingComponentDetailId = 1 AND strStatus = 'Exclude'
		IF(@ExcludeValidDestinationState IS NOT NULL)
			BEGIN
				SET @ExcludeValidDestinationState = REPLACE(@ExcludeValidDestinationState,',',''',''')
				SET @ExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND tblSMCompanyLocation.strStateProvince NOT IN (''' + @ExcludeValidDestinationState + ''')'
			END
		ELSE
			BEGIN
				SET @ExcludeDestinationState = ''
			END

	SELECT @QueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempReportingComponent (intReportingComponentId)
	EXEC(@QueryRC)

	SET @CountRC = (select count(intId) from @tblTempReportingComponent) 
	WHILE(@CountRC > 0)
	BEGIN
	SET @RCId = (SELECT intReportingComponentId FROM @tblTempReportingComponent WHERE intId = @CountRC)

		 -- GET INVENTORY RECEIPT/S
		 SET @QueryInvReceiptItemId = 'SELECT DISTINCT 0, tblICInventoryReceiptItem.intInventoryReceiptItemId, tblICInventoryReceipt.strBillOfLading FROM tblEMEntity 
									INNER JOIN tblICInventoryReceiptItem INNER JOIN tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId 
									INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId 
									INNER JOIN tblICItemMotorFuelTax INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode ON tblICInventoryReceiptItem.intItemId = tblICItemMotorFuelTax.intItemId 
									INNER JOIN tblAPVendor ON tblICInventoryReceipt.intEntityVendorId = tblAPVendor.intEntityVendorId ON tblEMEntity.intEntityId = tblAPVendor.intEntityVendorId 
									INNER JOIN tblEMEntityLocation ON tblEMEntity.intEntityId = tblEMEntityLocation.intEntityId 
									INNER JOIN tblTFReportingComponent ON tblTFValidProductCode.intReportingComponentDetailId = tblTFReportingComponent.intReportingComponentId 
									WHERE tblTFReportingComponent.intReportingComponentId IN(' + @ReportingComponentId + ') 
									AND tblICInventoryReceipt.dtmReceiptDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''' 
									' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
									' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ''

	     SET @QueryInvReceiptRecord = 'SELECT DISTINCT tblICInventoryReceiptItem.intInventoryReceiptItemId,tblTFReportingComponent.intTaxAuthorityId,tblTFReportingComponent.strFormCode,
									tblTFReportingComponentDetail.intReportingComponentDetailId,tblTFReportingComponent.strScheduleCode,tblTFReportingComponent.strType,
									tblTFValidProductCode.intProductCode,tblTFValidProductCode.strProductCode,tblICInventoryReceipt.strBillOfLading,tblICInventoryReceiptItem.dblReceived,
									tblICInventoryReceiptItem.dblGross, tblICInventoryReceiptItem.dblNet,tblICInventoryReceiptItem.dblBillQty,tblICInventoryReceipt.dtmReceiptDate,
									tblSMShipVia.strShipVia,tblSMShipVia.strTransporterLicense,tblSMShipVia.strTransportationMode,tblEMEntity.strName AS strVendorName,tblEMEntity_Transporter.strName AS strTransporterName,
									tblEMEntityLocation.strState AS strOriginState,tblSMCompanyLocation.strStateProvince AS strDestinationState,tblEMEntity.strFederalTaxId AS strVendorFEIN,
									tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN FROM tblSMShipVia 
									FULL OUTER JOIN tblEMEntity AS tblEMEntity_Transporter ON tblSMShipVia.intEntityShipViaId = tblEMEntity_Transporter.intEntityId 
									FULL OUTER JOIN tblAPVendor INNER JOIN tblICInventoryReceiptItem 
									INNER JOIN tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId 
									INNER JOIN tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId 
									INNER JOIN tblSMCompanyLocation ON tblICInventoryReceipt.intLocationId = tblSMCompanyLocation.intCompanyLocationId INNER JOIN tblICItemMotorFuelTax 
									INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode 
									INNER JOIN tblTFReportingComponentDetail ON tblTFValidProductCode.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId ON  tblICInventoryReceiptItem.intItemId = tblICItemMotorFuelTax.intItemId 
									INNER JOIN tblTFTaxCriteria ON tblTFTaxCriteria.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId 
									INNER JOIN tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
									INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId AND tblSMTaxCode.intTaxCodeId = tblICInventoryReceiptItemTax.intTaxCodeId 
									INNER JOIN tblTFReportingComponent ON tblTFReportingComponentDetail.intReportingComponentId = tblTFReportingComponent.intReportingComponentId 
									INNER JOIN tblTFValidDestinationState ON tblSMCompanyLocation.strStateProvince = tblTFValidDestinationState.strDestinationState ON tblAPVendor.intEntityVendorId = tblICInventoryReceipt.intEntityVendorId 
									INNER JOIN tblEMEntity ON tblEMEntity.intEntityId = tblAPVendor.intEntityVendorId INNER JOIN tblTFValidOriginState 
									INNER JOIN tblEMEntityLocation ON tblTFValidOriginState.strOriginState = tblEMEntityLocation.strState ON tblEMEntity.intEntityId = tblEMEntityLocation.intEntityId ON tblSMShipVia.intEntityShipViaId = tblICInventoryReceipt.intShipViaId 
									WHERE tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ') 
									AND tblICInventoryReceipt.dtmReceiptDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
									' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
									' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ''
			
				 
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
				SELECT * FROM @tblTempTransaction

				IF (@ReportingComponentId <> '' AND @FormReport = '')
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, 
																	   intItemId, 
																	   intTaxAuthorityId, 
																	   strFormCode, 
																	   intReportingComponentDetailId, 
																	   strScheduleCode,
																	   strType,
																	   intProductCodeId, 
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
																	   strOriginState, 
																	   strDestinationState, 
																	   strVendorFederalTaxId, 
																	   strTransporterFederalTaxId, 
																	   dtmReportingPeriodBegin,
																	   dtmReportingPeriodEnd,
																	   leaf) 

																	   SELECT @Guid, 
																	   intInventoryReceiptItemId, 
																	   intTaxAuthorityId, 
																	   strFormCode, 
																	   intReportingComponentDetailId, 
																	   strScheduleCode,
																	   strType,
																	   intProductCode,
																	   strProductCode, 
																	   strBillOfLading, 
																	   dblReceived, 
																	   dblGross, 
																		dblNet, 
																		dblBillQty, 
																		dtmReceiptDate, 
																		strShipVia, 
																		strTransporterLicense, 
																		strTransportationMode, 
																		strVendorName, 
																		strTransporterName, 
																		strOriginState, 
																		strDestinationState, 
																		strVendorFEIN, 
																		strTransporterFEIN, 
																		@DateFrom,
																		@DateTo,
																		1
																		FROM @tblTempTransaction
						
					END
				ELSE
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, @FormReport, 0, 1)
					END
				

			SET @CountRC = @CountRC - 1
		END

			--exec uspTFGetInventoryTax '66f6568c-a9cd-487b-ba80-e59876eb683f', '1', '04/01/2016', '04/30/2016', ''