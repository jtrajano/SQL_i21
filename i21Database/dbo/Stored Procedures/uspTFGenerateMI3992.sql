CREATE PROCEDURE [dbo].[uspTFGenerateMI3992]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @Output TABLE(
		  dblLine8_Col1 NUMERIC(18,0)
		, dblLine8_Col2 NUMERIC(18,0)
		, dblLine8_Col3 NUMERIC(18,0)
		, dblLine8_Col4 NUMERIC(18,0)
		, dblLine8_Col5 NUMERIC(18,0)
		, dblLine9_Col1 NUMERIC(18,0)
		, dblLine9_Col2 NUMERIC(18,0)
		, dblLine9_Col3 NUMERIC(18,0)
		, dblLine9_Col4 NUMERIC(18,0)
		, dblLine9_Col5 NUMERIC(18,0)
		, dblLine10_Col1 NUMERIC(18,0)
		, dblLine10_Col2 NUMERIC(18,0)
		, dblLine10_Col3 NUMERIC(18,0)
		, dblLine10_Col4 NUMERIC(18,0)
		, dblLine10_Col5 NUMERIC(18,0)
		, dblLine11_Col1 NUMERIC(18,0)
		, dblLine11_Col2 NUMERIC(18,0)
		, dblLine11_Col5 NUMERIC(18,0)
		, dblLine12_Col1 NUMERIC(18,0)
		, dblLine12_Col2 NUMERIC(18,0)
		, dblLine12_Col3 NUMERIC(18,0)
		, dblLine12_Col4 NUMERIC(18,0)
		, dblLine12_Col5 NUMERIC(18,0)
		, dblLine13_Col1 NUMERIC(18,0)
		, dblLine13_Col2 NUMERIC(18,0)
		, dblLine13_Col3 NUMERIC(18,0)
		, dblLine13_Col4 NUMERIC(18,0)
		, dblLine13_Col5 NUMERIC(18,0)
		, dblLine14_Col1 NUMERIC(18,0)
		, dblLine14_Col2 NUMERIC(18,0)
		, dblLine14_Col3 NUMERIC(18,0)
		, dblLine14_Col4 NUMERIC(18,0)
		, dblLine14_Col5 NUMERIC(18,0)
		, dblLine15_Col1 NUMERIC(18,0)
		, dblLine15_Col2 NUMERIC(18,0)
		, dblLine15_Col3 NUMERIC(18,0)
		, dblLine15_Col4 NUMERIC(18,0)
		, dblLine15_Col5 NUMERIC(18,0)
		, strTaxRate_Col1 NVARCHAR(25)
		, strTaxRate_Col2 NVARCHAR(25)
		, strTaxRate_Col3 NVARCHAR(25)
		, strTaxRate_Col4 NVARCHAR(25)
		, strTaxRate_Col5 NVARCHAR(25)
		, dblLine16a NUMERIC(18,0)
		, dblLine16b NUMERIC(18,0)
		, dblLine16c NUMERIC(18,0)
		, dblLine17 NUMERIC(18,0)
		, strLine18 NVARCHAR(25)
		, strLine19 NVARCHAR(25)
		, dblLine20 NUMERIC(18,2)
		, dblLine21_Col1 NUMERIC(18,0)
		, dblLine21_Col2 NUMERIC(18,0)
		, dblLine21_Col3 NUMERIC(18,0)
		, dblLine21_Col4 NUMERIC(18,0)
		, dblLine21_Col5 NUMERIC(18,0)
		, dblLine21_Col6 NUMERIC(18,0)
		, dblLine22_Col1 NUMERIC(18,0)
		, dblLine22_Col2 NUMERIC(18,0)
		, dblLine22_Col3 NUMERIC(18,0)
		, dblLine22_Col4 NUMERIC(18,0)
		, dblLine22_Col5 NUMERIC(18,0)
		, dblLine22_Col6 NUMERIC(18,0)	
		, dblLine23_Col5 NUMERIC(18,0)
		, dblLine24_Col1 NUMERIC(18,0)
		, dblLine24_Col2 NUMERIC(18,0)
		, dblLine24_Col3 NUMERIC(18,0)
		, dblLine24_Col4 NUMERIC(18,0)
		, dblLine24_Col6 NUMERIC(18,0)
		, dblLine25_Col6 NUMERIC(18,0)	
		, dblLine26_Col3 NUMERIC(18,0)
		, dblLine26_Col4 NUMERIC(18,0)
		, dblLine26_Col5 NUMERIC(18,0)
		, dblLine27_Col1 NUMERIC(18,0)
		, dblLine27_Col2 NUMERIC(18,0)
		, dblLine27_Col3 NUMERIC(18,0)
		, dblLine27_Col4 NUMERIC(18,0)
		, dblLine27_Col6 NUMERIC(18,0)
		, dblLine28_Col5 NUMERIC(18,0)
		, dblLine29_Col1 NUMERIC(18,0)
		, dblLine29_Col2 NUMERIC(18,0)
		, dblLine29_Col3 NUMERIC(18,0)
		, dblLine29_Col4 NUMERIC(18,0)
		, dblLine29_Col5 NUMERIC(18,0)
		, dblLine29_Col6 NUMERIC(18,0)
		, dblLine30_Col1 NUMERIC(18,0)
		, dblLine30_Col2 NUMERIC(18,0)
		, dblLine30_Col3 NUMERIC(18,0)
		, dblLine30_Col4 NUMERIC(18,0)
		, dblLine30_Col5 NUMERIC(18,0)
		, dblLine30_Col6 NUMERIC(18,0)
		, strLine31_Col1 NVARCHAR(25)
		, strLine31_Col2 NVARCHAR(25)
		, strLine31_Col3 NVARCHAR(25)
		, strLine31_Col4 NVARCHAR(25)
		, strLine31_Col5 NVARCHAR(25)
		, dblLine32_Col1 NUMERIC(18,0)
		, dblLine32_Col2 NUMERIC(18,0)
		, dblLine32_Col3 NUMERIC(18,0)
		, dblLine32_Col4 NUMERIC(18,0)
		, dblLine32_Col5 NUMERIC(18,0)
		, dblLine32_Col6 NUMERIC(18,0)
		, dblLine33_Col1 NUMERIC(18,0)
		, dblLine33_Col2 NUMERIC(18,0)
		, strLine34_Col1 NVARCHAR(25)
		, strLine34_Col2 NVARCHAR(25)
		, strLine34_Col3 NVARCHAR(25)
		, strLine34_Col4 NVARCHAR(25)
		, strLine34_Col5 NVARCHAR(25)
		, dblLine35_Col1 NUMERIC(18,0)
		, dblLine35_Col2 NUMERIC(18,0)
		, dblLine35_Col3 NUMERIC(18,0)
		, dblLine35_Col4 NUMERIC(18,0)
		, dblLine35_Col5 NUMERIC(18,0)
		, dblLine35_Col6 NUMERIC(18,0)
		, dtmFrom DATE
		, dtmTo DATE
		, strLine11_AllowanceRate NVARCHAR(25)
	)

	DECLARE @dblLine8_Col1 NUMERIC(18,0)
		, @dblLine8_Col2 NUMERIC(18,0)
		, @dblLine8_Col3 NUMERIC(18,0)
		, @dblLine8_Col4 NUMERIC(18,0)
		, @dblLine8_Col5 NUMERIC(18,0)
		, @dblLine9_Col1 NUMERIC(18,0)
		, @dblLine9_Col2 NUMERIC(18,0)
		, @dblLine9_Col3 NUMERIC(18,0)
		, @dblLine9_Col4 NUMERIC(18,0)
		, @dblLine9_Col5 NUMERIC(18,0)
		, @dblLine10_Col1 NUMERIC(18,0)
		, @dblLine10_Col2 NUMERIC(18,0)
		, @dblLine10_Col3 NUMERIC(18,0)
		, @dblLine10_Col4 NUMERIC(18,0)
		, @dblLine10_Col5 NUMERIC(18,0)
		, @dblLine11_Col1 NUMERIC(18,0)
		, @dblLine11_Col2 NUMERIC(18,0)
		, @dblLine11_Col5 NUMERIC(18,0)
		, @dblLine12_Col1 NUMERIC(18,0)
		, @dblLine12_Col2 NUMERIC(18,0)
		, @dblLine12_Col3 NUMERIC(18,0)
		, @dblLine12_Col4 NUMERIC(18,0)
		, @dblLine12_Col5 NUMERIC(18,0)
		, @dblLine13_Col1 NUMERIC(18,0)
		, @dblLine13_Col2 NUMERIC(18,0)
		, @dblLine13_Col3 NUMERIC(18,0)
		, @dblLine13_Col4 NUMERIC(18,0)
		, @dblLine13_Col5 NUMERIC(18,0)
		, @dblLine14_Col1 NUMERIC(18,0)
		, @dblLine14_Col2 NUMERIC(18,0)
		, @dblLine14_Col3 NUMERIC(18,0)
		, @dblLine14_Col4 NUMERIC(18,0)
		, @dblLine14_Col5 NUMERIC(18,0)
		, @dblLine15_Col1 NUMERIC(18,0)
		, @dblLine15_Col2 NUMERIC(18,0)
		, @dblLine15_Col3 NUMERIC(18,0)
		, @dblLine15_Col4 NUMERIC(18,0)
		, @dblLine15_Col5 NUMERIC(18,0)
		, @strTaxRate_Col1 NVARCHAR(25)
		, @strTaxRate_Col2 NVARCHAR(25)
		, @strTaxRate_Col3 NVARCHAR(25)
		, @strTaxRate_Col4 NVARCHAR(25)
		, @strTaxRate_Col5 NVARCHAR(25)
		, @dblLine16a NUMERIC(18,0)
		, @dblLine16b NUMERIC(18,0)
		, @dblLine16c NUMERIC(18,0)
		, @dblLine17 NUMERIC(18,0)
		, @strLine18 NVARCHAR(25)
		, @strLine19 NVARCHAR(25)
		, @dblLine20 NUMERIC(18,2)
		, @dblLine21_Col1 NUMERIC(18,0)
		, @dblLine21_Col2 NUMERIC(18,0)
		, @dblLine21_Col3 NUMERIC(18,0)
		, @dblLine21_Col4 NUMERIC(18,0)
		, @dblLine21_Col5 NUMERIC(18,0)
		, @dblLine21_Col6 NUMERIC(18,0)
		, @dblLine22_Col1 NUMERIC(18,0)
		, @dblLine22_Col2 NUMERIC(18,0)
		, @dblLine22_Col3 NUMERIC(18,0)
		, @dblLine22_Col4 NUMERIC(18,0)
		, @dblLine22_Col5 NUMERIC(18,0)	
		, @dblLine22_Col6 NUMERIC(18,0)	
		, @dblLine23_Col5 NUMERIC(18,0)
		, @dblLine24_Col1 NUMERIC(18,0)
		, @dblLine24_Col2 NUMERIC(18,0)
		, @dblLine24_Col3 NUMERIC(18,0)
		, @dblLine24_Col4 NUMERIC(18,0)
		, @dblLine24_Col6 NUMERIC(18,0)
		, @dblLine25_Col6 NUMERIC(18,0)	
		, @dblLine26_Col3 NUMERIC(18,0)
		, @dblLine26_Col4 NUMERIC(18,0)
		, @dblLine26_Col5 NUMERIC(18,0)
		, @dblLine27_Col1 NUMERIC(18,0)
		, @dblLine27_Col2 NUMERIC(18,0)
		, @dblLine27_Col3 NUMERIC(18,0)
		, @dblLine27_Col4 NUMERIC(18,0)
		, @dblLine27_Col6 NUMERIC(18,0)
		, @dblLine28_Col5 NUMERIC(18,0)
		, @dblLine29_Col1 NUMERIC(18,0)
		, @dblLine29_Col2 NUMERIC(18,0)
		, @dblLine29_Col3 NUMERIC(18,0)
		, @dblLine29_Col4 NUMERIC(18,0)
		, @dblLine29_Col5 NUMERIC(18,0)
		, @dblLine29_Col6 NUMERIC(18,0)
		, @dblLine30_Col1 NUMERIC(18,0)
		, @dblLine30_Col2 NUMERIC(18,0)
		, @dblLine30_Col3 NUMERIC(18,0)
		, @dblLine30_Col4 NUMERIC(18,0)
		, @dblLine30_Col5 NUMERIC(18,0)
		, @dblLine30_Col6 NUMERIC(18,0)
		, @strLine31_Col1 NVARCHAR(25)
		, @strLine31_Col2 NVARCHAR(25)
		, @strLine31_Col3 NVARCHAR(25)
		, @strLine31_Col4 NVARCHAR(25)
		, @strLine31_Col5 NVARCHAR(25)
		, @dblLine32_Col1 NUMERIC(18,0)
		, @dblLine32_Col2 NUMERIC(18,0)
		, @dblLine32_Col3 NUMERIC(18,0)
		, @dblLine32_Col4 NUMERIC(18,0)
		, @dblLine32_Col5 NUMERIC(18,0)
		, @dblLine32_Col6 NUMERIC(18,0)
		, @dblLine33_Col1 NUMERIC(18,0)
		, @dblLine33_Col2 NUMERIC(18,0)
		, @strLine34_Col1 NVARCHAR(25)
		, @strLine34_Col2 NVARCHAR(25)
		, @strLine34_Col3 NVARCHAR(25)
		, @strLine34_Col4 NVARCHAR(25)
		, @strLine34_Col5 NVARCHAR(25)
		, @dblLine35_Col1 NUMERIC(18,0)
		, @dblLine35_Col2 NUMERIC(18,0)
		, @dblLine35_Col3 NUMERIC(18,0)
		, @dblLine35_Col4 NUMERIC(18,0)
		, @dblLine35_Col5 NUMERIC(18,0)
		, @dblLine35_Col6 NUMERIC(18,0)
		, @dtmFrom DATE
		, @dtmTo DATE
		, @strLine11_AllowanceRate NVARCHAR(25)
		, @dblLine11_AllowanceRate  NUMERIC(18,8)
		, @dblTaxRate_Col1 NUMERIC(18,8)
		, @dblTaxRate_Col2 NUMERIC(18,8)
		, @dblTaxRate_Col3 NUMERIC(18,8)
		, @dblTaxRate_Col4 NUMERIC(18,8)
		, @dblTaxRate_Col5 NUMERIC(18,8)
		, @dblLine18 NUMERIC(18,8)
		, @dblLine19 NUMERIC(18,8)

	IF (ISNULL(@xmlParam,'') != '')
	BEGIN
		DECLARE @Guid NVARCHAR(250)

		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
		
		DECLARE @Params TABLE ([fieldname] NVARCHAR(50)
				, condition NVARCHAR(20)      
				, [from] NVARCHAR(50)
				, [to] NVARCHAR(50)
				, [join] NVARCHAR(10)
				, [begingroup] NVARCHAR(50)
				, [endgroup] NVARCHAR(50) 
				, [datatype] NVARCHAR(50)) 
 
		INSERT INTO @Params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH ([fieldname] NVARCHAR(50)
			, condition NVARCHAR(20)
			, [from] NVARCHAR(50)
			, [to] NVARCHAR(50)
			, [join] NVARCHAR(10)
			, [begingroup] NVARCHAR(50)
			, [endgroup] NVARCHAR(50)
			, [datatype] NVARCHAR(50))

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		-- PART 2
		SELECT @dblLine21_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Gasoline'
		SELECT @dblLine21_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine21_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Undyed Diesel'
		SELECT @dblLine21_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine21_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Dyed Diesel'
		SELECT @dblLine21_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Aviation'

		SELECT @dblLine22_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3B' AND strType = 'Gasoline'
		SELECT @dblLine22_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3B' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine22_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3B' AND strType = 'Undyed Diesel'
		SELECT @dblLine22_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3B' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine22_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3B' AND strType = 'Dyed Diesel'
		SELECT @dblLine22_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3B' AND strType = 'Aviation'

		SELECT @dblLine23_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Dyed Diesel'
	
		-- PART 3
		SELECT @dblLine24_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Gasoline'
		SELECT @dblLine24_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine24_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Undyed Diesel'
		SELECT @dblLine24_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine24_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Aviation'

		SELECT @dblLine25_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5C' AND strType = 'Aviation'

		SELECT @dblLine26_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5F' AND strType = 'Undyed Diesel'
		SELECT @dblLine26_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5F' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine26_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5F' AND strType = 'Dyed Diesel'

		SET @dblLine27_Col1 = ISNULL(@dblLine24_Col1, 0)
		SET @dblLine27_Col2 = ISNULL(@dblLine24_Col2, 0)
		SET @dblLine27_Col3 = ISNULL(@dblLine24_Col3, 0) + ISNULL(@dblLine26_Col3, 0)
		SET @dblLine27_Col4 = ISNULL(@dblLine24_Col4, 0) + ISNULL(@dblLine26_Col4, 0) 
		SET @dblLine27_Col6 = ISNULL(@dblLine24_Col6, 0) + ISNULL(@dblLine25_Col6, 0)
		
		-- PART 4
		SELECT @dblLine28_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6F' AND strType = 'Dyed Diesel'
	
		SELECT @dblLine29_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Gasoline'
		SELECT @dblLine29_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine29_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Undyed Diesel'
		SELECT @dblLine29_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine29_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Dyed Diesel'
		SELECT @dblLine29_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Aviation'

		SELECT @dblLine30_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Gasoline'
		SELECT @dblLine30_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine30_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Undyed Diesel'
		SELECT @dblLine30_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine30_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Dyed Diesel'
		SELECT @dblLine30_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Aviation'

		SELECT @strLine31_Col1 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line31Gas'
		SELECT @strLine31_Col2 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line31Ethanol'
		SELECT @strLine31_Col3 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line31UndyedDiesel'
		SELECT @strLine31_Col4 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line31UndyedBio'
		SELECT @strLine31_Col5 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line31DyedDiesel'

		SELECT @dblLine32_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Gasoline'
		SELECT @dblLine32_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine32_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Undyed Diesel'
		SELECT @dblLine32_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine32_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Dyed Diesel'
		SELECT @dblLine32_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Aviation'

		SELECT @dblLine33_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10M' AND strType = 'Gasoline'
		SELECT @dblLine33_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10M' AND strType = 'Ethanol Blends (E70 - E99)'

		SELECT @strLine34_Col1 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line34Gas'
		SELECT @strLine34_Col2 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line34Ethanol'
		SELECT @strLine34_Col3 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line34UndyedDiesel'
		SELECT @strLine34_Col4 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line34UndyedBio'
		SELECT @strLine34_Col5 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line34DyedBio'

		SELECT @dblLine35_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Gasoline'
		SELECT @dblLine35_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine35_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Undyed Diesel'
		SELECT @dblLine35_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine35_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Dyed Diesel'
		SELECT @dblLine35_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Aviation'

		-- PART 1
		SET @dblLine8_Col1 = @dblLine27_Col1
		SET @dblLine8_Col2 = @dblLine27_Col2
		SET @dblLine8_Col3 = @dblLine27_Col3
		SET @dblLine8_Col4 = @dblLine27_Col4
		SET @dblLine8_Col5 = @dblLine27_Col6

		SELECT @dblLine9_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Gasoline'
		SELECT @dblLine9_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine9_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Undyed Diesel'
		SELECT @dblLine9_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine9_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Aviation'

		SET @dblLine10_Col1 = @dblLine8_Col1 - @dblLine9_Col1
		SET @dblLine10_Col2 = @dblLine8_Col2 - @dblLine9_Col2
		SET @dblLine10_Col3 = @dblLine8_Col3 - @dblLine9_Col3
		SET @dblLine10_Col4 = @dblLine8_Col4 - @dblLine9_Col4
		SET @dblLine10_Col5 = @dblLine8_Col5 - @dblLine9_Col5

		SELECT @strLine11_AllowanceRate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line11'
		SET @dblLine11_AllowanceRate = CONVERT(NUMERIC(18,8), @strLine11_AllowanceRate) 

		SET @dblLine11_Col1 = @dblLine10_Col1 * @dblLine11_AllowanceRate
		SET @dblLine11_Col2 = @dblLine10_Col2 * @dblLine11_AllowanceRate
		SET @dblLine11_Col5 = @dblLine10_Col5 * @dblLine11_AllowanceRate

		SET @dblLine12_Col1 = @dblLine10_Col1 - @dblLine11_Col1
		SET @dblLine12_Col2 = @dblLine10_Col2 - @dblLine11_Col2
		SET @dblLine12_Col3 = @dblLine10_Col3 
		SET @dblLine12_Col4 = @dblLine10_Col4 
		SET @dblLine12_Col5 = @dblLine10_Col5 - @dblLine11_Col5

		SELECT @dblLine13_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Gasoline'
		SELECT @dblLine13_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine13_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Undyed Diesel'
		SELECT @dblLine13_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine13_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Aviation'

		SET @dblLine14_Col1 = @dblLine12_Col1 + @dblLine13_Col1
		SET @dblLine14_Col2 = @dblLine12_Col2 + @dblLine13_Col2
		SET @dblLine14_Col3 = @dblLine12_Col3 + @dblLine13_Col3
		SET @dblLine14_Col4 = @dblLine12_Col4 + @dblLine13_Col4
		SET @dblLine14_Col5 = @dblLine12_Col5 + @dblLine13_Col5

		SELECT @strTaxRate_Col1 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-TaxRateGas'
		SELECT @strTaxRate_Col2 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-TaxRateEthanol'
		SELECT @strTaxRate_Col3 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-TaxRateUndyedDiesel'
		SELECT @strTaxRate_Col4 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-TaxRateUndyedBIo'
		SELECT @strTaxRate_Col5 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-TaxRateAviation'

		SET @dblTaxRate_Col1 = CONVERT(NUMERIC(18,8), @strTaxRate_Col1) 
		SET @dblTaxRate_Col2 = CONVERT(NUMERIC(18,8), @strTaxRate_Col2) 
		SET @dblTaxRate_Col3 = CONVERT(NUMERIC(18,8), @strTaxRate_Col3) 
		SET @dblTaxRate_Col4 = CONVERT(NUMERIC(18,8), @strTaxRate_Col4) 
		SET @dblTaxRate_Col5 = CONVERT(NUMERIC(18,8), @strTaxRate_Col5) 

		SET @strTaxRate_Col1 = '$' + @strTaxRate_Col1
		SET @strTaxRate_Col2 = '$' + @strTaxRate_Col2
		SET @strTaxRate_Col3 = '$' + @strTaxRate_Col3
		SET @strTaxRate_Col4 = '$' + @strTaxRate_Col4
		SET @strTaxRate_Col5 = '$' + @strTaxRate_Col5

		SET @dblLine15_Col1 = @dblLine14_Col1 * @dblTaxRate_Col1
		SET @dblLine15_Col2 = @dblLine14_Col2 * @dblTaxRate_Col2
		SET @dblLine15_Col3 = @dblLine14_Col3 * @dblTaxRate_Col3
		SET @dblLine15_Col4 = @dblLine14_Col4 * @dblTaxRate_Col4
		SET @dblLine15_Col5 = @dblLine14_Col5 * @dblTaxRate_Col5

		SET @dblLine16a = @dblLine15_Col1 + @dblLine15_Col2
		SET @dblLine16b = @dblLine15_Col3 + @dblLine15_Col4
		SET @dblLine16c = @dblLine15_Col5

		SET @dblLine17 = @dblLine16a + @dblLine16b + @dblLine16c

		SELECT @strLine18 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line18'
		SELECT @strLine19 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3992-BI-Line19'

		SET @dblLine18 = CONVERT(NUMERIC(18,8), @strLine18) 
		SET @dblLine19 = CONVERT(NUMERIC(18,8), @strLine19) 

		SET @strLine18 = '$' + @strLine18
		SET @strLine19 = '$' + @strLine19

		SET @dblLine20 = @dblLine17 + @dblLine18 + @dblLine19

		INSERT INTO @Output VALUES(
			  @dblLine8_Col1 
			, @dblLine8_Col2 
			, @dblLine8_Col3 
			, @dblLine8_Col4 
			, @dblLine8_Col5 
			, @dblLine9_Col1 
			, @dblLine9_Col2 
			, @dblLine9_Col3 
			, @dblLine9_Col4 
			, @dblLine9_Col5 
			, @dblLine10_Col1 
			, @dblLine10_Col2 
			, @dblLine10_Col3 
			, @dblLine10_Col4 
			, @dblLine10_Col5 
			, @dblLine11_Col1 
			, @dblLine11_Col2 
			, @dblLine11_Col5 
			, @dblLine12_Col1 
			, @dblLine12_Col2 
			, @dblLine12_Col3 
			, @dblLine12_Col4 
			, @dblLine12_Col5 
			, @dblLine13_Col1 
			, @dblLine13_Col2 
			, @dblLine13_Col3 
			, @dblLine13_Col4 
			, @dblLine13_Col5 
			, @dblLine14_Col1 
			, @dblLine14_Col2 
			, @dblLine14_Col3 
			, @dblLine14_Col4 
			, @dblLine14_Col5 
			, @dblLine15_Col1 
			, @dblLine15_Col2 
			, @dblLine15_Col3 
			, @dblLine15_Col4 
			, @dblLine15_Col5 
			, @strTaxRate_Col1 
			, @strTaxRate_Col2 
			, @strTaxRate_Col3 
			, @strTaxRate_Col4 
			, @strTaxRate_Col5 
			, @dblLine16a 
			, @dblLine16b 
			, @dblLine16c 
			, @dblLine17 
			, @strLine18 
			, @strLine19 
			, @dblLine20 
			, @dblLine21_Col1 
			, @dblLine21_Col2 
			, @dblLine21_Col3 
			, @dblLine21_Col4 
			, @dblLine21_Col5 
			, @dblLine21_Col6 
			, @dblLine22_Col1 
			, @dblLine22_Col2 
			, @dblLine22_Col3 
			, @dblLine22_Col4 
			, @dblLine22_Col5 
			, @dblLine22_Col6 	
			, @dblLine23_Col5 
			, @dblLine24_Col1 
			, @dblLine24_Col2 
			, @dblLine24_Col3 
			, @dblLine24_Col4 
			, @dblLine24_Col6 
			, @dblLine25_Col6 	
			, @dblLine26_Col3 
			, @dblLine26_Col4 
			, @dblLine26_Col5 
			, @dblLine27_Col1 
			, @dblLine27_Col2 
			, @dblLine27_Col3 
			, @dblLine27_Col4 
			, @dblLine27_Col6 
			, @dblLine28_Col5 
			, @dblLine29_Col1 
			, @dblLine29_Col2 
			, @dblLine29_Col3 
			, @dblLine29_Col4 
			, @dblLine29_Col5 
			, @dblLine29_Col6 
			, @dblLine30_Col1 
			, @dblLine30_Col2 
			, @dblLine30_Col3 
			, @dblLine30_Col4 
			, @dblLine30_Col5 
			, @dblLine30_Col6 
			, @strLine31_Col1 
			, @strLine31_Col2 
			, @strLine31_Col3 
			, @strLine31_Col4 
			, @strLine31_Col5 
			, @dblLine32_Col1 
			, @dblLine32_Col2 
			, @dblLine32_Col3 
			, @dblLine32_Col4 
			, @dblLine32_Col5 
			, @dblLine32_Col6 
			, @dblLine33_Col1 
			, @dblLine33_Col2 
			, @strLine34_Col1 
			, @strLine34_Col2 
			, @strLine34_Col3 
			, @strLine34_Col4 
			, @strLine34_Col5 
			, @dblLine35_Col1 
			, @dblLine35_Col2 
			, @dblLine35_Col3 
			, @dblLine35_Col4 
			, @dblLine35_Col5 
			, @dblLine35_Col6 
			, @dtmFrom 
			, @dtmTo 
			, @strLine11_AllowanceRate)

	END

	SELECT * FROM @Output

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH

