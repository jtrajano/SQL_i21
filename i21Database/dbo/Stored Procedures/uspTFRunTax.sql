CREATE PROCEDURE [dbo].[uspTFRunTax]

--@dtmStartDate DATETIME,
--@dtmEndDate DATETIME,

@Guid UNIQUEIDENTIFIER,
@TA INT,
@FormCode NVARCHAR(50),
@ScheduleCode NVARCHAR(50)

AS
--SUMMARY COUNTING SELF PARAMETERS
--DECLARE @paramSummaryLineItem NVARCHAR(max)
--DECLARE @summaryLineItem NVARCHAR(max)
--SUMMARY VARIABLES
DECLARE @SmrySummaryItems NVARCHAR(max)
DECLARE @SmryParamId NVARCHAR(MAX)
DECLARE @SmryFET NVARCHAR(MAX)
DECLARE @SmrySET NVARCHAR(MAX)
DECLARE @SmrySST NVARCHAR(MAX)
DECLARE @SmryScheduleCodeParam NVARCHAR(MAX)
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
DECLARE @paramSplitted NVARCHAR(MAX)
DECLARE @paramId NVARCHAR(MAX)
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
delete from tblTFTaxReportSummary
	-- ======================== HEADER ==============================
	INSERT INTO tblTFTaxReportSummary (uniqGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strTaxType, dtmDateRun, strTaxPayerName,
			strLicenseNumber, strEmail, strFEINSSN, strCity, strState, strZipCode, strTelephoneNumber, strContactName)		
		    VALUES(@Guid, @TA, @FormCode, @ScheduleCode, 'Header', (CAST(GETDATE() AS DATE)),
				(SELECT top 1 strTaxPayerName FROM tblTFTransactions),
				(SELECT top 1 strLicenseNumber FROM tblTFTransactions),
				(SELECT top 1 strEmail FROM tblTFTransactions),
				(SELECT top 1 strFEINSSN FROM tblTFTransactions),
				(SELECT top 1 strCity FROM tblTFTransactions),
				(SELECT top 1 strState FROM tblTFTransactions),
				(SELECT top 1 strZipCode FROM tblTFTransactions),
				(SELECT top 1 strTelephoneNumber FROM tblTFTransactions),
				(SELECT top 1 strContactName FROM tblTFTransactions)
		   )

	-- ======================== SUMMARY ==============================
	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intTaxReportSummaryItems FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND intSummaryTaxAuthorityId = @TA AND strTaxType = 'Summary'  ORDER BY intTaxReportSummaryItems DESC
	SET @SmrySummaryItemsCount = (SELECT count(*) FROM @tblTempSummaryItem)


	DECLARE @query NVARCHAR(MAX)
	DECLARE @paramSplit NVARCHAR(MAX)
	DECLARE @param NVARCHAR(MAX)
	DECLARE @ScheduleCodeParam NVARCHAR(max) = ''

	DECLARE @tblTempSchedCodeParam TABLE(
			Id INT IDENTITY(1,1),
			strTempScheduleCode NVARCHAR(120))

	SELECT @query = 'SELECT ''' + REPLACE (@ScheduleCode,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempSchedCodeParam (strTempScheduleCode)
	EXEC(@query)
	SET @paramSplit = (SELECT COUNT(strTempScheduleCode) FROM @tblTempSchedCodeParam)

	DECLARE @count int
	DECLARE @val NVARCHAR(MAX) = ''
	SET @count = (SELECT COUNT(strTempScheduleCode) FROM @tblTempSchedCodeParam)
 
		WHILE(@paramSplit > 0)
		BEGIN
		
			SET @param = (SELECT strTempScheduleCode FROM @tblTempSchedCodeParam WHERE Id = @paramSplit)

			
			SET @ScheduleCodeParam += '''' + @param + ''','

				if (@paramSplit < @count - 1)
				begin
				    set @ScheduleCodeParam = (select substring(@ScheduleCodeParam, 1, len(@ScheduleCodeParam) -1))
					set @ScheduleCodeParam = '' + @ScheduleCodeParam + '' 
					
				end
		
			SET @paramSplit = @paramSplit - 1
		END
		

		WHILE(@SmrySummaryItemsCount > 0) -- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
		BEGIN
			-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
			SET @SmryParamId = (SELECT TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @SmrySummaryItemsCount)
			SET @SmryScheduleCodeParam = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
			SET @SmrySummaryItemId = (SELECT intTaxReportSummaryItemId FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)

			SET @SmryScheduleCodeParam = REPLACE(@SmryScheduleCodeParam,',',''',''')
			--SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
			--SET @paramSummaryLineItem = REPLACE(@summaryLineItem,',',''',''')

			-- END GET SCHEDULE CODE PARAMETERS FOR FILTERING
			--DECLARE @Item4Id INT
			--	SET @Item4Id = (SELECT TOP 1 intTaxReportSummaryItems FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND strSummaryTaxAuthority = @TA AND strTaxType = 'Summary' AND strSummarySection = 2 AND intSummaryItemNumber = 4)


			IF (@SmryScheduleCodeParam IS NOT NULL)
			BEGIN

				SET @SmrySummaryDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmrySummaryItemSequenceNumber = (SELECT intSummaryItemSequenceNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmrySummaryItemNumber = (SELECT intSummaryItemNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmrySummarySection = (SELECT strSummarySection FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				SET @SmryConfigValue = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId)
				-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

				IF @SmrySummaryItemId = 'MF-360-Summary-001'
					BEGIN
					print @SmryScheduleCodeParam
					print @ScheduleCode
					SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
						SET @SmryQuery = 'SELECT sum(pxrpt_sls_trans_gals) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') AND strScheduleCode IN (''' + @ScheduleCode + ''')'  
					SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmrySummaryItemId = 'MF-360-Summary-002'
					BEGIN
						SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
						SET @SmryQuery = 'SELECT SUM(pxrpt_sls_trans_gals) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') AND strScheduleCode IN (''' + @ScheduleCode + ''')'  
						SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmrySummaryItemId = 'MF-360-Summary-003'
					BEGIN
						SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
						SET @SmryQuery = 'SELECT SUM(pxrpt_sls_trans_gals) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') and strType = ''Gasoline'' AND strScheduleCode IN (''' + @ScheduleCode + ''')' 
						SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-004'
					BEGIN
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE strSection = ''Section 2:    Calculation of Gasoline Taxes Due'' AND b.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
		
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-005'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE strSection = ''Section 2:    Calculation of Gasoline Taxes Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-006'
					BEGIN
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE strSection = ''Section 2:    Calculation of Gasoline Taxes Due'' AND b.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-007'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE strSection = ''Section 2:    Calculation of Gasoline Taxes Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-008'
					BEGIN
						SET @SmryQuery = 'SELECT top 1 strColumnValue FROM tblTFTaxReportSummary WHERE strSection = ''Section 2:    Calculation of Gasoline Taxes Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-009'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE strSection = ''Section 2:    Calculation of Gasoline Taxes Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-010'
					BEGIN
						SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
						SET @SmryQuery = 'SELECT SUM(pxrpt_sls_trans_gals) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') AND strScheduleCode IN (''' + @ScheduleCode + ''')' 
						SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-011'
					BEGIN
						SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
						SET @SmryQuery = 'SELECT SUM(pxrpt_sls_trans_gals) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') AND strScheduleCode IN (''' + @ScheduleCode + ''')' 
						SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-012'
					BEGIN
						SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
						SET @SmryQuery = 'SELECT SUM(pxrpt_sls_trans_gals) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') AND strScheduleCode IN (''' + @ScheduleCode + ''')'  
						SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-013'
					BEGIN
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE strSection = ''Section 3:    Calculation of Oil Inspection Fees Due'' AND  b.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
		
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-014'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE strSection = ''Section 3:    Calculation of Oil Inspection Fees Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-015'
					BEGIN
						SET @SmryQuery = 'SELECT strColumnValue FROM tblTFTaxReportSummary WHERE strSection = ''Section 3:    Calculation of Oil Inspection Fees Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-016'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE strSection = ''Section 3:    Calculation of Oil Inspection Fees Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-017'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue)  FROM tblTFTaxReportSummary WHERE strSection IN(''Section 2:    Calculation of Gasoline Taxes Due'', ''Section 3:    Calculation of Oil Inspection Fees Due'') and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				--ELSE IF @SmrySummaryItemId = 'MF-360-Summary-018'
				--	BEGIN
				--		SET @SmryQuery = 'SELECT strColumnValue  FROM tblTFTaxReportSummary WHERE strSection = ''Section 3:    Calculation of Oil Inspection Fees Due'' and intItemSequenceNumber IN (''' + @SmryScheduleCodeParam + ''')'  
				--		INSERT INTO @tblTempSummaryTotal
				--		EXEC(@SmryQuery)
				--	END

				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-020'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE strSection = ''Section 4:    Calculation of Total Amount Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  

						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'MF-360-Summary-022'
					BEGIN
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE strSection = ''Section 4:    Calculation of Total Amount Due'' and intItemNumber IN (''' + @SmryScheduleCodeParam + ''')'  

						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				
				--ELSE
				--	BEGIN
				--		SET @SmryQuery = 'SELECT sum(pxrpt_sls_trans_gals) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''')'
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
						 (@SmryScheduleCodeParam),
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
	declare @ItemTotal nvarchar(max)
	declare @itemQuery NVARCHAR(max)
	declare @CountItems INT

	declare @ItemDescription nvarchar(max)
	SELECT @q = 'SELECT ''' + REPLACE (@ScheduleCode,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempScheduleCodeParam (strTempScheduleCode)
	EXEC(@q)

	SET @CountItems = (SELECT count(strSummaryFormCode) FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details')


	--SET @paramSplitted = (SELECT COUNT(strTempScheduleCode) FROM @tblTempScheduleCodeParam)
 
		WHILE(@CountItems > 0)
		BEGIN

			

			--SET @paramId = (SELECT strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE Id = @paramSplitted)
			SET @paramId = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' and intSummaryItemNumber = @CountItems)

			declare @schedParamId nvarchar(MAX)
			set @schedParamId = (select strTempScheduleCode from @tblTempScheduleCodeParam where strTempScheduleCode = @paramId)
		

			
			SET @DetailColumnValue_gas = (SELECT ISNULL(sum(pxrpt_sls_trans_gals), 0) AS 'FET' FROM tblTFTransactions where strScheduleCode = @schedParamId AND strType = 'Gasoline')
			SET @DetailColumnValue_kerosene = (SELECT ISNULL(sum(pxrpt_sls_trans_gals), 0) AS 'FET' FROM tblTFTransactions where strScheduleCode = @schedParamId AND strType = 'Kerosene')
			SET @DetailColumnValue_others = (SELECT ISNULL(sum(pxrpt_sls_trans_gals), 0) AS 'FET' FROM tblTFTransactions where strScheduleCode = @schedParamId AND strType = 'Others')
			--SET @ScheduleCodeCount = (SELECT sum(pxrpt_sls_trans_gals) FROM tblTFTransactions where strScheduleCode = @paramId and strFormCode = @FormCode)
			SET @ItemTotal = (SELECT ISNULL(sum(pxrpt_sls_trans_gals), 0) FROM tblTFTransactions where strScheduleCode IN(@schedParamId))
			
			--IF (@ScheduleCodeCount > 0)
			--BEGIN
				-- GAS
				set @ItemDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate where intSummaryItemNumber = @CountItems AND strTaxType = 'Details')
				
				if (@CountItems = 8 OR @CountItems = 9 OR @CountItems = 20 OR @CountItems = 21)
				begin
					SET @paramId = REPLACE(@paramId,',',''',''')
					SET @ScheduleCode = REPLACE(@ScheduleCode,',',''',''')
					print @ScheduleCode
					SET @itemQuery = 'SELECT ISNULL(sum(pxrpt_sls_trans_gals), 0) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @paramId + ''') AND strScheduleCode IN (''' + @ScheduleCode + ''')'  
					SET @ScheduleCode = REPLACE(@ScheduleCode,''',''',',')
	
					INSERT INTO @tblTempSummaryTotal
					EXEC(@itemQuery)
			

					INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode,strScheduleCode,strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
					VALUES(@Guid,@TA,@FormCode,'','Details','TOTAL', '',(select ISNULL(dbLColumnValue, 0) from @tblTempSummaryTotal), @ItemDescription, CAST(GETDATE() AS DATE))
				    delete from @tblTempSummaryTotal
				end
				else 
				begin
					-- GAS
					INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
					VALUES(@Guid,@TA,@FormCode,@paramId, 1, 'Details','Gasoline / Aviation Gasoline / Gasohol A', '',@DetailColumnValue_gas, @ItemDescription, CAST(GETDATE() AS DATE))

					-- KEROSENE
					INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
					VALUES(@Guid,@TA,@FormCode,@paramId, 2, 'Details','K-1/K-2 Kerosene B', '',@DetailColumnValue_kerosene, @ItemDescription, CAST(GETDATE() AS DATE))

					-- OTHERS
					INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
					VALUES(@Guid,@TA,@FormCode,@paramId, 3, 'Details','All Other Products C', '',@DetailColumnValue_others, @ItemDescription, CAST(GETDATE() AS DATE))

					-- TOTAL
					INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
					VALUES(@Guid,@TA,@FormCode,@paramId, 4, 'Details','TOTAL', '',@ItemTotal, @ItemDescription, CAST(GETDATE() AS DATE))

				end
			
			SET @CountItems = @CountItems - 1 

		END
