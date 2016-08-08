CREATE PROCEDURE [dbo].[uspTFGenerateSF900]

@Guid NVARCHAR(250),
@ScheduleCodeParam NVARCHAR(250)

AS

DECLARE @TA INT
DECLARE @FormCode NVARCHAR(50)
--HEADER
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
DECLARE @SmrySummaryTaxType NVARCHAR(MAX)
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

INSERT INTO tblTFTaxReportSummary (uniqGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strTaxType, dtmDateRun, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strTaxPayerName, 
		 	strFEINSSN, strEmail, strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strContactName, strLicenseNumber)

SELECT TOP 1 @Guid, @TA, @FormCode, '', 'Header', @DatePeriod,@DateBegin,@DateEnd, strCompanyName,
				@EIN, strContactEmail, strTaxAddress, strCity, strState, strZipCode, strContactPhone, strContactName, @LicenseNumber from tblTFCompanyPreference

	-- ======================== SUMMARY ==============================
	SET @TPName = (SELECT TOP 1 strTaxPayerName FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPAddress = (SELECT TOP 1 intTaxAuthorityId FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPCity = (SELECT TOP 1 strCity FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPState = (SELECT TOP 1 strState FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPZip = (SELECT TOP 1 strZipCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPPhone = (SELECT TOP 1 strTelephoneNumber FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPStateTaxID = (SELECT TOP 1 strTaxPayerIdentificationNumber FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPFEIN = (SELECT TOP 1 strTaxPayerFEIN FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
	SET @TPDBA = (SELECT TOP 1 strTaxPayerDBA FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)

	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intTaxReportSummaryItems FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode ORDER BY intTaxReportSummaryItems DESC

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
				SET @SmrySummaryTaxType = (SELECT strTaxType FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
				SET @SmryConfigValue = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryParamId AND strSummaryFormCode = @FormCode)
				-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

				IF @SmrySummaryItemId = 'SF-900-Summary-001'
					BEGIN
					--1. Total Receipts (From Section A, Line 5 on back of return)
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-002'
					BEGIN
					--2. Total Non-Taxable Disbursements (From Section B, Line 11 on back of return)
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-003'
					BEGIN
					--3. Taxable Gallons Sold or Used (From Section B, Line 3, on back of return)
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''5'',''11'')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-004'
					BEGIN
					--4. Gallons Received Tax Paid (From Section A, Line 1, on back of return)
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-005'
					BEGIN
					--5. Billed Taxable Gallons (Line 3 minus Line 4)
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-006'
					BEGIN
					--6. Tax Due (Multiply Line 5 by $0.16)
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-007'
					BEGIN
					--7. Amount of Tax Uncollectible from Eligible Purchasers - Complete Schedule 10E
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''SF-900-Summary-007''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-008'
					BEGIN
					--8. Adjusted Tax Due (Line 6 minus Line 7)
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-009'
					BEGIN
					--9. Collection Allowance (Multiply Line 8 by .016). If return filed or tax paid after due date enter zero (0)
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-010'
					BEGIN
					--10. Adjustment - Complete Schedule E-1 (Dollar amount only)
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''SF-900-Summary-010''' 
						INSERT INTO @tblTempSummaryTotal
					
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-011'
					BEGIN
					--11. Total special fuel tax due (Line 8 minus Line 9 plus or minus Line 10)
						DECLARE @value NUMERIC(18, 6)
						DECLARE @strvalue NVARCHAR(20)
						DECLARE @val1 NUMERIC(18, 6) = (SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN ('8','9')) - (a.strColumnValue)) FROM tblTFTaxReportSummary a WHERE a.intItemNumber IN ('8','9'))
						DECLARE @val2 NUMERIC(18, 6) = (select strColumnValue FROM tblTFTaxReportSummary WHERE intItemNumber IN ('10'))
						SET @value = (CASE WHEN SIGN(@val1)=SIGN(@val2) THEN @val1 + @val2 ELSE @val1 - @val2 END)
						SET @strvalue = (CONVERT(NVARCHAR(30), @value))

						SET @SmryQuery  = 'SELECT' + @strvalue
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-012'
					BEGIN
					--1. Total billed gallons (From Section 2, Line 5)
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-013'
					BEGIN
					--2. Oil inspection fees due (Multiply Line 1 by $0.01)
						SET @SmryQuery = 'SELECT strColumnValue * ' + @SmryConfigValue + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
		
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-014'
					BEGIN
					--3. Adjustments (Schedule E-1 must be attached and is subject to Department approval)
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''SF-900-Summary-014''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-015'
					BEGIN
					--4. Total oil inspection fees due (Line 2 plus or minus Line 3)
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-016'
					BEGIN
					--1. Total amount due (Section 2, Line 11 plus Section 3, Line 4)
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-017'
					BEGIN
					--2. Penalty
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''SF-900-Summary-017''' 
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-018'
					BEGIN
					--3. Interest
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''SF-900-Summary-018'''    
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-019'
					BEGIN
					--4. Net tax due (Line 1 plus Line 2 plus Line 3)
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
				END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-020'
					BEGIN
					--5. Payment(s)
						SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''SF-900-Summary-020''' 

						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-021'
				--6. Balance due (Line 4 minus Line 5)
					BEGIN
						SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCode + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCode + ''')'
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				--DETAILS RECEIPTS
				--IF @SmrySummaryItemId = 'SF-900-Summary-022'
					--BEGIN
					--1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)
						--SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						--INSERT INTO @tblTempSummaryTotal
						--EXEC(@SmryQuery)
					--END
				IF @SmrySummaryItemId = 'SF-900-Summary-023'
					BEGIN
					--1. Gallons Received Tax Paid (Carry forward to Section 2, Line 4 on front of return)
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-024'
					BEGIN
					--2. Gallons Received for Export (To be completed only by licensed exporters)
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-025'
					BEGIN
					--3. Gallons of Nontaxable Fuel Received and Sold or Used For a Taxable Purpose
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				IF @SmrySummaryItemId = 'SF-900-Summary-026'
					BEGIN
					--4. Gallons Imported Via Truck, Barge, or Rail, Tax Unpaid
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-027'
					BEGIN
					--5. Total Receipts (Add Lines 1 through 4, carry forward to Section 2, Line 1 on
						SET @SmryQuery = 'SELECT SUM(dblGross) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				--DETAILS DISBURSEMENT
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-029'
					BEGIN
					--1. Gallons Delivered Tax Collected and Gallons Blended or Dyed Fuel Used
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				IF @SmrySummaryItemId = 'SF-900-Summary-030'
					BEGIN
					--2. Diversions (Special fuel only)                  +/-
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-031'
					BEGIN
					--3. Taxable Gallons Sold or Used (Carry forward to Section 2, Line 3 on front
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCode + ''') AND strTaxType = ''Details'''
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-032'
					BEGIN
					--4. Gallons Delivered Via Rail, Pipeline, or Vessel to Licensed Suppliers, Tax
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-033'
					BEGIN
					--5. Gallons Disbursed on Exchange for Other Suppliers or Permissive Suppliers
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				IF @SmrySummaryItemId = 'SF-900-Summary-034'
					BEGIN
					--6. Gallons Exported by License Holder
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-035'
					BEGIN
					--7. Gallons Sold to Unlicensed Exporters for Export
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-036'
					BEGIN
					--8. Gallons Sold to Licensed Exporters for Export
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-037'
					BEGIN
					--9. Gallons of Undyed Fuel Sold to the U.S. Government - Tax Exempt
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-038'
					BEGIN
					--10. Gallons Sold of Tax Exempt Dyed Fuel
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmrySummaryItemId = 'SF-900-Summary-039'
					BEGIN
					--11. Total Non-Taxable Disbursements (Add Lines 4 through 10; carry forward to
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCode + ''')'  
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
						 (@FormCode),
						 (@SmryScheduleCode),
						 @SmrySummaryTaxType,
						 (''),
						 @SmrySummaryDescription,
						 @SmryTempTotal,
						 @SmrySummaryItemNumber,
						 @SmrySummaryItemSequenceNumber,
						 @SmrySummarySection,
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
			SET @SmrySummaryItemsCount = @SmrySummaryItemsCount - 1
		END


	