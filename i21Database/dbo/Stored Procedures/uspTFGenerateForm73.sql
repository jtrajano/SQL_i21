CREATE PROCEDURE [dbo].[uspTFGenerateForm73]
	@Guid NVARCHAR(50),
	@FormCodeParam NVARCHAR(MAX),
	@ScheduleCodeParam NVARCHAR(MAX),
	@Refresh BIT
AS

DECLARE @TFTransactionSummaryItem TFTransactionSummaryItem

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

DECLARE @QueryScheduleCodeParam NVARCHAR(MAX)
--DETAIL VARIABLES
DECLARE @ColumnA NVARCHAR(MAX)
DECLARE @ColumnB NVARCHAR(MAX)
DECLARE @ColumnC NVARCHAR(MAX)
DECLARE @ColumnD NVARCHAR(MAX)
DECLARE @ColumnE NVARCHAR(MAX)
DECLARE @ColumnF NVARCHAR(MAX)
DECLARE @ColumnG NVARCHAR(MAX)
DECLARE @ColumnH NVARCHAR(MAX)

DECLARE @TFScheduleCodeParam TFScheduleCodeParam

DECLARE @tblSchedule TABLE (
		intId INT IDENTITY(1,1),
		strSchedule NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		)
IF @Refresh = 1
		BEGIN
			DELETE FROM tblTFTransactionSummary
		END
-- ======================== HEADER ==============================
DECLARE @DatePeriod DATETIME
DECLARE @DateBegin DATETIME
DECLARE @DateEnd DATETIME

DECLARE @NEIdNumber NVARCHAR(50)
DECLARE @EIN NVARCHAR(50)
DECLARE @FaxNumber NVARCHAR(50)

SELECT TOP 1 @TA = intTaxAuthorityId, 
			 @TACode = strTaxAuthorityCode,
			 @DatePeriod = dtmReportingPeriodBegin,
			 @DateBegin = dtmReportingPeriodBegin,
			 @DateEnd = dtmReportingPeriodEnd
		FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam

SET @NEIdNumber = (SELECT strConfiguration FROM tblTFReportingComponentConfiguration RCC 
					  INNER JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCC.intReportingComponentId
					  WHERE RC.strFormCode = @FormCodeParam 
					  AND RCC.strTemplateItemId = 'Form-73-Header-NEIdNumber')

SELECT TOP 1 @EIN = strEin, 
			@FaxNumber = strFax 
	   FROM tblSMCompanySetup

--======================== HEADER ==============================
	INSERT INTO tblTFTransactionSummary (strSummaryGuid, 
		   intTaxAuthorityId, 
		   strFormCode, 
		   strScheduleCode, 
		   strSegment, 
		   dtmDateRun, 
		   dtmReportingPeriodBegin, 
		   dtmReportingPeriodEnd, 
		   strTaxPayerName, 
		   strTaxPayerFEIN, 
		   strEmail, 
		   strTaxPayerAddress, 
		   strCity, 
		   strState, 
		   strZipCode, 
		   strTelephoneNumber, 
		   strContactName, 
		   strTaxPayerIdentificationNumber, 
		   strFaxNumber)
	SELECT TOP 1 @Guid, 
		   @TA, 
		   @FormCodeParam, 
		   '', 
		   'Header', 
		   @DatePeriod,
		   @DateBegin,
		   @DateEnd, 
		   strCompanyName,
		   @EIN, 
		   strContactEmail, 
		   strTaxAddress, 
		   strCity, 
		   strState, 
		   strZipCode, 
		   strContactPhone, 
		   strContactName, 
		   @NEIdNumber, 
		   @FaxNumber 
	FROM tblTFCompanyPreference


	--INSERT INTO @TFTransactionSummaryItem (intTransactionSummaryItemId)  -- GET RC Config items BY FORM and insert into temp table

	--SELECT RCC.intReportingComponentConfigurationId
	--FROM tblTFReportingComponentConfiguration RCC INNER JOIN tblTFReportingComponent RC 
	--ON RC.intReportingComponentId = RCC.intReportingComponentId
	--WHERE RC.strFormCode = @FormCodeParam 
	--AND RCC.strSegment = 'Summary'
	--ORDER BY RCC.intReportingComponentConfigurationId DESC



	-- ======================== DETAIL ==============================
	DECLARE @ItemTotal NVARCHAR(MAX)
	DECLARE @itemQuery NVARCHAR(MAX)
	DECLARE @CountItems INT
	DECLARE @IncludeScheduleCode NVARCHAR(5) 

	DECLARE @ItemId NVARCHAR(50)
	DECLARE @ItemDescription NVARCHAR(MAX)
	SELECT @QueryScheduleCodeParam = 'SELECT ''' + REPLACE (@ScheduleCodeParam,',',''' UNION SELECT ''') + ''''
	INSERT INTO @TFScheduleCodeParam (strTempScheduleCode)
	EXEC(@QueryScheduleCodeParam)

	INSERT INTO @TFTransactionSummaryItem (strTemplateItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
		SELECT strTemplateItemId 
		FROM tblTFReportingComponentConfiguration config
			INNER JOIN tblTFReportingComponent rc 
			ON config.intReportingComponentId = rc.intReportingComponentId
			WHERE rc.strFormCode = @FormCodeParam 
			AND config.strSegment = 'Details' 
			ORDER BY config.intReportingComponentConfigurationId DESC

		SET @TemplateItemCount = (SELECT COUNT(strTemplateItemId) FROM @TFTransactionSummaryItem)

		WHILE(@TemplateItemCount > 0)
			BEGIN
				DECLARE @configScheduleCode NVARCHAR(MAX)
				DECLARE @SchedQuery NVARCHAR(MAX)

				DECLARE @Line19Total NUMERIC(18, 2)
				DECLARE @Line15ColumnE NUMERIC(18, 2)
				DECLARE @Line15ColumnG NUMERIC(18, 2)
				DECLARE @Line22Total NUMERIC(18, 2)
				DECLARE @Line23Total NUMERIC(18, 2)

				SELECT @TemplateItemId = strTemplateItemId FROM @TFTransactionSummaryItem WHERE intId = @TemplateItemCount

				-- GET SCHEDULE CODES BY COUNT ID FROM (RC CONFIG)
				SELECT @configScheduleCode = strScheduleCode, 
						@ItemId = strTemplateItemId,
						@TemplateItemNumber = intTemplateItemNumber,
						@ItemDescription = strDescription
				 FROM vyuTFGetReportingComponentConfiguration
				 WHERE strFormCode = @FormCodeParam 
				 AND strSegment = 'Details' 
				 AND strTemplateItemId = @TemplateItemId
				 order by intReportingComponentConfigurationId Desc

				---- GET SCHEDULE CODE BY PASSED PARAM
				DECLARE @paramScheduleCode NVARCHAR(MAX)
				SET @paramScheduleCode = (SELECT strTempScheduleCode 
										  FROM @TFScheduleCodeParam 
										  WHERE strTempScheduleCode = @configScheduleCode)

				--INSERT SCHEDULE (RC CONFIG) INTO TEMP TABLE @tblSchedule 
				SELECT @SchedQuery = 'SELECT ''' + REPLACE (@configScheduleCode,',',''' UNION SELECT ''') + ''''
				
				IF (@ItemId = 'Form-73-Details-001')
					BEGIN
							SET @ColumnA = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Gasohol / Ethanol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
							SET @ColumnB = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Undyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
							SET @ColumnC = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Dyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
							--================================RC CONFIG
							SET @ColumnD = '0.00'
							SET @ColumnE = '0.00'
							SET @ColumnF = '0.00'
							--================================RC CONFIG END
							SET @ColumnG = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Aviation Gasoline' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
							SET @ColumnH = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Aviation Jet Fuel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
					END
				IF (@ItemId = 'Form-73-Details-002')
					BEGIN
						SET @ColumnA = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline / Gasohol / Ethanol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnB = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Undyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnC = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Dyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
							--================================RC CONFIG
						SET @ColumnD = '0.00'
						SET @ColumnE = '0.00'
						SET @ColumnF = '0.00'
							--================================RC CONFIG END
						SET @ColumnG = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Aviation Gasoline' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnH = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = @paramScheduleCode AND strType = 'Aviation Jet Fuel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
					
					END
				IF (@ItemId = 'Form-73-Details-002')
					BEGIN
					INSERT INTO @tblSchedule (strSchedule)
					EXEC(@SchedQuery)
						SET @ColumnA = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Gasohol / Ethanol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnB = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Undyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnC = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Dyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						--================================RC CONFIG
						SET @ColumnD = '0.00'
						SET @ColumnE = '0.00'
						SET @ColumnF = '0.00'
						--================================RC CONFIG END
						SET @ColumnG = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Aviation Gasoline' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnH = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Aviation Jet Fuel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						DELETE FROM @tblSchedule
					END
				ELSE IF (@ItemId = 'Form-73-Details-003')
					BEGIN
						SET @ColumnA = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '5' AND strType = 'Gasoline / Gasohol / Ethanol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnB = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '5' AND strType = 'Undyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnD = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '5' AND strType = 'Undyed or Dyed Kerosene' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnG = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '5' AND strType = 'Aviation Gasoline' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnH = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '5' AND strType = 'Aviation Jet Fuel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
					END
				ELSE IF (@ItemId = 'Form-73-Details-004')
					BEGIN
						SET @ColumnD = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
										WHERE strTemplateItemId = 'Form-73-Config-001' AND strSegment = 'Configuration' AND strScheduleCode = 'D')
						SET @ColumnE = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
										WHERE strTemplateItemId = 'Form-73-Config-002' AND strSegment = 'Configuration' AND strScheduleCode = 'E')
						SET @ColumnF = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
										WHERE strTemplateItemId = 'Form-73-Config-003' AND strSegment = 'Configuration' AND strScheduleCode = 'F')
					END
				ELSE IF (@ItemId = 'Form-73-Details-005')
					BEGIN
						SET @ColumnB = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
										WHERE strTemplateItemId = 'Form-73-Config-004' AND strSegment = 'Configuration' AND strScheduleCode = 'B')
						SET @ColumnD = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
										WHERE strTemplateItemId = 'Form-73-Config-005' AND strSegment = 'Configuration' AND strScheduleCode = 'D')
					END
				ELSE IF (@ItemId = 'Form-73-Details-006')
					BEGIN
					--SET @IncludeScheduleCode = (SELECT TOP 1 strTempScheduleCode FROM @TFScheduleCodeParam WHERE strTempScheduleCode IN('6','7','8'))
						--IF(@IncludeScheduleCode IS NOT NULL)
						--	BEGIN
								INSERT INTO @tblSchedule (strSchedule)
								EXEC(@SchedQuery)

								SET @ColumnA = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction 
								WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) 
								AND strType = 'Gasoline / Gasohol / Ethanol' 
								AND uniqTransactionGuid = @Guid 
								AND strFormCode = @FormCodeParam)

								SET @ColumnB = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction 
								WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) 
								AND strType = 'Undyed Diesel / Biodiesel' 
								AND uniqTransactionGuid = @Guid 
								AND strFormCode = @FormCodeParam)
								
								SET @ColumnC = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction 
								WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) 
								AND strType = 'Dyed Diesel / Biodiesel' 
								AND uniqTransactionGuid = @Guid 
								AND strFormCode = @FormCodeParam)
								--================================RC CONFIG
								SET @ColumnD = '0.00'
								SET @ColumnE = '0.00'
								SET @ColumnF = '0.00'
								--================================RC CONFIG END
								SET @ColumnG = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction 
								WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) 
								AND strType = 'Aviation Gasoline' AND uniqTransactionGuid = @Guid 
								AND strFormCode = @FormCodeParam)

								SET @ColumnH = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction 
								WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) 
								AND strType = 'Aviation Jet Fuel' AND uniqTransactionGuid = @Guid 
								AND strFormCode = @FormCodeParam)

								DELETE FROM @tblSchedule
							--END
					
					END
				ELSE IF (@ItemId = 'Form-73-Details-007')
					BEGIN
						SET @ColumnA = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '10' AND strType = 'Gasoline / Gasohol / Ethanol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnB = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '10' AND strType = 'Undyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnC = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '10' AND strType = 'Dyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						--================================RC CONFIG
						SET @ColumnD = '0.00'
						SET @ColumnE = '0.00'
						SET @ColumnF = '0.00'
						--================================RC CONFIG END
						SET @ColumnG = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '10' AND strType = 'Aviation Gasoline' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
						SET @ColumnH = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode = '10' AND strType = 'Aviation Jet Fuel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
					END
				ELSE IF (@ItemId = 'Form-73-Details-008')
					BEGIN
						SET @ColumnB = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
										WHERE strTemplateItemId = 'Form-73-Config-006' AND strSegment = 'Configuration' AND strScheduleCode = 'B')
					END
				ELSE IF (@ItemId = 'Form-73-Details-009')
					BEGIN
								INSERT INTO @tblSchedule (strSchedule)
								EXEC(@SchedQuery)
								SET @ColumnA = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Gasoline / Gasohol / Ethanol' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
								SET @ColumnB = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Undyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
								SET @ColumnC = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Dyed Diesel / Biodiesel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
								--================================RC CONFIG
								SET @ColumnD = '0.00'
								SET @ColumnE = '0.00'
								SET @ColumnF = '0.00'
								--================================RC CONFIG END
								SET @ColumnG = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Aviation Gasoline' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
								SET @ColumnH = (SELECT ISNULL(SUM(dblGross), 0) FROM vyuTFGetTransaction WHERE strScheduleCode IN (SELECT strSchedule FROM @tblSchedule) AND strType = 'Aviation Jet Fuel' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
								DELETE FROM @tblSchedule
					
					END
					ELSE IF (@ItemId = 'Form-73-Details-010')
					BEGIN
							DECLARE @Line2ColumnA NUMERIC(18, 6)
							DECLARE @Line3ColumnD NUMERIC(18, 6)
							DECLARE @Line4ColumnD NUMERIC(18, 6)
							DECLARE @Line6G NUMERIC(18, 6)
							DECLARE @Line6H NUMERIC(18, 6)

								INSERT INTO @tblSchedule (strSchedule)
								EXEC(@SchedQuery)

								--Columns A, B, G, & H (line 2 minus lines 5, 6, 7, 8, & 9)
								SET @Line2ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber = 2
												AND strColumn = 'Gasoline / Gasohol / Ethanol' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

								SET @ColumnA = (@Line2ColumnA - (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber 
												IN(SELECT strSchedule FROM @tblSchedule) 
												AND strColumn = 'Gasoline / Gasohol / Ethanol' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam))

								SET @ColumnB = (@Line2ColumnA - (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber 
												IN(SELECT strSchedule FROM @tblSchedule) 
												AND strColumn = 'Undyed Diesel / Biodiesel' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam))
						
								SET @ColumnG = (@Line2ColumnA - (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber 
												IN(SELECT strSchedule FROM @tblSchedule) 
												AND strColumn = 'Aviation Gasoline' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam))

								SET @ColumnH = (@Line2ColumnA - (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber 
												IN(SELECT strSchedule FROM @tblSchedule) 
												AND strColumn = 'Aviation Jet Fuel' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam))
							
								--Column D (line 3 plus line 4)
								SET @Line3ColumnD = (SELECT strColumnValue FROM tblTFTransactionSummary 
								WHERE intItemNumber = 3 AND strColumn = 'Undyed or Dyed Kerosene' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
								SET @Line4ColumnD = (SELECT strColumnValue FROM tblTFTransactionSummary 
								WHERE intItemNumber = 4 AND strColumn = 'Undyed or Dyed Kerosene' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
								SET @ColumnD = (@Line3ColumnD + @Line4ColumnD)

								--Columns E & F (from line 4)
								SET @ColumnE = @Line4ColumnD
								SET @ColumnF = @Line4ColumnD

								DELETE FROM @tblSchedule
					END
					ELSE IF (@ItemId = 'Form-73-Details-011')
						BEGIN
							SET @ColumnA = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-007' AND strSegment = 'Configuration' AND strScheduleCode = 'A')
							SET @ColumnB = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-008' AND strSegment = 'Configuration' AND strScheduleCode = 'B')
							SET @ColumnD = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-009' AND strSegment = 'Configuration' AND strScheduleCode = 'D')
							SET @ColumnE = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-010' AND strSegment = 'Configuration' AND strScheduleCode = 'E')
							SET @ColumnF = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-011' AND strSegment = 'Configuration' AND strScheduleCode = 'F')
							SET @ColumnG = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-012' AND strSegment = 'Configuration' AND strScheduleCode = 'G')
							SET @ColumnH = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-013' AND strSegment = 'Configuration' AND strScheduleCode = 'H')
						END
					ELSE IF (@ItemId = 'Form-73-Details-012')
						BEGIN
							
							DECLARE @Line10ColumnA NUMERIC(18, 6)
							DECLARE @Line11ColumnA NUMERIC(18, 6)
							DECLARE @Line10ColumnB NUMERIC(18, 6)
							DECLARE @Line11ColumnB NUMERIC(18, 6)
							DECLARE @Line10ColumnD NUMERIC(18, 6)
							DECLARE @Line11ColumnD NUMERIC(18, 6)
							DECLARE @Line10ColumnE NUMERIC(18, 6)
							DECLARE @Line11ColumnE NUMERIC(18, 6)
							DECLARE @Line10ColumnF NUMERIC(18, 6)
							DECLARE @Line11ColumnF NUMERIC(18, 6)
							DECLARE @Line10ColumnG NUMERIC(18, 6)
							DECLARE @Line11ColumnG NUMERIC(18, 6)
							DECLARE @Line10ColumnH NUMERIC(18, 6)
							DECLARE @Line11ColumnH NUMERIC(18, 6)
							
							--Gross tax due by fuel type (line 10 multiplied by line 11)
							SET @Line10ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(10) AND strColumn = 'Gasoline / Gasohol / Ethanol' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)

							SET @Line11ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(11) AND strColumn = 'Gasoline / Gasohol / Ethanol' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @ColumnA = (@Line10ColumnA * @Line11ColumnA)

							SET @Line10ColumnB = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(10) AND strColumn = 'Undyed Diesel / Biodiesel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @Line11ColumnB = (SELECT strColumnValue FROM tblTFTransactionSummary 

							WHERE intItemNumber IN(11) AND strColumn = 'Undyed Diesel / Biodiesel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @ColumnB = (@Line10ColumnB * @Line11ColumnB)
								
							SET @Line10ColumnD = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(10) AND strColumn = 'Undyed or Dyed Kerosene' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @Line11ColumnD = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(11) AND strColumn = 'Undyed or Dyed Kerosene' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @ColumnD = (@Line10ColumnD * @Line11ColumnD)

							SET @Line10ColumnE = (SELECT strColumnValue FROM tblTFTransactionSummary
							WHERE intItemNumber IN(10) AND strColumn = 'Propane (LPG)' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @Line11ColumnE = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(11) AND strColumn = 'Propane (LPG)' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @ColumnE = (@Line10ColumnE * @Line11ColumnE)

							SET @Line10ColumnF = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(10) AND strColumn = 'Compressed Natural Gas (CNG) or Other' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @Line11ColumnF = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(11) AND strColumn = 'Compressed Natural Gas (CNG) or Other' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @ColumnF = (@Line10ColumnF * @Line11ColumnF)

							SET @Line10ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(10) AND strColumn = 'Aviation Gasoline' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @Line11ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(11) AND strColumn = 'Aviation Gasoline' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @ColumnG = (@Line10ColumnG * @Line11ColumnG)

							SET @Line10ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(10) AND strColumn = 'Aviation Jet Fuel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @Line11ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
							WHERE intItemNumber IN(11) AND strColumn = 'Aviation Jet Fuel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
							SET @ColumnH = (@Line10ColumnG * @Line11ColumnG)
						END
				ELSE IF(@ItemId = 'Form-73-Details-013')
					BEGIN
						--Gross tax due for motor vehicle fuels (line 12, column A);
						DECLARE @Line12ColumnA NUMERIC(18, 6)
						DECLARE @Line12ColumnB NUMERIC(18, 6)
						DECLARE @Line12ColumnD NUMERIC(18, 6)
						DECLARE @Line12ColumnE NUMERIC(18, 6)
						DECLARE @Line12ColumnF NUMERIC(18, 6)
						DECLARE @Line12ColumnG NUMERIC(18, 6)
						DECLARE @Line12ColumnH NUMERIC(18, 6)
				
						SET @ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(12) AND strColumn = 'Gasoline / Gasohol / Ethanol' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)

						--diesel fuel (line 12, total of columns B & D);
						SET @Line12ColumnB = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(12) AND strColumn = 'Undyed Diesel / Biodiesel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @Line12ColumnD = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(12) AND strColumn = 'Undyed or Dyed Kerosene' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @ColumnB = (@Line12ColumnB + @Line12ColumnD)

						--line 12, total of columns E & F);
						SET @Line12ColumnE = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(12) AND strColumn = 'Propane (LPG)' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @Line12ColumnF = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(12) AND strColumn = 'Compressed Natural Gas (CNG) or Other' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @ColumnE = (@Line12ColumnE + @Line12ColumnF)

						--line 12, total of columns G & H)
						SET @Line12ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(12) AND strColumn = 'Aviation Gasoline' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @Line12ColumnH = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(12) AND strColumn = 'Aviation Jet Fuel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @ColumnG = (@Line12ColumnG + @Line12ColumnH)
					END
				ELSE IF(@ItemId = 'Form-73-Details-014')
					BEGIN
						--Commissions allowed:
						--Columns A & G (.0500 on first $5,000 plus .0250 on excess over $5,000)
						DECLARE @Line13ColA NUMERIC(18, 6)
						DECLARE @Line13ColB NUMERIC(18, 6)
						DECLARE @Line13ColG NUMERIC(18, 6)
						DECLARE @Line13ColE NUMERIC(18, 6)

						SET @Line13ColA = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Gasoline / Gasohol / Ethanol' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						
						SET @ColumnA = CASE WHEN @Line13ColA < 5000 THEN (@Line13ColA * .05) 
											ELSE (5000 * .05 + ((@Line13ColA - 5000) * .025)) END

						SET @Line13ColB = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Undyed Diesel / Biodiesel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)

						SET @ColumnB = CASE WHEN @Line13ColB < 5000 THEN (@Line13ColB * .02) 
											ELSE (5000 * .02 + ((@Line13ColB - 5000) * .0050)) END

						SET @Line13ColG = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Aviation Gasoline' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)

						SET @ColumnG = CASE WHEN @Line13ColG < 5000 THEN (@Line13ColG * .05) 
											ELSE (5000 * .05 + ((@Line13ColG - 5000) * .025)) END

						SET @Line13ColE = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Propane (LPG)' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)

						SET @ColumnE = CASE WHEN @Line13ColE < 5000 THEN (@Line13ColE * .02) 
											ELSE (5000 * .02 + ((@Line13ColE - 5000) * .0050)) END

					END
				ELSE IF(@ItemId = 'Form-73-Details-015')
					BEGIN
						--Net tax due (line 13 minus line 14)
						DECLARE @Line13ColumnA NUMERIC(18, 6)
						DECLARE @Line14ColumnA NUMERIC(18, 6)

						DECLARE @Line13ColumnB NUMERIC(18, 6)
						DECLARE @Line14ColumnB NUMERIC(18, 6)

						DECLARE @Line13ColumnE NUMERIC(18, 6)
						DECLARE @Line14ColumnE NUMERIC(18, 6)

						DECLARE @Line13ColumnG NUMERIC(18, 6)
						DECLARE @Line14ColumnG NUMERIC(18, 6)

						SET @Line13ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Gasoline / Gasohol / Ethanol' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @Line14ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(14) AND strColumn = 'Gasoline / Gasohol / Ethanol' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @ColumnA = (@Line13ColumnA - @Line14ColumnA)

						SET @Line13ColumnB = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Undyed Diesel / Biodiesel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @Line14ColumnB = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(14) AND strColumn = 'Undyed Diesel / Biodiesel' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @ColumnB = (@Line13ColumnB - @Line14ColumnB)

						SET @Line13ColumnE = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Propane (LPG)' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @Line14ColumnE = (SELECT strColumnValue FROM tblTFTransactionSummary
						WHERE intItemNumber IN(14) AND strColumn = 'Propane (LPG)' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @ColumnE = (@Line13ColumnE - @Line14ColumnE)

						SET @Line13ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(13) AND strColumn = 'Aviation Gasoline' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @Line14ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
						WHERE intItemNumber IN(14) AND strColumn = 'Aviation Gasoline' AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
						SET @ColumnG = (@Line13ColumnG - @Line14ColumnG)

						SET @ColumnG = (@Line13ColumnG - @Line14ColumnG)
					END
				ELSE IF(@ItemId = 'Form-73-Details-016')
					BEGIN
					--Gallons subject to fee:
					
						DECLARE @LineColumnD NUMERIC(18, 6)
						DECLARE @Line2ColumnC NUMERIC(18, 6)
						DECLARE @Line6ColumnC NUMERIC(18, 6)

								--Columns A, B, D, G, & H (line 10 plus lines 5, 7, 8, & 9)
								SET @ColumnA = ((SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber = 10 
												AND strColumn = 'Gasoline / Gasohol / Ethanol' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam) + (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
																					   WHERE intItemNumber IN('5','7','8','9') 
																					   AND strColumn = 'Gasoline / Gasohol / Ethanol' 
																					   AND strSummaryGuid = @Guid 
																					   AND strFormCode = @FormCodeParam))
																					 

								SET @ColumnB = ((SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber = 10 
												AND strColumn = 'Undyed Diesel / Biodiesel'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam) + (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
																						WHERE intItemNumber IN('5','7','8','9') 
																						AND strColumn = 'Undyed Diesel / Biodiesel' 
																						AND strSummaryGuid = @Guid 
																						AND strFormCode = @FormCodeParam))

								SET @ColumnD = ((SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber = 10 
												AND strColumn = 'Undyed or Dyed Kerosene'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam) + (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
																						WHERE intItemNumber IN('5','7','8','9') 
																						AND strColumn = 'Undyed or Dyed Kerosene' 
																						AND strSummaryGuid = @Guid 
																						AND strFormCode = @FormCodeParam))


								SET @ColumnG = ((SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber = 10 
												AND strColumn = 'Aviation Gasoline' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam) + (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
																						WHERE intItemNumber IN('5','7','8','9') 
																						AND strColumn = 'Aviation Gasoline' 
																						AND strSummaryGuid = @Guid 
																						AND strFormCode = @FormCodeParam))

								SET @ColumnH = ((SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
												WHERE intItemNumber = 10 
												AND strColumn = 'Aviation Jet Fuel' 
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam) + (SELECT ISNULL(SUM(strColumnValue), 0) FROM tblTFTransactionSummary 
																						WHERE intItemNumber IN('5','7','8','9') 
																						AND strColumn = 'Aviation Jet Fuel' 
																						AND strSummaryGuid = @Guid 
																						AND strFormCode = @FormCodeParam))
							
								--Column C (line 2 minus line 6)
								SET @Line2ColumnC = (SELECT strColumnValue FROM tblTFTransactionSummary 
													WHERE intItemNumber IN('2') 
													AND strColumn = 'Dyed Diesel / Biodiesel'
													AND strSummaryGuid = @Guid 
													AND strFormCode = @FormCodeParam)

								SET @Line6ColumnC = (SELECT strColumnValue FROM tblTFTransactionSummary 
													WHERE intItemNumber IN('6') 
													AND strColumn = 'Dyed Diesel / Biodiesel'
													AND strSummaryGuid = @Guid 
													AND strFormCode = @FormCodeParam)

								SET @ColumnC = (@Line2ColumnC - @Line6ColumnC)

					END
				ELSE IF(@ItemId = 'Form-73-Details-017')
					BEGIN
						--FREE Rate
							SET @ColumnA = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-014' AND strSegment = 'Configuration' AND strScheduleCode = 'A')
							SET @ColumnB = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-015' AND strSegment = 'Configuration' AND strScheduleCode = 'B')
							SET @ColumnC = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-016' AND strSegment = 'Configuration' AND strScheduleCode = 'C')
							SET @ColumnD = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-017' AND strSegment = 'Configuration' AND strScheduleCode = 'D')
							SET @ColumnG = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-018' AND strSegment = 'Configuration' AND strScheduleCode = 'G')
							SET @ColumnH = (SELECT (CASE WHEN strConfiguration = '' THEN NULL ELSE strConfiguration END) FROM vyuTFGetReportingComponentConfiguration 
											WHERE strTemplateItemId = 'Form-73-Config-019' AND strSegment = 'Configuration' AND strScheduleCode = 'H')
					END
				ELSE IF(@ItemId = 'Form-73-Details-018')
					BEGIN
						--Total fee due (line 16 multiplied by line 17)
							DECLARE @Line16ColumnA NUMERIC(18, 6)
							DECLARE @Line17ColumnA NUMERIC(18, 6)

							DECLARE @Line16ColumnB NUMERIC(18, 6)
							DECLARE @Line17ColumnB NUMERIC(18, 6)

							DECLARE @Line16ColumnC NUMERIC(18, 6)
							DECLARE @Line17ColumnC NUMERIC(18, 6)

							DECLARE @Line16ColumnD NUMERIC(18, 6)
							DECLARE @Line17ColumnD NUMERIC(18, 6)

							DECLARE @Line16ColumnG NUMERIC(18, 6)
							DECLARE @Line17ColumnG NUMERIC(18, 6)

							DECLARE @Line16ColumnH NUMERIC(18, 6)
							DECLARE @Line17ColumnH NUMERIC(18, 6)

							--Gross tax due by fuel type (line 10 multiplied by line 11)
							SET @Line16ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(16) 
												AND strColumn = 'Gasoline / Gasohol / Ethanol'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

							SET @Line17ColumnA = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(17) 
												AND strColumn = 'Gasoline / Gasohol / Ethanol'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

							SET @ColumnA = (@Line16ColumnA * @Line17ColumnA)

							SET @Line16ColumnB = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(16) 
												AND strColumn = 'Undyed Diesel / Biodiesel'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)
							SET @Line17ColumnB = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(17) 
												AND strColumn = 'Undyed Diesel / Biodiesel'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

							SET @ColumnB = (@Line16ColumnB * @Line17ColumnB)
								
							SET @Line16ColumnC = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(16) 
												AND strColumn = 'Dyed Diesel / Biodiesel'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)
							SET @Line17ColumnC = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(17) 
												AND strColumn = 'Dyed Diesel / Biodiesel'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

							SET @ColumnC = (@Line16ColumnC * @Line17ColumnC)

							SET @ColumnD = (@Line16ColumnD * @Line17ColumnD)
						
							SET @Line16ColumnD = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(16) 
												AND strColumn = 'Undyed or Dyed Kerosene'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)
							SET @Line17ColumnD = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(17) 
												AND strColumn = 'Undyed or Dyed Kerosene'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

							SET @ColumnD = (@Line16ColumnD * @Line17ColumnD)

							SET @Line16ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(16) 
												AND strColumn = 'Aviation Gasoline'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)
							SET @Line17ColumnG = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(17) 
												AND strColumn = 'Aviation Gasoline'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

							SET @ColumnG = (@Line16ColumnG * @Line17ColumnG)

							SET @Line16ColumnH = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(16) 
												AND strColumn = 'Aviation Jet Fuel'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)
							SET @Line16ColumnH = (SELECT strColumnValue FROM tblTFTransactionSummary 
												WHERE intItemNumber IN(17) 
												AND strColumn = 'Aviation Jet Fuel'
												AND strSummaryGuid = @Guid 
												AND strFormCode = @FormCodeParam)

							SET @ColumnH = (@Line16ColumnH * @Line16ColumnH)

					END
					ELSE IF(@ItemId = 'Form-73-Details-019')
					BEGIN
						SET @Line19Total = (SELECT ISNULL(SUM(strColumnValue), 0) 
											FROM tblTFTransactionSummary
											WHERE intItemNumber IN(15) 
											AND strColumn IN('Gasoline / Gasohol / Ethanol', 'Undyed Diesel / Biodiesel')
											AND strFormCode = 'Form 73')
						SET @ColumnA = @Line19Total

					END
					ELSE IF(@ItemId = 'Form-73-Details-020')
					BEGIN
						SET @Line15ColumnE = (SELECT ISNULL(strColumnValue, 0) 
											  FROM tblTFTransactionSummary
											  WHERE intItemNumber IN(15) 
											  AND strColumn = 'Propane (LPG)'
											  AND strFormCode = 'Form 73')
						SET @ColumnA = @Line15ColumnE
					END
					ELSE IF(@ItemId = 'Form-73-Details-021')
					BEGIN
						SET @Line15ColumnG = (SELECT ISNULL(strColumnValue, 0) 
											  FROM tblTFTransactionSummary
											  WHERE intItemNumber IN(15) 
											  AND strColumn = 'Aviation Gasoline'
											  AND strFormCode = 'Form 73')
						SET @ColumnA = @Line15ColumnG
												
					END
					ELSE IF(@ItemId = 'Form-73-Details-022')
					BEGIN
						SET @Line22Total = (SELECT ISNULL(SUM(strColumnValue), 0) 
											FROM tblTFTransactionSummary
											WHERE intItemNumber IN(18) 
											AND strFormCode = 'Form 73')
						SET @ColumnA = @Line22Total
					END
					ELSE IF(@ItemId = 'Form-73-Details-023')
					BEGIN
						SET @Line23Total = @Line19Total + @Line15ColumnE + @Line15ColumnG + @Line22Total
						SET @ColumnA = @Line23Total
						PRINT @Line23Total
					END
					IF (@ItemId = 'Form-73-Details-019' OR @ItemId = 'Form-73-Details-020' OR @ItemId = 'Form-73-Details-021' OR @ItemId = 'Form-73-Details-022' OR @ItemId = 'Form-73-Details-023')
							BEGIN
								-- COLUMN A
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 1, 'Details','', '',@ColumnA, @ItemDescription, CAST(GETDATE() AS DATE))
							
							END
						ELSE
							BEGIN
									-- COLUMN A
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 1, 'Details','Gasoline / Gasohol / Ethanol', '',@ColumnA, @ItemDescription, CAST(GETDATE() AS DATE))

								-- COLUMN B
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 2, 'Details','Undyed Diesel / Biodiesel', '',@ColumnB, @ItemDescription, CAST(GETDATE() AS DATE))

								-- COLUMN C
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 3, 'Details','Dyed Diesel / Biodiesel', '',@ColumnC, @ItemDescription, CAST(GETDATE() AS DATE))

								-- COLUMN D
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 4, 'Details','Undyed or Dyed Kerosene', '',@ColumnD, @ItemDescription, CAST(GETDATE() AS DATE))

								-- COLUMN E
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 5, 'Details','Propane (LPG)', '',@ColumnE, @ItemDescription, CAST(GETDATE() AS DATE))

								-- COLUMN F
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 6, 'Details','Compressed Natural Gas (CNG) or Other', '',@ColumnF, @ItemDescription, CAST(GETDATE() AS DATE))

								-- COLUMN G
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 7, 'Details','Aviation Gasoline', '',@ColumnG, @ItemDescription, CAST(GETDATE() AS DATE))

								-- COLUMN H
								INSERT INTO tblTFTransactionSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemNumber, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
								VALUES(@Guid,@TA,@TACode,@FormCodeParam,@configScheduleCode, @TemplateItemNumber, 8, 'Details','Aviation Jet Fuel', '',@ColumnH, @ItemDescription, CAST(GETDATE() AS DATE))

								SELECT @ColumnA = 0, @ColumnB = 0, @ColumnC = 0, @ColumnD = 0, @ColumnE = 0, @ColumnF = 0, @ColumnG = 0, @ColumnH = 0
							
							END
						
				SET @TemplateItemCount = @TemplateItemCount - 1
			END
			
			DECLARE @isTransactionEmpty NVARCHAR(20)
			SET @isTransactionEmpty = (SELECT TOP 1 strProductCode FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
			IF(@isTransactionEmpty = 'No record found.')
				BEGIN
					UPDATE tblTFTransactionSummary SET strColumnValue = 0 WHERE strFormCode = @FormCodeParam
				END