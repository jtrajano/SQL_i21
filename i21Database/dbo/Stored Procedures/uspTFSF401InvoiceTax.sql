CREATE PROCEDURE [dbo].[uspTFSF401InvoiceTax]

@Guid NVARCHAR(50),
@ReportingComponentId NVARCHAR(MAX),
@DateFrom NVARCHAR(50),
@DateTo NVARCHAR(50),
@IsEdi NVARCHAR(10),
@Refresh NVARCHAR(5)

AS

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

DECLARE @QueryRC NVARCHAR(MAX)
DECLARE @query NVARCHAR(MAX)
DECLARE @CountRC INT
DECLARE @RCId NVARCHAR(50)

DECLARE @tblTempTransaction TABLE (
			intId INT,
			intReportingComponentId INT,
			intTaxAuthorityId INT,
			strTaxAuthority NVARCHAR(5),
			strFormCode NVARCHAR(20),
			strScheduleCode NVARCHAR(5),
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
			TRUNCATE TABLE tblTFTransactions --WHERE uniqTransactionGuid = @Guid
		END
		DELETE FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strProductCode = 'No record found.'

		SELECT @QueryRC = 'SELECT ''' + REPLACE (@ReportingComponentId,',',''' UNION SELECT ''') + ''''
		INSERT INTO @tblTempReportingComponent (intReportingComponentId)
		EXEC(@QueryRC)

		SET @CountRC = (SELECT count(intId) FROM @tblTempReportingComponent) 
		WHILE(@CountRC > 0)
			BEGIN
				SET @RCId = (SELECT intReportingComponentId FROM @tblTempReportingComponent WHERE intId = @CountRC)

				-- ORIGIN
				DECLARE @IncludeValidOriginState NVARCHAR(MAX) = NULL
				SELECT @IncludeValidOriginState = COALESCE(@IncludeValidOriginState + ',', '') + strOriginState FROM tblTFValidOriginState WHERE intReportingComponentId = @RCId AND strFilter = 'Include'
				IF(@IncludeValidOriginState IS NOT NULL)
					BEGIN
						SET @IncludeValidOriginState = REPLACE(@IncludeValidOriginState,',',''',''')
						SET @IncludeOriginState = '/*INCLUDE ORIGIN*/ AND TR.strVendorState IN (''' + @IncludeValidOriginState + ''')' 
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
						SET @ExcludeOriginState = '/*EXCLUDE ORIGIN*/  AND TR.strVendorState NOT IN (''' + @ExcludeValidOriginState + ''')'
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
						SET @IncludeDestinationState = '/*INCLUDE DESTINATION*/  AND TR.strCustomerState IN (''' + @IncludeValidDestinationState + ''')'
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
						SET @ExcludeDestinationState = '/*EXCLUDE DESTINATION*/ AND TR.strCustomerState NOT IN (''' + @ExcludeValidDestinationState + ''')'
					END
				ELSE
					BEGIN
						SET @ExcludeDestinationState = ''
					END

				--INVENTORY TRANSFER
				SET @query = 'INSERT INTO tblTFTransactions (uniqTransactionGuid, intReportingComponentId, intTaxAuthorityId, strTaxAuthority, strFormCode, strScheduleCode, strType, intProductCodeId, strProductCode, intItemId, dblQtyShipped, dblGross, dblNet,
							  dblBillQty, dblTax, dblTaxExempt, strInvoiceNumber, strPONumber, strBOLNumber, dtmDate, strDestinationCity, strDestinationState, strOriginCity, strOriginState, strShipVia, strTransporterLicense,
							  strTransportationMode, strTransporterName, strTransporterFederalTaxId, strConsignorName, strConsignorFederalTaxId, strTerminalControlNumber, strVendorName, strVendorFederalTaxId, strTaxPayerName,
							  strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strTaxPayerIdentificationNumber, strTaxPayerFEIN, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strItemNo,intIntegrationError,leaf)
							  SELECT ''' + @Guid + ''', RC.intReportingComponentId,
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
								SMCOMPSETUP.strCompanyName,
								SMCOMPSETUP.strAddress,
								SMCOMPSETUP.strCity,
								SMCOMPSETUP.strState,
								SMCOMPSETUP.strZip,
								SMCOMPSETUP.strPhone,
								SMCOMPSETUP.strStateTaxID,
								SMCOMPSETUP.strFederalTaxID,
								NULL,
								NULL,
								TR.strItemNumber,
								(SELECT COUNT(*) FROM tblTFIntegrationError),
								0
							  FROM tblSMCompanySetup AS SMCOMPSETUP CROSS JOIN tblTFValidProductCode AS VPC
							  INNER JOIN tblTFReportingComponent AS RC ON VPC.intReportingComponentId = RC.intReportingComponentId
							  INNER JOIN tblTFIntegrationItemProductCode AS IPC ON VPC.strProductCode = IPC.strProductCode
							  INNER JOIN tblTFIntegrationTransaction AS TR ON IPC.strSourceRecordConcatKey = TR.strSourceRecordConcatKey
							  WHERE (RC.intReportingComponentId IN(' + @RCId + ')) 
							  AND TR.dtmTransactionDate BETWEEN ''' + @DateFrom + ''' AND ''' + @DateTo + '''
							  ' + @IncludeOriginState + ' ' + @ExcludeOriginState + '
							  ' + @IncludeDestinationState + ' ' + @ExcludeDestinationState + ''

							 EXEC(@query)

				SET @CountRC = @CountRC - 1
			END
	
		DECLARE @HasResult INT
		SELECT TOP 1 @HasResult = intTransactionId FROM tblTFTransactions
		IF(@HasResult IS NULL AND @IsEdi = 'false')
			BEGIN
				INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, intProductCodeId, strProductCode, dtmDate,dtmReportingPeriodBegin,dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, 'SF-401', 0,'No record found.',GETDATE(), @DateFrom, @DateTo, 1)
		
			END