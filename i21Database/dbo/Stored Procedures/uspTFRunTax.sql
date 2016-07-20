CREATE PROCEDURE [dbo].[uspTFRunTax]

@Guid NVARCHAR(250),
@ScheduleCodeParam NVARCHAR(250)

AS

DECLARE @TA INT
DECLARE @FormCode NVARCHAR(50)

--SUMMARY VARIABLES
DECLARE @SmrySummaryItems NVARCHAR(MAX)
DECLARE @SmryParamId NVARCHAR(MAX)
DECLARE @SmryFET NVARCHAR(MAX)
DECLARE @SmrySET NVARCHAR(MAX)
DECLARE @SmrySST NVARCHAR(MAX)
DECLARE @SmryScheduleCode NVARCHAR(MAX)
DECLARE @SmrySummaryItemId NVARCHAR(20)
DECLARE @SmryConfigValue NVARCHAR(20)
DECLARE @SmrySummaryDescription NVARCHAR(MAX)
DECLARE @SmrySummaryItemNumber NVARCHAR(MAX)
DECLARE @SmrySummaryItemSequenceNumber NVARCHAR(MAX)
DECLARE @SmrySummarySection NVARCHAR(MAX)
DECLARE @SmryTempTotal NUMERIC(18, 2)
DECLARE @SmrySummaryItemsCount NVARCHAR(MAX) 
DECLARE @SmryQuery NVARCHAR(MAX)
--DETAIL VARIABLES
DECLARE @Kerosene NVARCHAR(MAX)
DECLARE @Others NVARCHAR(MAX)
DECLARE @DetailColumnValue_gas NVARCHAR(MAX)
DECLARE @DetailColumnValue_kerosene NVARCHAR(MAX)
DECLARE @DetailColumnValue_others NVARCHAR(MAX)
DECLARE @SummaryItems NVARCHAR(MAX)
DECLARE @ScheduleCodeCount NUMERIC(18,2)
DECLARE @q NVARCHAR(MAX)

DECLARE @DefaultValue INT = 0

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
DELETE FROM tblTFTaxReportSummary
	-- ======================== HEADER ==============================
DECLARE @DatePeriod DATETIME
DECLARE @DateBegin DATETIME
DECLARE @DateEnd DATETIME

DECLARE @LicenseNumber NVARCHAR(50)
DECLARE @EIN NVARCHAR(50)

SET @FormCode = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @TA = (SELECT TOP 1 intTaxAuthorityId FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @DatePeriod = (SELECT TOP 1 dtmDate FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @DateBegin = (SELECT TOP 1 dtmReportingPeriodBegin FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @DateEnd = (SELECT TOP 1 dtmReportingPeriodEnd FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @LicenseNumber = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND intTaxReportSummaryItemId = 'License Number')
SET @EIN = (SELECT TOP 1 strEin FROM tblSMCompanySetup)

-- ======================== HEADER ==============================
INSERT INTO tblTFTaxReportSummary (uniqGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strTaxType, dtmDateRun, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strTaxPayerName, 
		 	strFEINSSN, strEmail, strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strContactName, strLicenseNumber)

SELECT TOP 1 @Guid, @TA, @FormCode, '', 'Header', @DatePeriod,@DateBegin,@DateEnd, strCompanyName,
				@EIN, strContactEmail, strTaxAddress, strCity, strState, strZipCode, strContactPhone, strContactName, @LicenseNumber from tblTFCompanyPreference

	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intTaxReportSummaryItems FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND strTaxType = 'Summary'  ORDER BY intTaxReportSummaryItems DESC

	SET @SmrySummaryItemsCount = (SELECT COUNT(*) FROM @tblTempSummaryItem)


		WHILE(@SmrySummaryItemsCount > 0) -- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
		BEGIN
			-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
			SET @SmryParamId = (SELECT TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @SmrySummaryItemsCount)
			SET @SmryScheduleCode = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
			SET @SmrySummaryItemId = (SELECT intTaxReportSummaryItemId FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)

			SET @SmryScheduleCode = REPLACE(@SmryScheduleCode,',',''',''')

			IF (@SmryScheduleCode IS NOT NULL)
			BEGIN

				SET @SmrySummaryDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
				SET @SmrySummaryItemSequenceNumber = (SELECT intSummaryItemSequenceNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
				SET @SmrySummaryItemNumber = (SELECT intSummaryItemNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
				SET @SmrySummarySection = (SELECT strSummarySection FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
				SET @SmryConfigValue = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
				-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

				IF @SmrySummaryItemId = 'MF-360-Summary-001'
					BEGIN
					--PRINT @SmryReportingComponentId
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''') AND strType = ''Gasoline / Aviation Gasoline / Gasohol'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmrySummaryItemId = 'MF-360-Summary-002'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmrySummaryItemId = 'MF-360-Summary-003'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''') AND strType=''Gasoline / Aviation Gasoline / Gasohol''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-004'
					BEGIN
					--SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryReportingComponentId + ''')' 
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-005'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-006'
					BEGIN
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-007'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-008'
					BEGIN
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''MF-360-Summary-008'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-009'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-010'
					BEGIN
						
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')' 
					
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-011'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-012'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-013'
					BEGIN
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
		
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-014'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-015'
					BEGIN
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''MF-360-Summary-015'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-016'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-017'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue)  FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-018'
					BEGIN
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''MF-360-Summary-018'''    
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-019'
					BEGIN
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''MF-360-Summary-019'''    
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
				END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-020'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  

						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-021'
					BEGIN
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''MF-360-Summary-021''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-022'
					BEGIN
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-023'
					BEGIN
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''MF-360-Summary-023'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				--DETAILS
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-024'
					BEGIN
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''MF-360-Summary-023'''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
			

				SET @SmryTempTotal = (SELECT ISNULL(dbLColumnValue, 0) FROM @tblTempSummaryTotal)

				--IF (@SmryTempTotal IS NOT NULL) -- INSERT COMPUTED VALUES FROM TEMP TOTAL TABLE TO SUMMARY TABLE
				--BEGIN
					INSERT INTO tblTFTaxReportSummary
					(
						 uniqGuid,
						 intTaxAuthorityId,
						 strFormCode,
						 strScheduleCode,
						 strTaxType,
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
						 (@FormCode),
						 (@SmryScheduleCode),
						 ('Summary'),
						 (''),
						 @SmrySummaryDescription,
						 @SmryTempTotal,
						 @SmrySummaryItemNumber,
						 @SmrySummaryItemSequenceNumber,
						 @SmrySummarySection,
						 (CAST(GETDATE() AS DATE))
					)
				--END
			END

			DELETE FROM @tblTempSummaryTotal
			SET @SmrySummaryItemsCount = @SmrySummaryItemsCount - 1
		END


	-- ======================== DETAIL ==============================
	DECLARE @ItemTotal NVARCHAR(MAX)
	DECLARE @itemQuery NVARCHAR(MAX)
	DECLARE @CountItems INT

	DECLARE @ItemDescription nvarchar(MAX)
	SELECT @q = 'SELECT ''' + REPLACE (@ScheduleCodeParam,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempScheduleCodeParam (strTempScheduleCode)
	EXEC(@q)

	SET @CountItems = (SELECT COUNT(strSummaryFormCode) FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' AND strSummaryFormCode = @FormCode)

		WHILE(@CountItems > 0)
			BEGIN
				DECLARE @tplScheduleCode NVARCHAR(MAX)
				-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
				SET @tplScheduleCode = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' and intSummaryItemNumber = @CountItems AND strSummaryFormCode = @FormCode)

				-- GET SCHEDULE CODE BY PASSED PARAM
				DECLARE @paramScheduleCode NVARCHAR(MAX)
				SET @paramScheduleCode = (SELECT strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE strTempScheduleCode = @tplScheduleCode)

				IF (@paramScheduleCode = '5' OR @paramScheduleCode = '11' OR @paramScheduleCode = '6D' OR @paramScheduleCode = '6X' OR @paramScheduleCode = '7' OR @paramScheduleCode = '8' OR @paramScheduleCode = '10A' OR @paramScheduleCode = '10B')
					BEGIN
						SET @DetailColumnValue_gas = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid)
						SET @DetailColumnValue_kerosene = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid)
						SET @DetailColumnValue_others = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid)
						SET @ItemTotal = (SELECT ISNULL(sum(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN(@paramScheduleCode))
					END
				ELSE
					BEGIN
						SET @DetailColumnValue_gas = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid)
						SET @DetailColumnValue_kerosene = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid)
						SET @DetailColumnValue_others = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid)
						SET @ItemTotal = (SELECT ISNULL(sum(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN(@paramScheduleCode) AND uniqTransactionGuid = @Guid)
					END
			
					SET @ItemDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE intSummaryItemNumber = @CountItems AND strTaxType = 'Details' AND strSummaryFormCode = 'MF-360')

					-- ITEMS THAT HAVE MULTIPLE SCHEDULE CODES TO COMPUTE
					DECLARE @SchedQuery NVARCHAR(MAX)
					IF (@CountItems = 8)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 4, 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END

					ELSE IF (@CountItems = 9)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 2, 'Details','K-1/K-2 Kerosene B', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							-- OTHERS
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 3, 'Details','All Other Products C', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 4, 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END
					ELSE IF (@CountItems = 21)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 2, 'Details','K-1/K-2 Kerosene B', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'K-1 / K-2 Kerosene' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							-- OTHERS
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 3, 'Details','All Other Products C', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'All Other Products' AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', '', 'Details','TOTAL', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND uniqTransactionGuid = @Guid), @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END
					ELSE IF (@CountItems = 20)
						BEGIN
							SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
							INSERT INTO @tblSchedule (strSchedule)
							EXEC(@SchedQuery)
							DECLARE @TOTAL NUMERIC(18,2)
							SET @TOTAL = (SELECT SUM(CONVERT(NUMERIC(18, 2), strConfiguration)) FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND strSummaryScheduleCode = 'E-1') + (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Aviation Gasoline / Gasohol' AND uniqTransactionGuid = @Guid)
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@TOTAL, @ItemDescription, CAST(GETDATE() AS DATE))
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'', 4, 'Details','TOTAL', '',@TOTAL, @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblSchedule
						END
					ELSE 
						BEGIN
							-- GAS
							DECLARE @SmryDetailItemId NVARCHAR(MAX)
							SET @SmryDetailItemId = (SELECT intTaxReportSummaryItemId FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' and intSummaryItemNumber = @CountItems AND strSummaryFormCode = @FormCode)
							IF (@tplScheduleCode = 'E-1')
									BEGIN
										INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '', (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = @SmryDetailItemId), @ItemDescription, CAST(GETDATE() AS DATE))
									END
								ELSE
									BEGIN
										INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@DetailColumnValue_gas, @ItemDescription, CAST(GETDATE() AS DATE))
									END
							-- KEROSENE
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 2, 'Details','K-1/K-2 Kerosene B', '',@DetailColumnValue_kerosene, @ItemDescription, CAST(GETDATE() AS DATE))

							-- OTHERS
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 3, 'Details','All Other Products C', '',@DetailColumnValue_others, @ItemDescription, CAST(GETDATE() AS DATE))

							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
									VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 4, 'Details','TOTAL', '',@ItemTotal, @ItemDescription, CAST(GETDATE() AS DATE))
						END
				SET @CountItems = @CountItems - 1
			END