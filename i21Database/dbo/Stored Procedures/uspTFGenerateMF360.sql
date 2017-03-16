CREATE PROCEDURE [dbo].[uspTFGenerateMF360]
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

	DECLARE @TA INT
		, @TACode NVARCHAR(5)
		--SUMMARY VARIABLES
		, @ParamId NVARCHAR(MAX)
		, @ScheduleCode NVARCHAR(MAX)
		, @TemplateItemId NVARCHAR(20)
		, @TemplateConfiguration NVARCHAR(20)
		, @TemplateDescription NVARCHAR(MAX)
		, @TemplateItemNumber NVARCHAR(MAX)
		, @ReportItemSequence NVARCHAR(MAX)
		, @ReportSection NVARCHAR(MAX)
		, @TempComputedValue NUMERIC(18, 2)
		, @TemplateItemCount NVARCHAR(MAX) 
		, @Query NVARCHAR(MAX)
		--DETAIL VARIABLES
		, @DetailColumnValue_gas NVARCHAR(MAX)
		, @DetailColumnValue_kerosene NVARCHAR(MAX)
		, @DetailColumnValue_others NVARCHAR(MAX)
		, @QueryScheduleCodeParam NVARCHAR(MAX)

	DECLARE @tblTempScheduleCodeParam TABLE(Id INT IDENTITY(1,1)
		, strTempScheduleCode NVARCHAR(120))

	DECLARE @tblTempSummaryTotal TABLE (dbLColumnValue NUMERIC(18, 2))

	DECLARE @tblTempSummaryItem TABLE (Id INT IDENTITY(1,1)
		, TaxReportSummaryItemId INT)

	DECLARE @tblTempTaxReportSummary TABLE(intDefaultValue INT)

	DECLARE @tblSchedule TABLE (intId INT IDENTITY(1,1)
		, strSchedule NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL)

	IF @Refresh = 'true'
	BEGIN
		DELETE FROM tblTFTransactionSummary --WHERE strSummaryGuid = @Guid
	END
		-- ======================== HEADER ==============================
	DECLARE @DatePeriod DATETIME
		, @DateBegin DATETIME
		, @DateEnd DATETIME
		, @LicenseNumber NVARCHAR(50)
		, @EIN NVARCHAR(50)

	SELECT TOP 1 @TA = intTaxAuthorityId
		, @TACode = strTaxAuthorityCode
		, @DatePeriod = dtmDate
		, @DateBegin = dtmReportingPeriodBegin
		, @DateEnd = dtmReportingPeriodEnd
	FROM vyuTFGetTransaction
	WHERE uniqTransactionGuid = @Guid
		AND strFormCode = @FormCodeParam

	SELECT TOP 1 @LicenseNumber = strConfiguration
	FROM vyuTFGetReportingComponentConfiguration
	WHERE strFormCode = @FormCodeParam
		AND strTemplateItemId = 'MF-360-LicenseNumber'

	SELECT TOP 1 @EIN = strEin
	FROM tblSMCompanySetup
	
	-- ======================== HEADER ==============================
	INSERT INTO vyuTFGetTransactionSummary (strSummaryGuid
		, intTaxAuthorityId
		, strFormCode
		, strScheduleCode
		, strSegment
		, dtmDateRun
		, dtmReportingPeriodBegin
		, dtmReportingPeriodEnd
		, strTaxPayerName
		, strFEINSSN
		, strEmail
		, strTaxPayerAddress
		, strCity
		, strState
		, strZipCode
		, strTelephoneNumber
		, strContactName
		, strLicenseNumber
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
		, @EIN
		, strContactEmail
		, strTaxAddress
		, strCity
		, strState
		, strZipCode
		, strContactPhone
		, strContactName
		, @LicenseNumber
		, strContactName
	FROM tblTFCompanyPreference

	-- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)
	SELECT intReportingComponentConfigurationId
	FROM vyuTFGetReportingComponentConfiguration
	WHERE strFormCode = @FormCodeParam
		AND strSegment = 'Summary'
	ORDER BY intReportingComponentConfigurationId DESC
	
	SET @TemplateItemCount = (SELECT COUNT(*) FROM @tblTempSummaryItem)
	
	-- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
	WHILE(@TemplateItemCount > 0)
	BEGIN
		-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
		SELECT @ParamId = TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @TemplateItemCount

		SELECT TOP 1 @ScheduleCode = strScheduleCode
			, @TemplateItemId = strTemplateItemId
		FROM vyuTFGetReportingComponentConfiguration
		WHERE intReportingComponentConfigurationId = @ParamId
			AND strFormCode = @FormCodeParam		

		SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')

		IF (ISNULL(@ScheduleCode, '') <> '')
		BEGIN
			SELECT TOP 1 @TemplateDescription = strDescription
				, @ReportItemSequence = intReportItemSequence
				, @TemplateItemNumber = intTemplateItemNumber
				, @ReportSection = strReportSection
				, @TemplateConfiguration = strConfiguration
			FROM vyuTFGetReportingComponentConfiguration
			WHERE intReportingComponentConfigurationId = @ParamId
				AND strFormCode = @FormCodeParam
			
			-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE
			IF @TemplateItemId = 'MF-360-Summary-001'
			BEGIN
				SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND strType = ''Gasoline / Aviation Gasoline / Gasohol'' AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-002'
			BEGIN
				DECLARE @E1 NVARCHAR(50)
				SET @E1 = (SELECT ISNULL(SUM(CAST(strConfiguration AS INT)), 0) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId IN('MF-360-Summary-024','MF-360-Summary-025'))
				SET @Query = 'SELECT ISNULL(SUM(dblQtyShipped), 0) + ' + @E1 + ' FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''' AND strType = ''Gasoline / Aviation Gasoline / Gasohol'''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-003'
			BEGIN
				SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND strType=''Gasoline / Aviation Gasoline / Gasohol'' AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-004'
			BEGIN
			--SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @SmryReportingComponentId + ''')' 
				SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-005'
			BEGIN
				SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-006'
			BEGIN
				SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-007'
			BEGIN
				SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-008'
			BEGIN
				SET @Query = 'SELECT (CASE WHEN strConfiguration = '''' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = ''MF-360-Summary-008'''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-009'
			BEGIN
				SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-010'
			BEGIN
				SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 	
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-011'
			BEGIN
				SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-012'
			BEGIN
				SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-013'
			BEGIN
				SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END		
			ELSE IF @TemplateItemId = 'MF-360-Summary-014'
			BEGIN
				SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-015'
			BEGIN
				SET @Query = 'SELECT (CASE WHEN strConfiguration = '''' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = ''MF-360-Summary-015'''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-016'
			BEGIN
				SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-017'
			BEGIN
				SET @Query = 'SELECT SUM(strColumnValue)  FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-018'
			BEGIN
				SET @Query = 'SELECT (CASE WHEN strConfiguration = '''' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = ''MF-360-Summary-018'''    
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-019'
			BEGIN
				SET @Query = 'SELECT (CASE WHEN strConfiguration = '''' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = ''MF-360-Summary-019'''    
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-020'
			BEGIN
				SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-021'
			BEGIN
				SET @Query = 'SELECT (CASE WHEN strConfiguration = '''' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = ''MF-360-Summary-021''' 
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-022'
			BEGIN
				SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END
			ELSE IF @TemplateItemId = 'MF-360-Summary-023'
			BEGIN
				SET @Query = 'SELECT (CASE WHEN strConfiguration = '''' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = ''MF-360-Summary-023'''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END

			--DETAILS
			ELSE IF @TemplateItemId = 'MF-360-Summary-024'
			BEGIN
				SET @Query = 'SELECT (CASE WHEN strConfiguration = '''' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = ''MF-360-Summary-023'''  
				INSERT INTO @tblTempSummaryTotal
				EXEC(@Query)
			END

			SELECT @TempComputedValue = ISNULL(dbLColumnValue, 0) FROM @tblTempSummaryTotal

			INSERT INTO tblTFTransactionSummary (strSummaryGuid
				, intTaxAuthorityId
				, strTaxAuthority
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
				, @TACode
				, @FormCodeParam
				, @ScheduleCode
				, 'Summary'
				, ''
				, @TemplateDescription
				, @TempComputedValue
				, @TemplateItemNumber
				, @ReportItemSequence
				, @ReportSection
				, CAST(GETDATE() AS DATE))
		END

		DELETE FROM @tblTempSummaryTotal
		SET @TemplateItemCount = @TemplateItemCount - 1
	END

	-- ======================== DETAIL ==============================
	DECLARE @ItemTotal NVARCHAR(MAX)
	DECLARE @itemQuery NVARCHAR(MAX)
	DECLARE @CountItems INT

	DECLARE @ItemDescription nvarchar(MAX)
	SELECT @QueryScheduleCodeParam = 'SELECT ''' + REPLACE (@ScheduleCodeParam,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempScheduleCodeParam (strTempScheduleCode)
	EXEC(@QueryScheduleCodeParam)
	
	SELECT @CountItems = COUNT(strFormCode)
	FROM vyuTFGetReportingComponentConfiguration
	WHERE strSegment = 'Details'
		AND strFormCode = @FormCodeParam

	WHILE(@CountItems > 0)
	BEGIN
		DECLARE @tplScheduleCode NVARCHAR(MAX)
			, @paramScheduleCode NVARCHAR(MAX)

		-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
		SELECT TOP 1 @tplScheduleCode = strScheduleCode
		FROM vyuTFGetReportingComponentConfiguration
		WHERE strSegment = 'Details'
			AND intTemplateItemNumber = @CountItems
			AND strFormCode = @FormCodeParam

		-- GET SCHEDULE CODE BY PASSED PARAM
		SELECT TOP 1 @paramScheduleCode = strTempScheduleCode
		FROM @tblTempScheduleCodeParam
		WHERE strTempScheduleCode = @tplScheduleCode

		IF (@paramScheduleCode = '5' OR @paramScheduleCode = '11' OR @paramScheduleCode = '6D' OR @paramScheduleCode = '6X' OR @paramScheduleCode = '7' OR @paramScheduleCode = '8' OR @paramScheduleCode = '10A' OR @paramScheduleCode = '10B')
		BEGIN
			SELECT @DetailColumnValue_gas = ISNULL(SUM(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
			SELECT @DetailColumnValue_kerosene = ISNULL(SUM(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
			SELECT @DetailColumnValue_others = ISNULL(SUM(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
			SELECT @ItemTotal = ISNULL(sum(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN(@paramScheduleCode) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
		END
		ELSE
		BEGIN
			SELECT @DetailColumnValue_gas = ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
			SELECT @DetailColumnValue_kerosene = ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
			SELECT @DetailColumnValue_others = ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
			SELECT @ItemTotal = ISNULL(sum(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN(@paramScheduleCode) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam
		END
			
		SELECT @ItemDescription = strDescription FROM vyuTFGetReportingComponentConfiguration WHERE intTemplateItemNumber = @CountItems AND strSegment = 'Details' AND strFormCode = 'MF-360'

			-- ITEMS THAT HAVE MULTIPLE SCHEDULE CODES TO COMPUTE
		DECLARE @SchedQuery NVARCHAR(MAX)
		IF (@CountItems = 8)
		BEGIN
			SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
			INSERT INTO @tblSchedule (strSchedule)
			EXEC(@SchedQuery)
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 4, 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			DELETE FROM @tblSchedule
		END
		ELSE IF (@CountItems = 9)
		BEGIN
			SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
			INSERT INTO @tblSchedule (strSchedule)
			EXEC(@SchedQuery)
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 2, 'Details','K-1/K-2 Kerosene B', '',(SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			-- OTHERS
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 3, 'Details','All Other Products C', '',(SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 4, 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			DELETE FROM @tblSchedule
		END
		ELSE IF (@CountItems = 21)
		BEGIN
			SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
			INSERT INTO @tblSchedule (strSchedule)
			EXEC(@SchedQuery)
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 2, 'Details','K-1/K-2 Kerosene B', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			-- OTHERS
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 3, 'Details','All Other Products C', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', '', 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
			DELETE FROM @tblSchedule
		END
		ELSE IF (@CountItems = 20)
		BEGIN
			SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
			INSERT INTO @tblSchedule (strSchedule)
			EXEC(@SchedQuery)
			DECLARE @TOTAL NUMERIC(18,2)
			SET @TOTAL = (SELECT ISNULL(SUM(CONVERT(NUMERIC(18, 2), strConfiguration)), 0) FROM vyuTFGetReportingComponentConfiguration WHERE strFormCode = @FormCodeParam AND strScheduleCode = 'E-1') + (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@TOTAL, @ItemDescription, CAST(GETDATE() AS DATE))
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 4, 'Details','TOTAL', '',@TOTAL, @ItemDescription, CAST(GETDATE() AS DATE))
			DELETE FROM @tblSchedule
		END
		ELSE 
		BEGIN
			-- GAS
			DECLARE @SmryDetailItemId NVARCHAR(MAX)
			SET @SmryDetailItemId = (SELECT strTemplateItemId FROM vyuTFGetReportingComponentConfiguration WHERE strSegment = 'Details' and intTemplateItemNumber = @CountItems AND strFormCode = @FormCodeParam)

			IF (@tplScheduleCode = 'E-1')
			BEGIN
				INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
				VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '', (SELECT strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE strTemplateItemId = @SmryDetailItemId), @ItemDescription, CAST(GETDATE() AS DATE))
			END
			ELSE
			BEGIN
				INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
				VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@DetailColumnValue_gas, @ItemDescription, CAST(GETDATE() AS DATE))
			END

			-- KEROSENE
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 2, 'Details','K-1/K-2 Kerosene B', '',@DetailColumnValue_kerosene, @ItemDescription, CAST(GETDATE() AS DATE))

			-- OTHERS
			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
			VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 3, 'Details','All Other Products C', '',@DetailColumnValue_others, @ItemDescription, CAST(GETDATE() AS DATE))

			INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
					VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 4, 'Details','TOTAL', '',@ItemTotal, @ItemDescription, CAST(GETDATE() AS DATE))
		END
		SET @paramScheduleCode = NULL
		SET @CountItems = @CountItems - 1
	END
			
	DECLARE @isTransactionEmpty NVARCHAR(20)
	SET @isTransactionEmpty = (SELECT TOP 1 strProductCode FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
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