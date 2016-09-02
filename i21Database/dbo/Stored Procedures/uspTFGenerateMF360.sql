CREATE PROCEDURE [dbo].[uspTFGenerateMF360]

@Guid NVARCHAR(250),
@FormCodeParam NVARCHAR(MAX),
@ScheduleCodeParam NVARCHAR(MAX),
@Refresh NVARCHAR(5)

AS

DECLARE @FCode NVARCHAR(5) = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE strFormCode = @FormCodeParam AND uniqTransactionGuid = @Guid)
IF (@FCode IS NOT NULL)
BEGIN

DECLARE @TA INT
DECLARE @TACode NVARCHAR(5)
--SUMMARY VARIABLES
DECLARE @ParamId NVARCHAR(MAX)
DECLARE @ScheduleCode NVARCHAR(MAX)
DECLARE @TemplateItemId NVARCHAR(20)
DECLARE @TemplateConfiguration NVARCHAR(20)
DECLARE @TemplateDescription NVARCHAR(MAX)
DECLARE @TemplateItemNumber NVARCHAR(MAX)
DECLARE @ReportItemSequence NVARCHAR(MAX)
DECLARE @ReportSection NVARCHAR(MAX)
DECLARE @TempComputedValue NUMERIC(18, 2)
DECLARE @TemplateItemCount NVARCHAR(MAX) 
DECLARE @Query NVARCHAR(MAX)
--DETAIL VARIABLES
DECLARE @DetailColumnValue_gas NVARCHAR(MAX)
DECLARE @DetailColumnValue_kerosene NVARCHAR(MAX)
DECLARE @DetailColumnValue_others NVARCHAR(MAX)
DECLARE @QueryScheduleCodeParam NVARCHAR(MAX)

DECLARE @tblTempScheduleCodeParam TABLE(
			Id INT IDENTITY(1,1),
			strTempScheduleCode NVARCHAR(120))

DECLARE @tblTempSummaryTotal TABLE (
		 dbLColumnValue NUMERIC(18, 2))

DECLARE @tblTempSummaryItem TABLE (
		Id INT IDENTITY(1,1),
		TaxReportSummaryItemId INT)

DECLARE @tblTempTaxReportSummary TABLE(
	intDefaultValue INT
)
DECLARE @tblSchedule TABLE (
		intId INT IDENTITY(1,1),
		strSchedule NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		)
IF @Refresh = 'true'
		BEGIN
			DELETE FROM tblTFTaxReportSummary --WHERE strSummaryGuid = @Guid
		END
	-- ======================== HEADER ==============================
DECLARE @DatePeriod DATETIME
DECLARE @DateBegin DATETIME
DECLARE @DateEnd DATETIME

DECLARE @LicenseNumber NVARCHAR(50)
DECLARE @EIN NVARCHAR(50)

--SET @FormCodeParam = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @TA = (SELECT TOP 1 intTaxAuthorityId FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @TACode = (SELECT TOP 1 strTaxAuthority FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DatePeriod = (SELECT TOP 1 dtmDate FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DateBegin = (SELECT TOP 1 dtmReportingPeriodBegin FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DateEnd = (SELECT TOP 1 dtmReportingPeriodEnd FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @LicenseNumber = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE strFormCode = @FormCodeParam AND intTemplateItemId = 'License Number')
SET @EIN = (SELECT TOP 1 strEin FROM tblSMCompanySetup)

-- ======================== HEADER ==============================
INSERT INTO tblTFTaxReportSummary (strSummaryGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strSegment, dtmDateRun, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strTaxPayerName, 
		 	strFEINSSN, strEmail, strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strContactName, strLicenseNumber)

SELECT TOP 1 @Guid, @TA, @FormCodeParam, '', 'Header', @DatePeriod,@DateBegin,@DateEnd, strCompanyName,
				@EIN, strContactEmail, strTaxAddress, strCity, strState, strZipCode, strContactPhone, strContactName, @LicenseNumber from tblTFCompanyPreference

	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intReportTemplateId FROM tblTFTaxReportTemplate WHERE strFormCode = @FormCodeParam AND strSegment = 'Summary'  ORDER BY intReportTemplateId DESC

	SET @TemplateItemCount = (SELECT COUNT(*) FROM @tblTempSummaryItem)


		WHILE(@TemplateItemCount > 0) -- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
		BEGIN
			-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
			SET @ParamId = (SELECT TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @TemplateItemCount)
			SET @ScheduleCode = (SELECT strScheduleCode FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ParamId AND strFormCode = @FormCodeParam)
			SET @TemplateItemId = (SELECT intTemplateItemId FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ParamId AND strFormCode = @FormCodeParam)

			SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')

			IF (@ScheduleCode IS NOT NULL)
			BEGIN

				SET @TemplateDescription = (SELECT strDescription FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ParamId AND strFormCode = @FormCodeParam)
				SET @ReportItemSequence = (SELECT intReportItemSequence FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ParamId AND strFormCode = @FormCodeParam)
				SET @TemplateItemNumber = (SELECT intTemplateItemNumber FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ParamId AND strFormCode = @FormCodeParam)
				SET @ReportSection = (SELECT strReportSection FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ParamId AND strFormCode = @FormCodeParam)
				SET @TemplateConfiguration = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ParamId AND strFormCode = @FormCodeParam)
				-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

				IF @TemplateItemId = 'MF-360-Summary-001'
					BEGIN
					--PRINT @SmryReportingComponentId
						SET @Query = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND strType = ''Gasoline / Aviation Gasoline / Gasohol'' AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
					ELSE IF @TemplateItemId = 'MF-360-Summary-002'
					BEGIN
						DECLARE @E1 NVARCHAR(50)
						SET @E1 = (SELECT SUM(CAST(strConfiguration AS INT)) FROM tblTFTaxReportTemplate WHERE intTemplateItemId IN('MF-360-Summary-024','MF-360-Summary-025'))
						SET @Query = 'SELECT SUM(dblQtyShipped) + ' + @E1 + ' FROM tblTFTransactions WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
					ELSE IF @TemplateItemId = 'MF-360-Summary-003'
					BEGIN
						SET @Query = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND strType=''Gasoline / Aviation Gasoline / Gasohol'' AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-004'
					BEGIN
					--SET @Query = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryReportingComponentId + ''')' 
						SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END

				ELSE IF @TemplateItemId = 'MF-360-Summary-005'
					BEGIN
						SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-006'
					BEGIN
						SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-007'
					BEGIN
						SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-008'
					BEGIN
						SET @Query = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''MF-360-Summary-008'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-009'
					BEGIN
						SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END

				ELSE IF @TemplateItemId = 'MF-360-Summary-010'
					BEGIN
						
						SET @Query = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
					
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-011'
					BEGIN
						SET @Query = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-012'
					BEGIN
						SET @Query = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @ScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-013'
					BEGIN
						SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
		
				ELSE IF @TemplateItemId = 'MF-360-Summary-014'
					BEGIN
						SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-015'
					BEGIN
						SET @Query = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''MF-360-Summary-015'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-016'
					BEGIN
						SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-017'
					BEGIN
						SET @Query = 'SELECT SUM(strColumnValue)  FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END

				ELSE IF @TemplateItemId = 'MF-360-Summary-018'
					BEGIN
						SET @Query = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''MF-360-Summary-018'''    
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-019'
					BEGIN
						SET @Query = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''MF-360-Summary-019'''    
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
				END
				ELSE IF @TemplateItemId = 'MF-360-Summary-020'
					BEGIN
						SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  

						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-021'
					BEGIN
						SET @Query = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''MF-360-Summary-021''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-022'
					BEGIN
						SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @ScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				ELSE IF @TemplateItemId = 'MF-360-Summary-023'
					BEGIN
						SET @Query = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''MF-360-Summary-023'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
				--DETAILS
				ELSE IF @TemplateItemId = 'MF-360-Summary-024'
					BEGIN
						SET @Query = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''MF-360-Summary-023'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@Query)
					END
			

				SET @TempComputedValue = (SELECT ISNULL(dbLColumnValue, 0) FROM @tblTempSummaryTotal)

				--IF (@TempComputedValue IS NOT NULL) -- INSERT COMPUTED VALUES FROM TEMP TOTAL TABLE TO SUMMARY TABLE
				--BEGIN
					INSERT INTO tblTFTaxReportSummary
					(
						 strSummaryGuid,
						 intTaxAuthorityId,
						 strTaxAuthority,
						 strFormCode,
						 strScheduleCode,
						 strSegment,
						 strProductCode,
						 strDescription,
						 strColumnValue,
						 intItemNumber,
						 intItemSequenceNumber,
						 strSection,
						 dtmDateRun
					)		
					VALUES
					(
						 @Guid,
						 (@TA),
						 (@TACode),
						 (@FormCodeParam),
						 (@ScheduleCode),
						 ('Summary'),
						 (''),
						 @TemplateDescription,
						 @TempComputedValue,
						 @TemplateItemNumber,
						 @ReportItemSequence,
						 @ReportSection,
						 (CAST(GETDATE() AS DATE))
					)
				--END
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

	SET @CountItems = (SELECT COUNT(strFormCode) FROM tblTFTaxReportTemplate WHERE strSegment = 'Details' AND strFormCode = @FormCodeParam)

		WHILE(@CountItems > 0)
			BEGIN
				DECLARE @tplScheduleCode NVARCHAR(MAX)
				-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
				SET @tplScheduleCode = (SELECT strScheduleCode FROM tblTFTaxReportTemplate WHERE strSegment = 'Details' and intTemplateItemNumber = @CountItems AND strFormCode = @FormCodeParam)

				-- GET SCHEDULE CODE BY PASSED PARAM
				DECLARE @paramScheduleCode NVARCHAR(MAX)
				SET @paramScheduleCode = (SELECT strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE strTempScheduleCode = @tplScheduleCode)

				IF (@paramScheduleCode = '5' OR @paramScheduleCode = '11' OR @paramScheduleCode = '6D' OR @paramScheduleCode = '6X' OR @paramScheduleCode = '7' OR @paramScheduleCode = '8' OR @paramScheduleCode = '10A' OR @paramScheduleCode = '10B')
					BEGIN
						SET @DetailColumnValue_gas = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @DetailColumnValue_kerosene = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @DetailColumnValue_others = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ItemTotal = (SELECT ISNULL(sum(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN(@paramScheduleCode) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
					END
				ELSE
					BEGIN
						SET @DetailColumnValue_gas = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @DetailColumnValue_kerosene = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @DetailColumnValue_others = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ItemTotal = (SELECT ISNULL(sum(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN(@paramScheduleCode) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
					END
			
					SET @ItemDescription = (SELECT strDescription FROM tblTFTaxReportTemplate WHERE intTemplateItemNumber = @CountItems AND strSegment = 'Details' AND strFormCode = 'MF-360')

					-- ITEMS THAT HAVE MULTIPLE SCHEDULE CODES TO COMPUTE
					DECLARE @SchedQuery NVARCHAR(MAX)
					IF (@CountItems = 8)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 4, 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END

					ELSE IF (@CountItems = 9)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 2, 'Details','K-1/K-2 Kerosene B', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							-- OTHERS
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 3, 'Details','All Other Products C', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 4, 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END
					ELSE IF (@CountItems = 21)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 2, 'Details','K-1/K-2 Kerosene B', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							-- OTHERS
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 3, 'Details','All Other Products C', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', '', 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END
					ELSE IF (@CountItems = 20)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							DECLARE @TOTAL NUMERIC(18,2)
							SET @TOTAL = (SELECT SUM(CONVERT(NUMERIC(18, 2), strConfiguration)) FROM tblTFTaxReportTemplate WHERE strFormCode = @FormCodeParam AND strScheduleCode = 'E-1') + (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@TOTAL, @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 4, 'Details','TOTAL', '',@TOTAL, @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END
					ELSE 
						BEGIN
							-- GAS
							DECLARE @SmryDetailItemId NVARCHAR(MAX)
							SET @SmryDetailItemId = (SELECT intTemplateItemId FROM tblTFTaxReportTemplate WHERE strSegment = 'Details' and intTemplateItemNumber = @CountItems AND strFormCode = @FormCodeParam)
							IF (@tplScheduleCode = 'E-1')
									BEGIN
										INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '', (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = @SmryDetailItemId), @ItemDescription, CAST(GETDATE() AS DATE))
									END
								ELSE
									BEGIN
										INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@DetailColumnValue_gas, @ItemDescription, CAST(GETDATE() AS DATE))
									END
							-- KEROSENE
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 2, 'Details','K-1/K-2 Kerosene B', '',@DetailColumnValue_kerosene, @ItemDescription, CAST(GETDATE() AS DATE))

							-- OTHERS
							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 3, 'Details','All Other Products C', '',@DetailColumnValue_others, @ItemDescription, CAST(GETDATE() AS DATE))

							INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
									VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 4, 'Details','TOTAL', '',@ItemTotal, @ItemDescription, CAST(GETDATE() AS DATE))
						END
				SET @CountItems = @CountItems - 1
			END
			
			DECLARE @isTransactionEmpty NVARCHAR(20)
			SET @isTransactionEmpty = (SELECT TOP 1 strProductCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
			IF(@isTransactionEmpty = 'No record found.')
				BEGIN
					UPDATE tblTFTaxReportSummary SET strColumnValue = 0 WHERE strFormCode = @FormCodeParam
				END

END