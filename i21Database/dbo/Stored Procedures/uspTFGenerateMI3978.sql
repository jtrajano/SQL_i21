CREATE PROCEDURE [dbo].[uspTFGenerateMI3978]
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
		, dblLine11_Col3 NUMERIC(18,0)
		, dblLine11_Col4 NUMERIC(18,0)
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
		, dblLine14_Col5 NUMERIC(18,0)
		, dblLine15_Col1 NUMERIC(18,0)
		, dblLine15_Col2 NUMERIC(18,0)
		, dblLine15_Col3 NUMERIC(18,0)
		, dblLine15_Col4 NUMERIC(18,0)
		, dblLine15_Col5 NUMERIC(18,0)
		, dblLine16_Col1 NUMERIC(18,0)
		, dblLine16_Col2 NUMERIC(18,0)
		, dblLine16_Col3 NUMERIC(18,0)
		, dblLine16_Col4 NUMERIC(18,0)
		, dblLine16_Col5 NUMERIC(18,0)
		, dblLine17_Col1 NUMERIC(18,0)
		, dblLine17_Col2 NUMERIC(18,0)
		, dblLine17_Col3 NUMERIC(18,0)
		, dblLine17_Col4 NUMERIC(18,0)
		, dblLine17_Col5 NUMERIC(18,0)
		, dblLine18_Col1 NUMERIC(18,8)
		, dblLine18_Col2 NUMERIC(18,8)
		, dblLine18_Col3 NUMERIC(18,8)
		, dblLine18_Col4 NUMERIC(18,8)
		, dblLine18_Col5 NUMERIC(18,8)
		, dblLine19_Col5 NUMERIC(18,0)
		, dblLine20_Col1 NUMERIC(18,0)
		, dblLine20_Col2 NUMERIC(18,0)
		, dblLine20_Col3 NUMERIC(18,0)
		, dblLine20_Col4 NUMERIC(18,0)
		, dblLine20_Col5 NUMERIC(18,0)
		, strLine21_Col1 NVARCHAR(25)
		, strLine21_Col2 NVARCHAR(25)
		, strLine21_Col3 NVARCHAR(25)
		, strLine21_Col4 NVARCHAR(25)
		, strLine21_Col5 NVARCHAR(25)
		, dblLine22_Col1 NUMERIC(18,0)
		, dblLine22_Col2 NUMERIC(18,0)
		, dblLine22_Col3 NUMERIC(18,0)
		, dblLine22_Col4 NUMERIC(18,0)
		, dblLine22_Col5 NUMERIC(18,0)
		, dblLine23a NUMERIC(18,0)
		, dblLine23b NUMERIC(18,0)
		, dblLine23c NUMERIC(18,0)
		, dblLine24 NUMERIC(18,0)	
		, strLine25 NVARCHAR(25)
		, strLine26 NVARCHAR(25)
		, dblLine27 NUMERIC(18,2)
		, strTaxRate_Col1 NVARCHAR(25)
		, strTaxRate_Col2 NVARCHAR(25)
		, strTaxRate_Col3 NVARCHAR(25)
		, strTaxRate_Col4 NVARCHAR(25)
		, strTaxRate_Col5 NVARCHAR(25)
		, dblLine28_Col1 NUMERIC(18,0)
		, dblLine28_Col2 NUMERIC(18,0)
		, dblLine28_Col3 NUMERIC(18,0)
		, dblLine28_Col4 NUMERIC(18,0)
		, dblLine28_Col5 NUMERIC(18,0)
		, dblLine28_Col6 NUMERIC(18,0)
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
		, dblLine31_Col1 NUMERIC(18,0)
		, dblLine31_Col2 NUMERIC(18,0)
		, dblLine31_Col3 NUMERIC(18,0)
		, dblLine31_Col4 NUMERIC(18,0)
		, dblLine31_Col5 NUMERIC(18,0)
		, dblLine31_Col6 NUMERIC(18,0)
		, dblLine32_Col6 NUMERIC(18,0)
		, dblLine33_Col5 NUMERIC(18,0)
		, dblLine34_Col1 NUMERIC(18,0)
		, dblLine34_Col2 NUMERIC(18,0)
		, dblLine34_Col3 NUMERIC(18,0)
		, dblLine34_Col4 NUMERIC(18,0)
		, dblLine34_Col6 NUMERIC(18,0)
		, dblLine35_Col6 NUMERIC(18,0)
		, dblLine36_Col3 NUMERIC(18,0)
		, dblLine36_Col4 NUMERIC(18,0)
		, dblLine36_Col5 NUMERIC(18,0)
		, dblLine37_Col1 NUMERIC(18,0)
		, dblLine37_Col2 NUMERIC(18,0)
		, dblLine37_Col3 NUMERIC(18,0)
		, dblLine37_Col4 NUMERIC(18,0)
		, dblLine37_Col6 NUMERIC(18,0)
		, dblLine38_Col1 NUMERIC(18,0)
		, dblLine38_Col2 NUMERIC(18,0)
		, dblLine38_Col3 NUMERIC(18,0)
		, dblLine38_Col4 NUMERIC(18,0)
		, dblLine38_Col6 NUMERIC(18,0)
		, dblLine39_Col5 NUMERIC(18,0)
		, dblLine40_Col1 NUMERIC(18,0)
		, dblLine40_Col2 NUMERIC(18,0)
		, dblLine40_Col3 NUMERIC(18,0)
		, dblLine40_Col4 NUMERIC(18,0)
		, dblLine40_Col5 NUMERIC(18,0)
		, dblLine40_Col6 NUMERIC(18,0)
		, dblLine41_Col1 NUMERIC(18,0)
		, dblLine41_Col2 NUMERIC(18,0)
		, dblLine41_Col3 NUMERIC(18,0)
		, dblLine41_Col4 NUMERIC(18,0)
		, dblLine41_Col5 NUMERIC(18,0)
		, dblLine41_Col6 NUMERIC(18,0)
		, dblLine42_Col1 NUMERIC(18,0)
		, dblLine42_Col2 NUMERIC(18,0)
		, dblLine42_Col3 NUMERIC(18,0)
		, dblLine42_Col4 NUMERIC(18,0)
		, dblLine42_Col5 NUMERIC(18,0)
		, dblLine42_Col6 NUMERIC(18,0)
		, dblLine43_Col1 NUMERIC(18,0)
		, dblLine43_Col2 NUMERIC(18,0)
		, dblLine43_Col3 NUMERIC(18,0)
		, dblLine43_Col4 NUMERIC(18,0)
		, dblLine43_Col5 NUMERIC(18,0)
		, dblLine43_Col6 NUMERIC(18,0)
		, dblLine44_Col1 NUMERIC(18,0)
		, dblLine44_Col2 NUMERIC(18,0)
		, dblLine44_Col3 NUMERIC(18,0)
		, dblLine44_Col4 NUMERIC(18,0)
		, dblLine44_Col5 NUMERIC(18,0)
		, dblLine44_Col6 NUMERIC(18,0)
		, dblLine45_Col1 NUMERIC(18,0)
		, dblLine45_Col2 NUMERIC(18,0)
		, dblLine45_Col3 NUMERIC(18,0)
		, dblLine45_Col4 NUMERIC(18,0)
		, dblLine45_Col5 NUMERIC(18,0)
		, dblLine45_Col6 NUMERIC(18,0)
		, dblLine46_Col1 NUMERIC(18,0)
		, dblLine46_Col2 NUMERIC(18,0)
		, dblLine46_Col3 NUMERIC(18,0)
		, dblLine46_Col4 NUMERIC(18,0)
		, dblLine46_Col5 NUMERIC(18,0)	
		, dblLine47_Col1 NUMERIC(18,0)
		, dblLine47_Col2 NUMERIC(18,0)	
		, dblLine48_Col1 NUMERIC(18,0)
		, dblLine48_Col2 NUMERIC(18,0)
		, dblLine48_Col3 NUMERIC(18,0)
		, dblLine48_Col4 NUMERIC(18,0)
		, dblLine48_Col5 NUMERIC(18,0)
		, dblLine49_Col1 NUMERIC(18,0)
		, dblLine49_Col2 NUMERIC(18,0)
		, dblLine49_Col3 NUMERIC(18,0)
		, dblLine49_Col4 NUMERIC(18,0)
		, dblLine49_Col5 NUMERIC(18,0)
		, dblLine49_Col6 NUMERIC(18,0)	
		, dtmFrom DATE
		, dtmTo DATE
		, strLine14_AllowanceRate NVARCHAR(25)
		--, intTaxRateLen_Col1 INT
		--, intTaxRateLen_Col2 INT
		--, intTaxRateLen_Col3 INT
		--, intTaxRateLen_Col4 INT
		--, intTaxRateLen_Col5 INT
		--, intLine14_AllowanceRateLen INT
	)

	DECLARE  @dblLine8_Col1 NUMERIC(18,0)
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
		, @dblLine11_Col3 NUMERIC(18,0)
		, @dblLine11_Col4 NUMERIC(18,0)
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
		, @dblLine14_Col5 NUMERIC(18,0)
		, @dblLine15_Col1 NUMERIC(18,0)
		, @dblLine15_Col2 NUMERIC(18,0)
		, @dblLine15_Col3 NUMERIC(18,0)
		, @dblLine15_Col4 NUMERIC(18,0)
		, @dblLine15_Col5 NUMERIC(18,0)
		, @dblLine16_Col1 NUMERIC(18,0)
		, @dblLine16_Col2 NUMERIC(18,0)
		, @dblLine16_Col3 NUMERIC(18,0)
		, @dblLine16_Col4 NUMERIC(18,0)
		, @dblLine16_Col5 NUMERIC(18,0)
		, @dblLine17_Col1 NUMERIC(18,0)
		, @dblLine17_Col2 NUMERIC(18,0)
		, @dblLine17_Col3 NUMERIC(18,0)
		, @dblLine17_Col4 NUMERIC(18,0)
		, @dblLine17_Col5 NUMERIC(18,0)
		, @dblLine18_Col1 NUMERIC(18,8)
		, @dblLine18_Col2 NUMERIC(18,8)
		, @dblLine18_Col3 NUMERIC(18,8)
		, @dblLine18_Col4 NUMERIC(18,8)
		, @dblLine18_Col5 NUMERIC(18,8)
		, @dblLine19_Col5 NUMERIC(18,0)
		, @dblLine20_Col1 NUMERIC(18,8)
		, @dblLine20_Col2 NUMERIC(18,8)
		, @dblLine20_Col3 NUMERIC(18,8)
		, @dblLine20_Col4 NUMERIC(18,8)
		, @dblLine20_Col5 NUMERIC(18,8)
		, @dblLine21_Col1 NUMERIC(18,8)
		, @dblLine21_Col2 NUMERIC(18,8)
		, @dblLine21_Col3 NUMERIC(18,8)
		, @dblLine21_Col4 NUMERIC(18,8)
		, @dblLine21_Col5 NUMERIC(18,8)
		, @dblLine22_Col1 NUMERIC(18,0)
		, @dblLine22_Col2 NUMERIC(18,0)
		, @dblLine22_Col3 NUMERIC(18,0)
		, @dblLine22_Col4 NUMERIC(18,0)
		, @dblLine22_Col5 NUMERIC(18,0)
		, @dblLine23a NUMERIC(18,0)
		, @dblLine23b NUMERIC(18,0)
		, @dblLine23c NUMERIC(18,0)
		, @dblLine24 NUMERIC(18,0)	
		, @dblLine25 NUMERIC(18,8)
		, @dblLine26 NUMERIC(18,8)
		, @dblLine27 NUMERIC(18,2)
		, @dblTaxRate_Col1 NUMERIC(18,8)
		, @dblTaxRate_Col2 NUMERIC(18,8)
		, @dblTaxRate_Col3 NUMERIC(18,8)
		, @dblTaxRate_Col4 NUMERIC(18,8)
		, @dblTaxRate_Col5 NUMERIC(18,8)
		, @dblLine28_Col1 NUMERIC(18,0)
		, @dblLine28_Col2 NUMERIC(18,0)
		, @dblLine28_Col3 NUMERIC(18,0)
		, @dblLine28_Col4 NUMERIC(18,0)
		, @dblLine28_Col5 NUMERIC(18,0)
		, @dblLine28_Col6 NUMERIC(18,0)
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
		, @dblLine31_Col1 NUMERIC(18,0)
		, @dblLine31_Col2 NUMERIC(18,0)
		, @dblLine31_Col3 NUMERIC(18,0)
		, @dblLine31_Col4 NUMERIC(18,0)
		, @dblLine31_Col5 NUMERIC(18,0)
		, @dblLine31_Col6 NUMERIC(18,0)
		, @dblLine32_Col6 NUMERIC(18,0)
		, @dblLine33_Col5 NUMERIC(18,0)
		, @dblLine34_Col1 NUMERIC(18,0)
		, @dblLine34_Col2 NUMERIC(18,0)
		, @dblLine34_Col3 NUMERIC(18,0)
		, @dblLine34_Col4 NUMERIC(18,0)
		, @dblLine34_Col6 NUMERIC(18,0)
		, @dblLine35_Col6 NUMERIC(18,0)
		, @dblLine36_Col3 NUMERIC(18,0)
		, @dblLine36_Col4 NUMERIC(18,0)
		, @dblLine36_Col5 NUMERIC(18,0)
		, @dblLine37_Col1 NUMERIC(18,0)
		, @dblLine37_Col2 NUMERIC(18,0)
		, @dblLine37_Col3 NUMERIC(18,0)
		, @dblLine37_Col4 NUMERIC(18,0)
		, @dblLine37_Col6 NUMERIC(18,0)
		, @dblLine38_Col1 NUMERIC(18,0)
		, @dblLine38_Col2 NUMERIC(18,0)
		, @dblLine38_Col3 NUMERIC(18,0)
		, @dblLine38_Col4 NUMERIC(18,0)
		, @dblLine38_Col6 NUMERIC(18,0)
		, @dblLine39_Col5 NUMERIC(18,0)
		, @dblLine40_Col1 NUMERIC(18,0)
		, @dblLine40_Col2 NUMERIC(18,0)
		, @dblLine40_Col3 NUMERIC(18,0)
		, @dblLine40_Col4 NUMERIC(18,0)
		, @dblLine40_Col5 NUMERIC(18,0)
		, @dblLine40_Col6 NUMERIC(18,0)
		, @dblLine41_Col1 NUMERIC(18,0)
		, @dblLine41_Col2 NUMERIC(18,0)
		, @dblLine41_Col3 NUMERIC(18,0)
		, @dblLine41_Col4 NUMERIC(18,0)
		, @dblLine41_Col5 NUMERIC(18,0)
		, @dblLine41_Col6 NUMERIC(18,0)
		, @dblLine42_Col1 NUMERIC(18,0)
		, @dblLine42_Col2 NUMERIC(18,0)
		, @dblLine42_Col3 NUMERIC(18,0)
		, @dblLine42_Col4 NUMERIC(18,0)
		, @dblLine42_Col5 NUMERIC(18,0)
		, @dblLine42_Col6 NUMERIC(18,0)
		, @dblLine43_Col1 NUMERIC(18,0)
		, @dblLine43_Col2 NUMERIC(18,0)
		, @dblLine43_Col3 NUMERIC(18,0)
		, @dblLine43_Col4 NUMERIC(18,0)
		, @dblLine43_Col5 NUMERIC(18,0)
		, @dblLine43_Col6 NUMERIC(18,0)
		, @dblLine44_Col1 NUMERIC(18,0)
		, @dblLine44_Col2 NUMERIC(18,0)
		, @dblLine44_Col3 NUMERIC(18,0)
		, @dblLine44_Col4 NUMERIC(18,0)
		, @dblLine44_Col5 NUMERIC(18,0)
		, @dblLine44_Col6 NUMERIC(18,0)
		, @dblLine45_Col1 NUMERIC(18,0)
		, @dblLine45_Col2 NUMERIC(18,0)
		, @dblLine45_Col3 NUMERIC(18,0)
		, @dblLine45_Col4 NUMERIC(18,0)
		, @dblLine45_Col5 NUMERIC(18,0)
		, @dblLine45_Col6 NUMERIC(18,0)
		, @dblLine46_Col1 NUMERIC(18,0)
		, @dblLine46_Col2 NUMERIC(18,0)
		, @dblLine46_Col3 NUMERIC(18,0)
		, @dblLine46_Col4 NUMERIC(18,0)
		, @dblLine46_Col5 NUMERIC(18,0)	
		, @dblLine47_Col1 NUMERIC(18,0)
		, @dblLine47_Col2 NUMERIC(18,0)	
		, @dblLine48_Col1 NUMERIC(18,0)
		, @dblLine48_Col2 NUMERIC(18,0)
		, @dblLine48_Col3 NUMERIC(18,0)
		, @dblLine48_Col4 NUMERIC(18,0)
		, @dblLine48_Col5 NUMERIC(18,0)
		, @dblLine49_Col1 NUMERIC(18,0)
		, @dblLine49_Col2 NUMERIC(18,0)
		, @dblLine49_Col3 NUMERIC(18,0)
		, @dblLine49_Col4 NUMERIC(18,0)
		, @dblLine49_Col5 NUMERIC(18,0)
		, @dblLine49_Col6 NUMERIC(18,0)	
		, @dtmFrom DATE
		, @dtmTo DATE
		, @dblLine14_AllowanceRate NUMERIC(18,8)
		, @strTaxRate_Col1 NVARCHAR(25) = NULL
		, @strTaxRate_Col2 NVARCHAR(25) = NULL
		, @strTaxRate_Col3 NVARCHAR(25) = NULL
		, @strTaxRate_Col4 NVARCHAR(25) = NULL
		, @strTaxRate_Col5 NVARCHAR(25) = NULL
		, @intTaxRateLen_Col1 INT = NULL
		, @intTaxRateLen_Col2 INT = NULL
		, @intTaxRateLen_Col3 INT = NULL
		, @intTaxRateLen_Col4 INT = NULL
		, @intTaxRateLen_Col5 INT = NULL
		, @strLine14_AllowanceRate NVARCHAR(25) = NULL
		, @intLine14_AllowanceRateLen INT = NULL
		, @strLine21_Col1 NVARCHAR(25) = NULL
		, @strLine21_Col2 NVARCHAR(25) = NULL
		, @strLine21_Col3 NVARCHAR(25) = NULL
		, @strLine21_Col4 NVARCHAR(25) = NULL
		, @strLine21_Col5 NVARCHAR(25) = NULL
		, @strLine25 NVARCHAR(25) = NULL
		, @strLine26 NVARCHAR(25) = NULL
	

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
		SELECT @dblLine28_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Gasoline'
		SELECT @dblLine28_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine28_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Undyed Diesel'
		SELECT @dblLine28_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine28_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Dyed Diesel'
		SELECT @dblLine28_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2C' AND strType = 'Aviation'

		SELECT @dblLine29_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Gasoline'
		SELECT @dblLine29_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine29_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Undyed Diesel'
		SELECT @dblLine29_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine29_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Dyed Diesel'
		SELECT @dblLine29_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Aviation'

		SELECT @dblLine30_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2X' AND strType = 'Gasoline'
		SELECT @dblLine30_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2X' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine30_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2X' AND strType = 'Undyed Diesel'
		SELECT @dblLine30_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2X' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine30_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2X' AND strType = 'Dyed Diesel'
		SELECT @dblLine30_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2X' AND strType = 'Aviation'

		SELECT @dblLine31_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6X' AND strType = 'Gasoline'
		SELECT @dblLine31_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6X' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine31_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6X' AND strType = 'Undyed Diesel'
		SELECT @dblLine31_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6X' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine31_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6X' AND strType = 'Dyed Diesel'
		SELECT @dblLine31_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6X' AND strType = 'Aviation'

		SELECT @dblLine32_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10B' AND strType = 'Aviation'

		SELECT @dblLine33_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Dyed Diesel'

		-- PART 3
		SELECT @dblLine34_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Gasoline'
		SELECT @dblLine34_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine34_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Undyed Diesel'
		SELECT @dblLine34_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine34_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5' AND strType = 'Aviation'

		SELECT @dblLine35_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5C' AND strType = 'Aviation'

		SELECT @dblLine36_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5F' AND strType = 'Undyed Diesel'
		SELECT @dblLine36_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5F' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine36_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '5F' AND strType = 'Dyed Diesel'

		SELECT @dblLine37_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Gasoline'
		SELECT @dblLine37_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine37_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Undyed Diesel'
		SELECT @dblLine37_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine37_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Aviation'

		SET @dblLine38_Col1 = ISNULL(@dblLine34_Col1, 0) + ISNULL(@dblLine37_Col1, 0)
		SET @dblLine38_Col2 = ISNULL(@dblLine34_Col2, 0) + ISNULL(@dblLine37_Col2, 0)
		SET @dblLine38_Col3 = ISNULL(@dblLine34_Col3, 0) + ISNULL(@dblLine36_Col3, 0) + ISNULL(@dblLine37_Col3, 0)
		SET @dblLine38_Col4 = ISNULL(@dblLine34_Col4, 0) + ISNULL(@dblLine36_Col4, 0) + ISNULL(@dblLine37_Col4, 0)
		SET @dblLine38_Col6 = ISNULL(@dblLine34_Col6, 0) + ISNULL(@dblLine35_Col6, 0) + ISNULL(@dblLine37_Col6, 0)

		-- PART 4
		SELECT @dblLine39_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6F' AND strType = 'Dyed Diesel'

		SELECT @dblLine40_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6P' AND strType = 'Gasoline'
		SELECT @dblLine40_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6P' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine40_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6P' AND strType = 'Undyed Diesel'
		SELECT @dblLine40_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6P' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine40_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6P' AND strType = 'Dyed Diesel'
		SELECT @dblLine40_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6P' AND strType = 'Aviation'

		SELECT @dblLine41_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Gasoline'
		SELECT @dblLine41_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine41_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Undyed Diesel'
		SELECT @dblLine41_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine41_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Dyed Diesel'
		SELECT @dblLine41_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Aviation'

		SELECT @dblLine42_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Gasoline'
		SELECT @dblLine42_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine42_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Undyed Diesel'
		SELECT @dblLine42_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine42_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Dyed Diesel'
		SELECT @dblLine42_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Aviation'

		SELECT @dblLine43_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Gasoline'
		SELECT @dblLine43_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine43_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Undyed Diesel'
		SELECT @dblLine43_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine43_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Dyed Diesel'
		SELECT @dblLine43_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '9' AND strType = 'Aviation'

		SELECT @dblLine44_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6Z' AND strType = 'Gasoline'
		SELECT @dblLine44_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6Z' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine44_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6Z' AND strType = 'Undyed Diesel'
		SELECT @dblLine44_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6Z' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine44_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6Z' AND strType = 'Dyed Diesel'
		SELECT @dblLine44_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6Z' AND strType = 'Aviation'

		SELECT @dblLine45_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10F' AND strType = 'Gasoline'
		SELECT @dblLine45_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10F' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine45_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10F' AND strType = 'Undyed Diesel'
		SELECT @dblLine45_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10F' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine45_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10F' AND strType = 'Dyed Diesel'
		SELECT @dblLine45_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10F' AND strType = 'Aviation'

		SELECT @dblLine46_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Gasoline'
		SELECT @dblLine46_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine46_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Undyed Diesel'
		SELECT @dblLine46_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine46_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10G' AND strType = 'Dyed Diesel'
		
		SELECT @dblLine47_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10M' AND strType = 'Gasoline'
		SELECT @dblLine47_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10M' AND strType = 'Ethanol Blends (E70 - E99)'

		SELECT @dblLine48_Col1 =  CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line48Gas'
		SELECT @dblLine48_Col2 =  CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line48Ethanol'
		SELECT @dblLine48_Col3 =  CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line48UndyedDiesel'
		SELECT @dblLine48_Col4 =  CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line48UndyedBio'
		SELECT @dblLine48_Col5 =  CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line48Aviation'

		SELECT @dblLine49_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Gasoline'
		SELECT @dblLine49_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine49_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Undyed Diesel'
		SELECT @dblLine49_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine49_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Dyed Diesel'
		SELECT @dblLine49_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Aviation'

		-- PART 1
		SET @dblLine8_Col1 = @dblLine38_Col1
		SET @dblLine8_Col2 = @dblLine38_Col2
		SET @dblLine8_Col3 = @dblLine38_Col3
		SET @dblLine8_Col4 = @dblLine38_Col4
		SET @dblLine8_Col5 = @dblLine38_Col6

		SELECT @dblLine9_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Gasoline'
		SELECT @dblLine9_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine9_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Undyed Diesel'
		SELECT @dblLine9_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine9_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '1' AND strType = 'Aviation'

		SELECT @dblLine10_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line10Gas'
		SELECT @dblLine10_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line10Ethanol'
		SELECT @dblLine10_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line10UndyedDiesel'
		SELECT @dblLine10_Col4 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line10UndyedBio'
		SELECT @dblLine10_Col5 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line10Aviation'	

		SELECT @dblLine11_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line11Gas'
		SELECT @dblLine11_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line11Ethanol'
		SELECT @dblLine11_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line11UndyedDiesel'
		SELECT @dblLine11_Col4 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line11UndyedBio'
		
		SELECT @dblLine12_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line12Gas'
		SELECT @dblLine12_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line12Ethanol'
		SELECT @dblLine12_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line12UndyedDiesel'
		SELECT @dblLine12_Col4 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line12UndyedBio'
		SELECT @dblLine12_Col5 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line12Aviation'	

		SET @dblLine13_Col1 = @dblLine8_Col1 + @dblLine9_Col1 + @dblLine10_Col1 + @dblLine11_Col1 + @dblLine12_Col1
		SET @dblLine13_Col2 = @dblLine8_Col2 + @dblLine9_Col2 + @dblLine10_Col2 + @dblLine11_Col2 + @dblLine12_Col2
		SET @dblLine13_Col3 = @dblLine8_Col3 + @dblLine9_Col3 + @dblLine10_Col3 + @dblLine11_Col3 + @dblLine12_Col3
		SET @dblLine13_Col4 = @dblLine8_Col4 + @dblLine9_Col4 + @dblLine10_Col4 + @dblLine11_Col4 + @dblLine12_Col4
		SET @dblLine13_Col5 = @dblLine8_Col5 + @dblLine9_Col5 + @dblLine10_Col5 + @dblLine12_Col5

		SELECT @strLine14_AllowanceRate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line14'
		SET @intLine14_AllowanceRateLen = LEN(RIGHT(@strLine14_AllowanceRate, LEN(@strLine14_AllowanceRate) - CHARINDEX('.', @strLine14_AllowanceRate)))
		SET @dblLine14_AllowanceRate = CONVERT(NUMERIC(18,8), @strLine14_AllowanceRate) 

		SET @dblLine14_Col1 = @dblLine13_Col1 * @dblLine14_AllowanceRate
		SET @dblLine14_Col2 = @dblLine13_Col2 * @dblLine14_AllowanceRate
		SET @dblLine14_Col5 = @dblLine13_Col5 * @dblLine14_AllowanceRate

		SET @dblLine15_Col1 = @dblLine13_Col1 - @dblLine14_Col1
		SET @dblLine15_Col2 = @dblLine13_Col2 - @dblLine14_Col2
		SET @dblLine15_Col3 = @dblLine13_Col3 
		SET @dblLine15_Col4 = @dblLine13_Col4 
		SET @dblLine15_Col5 = @dblLine13_Col5 - @dblLine14_Col5

		SELECT @dblLine16_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Gasoline'
		SELECT @dblLine16_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Ethanol Blends (E70 - E99)'
		SELECT @dblLine16_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Undyed Diesel'
		SELECT @dblLine16_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Undyed Biodiesel (B05 or higher)'
		SELECT @dblLine16_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Aviation'

		SET @dblLine17_Col1 = @dblLine15_Col1 + @dblLine16_Col1
		SET @dblLine17_Col2 = @dblLine15_Col2 + @dblLine16_Col2
		SET @dblLine17_Col3 = @dblLine15_Col3 + @dblLine16_Col3
		SET @dblLine17_Col4 = @dblLine15_Col4 + @dblLine16_Col4
		SET @dblLine17_Col5 = @dblLine15_Col5 + @dblLine16_Col5

		SELECT @strTaxRate_Col1 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateGas'
		SELECT @strTaxRate_Col2 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateEthanol'
		SELECT @strTaxRate_Col3 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateUndyedDiesel'
		SELECT @strTaxRate_Col4 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateUndyedBIo'
		SELECT @strTaxRate_Col5 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateAviation'

		--SET @intTaxRateLen_Col1 = LEN(RIGHT(@strTaxRate_Col1, LEN(@strTaxRate_Col1) - CHARINDEX('.', @strTaxRate_Col1)))
		--SET @intTaxRateLen_Col2 = LEN(RIGHT(@strTaxRate_Col2, LEN(@strTaxRate_Col2) - CHARINDEX('.', @strTaxRate_Col2)))
		--SET @intTaxRateLen_Col3 = LEN(RIGHT(@strTaxRate_Col3, LEN(@strTaxRate_Col3) - CHARINDEX('.', @strTaxRate_Col3)))
		--SET @intTaxRateLen_Col4 = LEN(RIGHT(@strTaxRate_Col4, LEN(@strTaxRate_Col4) - CHARINDEX('.', @strTaxRate_Col4)))
		--SET @intTaxRateLen_Col5 = LEN(RIGHT(@strTaxRate_Col5, LEN(@strTaxRate_Col5) - CHARINDEX('.', @strTaxRate_Col5)))

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

		--SELECT @dblTaxRate_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,6), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateGas'
		--SELECT @dblTaxRate_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,6), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateEthanol'
		--SELECT @dblTaxRate_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,6), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateUndyedDiesel'
		--SELECT @dblTaxRate_Col4 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,6), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateUndyedBIo'
		--SELECT @dblTaxRate_Col5 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,6), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-TaxRateAviation'

		SET @dblLine18_Col1 = @dblLine17_Col1 * @dblTaxRate_Col1
		SET @dblLine18_Col2 = @dblLine17_Col2 * @dblTaxRate_Col2
		SET @dblLine18_Col3 = @dblLine17_Col3 * @dblTaxRate_Col3
		SET @dblLine18_Col4 = @dblLine17_Col4 * @dblTaxRate_Col4
		SET @dblLine18_Col5 = @dblLine17_Col5 * @dblTaxRate_Col5

		SELECT @dblLine19_Col5 =  CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line19'

		SET @dblLine20_Col1 = @dblLine18_Col1
		SET @dblLine20_Col2 = @dblLine18_Col2
		SET @dblLine20_Col3 = @dblLine18_Col3
		SET @dblLine20_Col4 = @dblLine18_Col4
		SET @dblLine20_Col5 = @dblLine18_Col5 - @dblLine19_Col5

		SELECT @strLine21_Col1 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line21Gas'
		SELECT @strLine21_Col2 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line21Ethanol'
		SELECT @strLine21_Col3 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line21UndyedDiesel'
		SELECT @strLine21_Col4 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line21UndyedBio'
		SELECT @strLine21_Col5 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line21Aviation'

		SET @dblLine21_Col1 = CONVERT(NUMERIC(18,8), @strLine21_Col1) 
		SET @dblLine21_Col2 = CONVERT(NUMERIC(18,8), @strLine21_Col2) 
		SET @dblLine21_Col3 = CONVERT(NUMERIC(18,8), @strLine21_Col3) 
		SET @dblLine21_Col4 = CONVERT(NUMERIC(18,8), @strLine21_Col4) 
		SET @dblLine21_Col5 = CONVERT(NUMERIC(18,8), @strLine21_Col5) 

		SET @strLine21_Col1 = '$' + @strLine21_Col1
		SET @strLine21_Col2 = '$' + @strLine21_Col2
		SET @strLine21_Col3 = '$' + @strLine21_Col3
		SET @strLine21_Col4 = '$' + @strLine21_Col4
		SET @strLine21_Col5 = '$' + @strLine21_Col5

		SET @dblLine22_Col1 = @dblLine20_Col1 + @dblLine21_Col1
		SET @dblLine22_Col2 = @dblLine20_Col2 + @dblLine21_Col2
		SET @dblLine22_Col3 = @dblLine20_Col3 + @dblLine21_Col3
		SET @dblLine22_Col4 = @dblLine20_Col4 + @dblLine21_Col4
		SET @dblLine22_Col5 = @dblLine20_Col5 + @dblLine21_Col5


		SET @dblLine23a = @dblLine22_Col1 + @dblLine22_Col2
		SET @dblLine23b = @dblLine22_Col3 + @dblLine22_Col4
		SET @dblLine23c = @dblLine22_Col5

		SET @dblLine24 = @dblLine23a + @dblLine23b + @dblLine23c

		SELECT @strLine25 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line25'
		SELECT @strLine26 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '3978-SU-Line26'

		SET @dblLine25 = CONVERT(NUMERIC(18,8), @strLine25) 
		SET @dblLine26 = CONVERT(NUMERIC(18,8), @strLine26) 

		SET @strLine25 = '$' + @strLine25
		SET @strLine26 = '$' + @strLine26

		SET @dblLine27 = @dblLine24 + @dblLine25 + @dblLine26

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
			, @dblLine11_Col3 
			, @dblLine11_Col4 
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
			, @dblLine14_Col5 
			, @dblLine15_Col1 
			, @dblLine15_Col2 
			, @dblLine15_Col3 
			, @dblLine15_Col4 
			, @dblLine15_Col5 
			, @dblLine16_Col1 
			, @dblLine16_Col2 
			, @dblLine16_Col3 
			, @dblLine16_Col4 
			, @dblLine16_Col5 
			, @dblLine17_Col1 
			, @dblLine17_Col2 
			, @dblLine17_Col3 
			, @dblLine17_Col4 
			, @dblLine17_Col5 
			, @dblLine18_Col1 
			, @dblLine18_Col2 
			, @dblLine18_Col3 
			, @dblLine18_Col4 
			, @dblLine18_Col5 
			, @dblLine19_Col5 
			, @dblLine20_Col1 
			, @dblLine20_Col2 
			, @dblLine20_Col3 
			, @dblLine20_Col4 
			, @dblLine20_Col5 
			, @strLine21_Col1 
			, @strLine21_Col2 
			, @strLine21_Col3 
			, @strLine21_Col4 
			, @strLine21_Col5 
			, @dblLine22_Col1 
			, @dblLine22_Col2 
			, @dblLine22_Col3 
			, @dblLine22_Col4 
			, @dblLine22_Col5 
			, @dblLine23a
			, @dblLine23b	
			, @dblLine23c
			, @dblLine24
			, @strLine25 
			, @strLine26 
			, @dblLine27 
			, @strTaxRate_Col1 
			, @strTaxRate_Col2 
			, @strTaxRate_Col3 
			, @strTaxRate_Col4 
			, @strTaxRate_Col5 
			, @dblLine28_Col1 
			, @dblLine28_Col2 
			, @dblLine28_Col3 
			, @dblLine28_Col4 
			, @dblLine28_Col5 
			, @dblLine28_Col6 
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
			, @dblLine31_Col1 
			, @dblLine31_Col2 
			, @dblLine31_Col3 
			, @dblLine31_Col4 
			, @dblLine31_Col5 
			, @dblLine31_Col6 
			, @dblLine32_Col6 
			, @dblLine33_Col5 
			, @dblLine34_Col1 
			, @dblLine34_Col2 
			, @dblLine34_Col3 
			, @dblLine34_Col4 
			, @dblLine34_Col6 
			, @dblLine35_Col6 
			, @dblLine36_Col3 
			, @dblLine36_Col4 
			, @dblLine36_Col5 
			, @dblLine37_Col1 
			, @dblLine37_Col2 
			, @dblLine37_Col3 
			, @dblLine37_Col4 
			, @dblLine37_Col6 
			, @dblLine38_Col1 
			, @dblLine38_Col2 
			, @dblLine38_Col3 
			, @dblLine38_Col4 
			, @dblLine38_Col6 
			, @dblLine39_Col5 
			, @dblLine40_Col1 
			, @dblLine40_Col2 
			, @dblLine40_Col3 
			, @dblLine40_Col4 
			, @dblLine40_Col5 
			, @dblLine40_Col6 
			, @dblLine41_Col1 
			, @dblLine41_Col2 
			, @dblLine41_Col3 
			, @dblLine41_Col4 
			, @dblLine41_Col5 
			, @dblLine41_Col6 
			, @dblLine42_Col1 
			, @dblLine42_Col2 
			, @dblLine42_Col3 
			, @dblLine42_Col4 
			, @dblLine42_Col5 
			, @dblLine42_Col6 
			, @dblLine43_Col1 
			, @dblLine43_Col2 
			, @dblLine43_Col3 
			, @dblLine43_Col4 
			, @dblLine43_Col5 
			, @dblLine43_Col6 
			, @dblLine44_Col1 
			, @dblLine44_Col2 
			, @dblLine44_Col3 
			, @dblLine44_Col4 
			, @dblLine44_Col5 
			, @dblLine44_Col6 
			, @dblLine45_Col1 
			, @dblLine45_Col2 
			, @dblLine45_Col3 
			, @dblLine45_Col4 
			, @dblLine45_Col5 
			, @dblLine45_Col6 
			, @dblLine46_Col1 
			, @dblLine46_Col2 
			, @dblLine46_Col3 
			, @dblLine46_Col4 
			, @dblLine46_Col5
			, @dblLine47_Col1 
			, @dblLine47_Col2
			, @dblLine48_Col1 
			, @dblLine48_Col2 
			, @dblLine48_Col3 
			, @dblLine48_Col4 
			, @dblLine48_Col5 
			, @dblLine49_Col1 
			, @dblLine49_Col2 
			, @dblLine49_Col3 
			, @dblLine49_Col4 
			, @dblLine49_Col5 
			, @dblLine49_Col6
			, @dtmFrom
			, @dtmTo
			, @strLine14_AllowanceRate
			--, @dblLine14_AllowanceRate
			--, @intTaxRateLen_Col1
			--, @intTaxRateLen_Col2
			--, @intTaxRateLen_Col3
			--, @intTaxRateLen_Col4
			--, @intTaxRateLen_Col5
			--, @intLine14_AllowanceRateLen
			)

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
