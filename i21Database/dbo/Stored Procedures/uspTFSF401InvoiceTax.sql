CREATE PROCEDURE [dbo].[uspTFSF401InvoiceTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(MAX),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@IsEdi NVARCHAR(10),
@Refresh NVARCHAR(5)

AS
--===================================================== i21 INVENTORY TRANSFER =====================================================

DECLARE @CountRC INT
DECLARE @QueryRC NVARCHAR(MAX)
DECLARE @RCId NVARCHAR(50)

DECLARE @tblTempReportingComponent TABLE (
			intId INT IDENTITY(1,1),
			intReportingComponentId INT
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
			strBillOfLading NVARCHAR(50),
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
			DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
		END
		DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'

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
		SELECT @IncludeValidOriginState = COALESCE(@IncludeValidOriginState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Include'
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
		SELECT @ExcludeValidOriginState = COALESCE(@ExcludeValidOriginState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'
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
		SELECT @IncludeValidDestinationState = COALESCE(@IncludeValidDestinationState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Include'
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
		SELECT @ExcludeValidDestinationState = COALESCE(@ExcludeValidDestinationState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @RCId AND strType = 'Exclude'
		IF(@ExcludeValidDestinationState IS NOT NULL)
			BEGIN
				SET @ExcludeValidDestinationState = REPLACE(@ExcludeValidDestinationState,',',''',''')
				SET @ExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND tblARInvoice.strShipToState NOT IN (''' + @ExcludeValidDestinationState + ''')'
			END
		ELSE
			BEGIN
				SET @ExcludeDestinationState = ''
			END

				--INVENTORY TRANSFER
				DECLARE @InvTransferQuery NVARCHAR(MAX)
				DECLARE @InvQueryPart1 NVARCHAR(MAX)
				DECLARE @InvQueryPart2 NVARCHAR(MAX)

				DECLARE @CriteriaCount INT
				DECLARE @Criteria NVARCHAR(200) = ''
				SET @CriteriaCount = (SELECT COUNT(tblTFReportingComponent.intReportingComponentId)
				FROM  tblTFReportingComponent INNER JOIN tblTFReportingComponentCriteria 
				ON tblTFReportingComponent.intReportingComponentId = tblTFReportingComponentCriteria.intReportingComponentId
				WHERE tblTFReportingComponent.intReportingComponentId = @RCId AND tblTFReportingComponentCriteria.strCriteria = '= 0')

				IF(@CriteriaCount > 0) 
					BEGIN
						SET @Criteria = ' AND strCriteria <> ''= 0'' AND strCriteria <> ''<> 0'''
					END

				SET @InvQueryPart1 = 'SELECT DISTINCT NULL AS intInvoiceDetailId,                                  
						 tblTFReportingComponent.intTaxAuthorityId, 
						 tblTFReportingComponent.strFormCode, 
						 tblTFReportingComponent.intReportingComponentId, 
						 tblTFReportingComponent.strScheduleCode, 
                         tblTFReportingComponent.strType, 
						 vyuTFGetReportingComponentDestinationState.intProductCode, 
						 vyuTFGetReportingComponentDestinationState.strProductCode, 
						 tblICInventoryTransferDetail.intItemId, 
                         tblICInventoryTransferDetail.dblQuantity AS dblQtyShipped, 
						 tblICInventoryTransferDetail.dblQuantity AS dblGross, 
						 tblICInventoryTransferDetail.dblQuantity AS dblNet, 
                         tblICInventoryTransferDetail.dblQuantity, 
						 NULL AS dblTax, 
						 NULL AS strInvoiceNumber, 
						 NULL AS strPONumber, 
						 tblTRLoadReceipt.strBillOfLading AS strBOLNumber,
						 tblTRLoadHeader.dtmLoadDateTime AS dtmDate,
						 tblSMCompanyLocation.strCity AS strDestinationCity,
						 tblSMCompanyLocation.strStateProvince AS strDestinationState,
						 tblEMEntityLocation.strCity AS strOriginCity, 
                         tblEMEntityLocation.strState AS strOriginState, 
						 tblSMCompanyLocation.strLocationName AS strCustomerName, 
                         tblSMCompanySetup.strEin AS strCustomerFEIN, 
						 NULL AS strAccountStatusCode, 
						 tblSMShipVia.strShipVia, 
						 tblSMShipVia.strTransporterLicense, 
						 tblSMShipVia.strTransportationMode, 
                         tblEMEntity.strName AS strTransporterName, 
						 tblEMEntity.strFederalTaxId AS strTransporterFEIN,
                         tblEMEntity.strName AS strConsignorName, 
						 tblEMEntity.strFederalTaxId AS strConsignorFEIN, 
						 NULL AS strTaxCode, 
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

				SET @InvQueryPart2 = 'FROM tblTFTaxCategory INNER JOIN
                         tblTFReportingComponentCriteria ON tblTFTaxCategory.intTaxCategoryId = tblTFReportingComponentCriteria.intTaxCategoryId INNER JOIN
                         tblSMTaxCode ON tblTFTaxCategory.intTaxCategoryId = tblSMTaxCode.intTaxCategoryId RIGHT OUTER JOIN
                         tblICInventoryTransferDetail INNER JOIN
                         tblICInventoryTransfer ON tblICInventoryTransferDetail.intInventoryTransferId = tblICInventoryTransfer.intInventoryTransferId INNER JOIN
                         tblICItemMotorFuelTax INNER JOIN
                         vyuTFGetReportingComponentDestinationState ON tblICItemMotorFuelTax.intProductCodeId = vyuTFGetReportingComponentDestinationState.intProductCode INNER JOIN
                         tblTFReportingComponent ON vyuTFGetReportingComponentDestinationState.intReportingComponentId = tblTFReportingComponent.intReportingComponentId ON 
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
                         tblSMCompanyLocation ON tblTRLoadDistributionHeader.intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId ON 
                         tblTFReportingComponentCriteria.intReportingComponentId = tblTFReportingComponent.intReportingComponentId LEFT OUTER JOIN
                         tblTFTerminalControlNumber ON tblTRSupplyPoint.intTerminalControlNumberId = tblTFTerminalControlNumber.intTerminalControlNumberId LEFT OUTER JOIN
                         tblARInvoice ON tblTRLoadDistributionHeader.intInvoiceId = tblARInvoice.intInvoiceId CROSS JOIN
                         tblSMCompanySetup
					WHERE (tblTFReportingComponent.intReportingComponentId IN (' + @RCId + ')) 
					AND (tblSMCompanyLocation.ysnTrackMFTActivity = 1)
					--AND (tblARInvoice.strBOLNumber IS NULL)
					AND (tblTRLoadHeader.dtmLoadDateTime BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + ''')
					AND (tblICInventoryTransfer.ysnPosted = 1) 
					AND tblSMShipVia.ysnCompanyOwnedCarrier = 1' + @Criteria + ''

					SET @InvTransferQuery = @InvQueryPart1 + @InvQueryPart2
					INSERT INTO @tblTempTransaction
					EXEC(@InvTransferQuery)

				IF (@ReportingComponentId <> '')
					BEGIN
						INSERT INTO tblTFTransaction (uniqTransactionGuid, 
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
																	   strBillOfLading,
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
																		--dblTax,
																		strInvoiceNumber,
																		strPONumber,
																		strBillOfLading,
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
						INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, leaf)VALUES(@Guid, 0, '', 0, 1)
					END

			SET @CountRC = @CountRC - 1
		END

		--DECLARE @HasResult INT
		--SELECT TOP 1 @HasResult = intId from @tblTempTransaction
		--IF(@HasResult IS NULL AND @IsEdi = 'false')
		--	BEGIN
		--		INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, (SELECT TOP 1 strFormCode from tblTFReportingComponent WHERE intReportingComponentId = @RCId), 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
		--	END

--===================================================== ORIGIN INVENTORY TRANSFER =====================================================
-- ORIGIN/DESTINATION
DECLARE @TRIncludeOriginState NVARCHAR(250)
DECLARE @TRExcludeOriginState NVARCHAR(250)
DECLARE @TRIncludeDestinationState NVARCHAR(250)
DECLARE @TRExcludeDestinationState NVARCHAR(250)
DECLARE @TRIncludeLocationState NVARCHAR(250)
DECLARE @TRExcludeLocationState NVARCHAR(250)

DECLARE @tblTRTempReportingComponent TABLE (
			intId INT IDENTITY(1,1),
			intReportingComponentId INT
		 )

DECLARE @TRQueryRC NVARCHAR(MAX)
DECLARE @TRquery NVARCHAR(MAX)
DECLARE @TRCountRC INT
DECLARE @TRRCId NVARCHAR(50)

	--IF @Refresh = 'true'
	--	BEGIN
	--		TRUNCATE TABLE tblTFTransaction --WHERE uniqTransactionGuid = @Guid
	--	END
	--	DELETE FROM tblTFTransaction WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'

		SELECT @TRQueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
		INSERT INTO @tblTRTempReportingComponent (intReportingComponentId)
		EXEC(@TRQueryRC)

		SET @TRCountRC = (SELECT count(intId) FROM @tblTRTempReportingComponent) 
		WHILE(@TRCountRC > 0)
			BEGIN
				SET @TRRCId = (SELECT intReportingComponentId FROM @tblTRTempReportingComponent WHERE intId = @TRCountRC)

				-- ORIGIN
				DECLARE @TRIncludeValidOriginState NVARCHAR(MAX) = NULL
				SELECT @TRIncludeValidOriginState = COALESCE(@TRIncludeValidOriginState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @TRRCId AND strType = 'Include'
				IF(@TRIncludeValidOriginState IS NOT NULL)
					BEGIN
						SET @TRIncludeValidOriginState = REPLACE(@TRIncludeValidOriginState,',',''',''')
						SET @TRIncludeOriginState = '/*INCLUDE ORIGIN*/ AND TR.strVendorState IN (''' + @TRIncludeValidOriginState + ''')' 
					END
				ELSE
					BEGIN
						SET @TRIncludeOriginState = ''
					END

				DECLARE @TRExcludeValidOriginState NVARCHAR(MAX) = NULL
				SELECT @TRExcludeValidOriginState = COALESCE(@TRExcludeValidOriginState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentOriginState WHERE intReportingComponentId = @TRRCId AND strType = 'Exclude'
				IF(@TRExcludeValidOriginState IS NOT NULL)
					BEGIN
						SET @TRExcludeValidOriginState = REPLACE(@TRExcludeValidOriginState,',',''',''')
						SET @TRExcludeOriginState = '/*EXCLUDE ORIGIN*/  AND TR.strVendorState NOT IN (''' + @TRExcludeValidOriginState + ''')'
					END
				ELSE
					BEGIN
						SET @TRExcludeOriginState = ''
					END

				-- DESTINATION
				DECLARE @TRIncludeValidDestinationState NVARCHAR(MAX) = NULL
				SELECT @TRIncludeValidDestinationState = COALESCE(@TRIncludeValidDestinationState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @TRRCId AND strType = 'Include'
				IF(@TRIncludeValidDestinationState IS NOT NULL)
					BEGIN
						SET @TRIncludeValidDestinationState = REPLACE(@TRIncludeValidDestinationState,',',''',''')
						SET @TRIncludeDestinationState = '/*INCLUDE DESTINATION*/  AND TR.strCustomerState IN (''' + @TRIncludeValidDestinationState + ''')'
					END
				ELSE
					BEGIN
						SET @TRIncludeDestinationState = ''
					END

				DECLARE @TRExcludeValidDestinationState NVARCHAR(MAX) = NULL
				SELECT @TRExcludeValidDestinationState = COALESCE(@TRExcludeValidDestinationState + ',', '') + strOriginDestinationState FROM vyuTFGetReportingComponentDestinationState WHERE intReportingComponentId = @TRRCId AND strType = 'Exclude'
				IF(@TRExcludeValidDestinationState IS NOT NULL)
					BEGIN
						SET @TRExcludeValidDestinationState = REPLACE(@TRExcludeValidDestinationState,',',''',''')
						SET @TRExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND TR.strCustomerState NOT IN (''' + @TRExcludeValidDestinationState + ''')'
					END
				ELSE
					BEGIN
						SET @TRExcludeDestinationState = ''
					END

				--INVENTORY TRANSFER
				SET @TRquery = 'INSERT INTO tblTFTransaction (uniqTransactionGuid, intReportingComponentId, intTaxAuthorityId, strTaxAuthority, strFormCode, strScheduleCode, strType, intProductCodeId, strProductCode, intItemId, dblQtyShipped, dblGross, dblNet,
							  dblBillQty, dblTax, dblTaxExempt, strInvoiceNumber, strPONumber, strBOLNumber, dtmDate, strDestinationCity, strDestinationState, strOriginCity, strOriginState, strShipVia, strTransporterLicense,
							  strTransportationMode, strTransporterName, strTransporterFederalTaxId, strConsignorName, strConsignorFederalTaxId, strTerminalControlNumber, strVendorName, strVendorFederalTaxId,strCustomerName,strCustomerFederalTaxId,
							  strTaxPayerName, strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strTaxPayerIdentificationNumber, strTaxPayerFEIN, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strItemNo,intIntegrationError,leaf)
							  SELECT DISTINCT ''' + @Guid + ''', RC.intReportingComponentId,
								RC.intTaxAuthorityId,
								IPC.strTaxAuthority,
								RC.strFormCode,
								RC.strScheduleCode,
								RC.strType,
								VPC.intProductCode,
								IPC.strProductCode,
								NULL AS intItemId,
								TR.dblTransactionOutboundGrossGals AS dblQtyShipped,
								TR.dblTransactionOutboundGrossGals AS dblGross,
								TR.dblTransactionOutboundNetGals AS dblNet,
								TR.dblTransactionOutboundBilledGals AS dblQuantity,
								NULL AS dblTax,
								NULL AS dblTaxExempt,
								NULL AS strInvoiceNumber,
								NULL AS strPONumber,
								TR.strTransactionBillOfLading,
								CONVERT(NVARCHAR(50), TR.dtmTransactionDate),
								TR.strCustomerCity AS strDestinationCity,
								TR.strCustomerState AS strDestinationState,
								TR.strVendorCity AS strOriginCity,
								TR.strVendorState AS strOriginState,
								TR.strCarrierTransportationMode AS strShipVia,
								TR.strCarrierLicenseNumber1 AS strTransporterLicense,
								TR.strCarrierTransportationMode AS strTransportationMode,
								TR.strCarrierName AS strTransporterName,
								TR.strCarrierFEIN AS strTransporterFEIN,
								TR.strCarrierName AS strConsignorName,
								TR.strCarrierFEIN AS strConsignorFEIN,
								TR.strVendorTerminalControlNumber AS strTerminalControlNumber,
								TR.strVendorName,
								TR.strVendorFEIN,
								TR.strCustomerName,
								TR.strCustomerTaxID1,
								SMCOMPSETUP.strCompanyName,
								SMCOMPSETUP.strAddress,
								SMCOMPSETUP.strCity,
								SMCOMPSETUP.strState,
								SMCOMPSETUP.strZip,
								SMCOMPSETUP.strPhone,
								SMCOMPSETUP.strStateTaxID,
								SMCOMPSETUP.strFederalTaxID,
								''' + @DateFrom + ''',
								''' + @DateTo + ''',
								TR.strItemNumber,
								(SELECT COUNT(*) FROM tblTFIntegrationError),
								0
							  FROM tblTFReportingComponentCriteria RIGHT OUTER JOIN
							  vyuTFGetReportingComponentProductCode AS VPC INNER JOIN
							  tblTFReportingComponent AS RC ON VPC.intReportingComponentId = RC.intReportingComponentId INNER JOIN
							  tblTFIntegrationItemProductCode AS IPC ON VPC.strProductCode = IPC.strProductCode INNER JOIN
							  tblTFIntegrationTransaction AS TR ON IPC.strItemNumber = TR.strItemNumber ON tblTFReportingComponentCriteria.intReportingComponentId = RC.intReportingComponentId CROSS JOIN
							  tblSMCompanySetup AS SMCOMPSETUP
							  WHERE (RC.intReportingComponentId IN(' + @TRRCId + ')) 
							  AND TR.strSourceSystem NOT IN (''F'')
							  AND TR.strTransactionType IN (''T'', ''O'')
							  AND TR.strCarrierCompanyOwnedIndicator = ''Y''
							  AND TR.dtmTransactionDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							  ' + @TRIncludeOriginState + ' ' + @TRExcludeOriginState + '
							  ' + @TRIncludeDestinationState + ' ' + @TRExcludeDestinationState + ' ' + @Criteria + ''

							 EXEC(@TRquery)

				SET @TRCountRC = @TRCountRC - 1
			END
	
		DECLARE @TRHasResult INT
		SELECT TOP 1 @TRHasResult = intTransactionId FROM tblTFTransaction
		IF(@TRHasResult IS NULL AND @IsEdi = 'false')
		BEGIN
			INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, 'SF-401', 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
		END
