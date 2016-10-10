CREATE PROCEDURE [dbo].[uspTFGT103InvoiceTax]

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
DECLARE @IncludeLocationState NVARCHAR(250)
DECLARE @ExcludeLocationState NVARCHAR(250)

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
			strConsignorName NVARCHAR(250),
			strConsignorFEIN NVARCHAR(50),
			strTaxCategory NVARCHAR(200),
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

	SELECT @QueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
	
	INSERT INTO @tblTempReportingComponent (intReportingComponentId)
	EXEC(@QueryRC)

	SET @CountRC = (select count(intId) from @tblTempReportingComponent) 
	WHILE(@CountRC > 0)
	BEGIN
	SET @RCId = (SELECT intReportingComponentId FROM @tblTempReportingComponent WHERE intId = @CountRC)

	-- ORIGIN
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

		-- DESTINATION
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

					SET @QueryInvoice = 'SELECT DISTINCT 0,tblARInvoiceDetail.intInvoiceDetailId,tblTFReportingComponent.intTaxAuthorityId,tblTFReportingComponent.strFormCode,tblTFReportingComponent.intReportingComponentId,tblTFReportingComponent.strScheduleCode, 
                         tblTFReportingComponent.strType,tblTFValidProductCode.intProductCode,tblTFValidProductCode.strProductCode,tblARInvoiceDetail.intItemId,
						 tblARInvoiceDetail.dblQtyShipped,tblARInvoiceDetail.dblQtyShipped AS dblGross,tblARInvoiceDetail.dblQtyShipped AS dblNet,tblARInvoiceDetail.dblQtyShipped AS dblBillQty,0,0 AS dblTaxExempt,
						 tblARInvoice.strInvoiceNumber,tblARInvoice.strPONumber,tblARInvoice.strBOLNumber,tblARInvoice.dtmDate, 
                         (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strCity ELSE tblARInvoice.strShipToCity END) AS strDestinationCity, 
                         (CASE WHEN tblARInvoice.intFreightTermId = 3 THEN tblSMCompanyLocation.strStateProvince ELSE tblARInvoice.strShipToState END) AS strDestinationState,tblSMCompanyLocation.strCity AS strOriginCity, 
                         tblSMCompanyLocation.strStateProvince AS strOriginState,tblEMEntity.strName,tblEMEntity.strFederalTaxId AS strCustomerFEIN,tblARAccountStatus.strAccountStatusCode,tblSMShipVia.strShipVia, 
                         tblSMShipVia.strTransporterLicense,tblSMShipVia.strTransportationMode,tblEMEntity_Transporter.strName AS strTransporterName,tblEMEntity_Transporter.strFederalTaxId AS strTransporterFEIN, 
                         '''', NULL,NULL,NULL,tblSMCompanySetup.strCompanyName,tblSMCompanySetup.strAddress,tblSMCompanySetup.strCity,tblSMCompanySetup.strState, 
                         tblSMCompanySetup.strZip,tblSMCompanySetup.strPhone,tblSMCompanySetup.strStateTaxID,tblSMCompanySetup.strFederalTaxID
					FROM tblEMEntity AS tblEMEntity_Transporter INNER JOIN tblSMShipVia ON tblEMEntity_Transporter.intEntityId = tblSMShipVia.intEntityShipViaId FULL OUTER JOIN
                         tblSMTaxCode INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId INNER JOIN
                         tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId INNER JOIN
                         tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId INNER JOIN
                         tblICItemMotorFuelTax INNER JOIN tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode ON tblARInvoiceDetail.intItemId = tblICItemMotorFuelTax.intItemId INNER JOIN
                         tblSMCompanyLocation ON tblARInvoice.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId INNER JOIN
                         tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId INNER JOIN
                         tblEMEntity ON tblARCustomer.intEntityCustomerId = tblEMEntity.intEntityId INNER JOIN
                         tblTFReportingComponent ON tblTFValidProductCode.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON 
                         tblSMShipVia.intEntityShipViaId = tblARInvoice.intShipViaId FULL OUTER JOIN
                         tblARAccountStatus ON tblARCustomer.intAccountStatusId = tblARAccountStatus.intAccountStatusId CROSS JOIN
                         tblSMCompanySetup WHERE (tblTFReportingComponent.intReportingComponentId IN(' + @RCId + ')) 
							 AND dtmDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							 ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
							 ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ' AND tblARInvoice.ysnPosted = 1'

		DELETE FROM @tblTempTransaction
		INSERT INTO @tblTempTransaction
		EXEC(@QueryInvoice)

		-- SET INCREMENT PRIMARY ID FOR TEMP @tblTempTransaction
		DECLARE @tblTempTransaction_intId INT
		SET @tblTempTransaction_intId = 0 UPDATE @tblTempTransaction SET @tblTempTransaction_intId = intId = @tblTempTransaction_intId + 1
	 
		SET @Count = (SELECT COUNT(intId) FROM @tblTempTransaction) 				
				WHILE(@Count > 0) -- LOOP ON INVOICE ID/S
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
						WHERE tblARInvoiceDetailTax.intInvoiceDetailId = @InvoiceDetailId AND (tblTFTaxCategory.strTaxCategory = 'IN Gasoline Use Tax (GUT)') AND tblARInvoiceDetailTax.dblTax = 0)

						UPDATE @tblTempTransaction SET dblTaxExempt = ISNULL(@TaxExempt, 0), strTaxCategory = @ExemptGallSold WHERE intInvoiceDetailId = @InvoiceDetailId
						--select * from @tblTempTransaction
						SET @Count = @Count - 1
				END

				--INVENTORY TRANSFER
				DECLARE @InvTransferQuery NVARCHAR(MAX)
				DECLARE @InvQueryPart1 NVARCHAR(MAX)
				DECLARE @InvQueryPart2 NVARCHAR(MAX)
		
				SET @InvQueryPart1 = 'SELECT DISTINCT 0, 
						 tblICInventoryTransferDetail.intInventoryTransferDetailId, 
						 tblTFReportingComponent.intTaxAuthorityId, 
						 tblTFReportingComponent.strFormCode,
						 tblTFReportingComponent.intReportingComponentId,
						 tblTFReportingComponent.strScheduleCode,
						 tblTFReportingComponent.strType, 
                         tblTFValidProductCode.intProductCode,
						 tblTFValidProductCode.strProductCode,
						 tblICInventoryTransferDetail.intItemId,
						 tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped,
						 tblICInventoryTransferDetail.dblQuantity AS dblGross, 
                         tblICInventoryTransferDetail.dblQuantity AS dblNet,
						 tblICInventoryTransferDetail.dblQuantity,
						 NULL, NULL, NULL, NULL AS strPONumber, 
                         tblTRLoadReceipt.strBillOfLading AS strBOLNumber,
						 tblICInventoryTransfer.dtmTransferDate AS dtmDate, 
						 tblSMCompanyLocation.strCity AS strDestinationCity,
						 tblSMCompanyLocation.strStateProvince AS strDestinationState,
						 tblEMEntityLocation.strCity AS strOriginCity,
						 tblEMEntityLocation.strState AS strOriginState, 
                         tblSMCompanyLocation.strLocationName AS strCustomerName, 
                         NULL AS strCustomerFEIN, 
						 NULL AS strAccountStatusCode, 
						 tblSMShipVia.strShipVia,
						 tblSMShipVia.strTransporterLicense, 
                         tblSMShipVia.strTransportationMode,
						 NULL,
						 NULL,
                         tblEMEntity.strName AS strConsignorName, 
						 tblEMEntity.strFederalTaxId AS strConsignorFEIN, 
						 NULL,
						 tblTFTerminalControlNumber.strTerminalControlNumber,
                         EntityAPVendor.strName AS strVendorName,
						 EntityAPVendor.strFederalTaxId AS strVendorFEIN,
						 tblSMCompanySetup.strCompanyName,
						 tblSMCompanySetup.strAddress,
						 tblSMCompanySetup.strCity,
                         tblSMCompanySetup.strState,
						 tblSMCompanySetup.strZip,
						 tblSMCompanySetup.strPhone,
						 tblSMCompanySetup.strStateTaxID,
						 tblSMCompanySetup.strFederalTaxID '
	
				SET @InvQueryPart2 = 'FROM tblICInventoryTransferDetail INNER JOIN
                         tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId INNER JOIN
                         tblICItemMotorFuelTax INNER JOIN
                         tblTFValidProductCode ON tblICItemMotorFuelTax.intProductCodeId = tblTFValidProductCode.intProductCode INNER JOIN
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
                         tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId INNER JOIN
                         tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId LEFT OUTER JOIN
                         tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId CROSS JOIN
                         tblSMCompanySetup
					WHERE (tblTFReportingComponent.intReportingComponentId IN (' + @RCId + ')) 
					AND (tblSMCompanyLocation.ysnTrackMFTActivity = 1)
					AND (tblARInvoice.strBOLNumber IS NULL)
					AND (tblTRLoadHeader.dtmLoadDateTime BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''')
					AND (tblICInventoryTransfer.ysnPosted = 1)'

					SET @InvTransferQuery = @InvQueryPart1 + @InvQueryPart2
					INSERT INTO @tblTempTransaction
					EXEC(@InvTransferQuery)

					-- INVENTORY TRANSFER --
					-- SET INCREMENT PRIMARY ID FOR TEMP @tblTempTransaction

					SET @tblTempTransaction_intId = 0 UPDATE @tblTempTransaction SET @tblTempTransaction_intId = intId = @tblTempTransaction_intId + 1
					SET @Count = (SELECT COUNT(intId) FROM @tblTempTransaction) 				
					WHILE(@Count > 0) -- LOOP ON INVOICE ID/S
						BEGIN
							SET @InvoiceDetailId = (SELECT intInvoiceDetailId FROM @tblTempTransaction WHERE intId = @Count)
							DECLARE @TaxAmountInvTransfer NUMERIC(18, 6)
							DECLARE @TaxExemptInvTransfer NUMERIC(18, 6)
							DECLARE @TaxAmountInvTransferTotal NUMERIC(18, 6)
							DECLARE @ConfigGUTRate NUMERIC(18, 6)
							DECLARE @GasoholConfig NUMERIC(18, 6)

							-- GASOLINE USE TAX COLLECTED
							SET @ConfigGUTRate = (SELECT TOP 1 strConfiguration FROM tblTFTaxReportTemplate WHERE strTemplateItemId = 'GT-103-2DGasoline') 
							SET @TaxAmountInvTransfer = (SELECT dblQtyShipped FROM @tblTempTransaction WHERE intId = @Count)
							SET @TaxAmountInvTransferTotal = @TaxAmountInvTransfer * @ConfigGUTRate
							UPDATE @tblTempTransaction SET dblTax = ISNULL(@TaxAmountInvTransferTotal, 0) WHERE strInvoiceNumber IS NULL AND intInvoiceDetailId = @InvoiceDetailId

							--EXEMPT GALLONS SOLD
							SET @TaxExemptInvTransfer = (SELECT tblARInvoiceDetail.dblQtyShipped
							FROM tblSMTaxCode INNER JOIN tblTFTaxCategory ON tblSMTaxCode.intTaxCategoryId = tblTFTaxCategory.intTaxCategoryId 
										  INNER JOIN tblARInvoiceDetailTax ON tblSMTaxCode.intTaxCodeId = tblARInvoiceDetailTax.intTaxCodeId 
										  INNER JOIN tblARInvoiceDetail ON tblARInvoiceDetailTax.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId 
										  INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId
							WHERE tblARInvoiceDetailTax.intInvoiceDetailId = @InvoiceDetailId AND (tblTFTaxCategory.strTaxCategory = 'IN Gasoline Use Tax (GUT)') AND tblARInvoiceDetailTax.dblTax = 0)
							UPDATE @tblTempTransaction SET dblTaxExempt = ISNULL(@TaxExemptInvTransfer, 0), strTaxCategory = @ExemptGallSold WHERE intInvoiceDetailId = @InvoiceDetailId
							SET @Count = @Count - 1
					END

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
																	   strConsignorName,
																	   strConsignorFederalTaxId,
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
																		strConsignorName,
																	    strConsignorFEIN,
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
