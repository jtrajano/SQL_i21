CREATE PROCEDURE [dbo].[uspTFGenerateSF401]

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
DECLARE @MotorCarrier NVARCHAR(50)
DECLARE @EIN NVARCHAR(50)

--SET @FormCodeParam = (SELECT TOP 1 strFormCode FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid)
SET @TA = (SELECT TOP 1 intTaxAuthorityId FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @TACode = (SELECT TOP 1 strTaxAuthority FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DatePeriod = (SELECT TOP 1 dtmDate FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DateBegin = (SELECT TOP 1 dtmReportingPeriodBegin FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @DateEnd = (SELECT TOP 1 dtmReportingPeriodEnd FROM tblTFTransactions WHERE uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
SET @LicenseNumber = (SELECT TOP 1 strConfiguration FROM tblTFTaxReportTemplate WHERE strFormCode = @FormCodeParam AND strTemplateItemId = 'SF-401-LicenseNumber')
SET @MotorCarrier = (SELECT TOP 1 strConfiguration FROM tblTFTaxReportTemplate WHERE strFormCode = @FormCodeParam AND strTemplateItemId = 'SF-401-MotorCarrier')
SET @EIN = (SELECT TOP 1 strEin FROM tblSMCompanySetup)


	INSERT INTO tblTFTaxReportSummary (strSummaryGuid, intTaxAuthorityId, strFormCode, strScheduleCode, strSegment, dtmDateRun, dtmReportingPeriodBegin, dtmReportingPeriodEnd, strTaxPayerName, 
		 		strFEINSSN, strEmail, strTaxPayerAddress, strCity, strState, strZipCode, strTelephoneNumber, strContactName, strLicenseNumber, strMotorCarrier)

	SELECT TOP 1 @Guid, @TA, @FormCodeParam, '', 'Header', @DatePeriod,@DateBegin,@DateEnd, strCompanyName,
					@EIN, strContactEmail, strTaxAddress, strCity, strState, strZipCode, strContactPhone, strContactName, @LicenseNumber, @MotorCarrier from tblTFCompanyPreference

-- ======================== DETAIL ==============================
	DECLARE @ItemTotal NVARCHAR(MAX)
	DECLARE @itemQuery NVARCHAR(MAX)
	DECLARE @CountItems INT

	DECLARE @ItemDescription nvarchar(MAX)
	SELECT @QueryScheduleCodeParam = 'SELECT ''' + REPLACE (@ScheduleCodeParam,',',''' UNION SELECT ''') + ''''
	INSERT INTO @tblTempScheduleCodeParam (strTempScheduleCode)
	EXEC(@QueryScheduleCodeParam)

	select * from @tblTempScheduleCodeParam

	SET @CountItems = (SELECT COUNT(strFormCode) FROM tblTFTaxReportTemplate WHERE strSegment = 'Summary' AND strFormCode = @FormCodeParam) --COUNT TEMPLATE

		WHILE(@CountItems > 0)
			BEGIN
				DECLARE @tplScheduleCode NVARCHAR(MAX)
				-- GET SCHEDULE CODES BY COUNT ID FROM TEMPLATE TABLE
				SET @tplScheduleCode = (SELECT strScheduleCode FROM tblTFTaxReportTemplate WHERE strSegment = 'Summary' and intTemplateItemNumber = @CountItems AND strFormCode = @FormCodeParam)

				
				SET @ItemDescription = (SELECT strDescription FROM tblTFTaxReportTemplate WHERE intTemplateItemNumber = @CountItems AND strSegment = 'Summary' AND strFormCode = @FormCodeParam)
					
							DECLARE @SchedQuery NVARCHAR(MAX)
							IF (@CountItems = 4)
								BEGIN
									SELECT @SchedQuery = 'SELECT ''' + REPLACE (@tplScheduleCode,',',''' UNION SELECT ''') + ''''
									INSERT INTO @tblSchedule (strSchedule)
									EXEC(@SchedQuery)

									SELECT strSchedule FROM @tblSchedule
									SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN ('1A','2A','3A')

									INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
									VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 1, 'Summary','Column A Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN ('1A','2A','3A') AND strType = 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
									
									
									INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
									VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 2, 'Summary','Column B Gasoline (Gasoline, Gasohol)', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN ('1A','2A','3A') AND strType = 'Gasoline (Gasoline, Gasohol)' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
									-- OTHERS
									INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
									VALUES(@Guid,@TA,@TACode,@FormCodeParam,'', 3, 'Summary','Column C Other Products (Jet Fuel, Kerosene)', '',(SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode IN ('1A','2A','3A') AND strType = 'Other Products (Jet Fuel, Kerosene)' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam), @ItemDescription, CAST(GETDATE() AS DATE))
									
									DELETE FROM @tblSchedule
								END
							ELSE
								BEGIN
								-- GET SCHEDULE CODE BY PASSED PARAM
									DECLARE @paramScheduleCode NVARCHAR(MAX)
									SET @paramScheduleCode = (SELECT strTempScheduleCode FROM @tblTempScheduleCodeParam WHERE strTempScheduleCode = @tplScheduleCode)
									PRINT @paramScheduleCode
									SET @DetailColumnValue_gas = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)

									
									SET @DetailColumnValue_kerosene = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Gasoline (Gasoline, Gasohol)' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)


									SET @DetailColumnValue_others = (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblTFTransactions WHERE strScheduleCode = @paramScheduleCode AND strType = 'Other Products (Jet Fuel, Kerosene)' AND uniqTransactionGuid = @Guid AND strFormCode = @FormCodeParam)
									
									-- GAS
									DECLARE @SmryDetailItemId NVARCHAR(MAX)
									SET @SmryDetailItemId = (SELECT strTemplateItemId FROM tblTFTaxReportTemplate WHERE strSegment = 'Summary' and intTemplateItemNumber = @CountItems AND strFormCode = @FormCodeParam)
							
									INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment, strColumn,strProductCode,strColumnValue, strDescription, dtmDateRun)		
									VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 1, 'Summary','Column A Special Fuel (Dyed and Clear Diesel Fuel, Biodiesel and Blended Biodiesel)', '',@DetailColumnValue_gas, @ItemDescription, CAST(GETDATE() AS DATE))
							
									-- KEROSENE
									INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
									VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 2, 'Summary','Column B Gasoline (Gasoline, Gasohol)', '',@DetailColumnValue_kerosene, @ItemDescription, CAST(GETDATE() AS DATE))

									-- OTHERS
									INSERT INTO tblTFTaxReportSummary (strSummaryGuid,intTaxAuthorityId,strTaxAuthority,strFormCode, strScheduleCode, intItemSequenceNumber, strSegment,strColumn,strProductCode,strColumnValue,strDescription,dtmDateRun)		
									VALUES(@Guid,@TA,@TACode,@FormCodeParam,@tplScheduleCode, 3, 'Summary','Column C Other Products (Jet Fuel, Kerosene)', '',@DetailColumnValue_others, @ItemDescription, CAST(GETDATE() AS DATE))
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