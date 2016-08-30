CREATE PROCEDURE [dbo].[uspTFGenerateGT103]

@Guid NVARCHAR(250),
@FormCodeParam NVARCHAR(50),
@ScheduleCodeParam NVARCHAR(250),
@Refresh NVARCHAR(5)

AS

DECLARE @FCode NVARCHAR(5) = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE strFormCode = @FormCodeParam AND uniqTransactionGuid = @Guid)
IF (@FCode IS NOT NULL)
BEGIN

DECLARE @TA INT
--SUMMARY VARIABLES
DECLARE @ReportTemplateId NVARCHAR(MAX)
DECLARE @TemplateScheduleCodeParam NVARCHAR(MAX)
DECLARE @TemplateItemId NVARCHAR(20)
DECLARE @TemplateConfiguration NUMERIC(18, 6)
DECLARE @TemplateDescription NVARCHAR(MAX)
DECLARE @TemplateItemNumber NVARCHAR(MAX)
DECLARE @ReportItemSequence NVARCHAR(MAX)
DECLARE @ReportSection NVARCHAR(MAX)
DECLARE @TempComputedValue NUMERIC(18, 6)
DECLARE @TemplateItemCount NVARCHAR(MAX) 
DECLARE @QueryTransaction NVARCHAR(MAX)

DECLARE @tblTempSummaryTotal TABLE (
		 dbLColumnValue NUMERIC(18, 2))

DECLARE @tblTempSummaryItem TABLE (
		Id INT IDENTITY(1,1),
		TaxReportSummaryItemId INT)

IF @Refresh = 'true'
		BEGIN
			DELETE FROM tblTFTaxReportSummary --WHERE strSummaryGuid = @Guid
		END

-- ======================== HEADER ==============================

DECLARE @DatePeriod DATETIME
DECLARE @DateBegin DATETIME
DECLARE @DateEnd DATETIME

DECLARE @TaxID NVARCHAR(50)
DECLARE @EIN NVARCHAR(50)

--SET @FormCodeParam = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @TA = (SELECT TOP 1 intTaxAuthorityId FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DatePeriod = (SELECT TOP 1 dtmDate FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DateBegin = (SELECT TOP 1 dtmReportingPeriodBegin FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DateEnd = (SELECT TOP 1 dtmReportingPeriodEnd FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @TaxID = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE strFormCode = @FormCodeParam AND intTemplateItemId = 'TID')
SET @EIN = (SELECT TOP 1 strEin FROM tblSMCompanySetup)

INSERT INTO tblTFTaxReportSummary (strSummaryGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strSegment, dtmDateRun, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strTaxPayerName, strTaxPayerIdentificationNumber, 
					strTaxPayerFEIN,strEmail, strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strContactName)

SELECT TOP 1 @Guid, @TA, @FormCodeParam, '', 'Header', @DatePeriod,@DateBegin,@DateEnd, strCompanyName, @TaxID,
				@EIN, strContactEmail, strTaxAddress, strCity, strState, strZipCode, strContactPhone, strContactName from tblTFCompanyPreference
-- ======================== SUMMARY ==============================

	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intReportTemplateId FROM tblTFTaxReportTemplate WHERE strFormCode = @FormCodeParam AND strSegment = 'Summary' ORDER BY intReportTemplateId DESC

	SET @TemplateItemCount = (SELECT COUNT(*) FROM @tblTempSummaryItem)

	WHILE(@TemplateItemCount > 0) -- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
		BEGIN
			-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
			SET @ReportTemplateId = (SELECT TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @TemplateItemCount)
			SET @TemplateScheduleCodeParam = (SELECT strScheduleCode FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ReportTemplateId AND strFormCode = @FormCodeParam)
			SET @TemplateItemId = (SELECT intTemplateItemId FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ReportTemplateId AND strFormCode = @FormCodeParam)

			SET @TemplateScheduleCodeParam = REPLACE(@TemplateScheduleCodeParam,',',''',''')
			IF (@TemplateScheduleCodeParam IS NOT NULL)
			BEGIN
				SET @TemplateDescription = (SELECT strDescription FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ReportTemplateId AND strFormCode = @FormCodeParam)
				SET @ReportItemSequence = (SELECT intReportItemSequence FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ReportTemplateId AND strFormCode = @FormCodeParam)
				SET @TemplateItemNumber = (SELECT intTemplateItemNumber FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ReportTemplateId AND strFormCode = @FormCodeParam)
				SET @ReportSection = (SELECT strReportSection FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ReportTemplateId AND strFormCode = @FormCodeParam)
				SET @TemplateConfiguration = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intReportTemplateId = @ReportTemplateId AND strFormCode = @FormCodeParam)
				-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

				IF @TemplateItemId = 'GT-103-Summary-001'
					BEGIN
				--1. Total Gallons Sold for Period
						SET @QueryTransaction = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @TemplateScheduleCodeParam + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@QueryTransaction)
					END
					ELSE IF @TemplateItemId = 'GT-103-Summary-002'
					BEGIN
				--2. Total Exempt Gallons Sold for Period
						SET @QueryTransaction = 'SELECT SUM(dblTaxExempt) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @TemplateScheduleCodeParam + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@QueryTransaction)
					END
					ELSE IF @TemplateItemId = 'GT-103-Summary-003'
					BEGIN
				--3. Total Taxable Gallons Sold (Line 1 minus Line 2)
						SET @QueryTransaction = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
						INSERT INTO @tblTempSummaryTotal
						EXEC(@QueryTransaction)
					END
				ELSE IF @TemplateItemId = 'GT-103-Summary-004'
					BEGIN
				--4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2
						SET @QueryTransaction = 'SELECT strColumnValue * ' + CONVERT(NVARCHAR(50), @TemplateConfiguration) + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@QueryTransaction)
					END

				ELSE IF @TemplateItemId = 'GT-103-Summary-005'
					BEGIN
				--5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 0.73%
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''' + @TemplateItemId + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
							ELSE
							BEGIN
								SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
					END
				ELSE IF @TemplateItemId = 'GT-103-Summary-006'
					BEGIN
				--6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @QueryTransaction  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''') - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
							ELSE
							BEGIN
								SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
					END
				ELSE IF @TemplateItemId = 'GT-103-Summary-007'
					BEGIN
				--7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''' + @TemplateItemId + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
							ELSE
							BEGIN
								SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
					END
				ELSE IF @TemplateItemId = 'GT-103-Summary-008'
					BEGIN
				--8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #3)
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''' + @TemplateItemId + '''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
							ELSE
							BEGIN
								SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
					END
				ELSE IF @TemplateItemId = 'GT-103-Summary-009'
					BEGIN
				--9. Electronic Funds Transfer Credit
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''' + @TemplateItemId + '''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
							ELSE
							BEGIN
								SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
					END

				ELSE IF @TemplateItemId = 'GT-103-Summary-010'
					BEGIN
				--10. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @QueryTransaction = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTemplateItemId = ''' + @TemplateItemId + '''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
							ELSE
							BEGIN
								SET @QueryTransaction = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@QueryTransaction)
							END
					END
				ELSE IF @TemplateItemId = 'GT-103-Summary-011'
					BEGIN
				--11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).
						SET @QueryTransaction = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @TemplateScheduleCodeParam + ''') AND strSummaryGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCodeParam + '''' 
						DECLARE @Value NVARCHAR(MAX) = ''
						SET @Value = ((SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN('6','7','8') AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid) - (SELECT strColumnValue FROM tblTFTaxReportSummary WHERE intItemNumber IN('9') AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)) + (SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN('10') AND strFormCode = @FormCodeParam AND strSummaryGuid = @Guid)
			
						INSERT INTO @tblTempSummaryTotal(dbLColumnValue)values(@Value)
						EXEC(@QueryTransaction)
					END
		

				SET @TempComputedValue = (SELECT TOP 1 ISNULL(dbLColumnValue, 0) FROM @tblTempSummaryTotal)
				PRINT @TempComputedValue

					INSERT INTO tblTFTaxReportSummary
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
						 dtmDateRun
					)		
					VALUES
					(
						 @Guid,
						 (@TA),
						 (@FormCodeParam),
						 (@TemplateScheduleCodeParam),
						 ('Summary'),
						 (''),
						 @TemplateDescription,
						 @TempComputedValue,
						 @TemplateItemNumber,
						 @ReportItemSequence,
						 @ReportSection,
						 (CAST(GETDATE() AS DATE))
					)
			END

			DELETE FROM @tblTempSummaryTotal
			SET @TemplateItemCount = @TemplateItemCount - 1
		END

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
			SET @CountTemplateItem = (SELECT COUNT(strFormCode) FROM tblTFTaxReportTemplate WHERE strSegment = 'Details' AND strFormCode = @FormCodeParam)
				WHILE(@CountTemplateItem > 0)
					BEGIN
						-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
						SET @TemplateScheduleCode = (SELECT strScheduleCode FROM tblTFTaxReportTemplate WHERE strSegment = 'Details' and intTemplateItemNumber = @CountTemplateItem AND strFormCode = @FormCodeParam)

						-- GET SCHEDULE CODE BY PASSED PARAM
						DECLARE @paramTempScheduleCode NVARCHAR(MAX)
						SET @paramTempScheduleCode = (SELECT strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE strTempScheduleCode = @TemplateScheduleCode)

						SET @TemplateItemDescription = (SELECT strDescription FROM tblTFTaxReportTemplate WHERE intTemplateItemNumber = @CountTemplateItem AND strSegment = 'Details' AND strFormCode = @FormCodeParam)
						SET @TemplateSection = (SELECT strReportSection FROM tblTFTaxReportTemplate WHERE intTemplateItemNumber = @CountTemplateItem AND strSegment = 'Details' AND strFormCode = @FormCodeParam)

						DECLARE @Type NVARCHAR(MAX)
						SET @Type = (SELECT strDescription FROM tblTFTaxReportTemplate WHERE strSegment = 'Details' and intTemplateItemNumber = @CountTemplateItem AND strFormCode = @FormCodeParam)
					
								--INSERT CALCULATED VALUE INTO TRANSACTION TABLE
								--Disbursements - Schedule 2
								IF(@TemplateSection = 'Disbursements - Schedule 2')
									BEGIN
										IF(@Type = 'Total Gallons of Fuel Sold')
											BEGIN
												SET @TotalGallonsSold = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
												SET @TotalExemptGallonsSold = (SELECT ISNULL(SUM(dblTaxExempt), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
												SET @GasolineUseTaxCollected = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)

											END
										ELSE
											BEGIN
												SET @TotalGallonsSold = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
												SET @TotalExemptGallonsSold = (SELECT ISNULL(SUM(dblTaxExempt), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
												SET @GasolineUseTaxCollected = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
											END

											INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
											VALUES(@Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details', 'Total Gallons Sold', '',@TotalGallonsSold, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))

											INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
											VALUES(@Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details','Total Exempt Gallons Sold', '',@TotalExemptGallonsSold, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))

											INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
											VALUES(@Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details','Gasoline Use Tax Collected', '',@GasolineUseTaxCollected, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))
									END
							--Receipts - Schedule 1
							IF(@TemplateSection = 'Receipts - Schedule 1')
								BEGIN
							
									IF(@Type = 'Total Gallons of Fuel Purchased')
										BEGIN
											SET @ReceiptTotalGallsPurchased = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
											SET @GasolineUseTaxPaid = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
										END
									ELSE
										BEGIN
											SET @ReceiptTotalGallsPurchased = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
											SET @GasolineUseTaxPaid = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
										END

										INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details', 'Total Gallons Purchased', '',@ReceiptTotalGallsPurchased, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))
										INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@FormCodeParam,@TemplateScheduleCode, @CountTemplateItem, 'Details','Gasoline Use Tax Paid', '',@GasolineUseTaxPaid, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))
							END
					
						SET @CountTemplateItem = @CountTemplateItem - 1
					END
			DECLARE @isTransactionEmpty NVARCHAR(20)
			SET @isTransactionEmpty = (SELECT TOP 1 strProductCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
			IF(@isTransactionEmpty = 'No record found.')
				BEGIN
					UPDATE tblTFTaxReportSummary SET strColumnValue = 0 WHERE strFormCode = @FormCodeParam
				END
END