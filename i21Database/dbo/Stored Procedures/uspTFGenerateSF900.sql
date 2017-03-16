CREATE PROCEDURE [dbo].[uspTFGenerateSF900]

@Guid NVARCHAR(250),
@FormCodeParam NVARCHAR(MAX),
@ScheduleCodeParam NVARCHAR(MAX),
@Refresh NVARCHAR(5)

AS

--HEADER
DECLARE @TA INT
DECLARE @TPName NVARCHAR(250)
DECLARE @TPAddress NVARCHAR(MAX)
DECLARE @TPCity NVARCHAR(50)
DECLARE @TPState NVARCHAR(50)
DECLARE @TPZip NVARCHAR(10)
DECLARE @TPPhone NVARCHAR(50)
DECLARE @TPStateTaxID NVARCHAR(50)
DECLARE @TPFEIN NVARCHAR(50)
DECLARE @TPDBA NVARCHAR(50)

--SUMMARY VARIABLES
DECLARE @ParamId NVARCHAR(MAX)
DECLARE @TemplateScheduleCode NVARCHAR(MAX)
DECLARE @TemplateItemId NVARCHAR(20)
DECLARE @TemplateConfiguration NVARCHAR(20)
DECLARE @TemplateDescription NVARCHAR(MAX)
DECLARE @TemplateItemNumber NVARCHAR(MAX)
DECLARE @ReportItemSequence NVARCHAR(MAX)
DECLARE @ReportSection NVARCHAR(MAX)
DECLARE @TemplateSegment NVARCHAR(MAX)
DECLARE @TempComputedValue NUMERIC(18, 2)
DECLARE @SummaryItemCount NVARCHAR(MAX) 
DECLARE @Query NVARCHAR(MAX)

DECLARE @tblTempSummaryTotal TABLE (
		 dbLColumnValue NUMERIC(18, 2))

DECLARE @tblTempSummaryItem TABLE (
		Id INT IDENTITY(1,1),
		TaxReportSummaryItemId INT)

IF @Refresh = 'true'
		BEGIN
			DELETE FROM tblTFTransactionSummary --WHERE strSummaryGuid = @Guid
		END
	-- ======================== HEADER ==============================
DECLARE @DatePeriod DATETIME
DECLARE @DateBegin DATETIME
DECLARE @DateEnd DATETIME

DECLARE @LicenseNumber NVARCHAR(50)
DECLARE @EIN NVARCHAR(50)

-- ======================== SUMMARY ==============================
	SELECT TOP 1 
		@TA = intTaxAuthorityId, 
		@DatePeriod = dtmDate,
		@DateBegin = dtmReportingPeriodBegin,
		@DateEnd = dtmReportingPeriodEnd,
		@TPName = strTaxPayerName,
		@TPAddress = intTaxAuthorityId,
		@TPCity = strCity,
		@TPState = strState,
		@TPZip = strZipCode,
		@TPPhone = strTelephoneNumber,
		@TPStateTaxID = strTaxPayerIdentificationNumber,
		@TPFEIN = strTaxPayerFEIN,
		@TPDBA = strTaxPayerDBA
		FROM vyuTFGetTransaction
		WHERE uniqTransactionGuid = @Guid 
		AND strFormCode = @FormCodeParam
	 
	SELECT TOP 1 @LicenseNumber = strConfiguration 
		FROM vyuTFGetReportingComponentConfiguration config INNER JOIN tblTFReportingComponent rc 
			ON config.intReportingComponentId = rc.intReportingComponentId 
		WHERE rc.strFormCode = @FormCodeParam 
		AND config.strTemplateItemId = 'SF-900-LicenseNumber'
	
	SELECT TOP 1 @EIN = strEin FROM tblSMCompanySetup	

	INSERT INTO tblTFTransactionSummary (
		strSummaryGuid
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

		INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
		SELECT intReportingComponentConfigurationId 
		FROM vyuTFGetReportingComponentConfiguration config INNER JOIN tblTFReportingComponent rc 
				ON config.intReportingComponentId = rc.intReportingComponentId 
			WHERE rc.strFormCode = @FormCodeParam 
		ORDER BY config.intReportingComponentConfigurationId DESC

		SET @SummaryItemCount = (SELECT COUNT(*) FROM @tblTempSummaryItem)

			WHILE(@SummaryItemCount > 0) -- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
			BEGIN
				-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
				SET @ParamId = (SELECT TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @SummaryItemCount)
				SELECT TOP 1 @TemplateScheduleCode = config.strScheduleCode, 
							 @TemplateItemId = config.strTemplateItemId,
							 @TemplateDescription = config.strDescription,
							 @ReportItemSequence = config.intReportItemSequence,
							 @TemplateItemNumber = config.intTemplateItemNumber,
							 @ReportSection = config.strReportSection,
							 @TemplateSegment = config.strSegment,
							 @TemplateConfiguration = config.strConfiguration
						FROM vyuTFGetReportingComponentConfiguration config
						INNER JOIN tblTFReportingComponent rc 
						ON config.intReportingComponentId = rc.intReportingComponentId
						WHERE intReportingComponentConfigurationId = @ParamId 
						AND rc.strFormCode = @FormCodeParam

				SET @TemplateScheduleCode = REPLACE(@TemplateScheduleCode,',',''',''')
					IF (@TemplateScheduleCode IS NOT NULL)
					BEGIN
						-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

						IF @TemplateItemId = 'SF-900-Summary-001'
							BEGIN
							--1. Total Receipts (From Section A, Line 5 on back of return)
								SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-002'
							BEGIN
							--2. Total Non-Taxable Disbursements (From Section B, Line 11 on back of return)
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-003'
							BEGIN
							--3. Taxable Gallons Sold or Used (From Section B, Line 3, on back of return)
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''5'',''11'') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-004'
							BEGIN
							--4. Gallons Received Tax Paid (From Section A, Line 1, on back of return)
								SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END

						ELSE IF @TemplateItemId = 'SF-900-Summary-005'
							BEGIN
							--5. Billed Taxable Gallons (Line 3 minus Line 4)
								SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-006'
							BEGIN
							--6. Tax Due (Multiply Line 5 by $0.16)
								SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''' AND strSegment = ''Summary'''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-007'
							BEGIN
							--7. Amount of Tax Uncollectible from Eligible Purchasers - Complete Schedule 10E
								SET @Query = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''SF-900-Summary-007''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-008'
							BEGIN
							--8. Adjusted Tax Due (Line 6 minus Line 7)
								SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-009'
							BEGIN
							--9. Collection Allowance (Multiply Line 8 by .016). If return filed or tax paid after due date enter zero (0)
								SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-010'
							BEGIN
							--10. Adjustment - Complete Schedule E-1 (Dollar amount only)
								SET @Query = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''SF-900-Summary-010''' 
								INSERT INTO @tblTempSummaryTotal
					
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-011'
							BEGIN
							--11. Total special fuel tax due (Line 8 minus Line 9 plus or minus Line 10)
								DECLARE @value NUMERIC(18, 6)
								DECLARE @strvalue NVARCHAR(20)
								--Line 8 minus Line 9 
								DECLARE @val1 NUMERIC(18, 6) = (SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN ('8','9') AND strSummaryGuid = @Guid AND strFormCode = @FormCodeParam) - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN ('8','9') AND strSummaryGuid = @Guid AND strFormCode = @FormCodeParam)
								--Get Line 10
								DECLARE @val2 NUMERIC(18, 6) = (select strColumnValue from tblTFTransactionSummary where intItemNumber IN ('10') AND strSummaryGuid = @Guid AND strFormCode = @FormCodeParam)
								--plus line 10
								SET @value = @val1 + @val2
								SET @strvalue = (CONVERT(NVARCHAR(30), @value))
								SET @Query  = 'SELECT ' + @strvalue
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-012'
							BEGIN
							--1. Total billed gallons (From Section 2, Line 5)
								SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-013'
							BEGIN
							--2. Oil inspection fees due (Multiply Line 1 by $0.01)
								SET @Query = 'SELECT strColumnValue * ' + @TemplateConfiguration + ' FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
		
						ELSE IF @TemplateItemId = 'SF-900-Summary-014'
							BEGIN
							--3. Adjustments (Schedule E-1 must be attached and is subject to Department approval)
								SET @Query = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''SF-900-Summary-014''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-015'
							BEGIN
							--4. Total oil inspection fees due (Line 2 plus or minus Line 3)
								SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-016'
							BEGIN
							--1. Total amount due (Section 2, Line 11 plus Section 3, Line 4)
								SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-017'
							BEGIN
							--2. Penalty
								SET @Query = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''SF-900-Summary-017''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END

						ELSE IF @TemplateItemId = 'SF-900-Summary-018'
							BEGIN
							--3. Interest
								SET @Query = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''SF-900-Summary-018'''    
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-019'
							BEGIN
							--4. Net tax due (Line 1 plus Line 2 plus Line 3)
								SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
						END
						ELSE IF @TemplateItemId = 'SF-900-Summary-020'
							BEGIN
							--5. Payment(s)
								SET @Query = 'SELECT strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''SF-900-Summary-020''' 

								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-021'
						--6. Balance due (Line 4 minus Line 5)
							BEGIN
								SET @Query  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTransactionSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTransactionSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END

						--DETAILS RECEIPTS
						--IF @TemplateItemId = 'SF-900-Summary-022'
							--BEGIN
							--1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)
								--SET @Query = 'SELECT SUM(dblGross) FROM tblTFTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''')'  
								--INSERT INTO @tblTempSummaryTotal
								--EXEC(@Query)
							--END
						IF @TemplateItemId = 'SF-900-Summary-023'
							BEGIN
							--1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)
								SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-024'
							BEGIN
							--2. Gallons Received for Export (To be completed only by licensed exporters)
								SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-025'
							BEGIN
							--3. Gallons of Nontaxable Fuel Received and Sold or Used For a Taxable Purpose
								SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						IF @TemplateItemId = 'SF-900-Summary-026'
							BEGIN
							--4. Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid
								SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-027'
							BEGIN
							--5. Total Receipts (Add Lines 1 through 4, carry forward to Section 2, Line 1 on
								SET @Query = 'SELECT SUM(dblGross) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END

						--DETAILS DISBURSEMENT
						ELSE IF @TemplateItemId = 'SF-900-Summary-029'
							BEGIN
							--1. Gallons Delivered Tax Collected and Gallons Blended or Dyed Fuel Used
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						IF @TemplateItemId = 'SF-900-Summary-030'
							BEGIN
							--2. Diversions (Special fuel only)                  +/-
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-031'
							BEGIN
							--3. Taxable Gallons Sold or Used (Carry forward to Section 2, Line 3 on front
								SET @Query = 'SELECT SUM(strColumnValue) FROM tblTFTransactionSummary WHERE intItemNumber IN (''' + @TemplateScheduleCode + ''') AND strSegment = ''Details'' AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-032'
							BEGIN
							--4. Gallons Delivered Via Rail, Pipeline, or Vessel to Licensed Suppliers, Tax
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-033'
							BEGIN
							--5. Gallons Disbursed on Exchange for Other Suppliers or Permissive Suppliers
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						IF @TemplateItemId = 'SF-900-Summary-034'
							BEGIN
							--6. Gallons Exported by License Holder
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-035'
							BEGIN
							--7. Gallons Sold to Unlicensed Exporters for Export
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-036'
							BEGIN
							--8. Gallons Sold to Licensed Exporters for Export
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-037'
							BEGIN
							--9. Gallons of Undyed Fuel Sold to the U.S. Government - Tax Exempt
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-038'
							BEGIN
							--10. Gallons Sold of Tax Exempt Dyed Fuel
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END
						ELSE IF @TemplateItemId = 'SF-900-Summary-039'
							BEGIN
							--11. Total Non-Taxable Disbursements (Add Lines 4 through 10; carry forward to
								SET @Query = 'SELECT SUM(dblQtyShipped) FROM vyuTFGetTransaction WHERE strScheduleCode IN (''' + @TemplateScheduleCode + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@Query)
							END


						--PRINT @TemplateItemId
						SET @TempComputedValue = (SELECT ISNULL(dbLColumnValue, 0) FROM @tblTempSummaryTotal)

						--IF (@TempComputedValue IS NOT NULL) -- INSERT COMPUTED VALUES FROM TEMP TOTAL TABLE TO SUMMARY TABLE
						--BEGIN
							INSERT INTO tblTFTransactionSummary
							(
								 strSummaryGuid,
								 intTaxAuthorityId,
								 strFormCode,
								 strScheduleCode,
								 strSegment,
								 strProductCode,
								 strDescription,
								 strColumnValue,
								 intItemNumber,
								 intItemSequenceNumber,
								 strSection,
								 dtmDateRun,
								 strTaxPayerName,
								 strTaxPayerAddress,
								 strCity,
								 strState,
								 strZipCode,
								 strTelephoneNumber,
								 strTaxPayerIdentificationNumber,
								 strTaxPayerFEIN,
								 strTaxPayerDBA
							)		
							VALUES
							(
								 @Guid,
								 (@TA),
								 (@FormCodeParam),
								 (@TemplateScheduleCode),
								 @TemplateSegment,
								 (''),
								 @TemplateDescription,
								 @TempComputedValue,
								 @TemplateItemNumber,
								 @ReportItemSequence,
								 @ReportSection,
								 (CAST(GETDATE() AS DATE)),
								 @TPName,
								 @TPAddress,
								 @TPCity,
								 @TPState,
								 @TPZip,
								 @TPPhone,
								 @TPStateTaxID,
								 @TPFEIN,
								 @TPDBA
							)
						--END
					END
				DELETE FROM @tblTempSummaryTotal
				SET @SummaryItemCount = @SummaryItemCount - 1
			END
			DECLARE @isTransactionEmpty NVARCHAR(20)
				SET @isTransactionEmpty = (SELECT TOP 1 strProductCode FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
				IF(@isTransactionEmpty = 'No record found.')
					BEGIN
						UPDATE tblTFTransactionSummary SET strColumnValue = 0 WHERE strFormCode = @FormCodeParam
					END
