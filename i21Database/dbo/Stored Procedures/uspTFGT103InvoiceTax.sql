CREATE PROCEDURE [dbo].[uspTFGT103InvoiceTax]

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

DECLARE @tblTempReportingComponent TABLE (
			intId INT IDENTITY(1,1),
			intReportingComponentId INT
		 )
DECLARE @tblTempInvoiceTransaction TABLE (
			intId INT,
			intInvoiceDetailId INT,
			strInvoiceNumber NVARCHAR(50)
		 )
DECLARE @tblTempTransaction TABLE (
			intId INT,
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
			dblTaxExempt NUMERIC(18, 2),
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
			strTaxCategory NVARCHAR(200),
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

		SET @QueryInvoice = 'SELECT DISTINCT 0,
                             tblARInvoiceDetail.intInvoiceDetailId,tblTFReportingComponent.intTaxAuthorityId,tblTFReportingComponent.strFormCode, 
							 tblTFReportingComponentDetail.intReportingComponentDetailId,tblTFReportingComponent.strScheduleCode,tblTFReportingComponent.strType,tblTFValidProductCode.intProductCode,tblTFValidProductCode.strProductCode, 
							 tblARInvoiceDetail.intItemId,tblARInvoiceDetail.dblQtyShipped,0,0 AS dblTaxExempt,tblARInvoice.strInvoiceNumber,tblARInvoice.strPONumber, 
							 tblARInvoice.strBOLNumber,tblARInvoice.dtmDate,tblARInvoice.strShipToCity AS strDestinationCity,tblARInvoice.strShipToState AS strDestinationState, 
							 tblSMCompanyLocation.strCity AS strOriginCity,tblSMCompanyLocation.strStateProvince AS strOriginState,tblEMEntity.strName, 
							 tblEMEntity.strFederalTaxId AS strCustomerFEIN,tblARAccountStatus.strAccountStatusCode,tblSMShipVia.strShipVia,tblSMShipVia.strTransporterLicense, 
							 tblSMShipVia.strTransportationMode,tblEMEntity_Transporter.strName AS strTransporterName,tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN,'''',
							 tblSMCompanySetup.strCompanyName,tblSMCompanySetup.strAddress,tblSMCompanySetup.strCity,tblSMCompanySetup.strState, 
							 tblSMCompanySetup.strZip,tblSMCompanySetup.strPhone,tblSMCompanySetup.strStateTaxID,tblSMCompanySetup.strFederalTaxID
							 FROM tblEMEntity AS tblEMEntity_Transporter INNER JOIN
							 tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityShipViaId FULL OUTER JOIN
							 tblTFReportingComponent INNER JOIN tblICItemMotorFuelTax INNER JOIN
							 tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode INNER JOIN
							 tblTFReportingComponentDetail ON tblTFValidProductCode.intReportingComponentDetailId = tblTFReportingComponentDetail.intReportingComponentDetailId ON 
							 tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentDetail.intReportingComponentId INNER JOIN
							 tblSMTaxCode INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId INNER JOIN
							 tblARInvoiceDetail INNER JOIN
							 tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId INNER JOIN
							 tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId ON 
							 tblICItemMotorFuelTax.intItemId = tblARInvoiceDetail.intItemId INNER JOIN
							 tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId INNER JOIN
							 tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId INNER JOIN
							 tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId ON tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId FULL OUTER JOIN
							 tblARAccountStatus ON tblARCustomer.intAccountStatusId = tblARAccountStatus.intAccountStatusId CROSS JOIN
							 tblSMCompanySetup
							 WHERE (tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ')) 
							 AND dtmDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							 ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
							 ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ''

		DELETE FROM @tblTempTransaction
		INSERT INTO @tblTempTransaction
		EXEC(@QueryInvoice)

		-- SET INCREMENT PRIMARY ID FOR TEMP @tblTempTransaction
		DECLARE @tblTempTransaction_intId int
		SET @tblTempTransaction_intId = 0 UPDATE @tblTempTransaction SET @tblTempTransaction_intId = intId = @tblTempTransaction_intId + 1
	 
		SET @Count = (select COUNT(intId) from @tblTempTransaction) 				
				WHILE(@Count > 0) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
					BEGIN
						SET @InvoiceDetailId = (SELECT intInvoiceDetailId FROM @tblTempTransaction WHERE intId = @Count)
						DECLARE @TaxAmount NUMERIC(18, 6)
						DECLARE @TaxExempt NUMERIC(18, 6)

						-- GASOLINE USE TAX COLLECTED
						SET @TaxAmount = (SELECT tblARInvoiceDetailTax.dblTax
						FROM tblSMTaxCode INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
									  INNER JOIN tblARInvoiceDetailTax ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId 
									  INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetailTax.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId 
									  INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
						WHERE tblARInvoiceDetailTax.intInvoiceDetailId = @InvoiceDetailId AND (tblTFTaxCategory.strTaxCategory = @GasolineUseTax))

						UPDATE @tblTempTransaction SET dblTax = ISNULL(@TaxAmount, 0), strTaxCategory = @GasolineUseTax WHERE intInvoiceDetailId = @InvoiceDetailId
						
						--EXEMPT GALLONS SOLD
						SET @TaxExempt = (SELECT tblARInvoiceDetail.dblQtyShipped
						FROM tblSMTaxCode INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
									  INNER JOIN tblARInvoiceDetailTax ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId 
									  INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetailTax.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId 
									  INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
						WHERE tblARInvoiceDetailTax.intInvoiceDetailId = @InvoiceDetailId AND (tblTFTaxCategory.strTaxCategory = 'IN Excise Tax') AND tblARInvoiceDetailTax.dblTax = 0)

						UPDATE @tblTempTransaction SET dblTaxExempt = ISNULL(@TaxExempt, 0), strTaxCategory = @ExemptGallSold WHERE intInvoiceDetailId = @InvoiceDetailId
						select * from @tblTempTransaction
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
																	   dblTax,
																	   dblTaxExempt,
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
																		dblTax,
																		dblTaxExempt,
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

		DECLARE @HasResult INT
		SELECT TOP 1 @HasResult = intId from @tblTempTransaction
		IF(@HasResult IS NULL)
			BEGIN
				INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId), 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
			END