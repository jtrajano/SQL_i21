CREATE PROCEDURE [dbo].[uspTFGetInvoiceTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(MAX),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@IsEdi NVARCHAR(10),
@Refresh NVARCHAR(5)

AS

DECLARE @Count INT
DECLARE @CountRC INT
DECLARE @InvoiceDetailId NVARCHAR(50)
DECLARE @QueryInvoice NVARCHAR(MAX)
DECLARE @QueryReceipt NVARCHAR(MAX)
DECLARE @QueryTaxCategory NVARCHAR(MAX)

DECLARE @TaxCodeId NVARCHAR(50)
DECLARE @TaxCategoryCount INT
DECLARE @TaxCriteria NVARCHAR(10)
DECLARE @TaxCategory NVARCHAR(MAX)
DECLARE @QueryrInvoiceDetailId NVARCHAR(MAX)
DECLARE @IsValidCategory INT
DECLARE @QueryInvoiceNumber NVARCHAR(MAX)
DECLARE @QueryRC NVARCHAR(MAX)
DECLARE @RCId NVARCHAR(50)

DECLARE @tblTempReportingComponent TABLE (
			intId INT IDENTITY(1,1),
			intReportingComponentId INT
		 )
DECLARE @tblTempInvoiceTransaction TABLE (
			intId INT,
			intInvoiceDetailId INT,
			strInvoiceNumber NVARCHAR(50)
		 )
DECLARE @tblTempTaxCategory TABLE (
			intId INT,
			intTaxCodeId INT,
			strCriteria NVARCHAR(50)
		 )
DECLARE @tblTempInvoiceDetail TABLE (
			intId INT IDENTITY(1,1),
			intInvoiceDetailId INT
		 )
DECLARE @tblTempTransaction TABLE (
			intId INT IDENTITY(1,1),
			intInvoiceDetailId INT,
			intTaxAuthorityId INT,
			strFormCode NVARCHAR(50),
			intReportingComponentId INT,
			strScheduleCode NVARCHAR(50),
			strType NVARCHAR(150),
			intProductCode INT,
			strProductCode NVARCHAR(20),
			intItemId INT,
			dblQtyShipped NUMERIC(18, 6),
			dblGross NUMERIC(18, 6),
			dblNet NUMERIC(18, 6),
			dblBillQty NUMERIC(18, 6),
			dblTax NUMERIC(18, 2),
			strInvoiceNumber NVARCHAR(50),
			strPONumber NVARCHAR(50),
			strBOLNumber NVARCHAR(50),
			dtmDate DATETIME,
			strDestinationCity NVARCHAR(50),
			strDestinationState NVARCHAR(50),
			strOriginCity NVARCHAR(50),
			strOriginState NVARCHAR(50),
			strCustomerName NVARCHAR(250),
			strCustomerFEIN NVARCHAR(50),
			strAccountStatusCode NVARCHAR(50),
			strShipVia NVARCHAR(50),
			strTransporterLicense NVARCHAR(50),
			strTransportationMode NVARCHAR(50),
			strTransporterName NVARCHAR(250),
			strTransporterFEIN NVARCHAR(50),
			strTaxCode NVARCHAR(200),
			strTerminalControlNumber NVARCHAR(50),
			strVendorName NVARCHAR(50),
			strVendorFederalTaxId NVARCHAR(50),
			--HEADER
			strHeaderCompanyName NVARCHAR(250),
			strHeaderAddress NVARCHAR(MAX),
			strHeaderCity NVARCHAR(50),
			strHeaderState NVARCHAR(50),
			strHeaderZip NVARCHAR(50),
			strHeaderPhone NVARCHAR(50),
			strHeaderStateTaxID NVARCHAR(50),
			strHeaderFederalTaxID NVARCHAR(50)
		 )

	IF @Refresh = 'true'
		BEGIN
			DELETE FROM tblTFTransactions --WHERE uniqTransactionGuid = @Guid
		END
		DELETE FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'

	-- ORIGIN/DESTINATION
	DECLARE @IncludeOriginState NVARCHAR(250)
	DECLARE @ExcludeOriginState NVARCHAR(250)
	DECLARE @IncludeDestinationState NVARCHAR(250)
	DECLARE @ExcludeDestinationState NVARCHAR(250)

	DECLARE @IncludeLocationState NVARCHAR(250)
	DECLARE @ExcludeLocationState NVARCHAR(250)

	-- ORIGIN
	SELECT @QueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
	
	INSERT INTO @tblTempReportingComponent (intReportingComponentId)
	EXEC(@QueryRC)

	SET @CountRC = (select count(intId) from @tblTempReportingComponent) 
	WHILE(@CountRC > 0)
	BEGIN
	SET @RCId = (SELECT intReportingComponentId FROM @tblTempReportingComponent WHERE intId = @CountRC)

		DECLARE @IncludeValidOriginState NVARCHAR(MAX) = NULL
		SELECT @IncludeValidOriginState = COALESCE(@IncludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentId = @RCId AND strFilter = 'Include'
		IF(@IncludeValidOriginState IS NOT NULL)
			BEGIN
				SET @IncludeValidOriginState = REPLACE(@IncludeValidOriginState,',',''',''')
				SET @IncludeOriginState = '/*INCLUDE ORIGIN*/ AND tblSMCompanyLocation.strStateProvince IN (''' + @IncludeValidOriginState + ''')' 
			END
		ELSE
			BEGIN
				SET @IncludeOriginState = ''
			END

		DECLARE @ExcludeValidOriginState NVARCHAR(MAX) = NULL
		SELECT @ExcludeValidOriginState = COALESCE(@ExcludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentId = @RCId AND strFilter = 'Exclude'
		IF(@ExcludeValidOriginState IS NOT NULL)
			BEGIN
				SET @ExcludeValidOriginState = REPLACE(@ExcludeValidOriginState,',',''',''')
				SET @ExcludeOriginState = '/*EXCLUDE ORIGIN*/  AND tblSMCompanyLocation.strStateProvince NOT IN (''' + @ExcludeValidOriginState + ''')'
			END
		ELSE
			BEGIN
				SET @ExcludeOriginState = ''
			END

		-- DESTINATION NON PICKUP
		DECLARE @IncludeValidDestinationState NVARCHAR(MAX) = NULL
		SELECT @IncludeValidDestinationState = COALESCE(@IncludeValidDestinationState + ',', '') + strDestinationState FROM tblTFValidDestinationState WHERE intReportingComponentId = @RCId AND strStatus = 'Include'
		IF(@IncludeValidDestinationState IS NOT NULL)
			BEGIN
				SET @IncludeValidDestinationState = REPLACE(@IncludeValidDestinationState,',',''',''')
				SET @IncludeDestinationState = '/*INCLUDE DESTINATION*/  AND tblARInvoice.strShipToState IN (''' + @IncludeValidDestinationState + ''')'
			END
		ELSE
			BEGIN
				SET @IncludeDestinationState = ''
			END

		DECLARE @ExcludeValidDestinationState NVARCHAR(MAX) = NULL
		SELECT @ExcludeValidDestinationState = COALESCE(@ExcludeValidDestinationState + ',', '') + strDestinationState FROM tblTFValidDestinationState WHERE intReportingComponentId = @RCId AND strStatus = 'Exclude'
		IF(@ExcludeValidDestinationState IS NOT NULL)
			BEGIN
				SET @ExcludeValidDestinationState = REPLACE(@ExcludeValidDestinationState,',',''',''')
				SET @ExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND tblARInvoice.strShipToState NOT IN (''' + @ExcludeValidDestinationState + ''')'
			END
		ELSE
			BEGIN
				SET @ExcludeDestinationState = ''
			END

		 SET @QueryInvoiceNumber = 'SELECT DISTINCT 0, tblARInvoiceDetail.intInvoiceDetailId, tblARInvoice.strInvoiceNumber FROM tblARInvoiceDetail 
								   INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
								   INNER JOIN  tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId 
								   INNER JOIN tblTFTaxCriteria INNER JOIN tblICItemMotorFuelTax 
								   INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode 
								   INNER JOIN tblTFReportingComponent ON tblTFValidProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON  tblTFTaxCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId 
								   INNER JOIN tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
								   INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId ON tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId AND  tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId 
								   INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
								   WHERE tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ') 
								   AND tblARInvoice.dtmDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''' 
									' + @IncludeOriginState + ' ' + @ExcludeOriginState + ' 
									' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND tblARInvoice.ysnPosted = 1'

		 DECLARE @HasCriteria INT = (SELECT TOP 1 tblTFTaxCriteria.intTaxCategoryId FROM tblTFTaxCriteria INNER JOIN tblTFReportingComponent ON tblTFTaxCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId WHERE (tblTFTaxCriteria.intReportingComponentId = @RCId))
		 IF(@HasCriteria IS NOT NULL)
			BEGIN
				DECLARE @QueryInvoiceWCriteriaPart1 NVARCHAR(MAX)
				DECLARE @QueryInvoiceWCriteriaPart2 NVARCHAR(MAX)

				SET @QueryInvoiceWCriteriaPart1 = 'SELECT DISTINCT 
                         tblARInvoiceDetail.intInvoiceDetailId, tblTFReportingComponent.intTaxAuthorityId, tblTFReportingComponent.strFormCode, tblTFReportingComponent.intReportingComponentId, 
                         tblTFReportingComponent.strScheduleCode, tblTFReportingComponent.strType, tblTFValidProductCode.intProductCode, tblTFValidProductCode.strProductCode, tblARInvoiceDetail.intItemId, 
                         tblARInvoiceDetail.dblQtyShipped,tblARInvoiceDetail.dblQtyShipped AS dblNet, tblARInvoiceDetail.dblQtyShipped AS dblGross,tblARInvoiceDetail.dblQtyShipped AS dblBillQty,tblARInvoiceDetailTax.dblTax, tblARInvoice.strInvoiceNumber, tblARInvoice.strPONumber, tblARInvoice.strBOLNumber, 
                         tblARInvoice.dtmDate, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity, 
                         (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState, tblSMCompanyLocation.strCity AS strOriginCity, 
                         tblSMCompanyLocation.strStateProvince AS strOriginState, tblEMEntity.strName, tblEMEntity.strFederalTaxId AS strCustomerFEIN, tblARAccountStatus.strAccountStatusCode, tblSMShipVia.strShipVia, 
                         tblSMShipVia.strTransporterLicense, tblSMShipVia.strTransportationMode, tblEMEntity_Transporter.strName AS strTransporterName, tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN, 
                         tblSMTaxCode.strTaxCode, NULL, NULL, NULL, tblSMCompanySetup.strCompanyName, tblSMCompanySetup.strAddress, tblSMCompanySetup.strCity, 
                         tblSMCompanySetup.strState, tblSMCompanySetup.strZip, tblSMCompanySetup.strPhone, tblSMCompanySetup.strStateTaxID, tblSMCompanySetup.strFederalTaxID '

				SET @QueryInvoiceWCriteriaPart2 = 'FROM tblEMEntity AS tblEMEntity_Transporter INNER JOIN
                         tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityShipViaId FULL OUTER JOIN
                         tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId INNER JOIN
                         tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId INNER JOIN
                         tblTFTaxCriteria INNER JOIN tblICItemMotorFuelTax INNER JOIN
                         tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode INNER JOIN
                         tblTFReportingComponent ON tblTFValidProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON 
                         tblTFTaxCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId INNER JOIN
                         tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId INNER JOIN
                         tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId ON tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId AND 
                         tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId INNER JOIN
                         tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId INNER JOIN
                         tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId INNER JOIN
                         tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId FULL OUTER JOIN
                         tblARAccountStatus ON tblARCustomer.intAccountStatusId = tblARAccountStatus.intAccountStatusId CROSS JOIN
                         tblSMCompanySetup
						WHERE (tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ')) 
						AND dtmDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
						' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
						' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND tblARInvoice.ysnPosted = 1'

					SET @QueryInvoice = @QueryInvoiceWCriteriaPart1 + @QueryInvoiceWCriteriaPart2
			END
		ELSE
			BEGIN
				DECLARE @QueryInvoicePart1 NVARCHAR(MAX)
				DECLARE @QueryInvoicePart2 NVARCHAR(MAX)

				SET @QueryInvoicePart1 = 'SELECT DISTINCT tblARInvoiceDetail.intInvoiceDetailId, tblTFReportingComponent.intTaxAuthorityId, tblTFReportingComponent.strFormCode, tblTFReportingComponent.intReportingComponentId, 
                         tblTFReportingComponent.strScheduleCode, tblTFReportingComponent.strType, tblTFValidProductCode.intProductCode, tblTFValidProductCode.strProductCode, tblARInvoiceDetail.intItemId, 
                         tblARInvoiceDetail.dblQtyShipped,tblARInvoiceDetail.dblQtyShipped AS dblNet, tblARInvoiceDetail.dblQtyShipped AS dblGross,tblARInvoiceDetail.dblQtyShipped AS dblBillQty,tblARInvoiceDetailTax.dblTax, tblARInvoice.strInvoiceNumber, tblARInvoice.strPONumber, tblARInvoice.strBOLNumber, 
                         tblARInvoice.dtmDate, (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity, 
                         (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState, tblSMCompanyLocation.strCity AS strOriginCity, 
                         tblSMCompanyLocation.strStateProvince AS strOriginState, tblEMEntity.strName, tblEMEntity.strFederalTaxId AS strCustomerFEIN, tblARAccountStatus.strAccountStatusCode, tblSMShipVia.strShipVia, 
                         tblSMShipVia.strTransporterLicense, tblSMShipVia.strTransportationMode, tblEMEntity_Transporter.strName AS strTransporterName, tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN, 
                         tblSMTaxCode.strTaxCode, NULL, NULL, NULL, tblSMCompanySetup.strCompanyName, tblSMCompanySetup.strAddress, tblSMCompanySetup.strCity, 
                         tblSMCompanySetup.strState, tblSMCompanySetup.strZip, tblSMCompanySetup.strPhone, tblSMCompanySetup.strStateTaxID, tblSMCompanySetup.strFederalTaxID '

				SET @QueryInvoicePart2 = 'FROM tblEMEntity AS tblEMEntity_Transporter INNER JOIN
                         tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityShipViaId FULL OUTER JOIN
                         tblICItemMotorFuelTax INNER JOIN
                         tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode INNER JOIN
                         tblTFReportingComponent ON tblTFValidProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId INNER JOIN
                         tblSMTaxCode INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId INNER JOIN
                         tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId INNER JOIN
                         tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId ON 
                         tblICItemMotorFuelTax.intItemId = tblARInvoiceDetail.intItemId INNER JOIN
                         tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId INNER JOIN
                         tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId INNER JOIN
                         tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId FULL OUTER JOIN
                         tblARAccountStatus ON tblARCustomer.intAccountStatusId = tblARAccountStatus.intAccountStatusId CROSS JOIN
                         tblSMCompanySetup
						 WHERE (tblTFReportingComponent.intReportingComponentId IN (' + @RCId + '))
						 AND dtmDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
						' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
						' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND tblARInvoice.ysnPosted = 1'

				SET @QueryInvoice = @QueryInvoicePart1 + @QueryInvoicePart2
			END
	
		DELETE FROM @tblTempInvoiceTransaction
		INSERT INTO @tblTempInvoiceTransaction
		EXEC(@QueryInvoiceNumber)

		DELETE FROM @tblTempTransaction
		INSERT INTO @tblTempTransaction
		EXEC(@QueryInvoice)

		-- SET INCREMENT ID TEMP TRANSACTION
		DECLARE @tblTempReceiptTransation_intId INT
		SET @tblTempReceiptTransation_intId = 0 UPDATE @tblTempInvoiceTransaction SET @tblTempReceiptTransation_intId = intId = @tblTempReceiptTransation_intId + 1

		-- RETRIEVE TAX CATEGORY BASED ON RECEIPT ITEM ID/S
		SET @QueryTaxCategory = 'SELECT 0, tblSMTaxCode.intTaxCodeId, tblTFTaxCriteria.strCriteria
								 FROM   tblSMTaxCode INNER JOIN
										tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId INNER JOIN
										tblTFTaxCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFTaxCriteria.intTaxCategoryId
								 WHERE  (tblTFTaxCriteria.intReportingComponentId IN(' + @RCId + '))'
						
		DELETE FROM @tblTempTaxCategory			 
		INSERT INTO @tblTempTaxCategory
		EXEC(@QueryTaxCategory)

		-- SET INCREMENT ID TEMP CATEGORY
		DECLARE @tblTempTaxCategory_intId INT
		SET @tblTempTaxCategory_intId = 0 UPDATE @tblTempTaxCategory SET @tblTempTaxCategory_intId = intId = @tblTempTaxCategory_intId + 1

		SET @Count = (SELECT count(intId) FROM @tblTempInvoiceTransaction) 				
				WHILE(@Count > 0) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
					BEGIN
						SET @InvoiceDetailId = (SELECT intInvoiceDetailId FROM @tblTempInvoiceTransaction WHERE intId = @Count)
						 SET @TaxCategoryCount = (select count(intId) FROM @tblTempTaxCategory)
								 WHILE(@TaxCategoryCount > 0) -- LOOP ON TAX CATEGORY
								 BEGIN
									
									SET @TaxCodeId = (SELECT intTaxCodeId FROM @tblTempTaxCategory WHERE intId = @TaxCategoryCount)
									SET @TaxCriteria = (SELECT strCriteria FROM @tblTempTaxCategory WHERE intId = @TaxCategoryCount)

									SET @QueryrInvoiceDetailId =  'SELECT DISTINCT tblARInvoiceDetailTax.intInvoiceDetailId
																	  FROM  tblARInvoiceDetail INNER JOIN
																			tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId
																			WHERE tblARInvoiceDetailTax.intInvoiceDetailId IN(''' + @InvoiceDetailId + ''')
																			AND (tblARInvoiceDetailTax.intTaxCodeId = ''' + @TaxCodeId + ''')
																			AND (tblARInvoiceDetailTax.dblTax ' + @TaxCriteria + ')'

										   
									DELETE FROM @tblTempInvoiceDetail
									INSERT INTO @tblTempInvoiceDetail
									EXEC(@QueryrInvoiceDetailId)
	
									SET @IsValidCategory = (SELECT intInvoiceDetailId FROM @tblTempInvoiceDetail)
											 IF (@IsValidCategory IS NULL) -- IF CATEGORY DOES NOT EXIST, EXIT LOOP
												 BEGIN
													 DELETE FROM @tblTempTransaction WHERE intInvoiceDetailId = @InvoiceDetailId
													 
													BREAK
												 END
									SET @TaxCategoryCount = @TaxCategoryCount - 1
								 END
								 
						SET @Count = @Count - 1
				END

				--INVENTORY TRANSFER
				DECLARE @InvTransferQuery NVARCHAR(MAX)
				DECLARE @InvQueryPart1 NVARCHAR(MAX)
				DECLARE @InvQueryPart2 NVARCHAR(MAX)
		
				SET @InvQueryPart1 = 'SELECT DISTINCT 
                         NULL AS intInvoiceDetailId, tblTFReportingComponent.intTaxAuthorityId, tblTFReportingComponent.strFormCode, tblTFReportingComponent.intReportingComponentId, tblTFReportingComponent.strScheduleCode, 
                         tblTFReportingComponent.strType, tblTFValidProductCode.intProductCode, tblTFValidProductCode.strProductCode, tblICInventoryTransferDetail.intItemId,tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped, 
                         tblICInventoryTransferDetail.dblQuantity AS dblGross, tblICInventoryTransferDetail.dblQuantity AS dblNet, tblICInventoryTransferDetail.dblQuantity, NULL AS dblTax, NULL AS strInvoiceNumber, NULL 
                         AS strPONumber, tblTRLoadReceipt.strBillOfLading AS strBOLNumber, tblICInventoryTransfer.dtmTransferDate AS dtmDate, tblSMCompanyLocation.strCity AS strDestinationCity, 
                         tblSMCompanyLocation.strStateProvince AS strDestinationState, tblEMEntityLocation.strCity AS strOriginCity, tblEMEntityLocation.strState AS strOriginState, 
                         tblSMCompanyLocation.strLocationName AS strCustomerName, tblEMEntity_1.strFederalTaxId AS strCustomerFEIN, NULL AS strAccountStatusCode, tblSMShipVia.strShipVia, tblSMShipVia.strTransporterLicense, 
                         tblSMShipVia.strTransportationMode, tblEMEntity.strName AS strTransporterName, tblEMEntity.strFederalTaxId AS strTransporterFEIN, NULL AS strTaxCode, 
                         tblTFTerminalControlNumber.strTerminalControlNumber, EntityAPVendor.strName AS strVendorName, EntityAPVendor.strFederalTaxId AS strVendorFEIN, tblSMCompanySetup.strCompanyName, 
                         tblSMCompanySetup.strAddress, tblSMCompanySetup.strCity, tblSMCompanySetup.strState, tblSMCompanySetup.strZip, tblSMCompanySetup.strPhone, tblSMCompanySetup.strStateTaxID, 
                         tblSMCompanySetup.strFederalTaxID '

				SET @InvQueryPart2 = 'FROM tblICInventoryTransferDetail INNER JOIN
                         tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId INNER JOIN
                         tblICItemMotorFuelTax INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode INNER JOIN
                         tblTFReportingComponent ON tblTFValidProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON 
                         tblICInventoryTransferDetail.intItemId = tblICItemMotorFuelTax.intItemId INNER JOIN
                         tblTRLoadReceipt ON tblICInventoryTransfer.intInventoryTransferId = tblTRLoadReceipt.intInventoryTransferId INNER JOIN
                         tblTRLoadHeader ON tblTRLoadReceipt.intLoadHeaderId = tblTRLoadHeader.intLoadHeaderId INNER JOIN
                         tblTRLoadDistributionHeader ON tblTRLoadHeader.intLoadHeaderId = tblTRLoadDistributionHeader.intLoadHeaderId INNER JOIN
                         tblSMShipVia ON tblTRLoadHeader.intShipViaId = tblSMShipVia.intEntityShipViaId INNER JOIN
                         tblEMEntity ON tblSMShipVia.intEntityShipViaId = tblEMEntity.intEntityId INNER JOIN
                         tblAPVendor ON tblTRLoadReceipt.intTerminalId = tblAPVendor.intEntityVendorId INNER JOIN
                         tblEMEntity AS EntityAPVendor ON tblAPVendor.intEntityVendorId = EntityAPVendor.intEntityId INNER JOIN
                         tblTRSupplyPoint ON tblTRLoadReceipt.intSupplyPointId = tblTRSupplyPoint.intSupplyPointId INNER JOIN
                         tblEMEntityLocation ON tblTRSupplyPoint.intEntityLocationId = tblEMEntityLocation.intEntityLocationId INNER JOIN
                         tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId INNER JOIN
                         tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId INNER JOIN
                         tblEMEntity AS tblEMEntity_1 ON tblICInventoryTransfer.intEntityId = tblEMEntity_1.intEntityId CROSS JOIN
                         tblSMCompanySetup
					WHERE (tblTFReportingComponent.intReportingComponentId IN (' + @RCId + ')) 
					AND (tblICInventoryTransfer.intSourceType = 3) 
					AND (tblICInventoryTransfer.dtmTransferDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''')
					AND (tblICInventoryTransfer.ysnPosted = 1)'

					SET @InvTransferQuery = @InvQueryPart1 + @InvQueryPart2
					INSERT INTO @tblTempTransaction
					EXEC(@InvTransferQuery)


				IF (@ReportingComponentId <> '')
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, 
																	   intTaxAuthorityId,
																	   strTaxAuthority,
																	   strFormCode,
																	   intReportingComponentId,
																	   strScheduleCode,
																	   intProductCodeId,
																	   strProductCode,
																	   intItemId,
																	   dblQtyShipped,
																	   dblGross,
																	   dblNet,
																	   dblBillQty,
																	   --dblTax,
																	   strInvoiceNumber,
																	   strPONumber,
																	   strBOLNumber,
																	   dtmDate,
																	   strDestinationCity,
																	   strDestinationState,
																	   strOriginCity,
																	   strOriginState,
																	   strCustomerName,
																	   strCustomerFederalTaxId,
																	   strShipVia,
																	   strTransporterLicense,
																	   strTransportationMode,
																	   strTransporterName,
																	   strTransporterFederalTaxId,
																	   strType,
																	   strTerminalControlNumber,
																	   strVendorName,
																	   strVendorFederalTaxId,
																	   strTaxPayerName,
																	   strTaxPayerAddress,
																	   strCity,
																	   strState,
																	   strZipCode,
																	   strTelephoneNumber,
																	   strTaxPayerIdentificationNumber,
																	   strTaxPayerFEIN,
																	   dtmReportingPeriodBegin,
																	   dtmReportingPeriodEnd,
																	   leaf) 

																	   SELECT DISTINCT @Guid, 
																	    --intInvoiceDetailId
																		intTaxAuthorityId,
																		(SELECT strTaxAuthorityCode FROM tblTFTaxAuthority WHERE intTaxAuthorityId = (SELECT DISTINCT TOP 1 intTaxAuthorityId FROM @tblTempTransaction)),
																		strFormCode,
																		intReportingComponentId,
																		strScheduleCode,
																		intProductCode,
																		strProductCode,
																		intItemId,
																		dblQtyShipped,
																		dblGross,
																	    dblNet,
																	    dblBillQty,
																		--dblTax,
																		strInvoiceNumber,
																		strPONumber,
																		strBOLNumber,
																		dtmDate,
																		strDestinationCity,
																		strDestinationState,
																		strOriginCity,
																		strOriginState,
																		strCustomerName,
																		strCustomerFEIN,
																		--strAccountStatusCode,
																		strShipVia,
																		strTransporterLicense,
																		strTransportationMode,
																		strTransporterName,
																		strTransporterFEIN,
																		strType,
																		strTerminalControlNumber,
																		strVendorName,
																	    strVendorFederalTaxId,
																		--HEADER
																		strHeaderCompanyName,
																		strHeaderAddress,
																		strHeaderCity,
																		strHeaderState,
																		strHeaderZip,
																		strHeaderPhone,
																		strHeaderStateTaxID,
																		strHeaderFederalTaxID,
																		@DateFrom,
																		@DateTo,
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
				INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId), 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
			END