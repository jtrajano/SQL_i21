CREATE PROCEDURE [dbo].[uspTFGT103RunTax]

@Guid NVARCHAR(250),
@FormCode NVARCHAR(50),
@ScheduleCodeParam NVARCHAR(250),
@Refresh NVARCHAR(5)

AS

DECLARE @TA INT
--DECLARE @FormCode NVARCHAR(50)

--SUMMARY VARIABLES
DECLARE @SmryTempSummaryId NVARCHAR(MAX)
DECLARE @SmryFET NVARCHAR(MAX)
DECLARE @SmrySET NVARCHAR(MAX)
DECLARE @SmrySST NVARCHAR(MAX)
DECLARE @SmryScheduleCodeParam NVARCHAR(MAX)
DECLARE @SmryTemplateItemId NVARCHAR(20)
DECLARE @SmryConfigValue NUMERIC(18, 6)
DECLARE @SmryTemplateDescription NVARCHAR(MAX)
DECLARE @SmryTemplateItemNumber NVARCHAR(MAX)
DECLARE @SmryTemplateItemSequenceNumber NVARCHAR(MAX)
DECLARE @SmryTemplateSection NVARCHAR(MAX)
DECLARE @SmryTempTotal NUMERIC(18, 6)
DECLARE @SmryTemplateItemCount NVARCHAR(MAX) 
DECLARE @SmryQuery NVARCHAR(MAX)

DECLARE @tblTempSummaryTotal TABLE (
		 dbLColumnValue NUMERIC(18, 2))

DECLARE @tblTempSummaryItem TABLE (
		Id INT IDENTITY(1,1),
		TaxReportSummaryItemId INT)

IF @Refresh = 'true'
		BEGIN
			DELETE FROM tblTFTaxReportSummary
		END

-- ======================== HEADER ==============================

DECLARE @DatePeriod DATETIME
DECLARE @DateBegin DATETIME
DECLARE @DateEnd DATETIME

DECLARE @TaxID NVARCHAR(50)
DECLARE @EIN NVARCHAR(50)

--SET @FormCode = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @TA = (SELECT TOP 1 intTaxAuthorityId FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
SET @DatePeriod = (SELECT TOP 1 dtmDate FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
SET @DateBegin = (SELECT TOP 1 dtmReportingPeriodBegin FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
SET @DateEnd = (SELECT TOP 1 dtmReportingPeriodEnd FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
SET @TaxID = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND intTaxReportSummaryItemId = 'TID')
SET @EIN = (SELECT TOP 1 strEin FROM tblSMCompanySetup)

INSERT INTO tblTFTaxReportSummary (uniqGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strTaxType, dtmDateRun, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strTaxPayerName, strTaxPayerIdentificationNumber, 
					strTaxPayerFEIN,strEmail, strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strContactName)

SELECT TOP 1 @Guid, @TA, @FormCode, '', 'Header', @DatePeriod,@DateBegin,@DateEnd, strCompanyName, @TaxID,
				@EIN, strContactEmail, strTaxAddress, strCity, strState, strZipCode, strContactPhone, strContactName from tblTFCompanyPreference
-- ======================== SUMMARY ==============================

	INSERT INTO @tblTempSummaryItem (TaxReportSummaryItemId)  -- GET SUMMARY ITEMS TABLE HELPER BY FORM AND TA THEN INSERT INTO TBLTEMPSUMMARY
	SELECT intTaxReportSummaryItems FROM tblTFTaxReportTemplate WHERE strSummaryFormCode = @FormCode AND strTaxType = 'Summary' ORDER BY intTaxReportSummaryItems DESC

	SET @SmryTemplateItemCount = (SELECT COUNT(*) FROM @tblTempSummaryItem)

	WHILE(@SmryTemplateItemCount > 0) -- LOOP ON SUMMARY ITEMS AND INSERT INTO SUMMARY TABLE
		BEGIN
			-- GET SCHEDULE CODE PARAMETERS FOR FILTERING
			SET @SmryTempSummaryId = (SELECT TaxReportSummaryItemId FROM @tblTempSummaryItem WHERE Id = @SmryTemplateItemCount)
			SET @SmryScheduleCodeParam = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryTempSummaryId AND strSummaryFormCode = @FormCode)
			SET @SmryTemplateItemId = (SELECT intTaxReportSummaryItemId FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryTempSummaryId AND strSummaryFormCode = @FormCode)

			SET @SmryScheduleCodeParam = REPLACE(@SmryScheduleCodeParam,',',''',''')
			IF (@SmryScheduleCodeParam IS NOT NULL)
			BEGIN
				SET @SmryTemplateDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryTempSummaryId AND strSummaryFormCode = @FormCode)
				SET @SmryTemplateItemSequenceNumber = (SELECT intSummaryItemSequenceNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryTempSummaryId AND strSummaryFormCode = @FormCode)
				SET @SmryTemplateItemNumber = (SELECT intSummaryItemNumber FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryTempSummaryId AND strSummaryFormCode = @FormCode)
				SET @SmryTemplateSection = (SELECT strSummarySection FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryTempSummaryId AND strSummaryFormCode = @FormCode)
				SET @SmryConfigValue = (SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItems = @SmryTempSummaryId AND strSummaryFormCode = @FormCode)
				-- INSERT COMPUTED VALUES ON TEMPORARY TOTAL TABLE

				IF @SmryTemplateItemId = 'GT-103-Summary-001'
					BEGIN
				--1. Total Gallons Sold for Period
						SET @SmryQuery = 'SELECT SUM(dblQtyShipped) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCode + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmryTemplateItemId = 'GT-103-Summary-002'
					BEGIN
				--2. Total Exempt Gallons Sold for Period
						SET @SmryQuery = 'SELECT SUM(dblTaxExempt) FROM tblTFTransactions WHERE strScheduleCode IN (''' + @SmryScheduleCodeParam + ''') AND uniqTransactionGuid = ''' + @Guid + ''' AND strFormCode = ''' + @FormCode + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
					ELSE IF @SmryTemplateItemId = 'GT-103-Summary-003'
					BEGIN
				--3. Total Taxable Gallons Sold (Line 1 minus Line 2)
						SET @SmryQuery = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')  AND uniqGuid = ''' + @Guid + ''''
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END
				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-004'
					BEGIN
				--4. Gasoline Use Tax Due. (Line 3 multiplied by the current rate. See Departmental Notice #2
						SET @SmryQuery = 'SELECT strColumnValue * ' + CONVERT(NVARCHAR(50), @SmryConfigValue) + ' FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCodeParam + ''') AND uniqGuid = ''' + @Guid + ''''  
						INSERT INTO @tblTempSummaryTotal
						EXEC(@SmryQuery)
					END

				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-005'
					BEGIN
				--5. Collection Allowance. Do not calculate this allowance if your return and payment are late. Collection allowance rate is 0.73%
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''' + @SmryTemplateItemId + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
							ELSE
							BEGIN
								SET @SmryQuery = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
					END
				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-006'
					BEGIN
				--6. Net Gasoline Use Tax Due. Subtotal of use tax and collection allowance. (Line 4 minus Line 5)
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @SmryQuery  = 'SELECT TOP 1 (a.strColumnValue) - ((SELECT SUM(b.strColumnValue) FROM tblTFTaxReportSummary b WHERE b.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')) - (a.strColumnValue)) FROM   tblTFTaxReportSummary a WHERE a.intItemNumber IN (''' + @SmryScheduleCodeParam + ''')  AND uniqGuid = ''' + @Guid + ''''
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
							ELSE
							BEGIN
								SET @SmryQuery = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
					END
				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-007'
					BEGIN
				--7. Penalty Due. If late, the penalty is 10% of the tax due on Line 6 or $5, whichever is greater.
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''' + @SmryTemplateItemId + ''''  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
							ELSE
							BEGIN
								SET @SmryQuery = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
					END
				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-008'
					BEGIN
				--8. Interest Due. If late, multiply Line 6 by the interest rate (see Departmental Notice #3)
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''' + @SmryTemplateItemId + '''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
							ELSE
							BEGIN
								SET @SmryQuery = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
					END
				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-009'
					BEGIN
				--9. Electronic Funds Transfer Credit
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''' + @SmryTemplateItemId + '''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
							ELSE
							BEGIN
								SET @SmryQuery = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
					END

				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-010'
					BEGIN
				--10. Adjustments. If negative entry, use a negative sign. (You must provide an explanation and
						IF(@ScheduleCodeParam <> '')
							BEGIN
								SET @SmryQuery = 'SELECT strConfiguration FROM tblTFTaxReportTemplate WHERE intTaxReportSummaryItemId = ''' + @SmryTemplateItemId + '''' 
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
							ELSE
							BEGIN
								SET @SmryQuery = 'SELECT TOP 1 0 FROM tblTFTaxReportTemplate'  
								INSERT INTO @tblTempSummaryTotal
								EXEC(@SmryQuery)
							END
					END
				ELSE IF @SmryTemplateItemId = 'GT-103-Summary-011'
					BEGIN
				--11. Total Amount Due. (Add Lines 6 through 8, subtract Line 9, add Line 10).
						SET @SmryQuery = 'SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN (''' + @SmryScheduleCodeParam + ''') AND uniqGuid = ''' + @Guid + '''' 
						DECLARE @Value NVARCHAR(MAX) = ''
						SET @Value = ((SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN('6','7','8') AND strFormCode = @FormCode) - (SELECT strColumnValue FROM tblTFTaxReportSummary WHERE intItemNumber IN('9') AND strFormCode = @FormCode)) + (SELECT SUM(strColumnValue) FROM tblTFTaxReportSummary WHERE intItemNumber IN('10') AND strFormCode = @FormCode)
			
						INSERT INTO @tblTempSummaryTotal(dbLColumnValue)values(@Value)
						EXEC(@SmryQuery)
					END
		

				SET @SmryTempTotal = (SELECT TOP 1 ISNULL(dbLColumnValue, 0) FROM @tblTempSummaryTotal)
				PRINT @SmryTempTotal

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
						 @SmryTemplateDescription,
						 @SmryTempTotal,
						 @SmryTemplateItemNumber,
						 @SmryTemplateItemSequenceNumber,
						 @SmryTemplateSection,
						 (CAST(GETDATE() AS DATE))
					)
			END

			DELETE FROM @tblTempSummaryTotal
			SET @SmryTemplateItemCount = @SmryTemplateItemCount - 1
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
			SET @CountTemplateItem = (SELECT COUNT(strSummaryFormCode) FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' AND strSummaryFormCode = @FormCode)
				WHILE(@CountTemplateItem > 0)
					BEGIN
						-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
						SET @TemplateScheduleCode = (SELECT strSummaryScheduleCode FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' and intSummaryItemNumber = @CountTemplateItem AND strSummaryFormCode = @FormCode)

						-- GET SCHEDULE CODE BY PASSED PARAM
						DECLARE @paramTempScheduleCode NVARCHAR(MAX)
						SET @paramTempScheduleCode = (SELECT strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE strTempScheduleCode = @TemplateScheduleCode)

						SET @TemplateItemDescription = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE intSummaryItemNumber = @CountTemplateItem AND strTaxType = 'Details' AND strSummaryFormCode = @FormCode)
						SET @TemplateSection = (SELECT strSummarySection FROM tblTFTaxReportTemplate WHERE intSummaryItemNumber = @CountTemplateItem AND strTaxType = 'Details' AND strSummaryFormCode = @FormCode)

						DECLARE @Type NVARCHAR(MAX)
						SET @Type = (SELECT strSummaryItemDescription FROM tblTFTaxReportTemplate WHERE strTaxType = 'Details' and intSummaryItemNumber = @CountTemplateItem AND strSummaryFormCode = @FormCode)
					
								--INSERT CALCULATED VALUE INTO TRANSACTION TABLE
								--Disbursements - Schedule 2
								IF(@TemplateSection = 'Disbursements - Schedule 2')
									BEGIN
										IF(@Type = 'Total Gallons of Fuel Sold')
											BEGIN
												SET @TotalGallonsSold = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
												SET @TotalExemptGallonsSold = (SELECT ISNULL(SUM(dblTaxExempt), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
												SET @GasolineUseTaxCollected = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)

											END
										ELSE
											BEGIN
												SET @TotalGallonsSold = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
												SET @TotalExemptGallonsSold = (SELECT ISNULL(SUM(dblTaxExempt), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
												SET @GasolineUseTaxCollected = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
											END

											INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
											VALUES(@Guid,@TA,@FormCode,@TemplateScheduleCode, @CountTemplateItem, 'Details', 'Total Gallons Sold', '',@TotalGallonsSold, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))

											INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
											VALUES(@Guid,@TA,@FormCode,@TemplateScheduleCode, @CountTemplateItem, 'Details','Total Exempt Gallons Sold', '',@TotalExemptGallonsSold, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))

											INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
											VALUES(@Guid,@TA,@FormCode,@TemplateScheduleCode, @CountTemplateItem, 'Details','Gasoline Use Tax Collected', '',@GasolineUseTaxCollected, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))
									END
							--Receipts - Schedule 1
							IF(@TemplateSection = 'Receipts - Schedule 1')
								BEGIN
							
									IF(@Type = 'Total Gallons of Fuel Purchased')
										BEGIN
											SET @ReceiptTotalGallsPurchased = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
											SET @GasolineUseTaxPaid = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
										END
									ELSE
										BEGIN
											SET @ReceiptTotalGallsPurchased = (SELECT ISNULL(SUM(dblGross), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
											SET @GasolineUseTaxPaid = (SELECT ISNULL(SUM(dblTax), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramTempScheduleCode AND strType = @Type AND uniqTransactionGuid = @Guid AND strFormCode = @FormCode)
										END

										INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@FormCode,@TemplateScheduleCode, @CountTemplateItem, 'Details', 'Total Gallons Purchased', '',@ReceiptTotalGallsPurchased, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))
										INSERT INTO tblTFTaxReportSummary (uniqGuid,intTaxAuthorityId,strFormCode, strScheduleCode, intItemSequenceNumber, strTaxType, strColumn,strProductCode,strColumnValue, strSection,strDescription, dtmDateRun)		
										VALUES(@Guid,@TA,@FormCode,@TemplateScheduleCode, @CountTemplateItem, 'Details','Gasoline Use Tax Paid', '',@GasolineUseTaxPaid, @TemplateSection, @TemplateItemDescription, CAST(GETDATE() AS DATE))
							END
					
						SET @CountTemplateItem = @CountTemplateItem - 1
					END