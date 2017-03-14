CREATE PROCEDURE [dbo].[uspTFGenerateGT103]
	@Guid NVARCHAR(250)
	, @FormCodeParam NVARCHAR(MAX)
	, @ScheduleCodeParam NVARCHAR(MAX)
	, @Refresh NVARCHAR(5)

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @TFTransactionSummaryTotal TFTransactionSummaryTotal

	DECLARE @TA INT
	--SUMMARY VARIABLES
	DECLARE @ReportTemplateId INT
	DECLARE @TemplateScheduleCodeParam NVARCHAR(MAX)
	DECLARE @TemplateItemId NVARCHAR(20)
	DECLARE @TemplateConfiguration NUMERIC(18, 6)
	DECLARE @TemplateDescription NVARCHAR(MAX)
	DECLARE @TemplateItemNumber NVARCHAR(MAX)
	DECLARE @ReportItemSequence NVARCHAR(MAX)
	DECLARE @ReportSection NVARCHAR(MAX)
	DECLARE @TempComputedValue NUMERIC(18, 6)
	DECLARE @QueryTransaction NVARCHAR(MAX)

	IF @Refresh = 'true'
	BEGIN
		DELETE FROM tblTFTransactionSummary
	END

	-- ======================== HEADER ==============================
	DECLARE @DatePeriod DATETIME
	DECLARE @DateBegin DATETIME
	DECLARE @DateEnd DATETIME
	DECLARE @TaxID NVARCHAR(50)
	DECLARE @EIN NVARCHAR(50)
		, @FaxNumber NVARCHAR(50)

	SELECT TOP 1 @TA = intTaxAuthorityId
		, @DatePeriod = dtmDate
		, @DateBegin = dtmReportingPeriodBegin
		, @DateEnd = dtmReportingPeriodEnd
	FROM vyuTFGetTransaction
	WHERE uniqTransactionGuid = @Guid
		AND strFormCode = @FormCodeParam
	
	SELECT TOP 1 @TaxID = strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'GT-103-TID'
	SELECT TOP 1 @EIN = strEin, @FaxNumber = strFax FROM tblSMCompanySetup

	INSERT INTO tblTFTransactionSummary (strSummaryGuid
		, intTaxAuthorityId
		, strFormCode
		, strScheduleCode
		, strSegment
		, dtmDateRun
		, dtmReportingPeriodBegin
		, dtmReportingPeriodEnd
		, strTaxPayerName
		, strTaxPayerIdentificationNumber
		, strTaxPayerFEIN
		, strEmail
		, strTaxPayerAddress
		, strCity
		, strState
		, strZipCode
		, strTelephoneNumber
		, strContactName
		, strFaxNumber)
	SELECT TOP 1 @Guid
		, @TA
		, @FormCodeParam
		, ''
		, 'Header'
		, @DatePeriod
		, @DateBegin
		, @DateEnd
		, strCompanyName
		, @TaxID
		, @EIN
		, strContactEmail
		, strTaxAddress
		, strCity
		, strState
		, strZipCode
		, strContactPhone
		, strContactName
		, @FaxNumber
	FROM tblTFCompanyPreference
	
	-- ======================== SUMMARY ==============================
	-- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intTransactionSummaryItemId = intReportingComponentConfigurationId
		, Config.strScheduleCode
		, strTemplateItemId
		, strDescription
		, intReportItemSequence
		, intTemplateItemNumber
		, strReportSection
		, strConfiguration
	INTO #tmpTransactionSummaryItem
	FROM tblTFReportingComponentConfiguration Config
	INNER JOIN tblTFReportingComponent RC ON Config.intReportingComponentId = RC.intReportingComponentId
	WHERE RC.strFormCode = @FormCodeParam 
		AND Config.strSegment = 'Summary'
	ORDER BY Config.intReportingComponentConfigurationId DESC
	
	-- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpTransactionSummaryItem)
	BEGIN
		-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
		SELECT TOP 1 @ReportTemplateId = intTransactionSummaryItemId
			, @TemplateScheduleCodeParam = strScheduleCode
			, @TemplateItemId = strTemplateItemId
			, @TemplateDescription = strDescription
			, @ReportItemSequence = intReportItemSequence
			, @TemplateItemNumber = intTemplateItemNumber
			, @ReportSection = strReportSection
			, @TemplateConfiguration = strConfiguration
		FROM #tmpTransactionSummaryItem

		SET @TemplateScheduleCodeParam = REPLACE(@TemplateScheduleCodeParam,',',''',''')
		IF (@TemplateScheduleCodeParam IS NOT NULL)
		BEGIN			
			-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE
			IF @TemplateItemId = 'GT-103-Summary-001'
			BEGIN
			--1. Total Gallons Sold for Period
				SET @QueryTransaction = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCodeParam + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @TFTransactionSummaryTotal
				EXEC(@QueryTransaction)
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-002'
			BEGIN
			--2. Total Exempt Gallons Sold for Period
				SET @QueryTransaction = 'SELECT SUM(dblTaxExempt) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCodeParam + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @TFTransactionSummaryTotal
				EXEC(@QueryTransaction)
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-003'
			BEGIN
			--3. Total Taxable Gallons Sold (Line 1 minus Line 2)
				SET @QueryTransaction = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
				INSERT INTO @TFTransactionSummaryTotal
				EXEC(@QueryTransaction)
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-004'
			BEGIN
			--4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2
				SET @QueryTransaction = 'SELECT strColumnValue * ' + CONVERT(NVARCHAR(50), @TemplateConfiguration) + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @TFTransactionSummaryTotal
				EXEC(@QueryTransaction)
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-005'
			BEGIN
			--5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 0.73%
				IF(@ScheduleCodeParam <> '')
				BEGIN
					SET @QueryTransaction = 'SELECT strColumnValue * ' + CONVERT(NVARCHAR(50), @TemplateConfiguration) + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
				ELSE
				BEGIN
					SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFReportingComponentConfiguration'  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-006'
			BEGIN
			--6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)
				IF(@ScheduleCodeParam <> '')
				BEGIN
					SET @QueryTransaction  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
				ELSE
				BEGIN
					SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFReportingComponentConfiguration'  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-007'
			BEGIN
			--7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.
				IF(@ScheduleCodeParam <> '')
				BEGIN
					SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''' + @TemplateItemId + ''''  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
				ELSE
				BEGIN
					SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFReportingComponentConfiguration'  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-008'
			BEGIN
			--8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #3)
				IF(@ScheduleCodeParam <> '')
				BEGIN
					SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''' + @TemplateItemId + '''' 
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
				ELSE
				BEGIN
					SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFReportingComponentConfiguration'  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-009'
			BEGIN
			--9. Electronic Funds Transfer Credit
				IF(@ScheduleCodeParam <> '')
				BEGIN
					SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''' + @TemplateItemId + '''' 
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
				ELSE
				BEGIN
					SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFReportingComponentConfiguration'  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-010'
			BEGIN
			--10. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and
				IF(@ScheduleCodeParam <> '')
				BEGIN
					SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''' + @TemplateItemId + '''' 
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
				ELSE
				BEGIN
					SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFReportingComponentConfiguration'  
					INSERT INTO @TFTransactionSummaryTotal
					EXEC(@QueryTransaction)
				END
			END
			ELSE IF @TemplateItemId = 'GT-103-Summary-011'
			BEGIN
			--11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).
				SET @QueryTransaction = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
				DECLARE @Value NVARCHAR(MAX) = ''
				SET @Value = ((SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN('6','7','8') AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid) - (SELECT strColumnValue FROM tblTFTransactionSummary WHERE intItemNumber IN('9') AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)) + (SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN('10') AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
			
				INSERT INTO @TFTransactionSummaryTotal(dbLColumnValue)values(@Value)
				EXEC(@QueryTransaction)
			END		

			SET @TempComputedValue = (SELECT TOP 1 ISNULL(dbLColumnValue, 0) FROM @TFTransactionSummaryTotal)
			PRINT @TempComputedValue

			INSERT INTO tblTFTransactionSummary(
				strSummaryGuid
				, intTaxAuthorityId
				, strFormCode
				, strScheduleCode
				, strSegment
				, strProductCode
				, strDescription
				, strColumnValue
				, intItemNumber
				, intItemSequenceNumber
				, strSection
				, dtmDateRun)		
			VALUES (@Guid
				, @TA
				, @FormCodeParam
				, @TemplateScheduleCodeParam
				, 'Summary'
				, ''
				, @TemplateDescription
				, @TempComputedValue
				, @TemplateItemNumber
				, @ReportItemSequence
				, @ReportSection
				, CAST(GETDATE() AS DATE))
		END

		DELETE FROM @TFTransactionSummaryTotal
		DELETE FROM #tmpTransactionSummaryItem WHERE intTransactionSummaryItemId = @ReportTemplateId
	END

	DROP TABLE #tmpTransactionSummaryItem
	-- ======================== DETAILS ==============================
	--DETAIL VARIABLES
	--Receipts - Schedule 1
	DECLARE @ReceiptTotalGallsPurchased NVARCHAR(MAX)
	DECLARE @GasolineUseTaxPaid NVARCHAR(MAX)

	--Disbursements - Schedule 2
	DECLARE @TotalGallonsSold NVARCHAR(MAX)
	DECLARE @TotalExemptGallonsSold NVARCHAR(MAX)
	DECLARE @GasolineUseTaxCollected NVARCHAR(MAX)

	DECLARE @queryScheduleCodeParam NVARCHAR(MAX)
	DECLARE @CountTemplateItem INT
	DECLARE @TemplateScheduleCode NVARCHAR(MAX)

	DECLARE @TemplateItemDescription NVARCHAR(MAX)
	DECLARE @TemplateSection NVARCHAR(MAX)
	DECLARE @Type NVARCHAR(MAX)

	DECLARE @ItemTotal NVARCHAR(MAX)

	DECLARE @tblTempScheduleCodeParam TABLE(
				Id INT IDENTITY(1,1),
				strTempScheduleCode NVARCHAR(120))

	DECLARE @itemQuery NVARCHAR(MAX)
	DECLARE @Total NVARCHAR(MAX)

	--SPLIT SCHEDULE CODE AND INSERT TO @tblTempScheduleCodeParam
	SELECT @queryScheduleCodeParam = 'SELECT ''' + REPLACE (@ScheduleCodeParam,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempScheduleCodeParam (strTempScheduleCode)
	EXEC(@queryScheduleCodeParam)
	--END

	--COUNT REPORT TEMPLATE AND LOOP
	SELECT @CountTemplateItem = COUNT(rc.strFormCode) 
	FROM tblTFReportingComponentConfiguration config 
	INNER JOIN tblTFReportingComponent rc ON config.intReportingComponentId = rc.intReportingComponentId
	WHERE config.strSegment = 'Details' AND rc.strFormCode = @FormCodeParam

	WHILE(@CountTemplateItem > 0)
	BEGIN
		-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
		SELECT TOP 1 @TemplateScheduleCode = config.strScheduleCode
			, @TemplateItemDescription = config.strDescription
			, @TemplateSection = config.strReportSection
			, @Type = config.strDescription
		FROM tblTFReportingComponentConfiguration config 
		INNER JOIN tblTFReportingComponent rc ON config.intReportingComponentId = rc.intReportingComponentId
		WHERE config.intTemplateItemNumber = @CountTemplateItem
			AND config.strSegment = 'Details'
			AND rc.strFormCode = @FormCodeParam

		-- GET SCHEDULE CODE BY PASSED PARAM
		DECLARE @paramTempScheduleCode NVARCHAR(MAX)
		SELECT @paramTempScheduleCode = strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE strTempScheduleCode = @TemplateScheduleCode

		--INSERT CALCULATED VALUE INTO TRANSACTION TABLE
		--Disbursements - Schedule 2
		IF(@TemplateSection = 'Disbursements - Schedule 2')
		BEGIN
			IF(@Type = 'Total Gallons of Fuel Sold')
			BEGIN
				SELECT @TotalGallonsSold = ISNULL(SUM(dblQtyShipped), 0),
						@TotalExemptGallonsSold = ISNULL(SUM(dblTaxExempt), 0),
						@GasolineUseTaxCollected = ISNULL(SUM(dblTax), 0)
					FROM vyuTFGetTransaction 
					WHERE strScheduleCode = @paramTempScheduleCode 
					AND uniqTransactionGuid = @Guid 
					AND strFormCode = @FormCodeParam
			END
			ELSE
			BEGIN
				SELECT @TotalGallonsSold = ISNULL(SUM(dblQtyShipped), 0),
						@TotalExemptGallonsSold = ISNULL(SUM(dblTaxExempt), 0),
						@GasolineUseTaxCollected = ISNULL(SUM(dblTax), 0)
					FROM vyuTFGetTransaction 
					WHERE strScheduleCode = @paramTempScheduleCode 
					AND strType = @Type 
					AND uniqTransactionGuid = @Guid 
					AND strFormCode = @FormCodeParam
			END
			-- REFACTOR THIS
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
			SELECT @Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details', 'Total Gallons Sold', '',@TotalGallonsSold, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE)
			UNION
			SELECT @Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details','Total Exempt Gallons Sold', '',@TotalExemptGallonsSold, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE)
			UNION
			SELECT @Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details','Gasoline Use Tax Collected', '',@GasolineUseTaxCollected, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE)
		END
		--Receipts - Schedule 1
		IF(@TemplateSection = 'Receipts - Schedule 1')
		BEGIN
			IF(@Type = 'Total Gallons of Fuel Purchased')
			BEGIN
				SELECT @ReceiptTotalGallsPurchased = ISNULL(SUM(dblGross), 0),
						@GasolineUseTaxPaid = ISNULL(SUM(dblTax), 0)
					FROM vyuTFGetTransaction 
					WHERE strScheduleCode = @paramTempScheduleCode 
					AND uniqTransactionGuid = @Guid 
					AND strFormCode = @FormCodeParam
			END
			ELSE
			BEGIN
				SELECT @ReceiptTotalGallsPurchased = ISNULL(SUM(dblGross), 0),
						@GasolineUseTaxPaid = ISNULL(SUM(dblTax), 0) 
					FROM vyuTFGetTransaction 
					WHERE strScheduleCode = @paramTempScheduleCode 
					AND strType = @Type 
					AND uniqTransactionGuid = @Guid 
					AND strFormCode = @FormCodeParam
			END
			-- REFACTOR THIS
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
			SELECT @Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details', 'Total Gallons Purchased', '',@ReceiptTotalGallsPurchased, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE)
			UNION
			SELECT @Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details','Gasoline Use Tax Paid', '',@GasolineUseTaxPaid, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE)
		END
					
		SET @CountTemplateItem = @CountTemplateItem - 1
	END

	DECLARE @isTransactionEmpty NVARCHAR(20)
	SELECT TOP 1 @isTransactionEmpty = strProductCode
	FROM vyuTFGetTransaction
	WHERE uniqTransactionGuid = @Guid
		AND strFormCode = @FormCodeParam
		
	IF(@isTransactionEmpty = 'No record found.')
	BEGIN
		UPDATE tblTFTransactionSummary SET strColumnValue = 0 WHERE strFormCode = @FormCodeParam
	END

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH