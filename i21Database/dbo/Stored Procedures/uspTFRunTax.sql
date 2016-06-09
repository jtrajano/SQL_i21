CREATE PROCEDURE [dbo].[uspTFRunTax]

@Guid UNIQUEIDENTIFIER,
@ScheduleCode NVARCHAR(250)

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
DECLARE @SmryTempTotal INT
DECLARE @SmrySummaryItemsCount NVARCHAR(MAX) 
DECLARE @SmryQuery NVARCHAR(MAX)
--DETAIL VARIABLES
DECLARE @Kerosene NVARCHAR(MAX)
DECLARE @Others NVARCHAR(MAX)
DECLARE @DetailColumnValue_gas NVARCHAR(MAX)
DECLARE @DetailColumnValue_kerosene NVARCHAR(MAX)
DECLARE @DetailColumnValue_others NVARCHAR(MAX)
DECLARE @SummaryItems NVARCHAR(MAX)
DECLARE @ScheduleCodeCount int
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
DELETE FROM tblTFTaxReportSummary
	-- ======================== HEADER ==============================
INSERT INTO tblTFTaxReportSummary (uniqGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strTaxType, dtmDateRun, strTaxPayerName,
			strLicenseNumber, strEmail, strFEINSSN, strCity, strState, strZipCode, strTelephoneNumber, strContactName)

			SELECT DISTINCT @Guid, intTaxAuthorityId, strFormCode, '', '', dtmDate, strTaxPayerName, 
					strLicenseNumber, strEmail, strFEINSSN, strCity, strState, strZipCode, strTelephoneNumber, strContactName from tblTFTransactions

	-- ======================== SUMMARY ==============================

	SET @FormCode = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TA = (SELECT TOP 1 intTaxAuthorityId FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)

	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intTaxReportSummaryItems FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND strTaxType = 'Summary'  ORDER BY intTaxReportSummaryItems DESC

	SET @SmrySummaryItemsCount = (SELECT COUNT(*) FROM @tblTempSummaryItem)


		WHILE(@SmrySummaryItemsCount > 0) -- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
		BEGIN
			-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
			SET @SmryParamId = (SELECT TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @SmrySummaryItemsCount)
			SET @SmryScheduleCode = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
			SET @SmrySummaryItemId = (SELECT intTaxReportSummaryItemId FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)

			SET @SmryScheduleCode = REPLACE(@SmryScheduleCode,',',''',''')

			IF (@SmryScheduleCode IS NOT NULL)
			BEGIN

				SET @SmrySummaryDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmrySummaryItemSequenceNumber = (SELECT intSummaryItemSequenceNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmrySummaryItemNumber = (SELECT intSummaryItemNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmrySummarySection = (SELECT strSummarySection FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmryConfigValue = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

				IF @SmrySummaryItemId = 'MF-360-Summary-001'
					BEGIN
					--PRINT @SmryReportingComponentId
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmrySummaryItemId = 'MF-360-Summary-002'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmrySummaryItemId = 'MF-360-Summary-003'
					BEGIN
						SET @SmryQuery = 'SELECT dblGross FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')' 
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
						--SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE strSection = ''Section 2:    Calculation of Gasoline Taxes Due'' and intItemNumber IN (''' + @SmryReportingComponentId + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-008'
					BEGIN
						SET @SmryQuery = 'SELECT top 1 strColumnValue FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
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
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')' 
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
						--SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE strSection = ''Section 3:    Calculation of Oil Inspection Fees Due'' and intItemNumber IN (''' + @SmryReportingComponentId + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-015'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
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

				--ELSE IF @SmrySummaryItemId = 'MF-360-Summary-018'
				--	BEGIN
				--		SET @SmryQuery = 'SELECT strColumnValue  FROM tblTFTaxReportSummary WHERE strSection = ''Section 3:    Calculation of Oil Inspection Fees Due'' and intItemSequenceNumber IN (''' + @SmryReportingComponentId + ''')'  
				--		INSERT INTO @tblTempSummaryTotal
				--		EXEC(@SmryQuery)
				--	END

				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-020'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  

						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-022'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  

						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				
				--ELSE
				--	BEGIN
				--		SET @SmryQuery = 'SELECT sum(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryReportingComponentId + ''')'
				--		INSERT INTO @tblTempSummaryTotal
				--		EXEC(@SmryQuery)
				--	END
			

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
	SELECT @q = 'SELECT ''' + REPLACE (@ScheduleCode,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempScheduleCodeParam (strTempScheduleCode)
	EXEC(@q)

	SET @CountItems = (SELECT COUNT(strSummaryFormCode) FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details')

		WHILE(@CountItems > 0)
			BEGIN
				DECLARE @tplScheduleCode NVARCHAR(MAX)
				-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
				SET @tplScheduleCode = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' and intSummaryItemNumber = @CountItems)

				-- GET SCHEDULE CODE BY PASSED PARAM
				DECLARE @paramScheduleCode NVARCHAR(MAX)
				SET @paramScheduleCode = (SELECT strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE strTempScheduleCode = @tplScheduleCode)
			
				SET @DetailColumnValue_gas = (SELECT ISNULL(SUM(dblGross), 0) AS 'FET' FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Aviation Gasoline / Gasohol')
				SET @DetailColumnValue_kerosene = (SELECT ISNULL(SUM(dblGross), 0) AS 'FET' FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'K-1 / K-2 Kerosene')
				SET @DetailColumnValue_others = (SELECT ISNULL(SUM(dblGross), 0) AS 'FET' FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'All Other Products')
				SET @ItemTotal = (SELECT ISNULL(sum(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN(@paramScheduleCode))
			
				--IF (@ScheduleCodeCount > 0)
				--BEGIN
					PRINT @TA
					SET @ItemDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE intSummaryItemNumber = @CountItems AND strTaxType = 'Details')

					-- ITEMS THAT HAVE MULTIPLE SCHEDULE CODES TO COMPUTE
					IF (@CountItems = 8 OR @CountItems = 9 OR @CountItems = 20 OR @CountItems = 21)
						BEGIN
							SET @tplScheduleCode = REPLACE(@tplScheduleCode,',',''',''')
							SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
					
							SET @itemQuery = 'SELECT ISNULL(sum(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @tplScheduleCode + ''') AND strScheduleCode IN (''' + @ScheduleCode + ''')'  
							SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
	
							INSERT INTO @tblTempSummaryTotal
							EXEC(@itemQuery)
			
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode,strScheduleCode,strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,'','Details','TOTAL', '',(SELECT ISNULL(dbLColumnValue, 0) FROM @tblTempSummaryTotal), @ItemDescription, CAST(GETDATE() AS DATE))
							DELETE FROM @tblTempSummaryTotal
						END
					ELSE 
						BEGIN
							-- GAS
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@DetailColumnValue_gas, @ItemDescription, CAST(GETDATE() AS DATE))

							-- KEROSENE
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 2, 'Details','K-1/K-2 Kerosene B', '',@DetailColumnValue_kerosene, @ItemDescription, CAST(GETDATE() AS DATE))

							-- OTHERS
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 3, 'Details','All Other Products C', '',@DetailColumnValue_others, @ItemDescription, CAST(GETDATE() AS DATE))

							-- TOTAL
							INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
							VALUES(@Guid,@TA,@FormCode,@tplScheduleCode, 4, 'Details','TOTAL', '',@ItemTotal, @ItemDescription, CAST(GETDATE() AS DATE))
						END
				SET @CountItems = @CountItems - 1 
			END


			--EXEC uspTFRunTax '66f6568c-a9cd-487b-ba80-e59876eb683f', ''