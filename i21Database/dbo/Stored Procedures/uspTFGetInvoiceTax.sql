CREATE PROCEDURE [dbo].[uspTFGetInvoiceTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(20),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@FormReport NVARCHAR(50),
@isMainForm NVARCHAR(5)

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
			intReportingComponentDetailId INT,
			strScheduleCode NVARCHAR(50),
			strType NVARCHAR(150),
			intProductCode INT,
			strProductCode NVARCHAR(20),
			intItemId INT,
			dblQtyShipped NUMERIC(18, 6),
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

	IF (@isMainForm != 'true')
		BEGIN
			DELETE FROM tblTFTransactions
		END

	-- ORIGIN/DESTINATION
	DECLARE @IncludeOriginState NVARCHAR(250)
	DECLARE @ExcludeOriginState NVARCHAR(250)
	DECLARE @IncludeDestinationState NVARCHAR(250)
	DECLARE @ExcludeDestinationState NVARCHAR(250)

	-- ORIGIN
	SELECT @QueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
	
	INSERT INTO @tblTempReportingComponent (intReportingComponentId)
	EXEC(@QueryRC)

	SET @CountRC = (select count(intId) from @tblTempReportingComponent) 
	WHILE(@CountRC > 0)
	BEGIN
	SET @RCId = (SELECT intReportingComponentId FROM @tblTempReportingComponent WHERE intId = @CountRC)

		DECLARE @IncludeValidOriginState NVARCHAR(MAX) = NULL
		SELECT @IncludeValidOriginState = COALESCE(@IncludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentDetailId = @RCId AND strFilter = 'Include'
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
		SELECT @ExcludeValidOriginState = COALESCE(@ExcludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentDetailId = @RCId AND strFilter = 'Exclude'
		IF(@ExcludeValidOriginState IS NOT NULL)
			BEGIN
				SET @ExcludeValidOriginState = REPLACE(@ExcludeValidOriginState,',',''',''')
				SET @ExcludeOriginState = '/*EXCLUDE ORIGIN*/  AND tblSMCompanyLocation.strStateProvince NOT IN (''' + @ExcludeValidOriginState + ''')'
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
				SET @IncludeDestinationState = '/*INCLUDE DESTINATION*/  AND tblARInvoice.strShipToState IN (''' + @IncludeValidDestinationState + ''')'
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
				SET @ExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND tblARInvoice.strShipToState NOT IN (''' + @ExcludeValidDestinationState + ''')'
			END
		ELSE
			BEGIN
				SET @ExcludeDestinationState = ''
			END

		 -- GET INVENTORY RECEIPT/S
		 SET @QueryInvoiceNumber = 'SELECT DISTINCT 0, tblARInvoiceDetail.intInvoiceDetailId, tblARInvoice.strInvoiceNumber FROM tblARInvoiceDetail 
								   INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
								   INNER JOIN  tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId 
								   INNER JOIN tblTFTaxCriteria INNER JOIN tblICItemMotorFuelTax 
								   INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode 
								   INNER JOIN tblTFReportingComponentDetail ON tblTFValidProductCode.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId ON  tblTFTaxCriteria.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId 
								   INNER JOIN tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
								   INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId ON tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId AND  tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId 
								   INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId 
								   WHERE tblTFReportingComponentDetail.intReportingComponentDetailId IN(' + @RCId + ') 
								   AND tblARInvoice.dtmDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''' 
									' + @IncludeOriginState + ' ' + @ExcludeOriginState + ' 
									' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ''


		SET @QueryInvoice = 'SELECT DISTINCT
                             tblARInvoiceDetail.intInvoiceDetailId,tblTFReportingComponent.intTaxAuthorityId,tblTFReportingComponent.strFormCode, 
							 tblTFReportingComponentDetail.intReportingComponentDetailId,tblTFReportingComponent.strScheduleCode,tblTFReportingComponent.strType,tblTFValidProductCode.intProductCode,tblTFValidProductCode.strProductCode, 
							 tblARInvoiceDetail.intItemId,tblARInvoiceDetail.dblQtyShipped,tblARInvoiceDetailTax.dblTax,tblARInvoice.strInvoiceNumber,tblARInvoice.strPONumber, 
							 tblARInvoice.strBOLNumber,tblARInvoice.dtmDate,tblARInvoice.strShipToCity AS strDestinationCity,tblARInvoice.strShipToState AS strDestinationState, 
							 tblSMCompanyLocation.strCity AS strOriginCity,tblSMCompanyLocation.strStateProvince AS strOriginState,tblEMEntity.strName, 
							 tblEMEntity.strFederalTaxId AS strCustomerFEIN,tblARAccountStatus.strAccountStatusCode,tblSMShipVia.strShipVia,tblSMShipVia.strTransporterLicense, 
							 tblSMShipVia.strTransportationMode,tblEMEntity_Transporter.strName AS strTransporterName,tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN,tblSMTaxCode.strTaxCode,
							 tblSMCompanySetup.strCompanyName,tblSMCompanySetup.strAddress,tblSMCompanySetup.strCity,tblSMCompanySetup.strState, 
							 tblSMCompanySetup.strZip,tblSMCompanySetup.strPhone,tblSMCompanySetup.strStateTaxID,tblSMCompanySetup.strFederalTaxID
							 FROM tblEMEntity AS tblEMEntity_Transporter 
							 INNER JOIN tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityShipViaId 
							 FULL OUTER JOIN tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
							 INNER JOIN tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId 
							 INNER JOIN tblTFReportingComponent INNER JOIN tblTFTaxCriteria INNER JOIN tblICItemMotorFuelTax 
							 INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode 
							 INNER JOIN tblTFReportingComponentDetail ON tblTFValidProductCode.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId ON tblTFTaxCriteria.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId 
							 INNER JOIN tblTFTaxCategory ON tblTFTaxCriteria.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
							 INNER JOIN tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentDetail.intReportingComponentId ON tblARInvoiceDetailTax.intTaxCodeId = tblSMTaxCode.intTaxCodeId AND tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId 
							 INNER JOIN tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId 
							 INNER JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId INNER JOIN tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId 
							 FULL OUTER JOIN tblARAccountStatus ON tblARCustomer.intAccountStatusId = tblARAccountStatus.intAccountStatusId
							 CROSS JOIN tblSMCompanySetup
							 WHERE (tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ')) 
							 AND dtmDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							 ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
							 ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ''
			
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
								 WHERE  (tblTFTaxCriteria.intReportingComponentDetailId IN(' + @RCId + '))'
						
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

				IF (@ReportingComponentId <> '' AND @FormReport = '')
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, 
																	   intTaxAuthorityId,
																	   strFormCode,
																	   intReportingComponentDetailId,
																	   strScheduleCode,
																	   intProductCodeId,
																	   strProductCode,
																	   intItemId,
																	   dblQtyShipped,
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
																	   strTaxPayerName,
																	   strTaxPayerAddress,
																	   strCity,
																	   strState,
																	   strZipCode,
																	   strTelephoneNumber,
																	   strTaxPayerIdentificationNumber,
																	   strTaxPayerFEIN,
																	   leaf) 

																	   SELECT DISTINCT @Guid, 
																	    --intInvoiceDetailId
																		intTaxAuthorityId,
																		strFormCode,
																		intReportingComponentDetailId,
																		strScheduleCode,
																		intProductCode,
																		strProductCode,
																		intItemId,
																		dblQtyShipped,
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
																		--HEADER
																		strHeaderCompanyName,
																		strHeaderAddress,
																		strHeaderCity,
																		strHeaderState,
																		strHeaderZip,
																		strHeaderPhone,
																		strHeaderStateTaxID,
																		strHeaderFederalTaxID,
																		1
																		FROM @tblTempTransaction
						
					END
				ELSE
					BEGIN
						INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, @FormReport, 0, 1)
					END

			SET @CountRC = @CountRC - 1
		END