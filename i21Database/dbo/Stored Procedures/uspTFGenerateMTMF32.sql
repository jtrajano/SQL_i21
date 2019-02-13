CREATE PROCEDURE [dbo].[uspTFGenerateMTMF32]
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
		 dblLine1_1_Col1 NUMERIC(18,0)
		, dblLine1_1_Col2 NUMERIC(18,0)
		, dblLine1_1_Col3 NUMERIC(18,0)
		, dblLine1_1_Col4 NUMERIC(18,0)
		, dblLine2_1_Col1 NUMERIC(18,0)
		, dblLine2_1_Col2 NUMERIC(18,0)
		, dblLine2_1_Col3 NUMERIC(18,0)
		, strTaxRate_1_Col1 NVARCHAR(25)
		, strTaxRate_1_Col2 NVARCHAR(25)
		, strTaxRate_1_Col3 NVARCHAR(25)
		, strLine3_1_Rate NVARCHAR(25)
		, dblLine3_1_Col2 NUMERIC(18,0)
		, dblLine4_1_Col1 NUMERIC(18,0)
		, dblLine4_1_Col2 NUMERIC(18,0)
		, dblLine4_1_Col3 NUMERIC(18,0)
		, dblLine5_1_Col1 NUMERIC(18,0)
		, dblLine5_1_Col2 NUMERIC(18,0)
		, dblLine5_1_Col3 NUMERIC(18,0)
		, dblLine5_1_Col4 NUMERIC(18,0)
		, dblLine6_1_Col2 NUMERIC(18,0)
		, dblLine6_1_Col3 NUMERIC(18,0)
		, dblLine6_1_Col4 NUMERIC(18,0)
		, dblLine7_1_Col1 NUMERIC(18,0)
		, dblLine7_1_Col2 NUMERIC(18,0)
		, dblLine7_1_Col3 NUMERIC(18,0)
		, dblLine7_1_Col4 NUMERIC(18,0)
		, dblLine8_1_Col1 NUMERIC(18,0)
		, dblLine8_1_Col2 NUMERIC(18,0)
		, dblLine8_1_Col3 NUMERIC(18,0)
		, dblLine8_1_Col4 NUMERIC(18,0)
		, strLine8_1_Rate NVARCHAR(25)
		, strLine9_1_Rate NVARCHAR(25)
		, dblLine10_1_Col1 NUMERIC(18,0)
		, dblLine10_1_Col2 NUMERIC(18,0)
		, dblLine10_1_Col3 NUMERIC(18,0)
		, dblLine10_1_Col4 NUMERIC(18,0)
		, strLine11_1_Penalty NVARCHAR(25)
		, strLine12_1_Interest NVARCHAR(25)
		, dblLine13_1_Col1 NUMERIC(18,2)
		, dblLine1_2_Col1 NUMERIC(18,0)
		, dblLine1_2_Col2 NUMERIC(18,0)
		, dblLine1_2_Col3 NUMERIC(18,0)
		, dblLine1_2_Col4 NUMERIC(18,0)
		, dblLine2_2_Col1 NUMERIC(18,0)
		, dblLine2_2_Col2 NUMERIC(18,0)
		, dblLine2_2_Col3 NUMERIC(18,0)
		, dblLine2_2_Col4 NUMERIC(18,0)		
		, dblLine3_2_Col1 NUMERIC(18,0)
		, dblLine3_2_Col2 NUMERIC(18,0)
		, dblLine3_2_Col3 NUMERIC(18,0)
		, dblLine3_2_Col4 NUMERIC(18,0)
		, dblLine4_2_Col1 NUMERIC(18,0)
		, dblLine4_2_Col2 NUMERIC(18,0)
		, dblLine4_2_Col3 NUMERIC(18,0)
		, dblLine4_2_Col4 NUMERIC(18,0)
		, dblLine5_2_Col1 NUMERIC(18,0)
		, dblLine5_2_Col2 NUMERIC(18,0)
		, dblLine5_2_Col3 NUMERIC(18,0)
		, dblLine5_2_Col4 NUMERIC(18,0)
		, dblLine6_2_Col1 NUMERIC(18,0)
		, dblLine6_2_Col2 NUMERIC(18,0)
		, dblLine6_2_Col3 NUMERIC(18,0)
		, dblLine6_2_Col4 NUMERIC(18,0)
		, dblLine7_2_Col1 NUMERIC(18,0)
		, dblLine7_2_Col2 NUMERIC(18,0)
		, dblLine7_2_Col3 NUMERIC(18,0)
		, dblLine7_2_Col4 NUMERIC(18,0)
		, dblLine8_2_Col1 NUMERIC(18,0)
		, dblLine8_2_Col2 NUMERIC(18,0)
		, dblLine8_2_Col3 NUMERIC(18,0)
		, dblLine8_2_Col4 NUMERIC(18,0)
		, dblLine9_2_Col1 NUMERIC(18,0)
		, dblLine9_2_Col2 NUMERIC(18,0)
		, dblLine9_2_Col3 NUMERIC(18,0)
		, dblLine9_2_Col4 NUMERIC(18,0)
		, dblLine10_2_Col1 NUMERIC(18,0)
		, dblLine11_2_Col2 NUMERIC(18,0)
		, dblLine12_2_Col2 NUMERIC(18,0)	
		, dblLine13_2_Col2 NUMERIC(18,0)
		, dblLine13_2_Col3 NUMERIC(18,0)
		, dblLine13_2_Col4 NUMERIC(18,0)
		, dblLine14_2_Col3 NUMERIC(18,0)	
		, dblLine14_2_Col4 NUMERIC(18,0)
		, dtmFrom DATE
		, dtmTo DATE)

	DECLARE  @dblLine1_1_Col1 NUMERIC(18,0)
		,  @dblLine1_1_Col2 NUMERIC(18,0)
		,  @dblLine1_1_Col3 NUMERIC(18,0)
		,  @dblLine1_1_Col4 NUMERIC(18,0)
		,  @dblLine2_1_Col1 NUMERIC(18,0)
		,  @dblLine2_1_Col2 NUMERIC(18,0)
		,  @dblLine2_1_Col3 NUMERIC(18,0)
		,  @strTaxRate_1_Col1 NVARCHAR(25)
		,  @strTaxRate_1_Col2 NVARCHAR(25)
		,  @strTaxRate_1_Col3 NVARCHAR(25)
		,  @strLine3_1_Rate NVARCHAR(25)
		,  @dblLine3_1_Col2 NUMERIC(18,0)
		,  @dblLine4_1_Col1 NUMERIC(18,0)
		,  @dblLine4_1_Col2 NUMERIC(18,0)
		,  @dblLine4_1_Col3 NUMERIC(18,0)
		,  @dblLine5_1_Col1 NUMERIC(18,0)
		,  @dblLine5_1_Col2 NUMERIC(18,0)
		,  @dblLine5_1_Col3 NUMERIC(18,0)
		,  @dblLine5_1_Col4 NUMERIC(18,0)
		,  @dblLine6_1_Col2 NUMERIC(18,0)
		,  @dblLine6_1_Col3 NUMERIC(18,0)
		,  @dblLine6_1_Col4 NUMERIC(18,0)
		,  @dblLine7_1_Col1 NUMERIC(18,0)
		,  @dblLine7_1_Col2 NUMERIC(18,0)
		,  @dblLine7_1_Col3 NUMERIC(18,0)
		,  @dblLine7_1_Col4 NUMERIC(18,0)
		,  @strLine8_1_Rate NVARCHAR(25)
		,  @dblLine8_1_Col1 NUMERIC(18,0)
		,  @dblLine8_1_Col2 NUMERIC(18,0)
		,  @dblLine8_1_Col3 NUMERIC(18,0)
		,  @dblLine8_1_Col4 NUMERIC(18,0)
		,  @strLine9_1_Rate NVARCHAR(25)
		,  @dblLine10_1_Col1 NUMERIC(18,0)
		,  @dblLine10_1_Col2 NUMERIC(18,0)
		,  @dblLine10_1_Col3 NUMERIC(18,0)
		,  @dblLine10_1_Col4 NUMERIC(18,0)
		,  @strLine11_1_Penalty NVARCHAR(25)
		,  @strLine12_1_Interest NVARCHAR(25)
		,  @dblLine13_1_Col1 NUMERIC(18,2)
		,  @dblLine1_2_Col1 NUMERIC(18,0)
		,  @dblLine1_2_Col2 NUMERIC(18,0)
		,  @dblLine1_2_Col3 NUMERIC(18,0)
		,  @dblLine1_2_Col4 NUMERIC(18,0)
		,  @dblLine2_2_Col1 NUMERIC(18,0)
		,  @dblLine2_2_Col2 NUMERIC(18,0)
		,  @dblLine2_2_Col3 NUMERIC(18,0)
		,  @dblLine2_2_Col4 NUMERIC(18,0)		
		,  @dblLine3_2_Col1 NUMERIC(18,0)
		,  @dblLine3_2_Col2 NUMERIC(18,0)
		,  @dblLine3_2_Col3 NUMERIC(18,0)
		,  @dblLine3_2_Col4 NUMERIC(18,0)
		,  @dblLine4_2_Col1 NUMERIC(18,0)
		,  @dblLine4_2_Col2 NUMERIC(18,0)
		,  @dblLine4_2_Col3 NUMERIC(18,0)
		,  @dblLine4_2_Col4 NUMERIC(18,0)
		,  @dblLine5_2_Col1 NUMERIC(18,0)
		,  @dblLine5_2_Col2 NUMERIC(18,0)
		,  @dblLine5_2_Col3 NUMERIC(18,0)
		,  @dblLine5_2_Col4 NUMERIC(18,0)
		,  @dblLine6_2_Col1 NUMERIC(18,0)
		,  @dblLine6_2_Col2 NUMERIC(18,0)
		,  @dblLine6_2_Col3 NUMERIC(18,0)
		,  @dblLine6_2_Col4 NUMERIC(18,0)
		,  @dblLine7_2_Col1 NUMERIC(18,0)
		,  @dblLine7_2_Col2 NUMERIC(18,0)
		,  @dblLine7_2_Col3 NUMERIC(18,0)
		,  @dblLine7_2_Col4 NUMERIC(18,0)
		,  @dblLine8_2_Col1 NUMERIC(18,0)
		,  @dblLine8_2_Col2 NUMERIC(18,0)
		,  @dblLine8_2_Col3 NUMERIC(18,0)
		,  @dblLine8_2_Col4 NUMERIC(18,0)
		,  @dblLine9_2_Col1 NUMERIC(18,0)
		,  @dblLine9_2_Col2 NUMERIC(18,0)
		,  @dblLine9_2_Col3 NUMERIC(18,0)
		,  @dblLine9_2_Col4 NUMERIC(18,0)
		,  @dblLine10_2_Col1 NUMERIC(18,0)
		,  @dblLine11_2_Col2 NUMERIC(18,0)
		,  @dblLine12_2_Col2 NUMERIC(18,0)	
		,  @dblLine13_2_Col2 NUMERIC(18,0)
		,  @dblLine13_2_Col3 NUMERIC(18,0)
		,  @dblLine13_2_Col4 NUMERIC(18,0)
		,  @dblLine14_2_Col3 NUMERIC(18,0)	
		,  @dblLine14_2_Col4 NUMERIC(18,0)
		,  @dblLine1_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine2_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine3_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine4_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine1_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine2_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine3_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine4_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine1_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine2_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine3_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine4_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine1_2_Col2_Jetfuel NUMERIC(18,0)
		,  @dblLine2_2_Col2_Jetfuel NUMERIC(18,0)
		,  @dblLine3_2_Col2_Jetfuel NUMERIC(18,0)
		,  @dblLine4_2_Col2_Jetfuel NUMERIC(18,0)
		,  @dblLine5_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine6_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine7_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine8_2_Col1_Gasoline NUMERIC(18,0)
		,  @dblLine5_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine6_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine7_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine8_2_Col1_Gasohol NUMERIC(18,0)
		,  @dblLine5_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine6_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine7_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine8_2_Col2_Aviation NUMERIC(18,0)
		,  @dblLine5_2_Col2_Jetfuel NUMERIC(18,0)
		,  @dblLine6_2_Col2_Jetfuel NUMERIC(18,0)
		,  @dblLine7_2_Col2_Jetfuel NUMERIC(18,0)
		,  @dblLine8_2_Col2_Jetfuel NUMERIC(18,0)
		, @dblTaxRate_1_Col1 NUMERIC(18,8)
		, @dblTaxRate_1_Col2 NUMERIC(18,8)
		, @dblTaxRate_1_Col3 NUMERIC(18,8)
		, @dblLine8_1_Rate NUMERIC(18,8)
		, @dblLine9_1_Rate NUMERIC(18,8)
		, @dblLine11_1_Penalty NUMERIC(18,8)
		, @dblLine12_1_Interest NUMERIC(18,8)

	IF (ISNULL(@xmlParam,'') != '')
	BEGIN

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

		DECLARE @Guid NVARCHAR(100)
		DECLARE @dtmFrom DATETIME = NULL, @dtmTo DATETIME = NULL

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid


		-- SECTION 2
		SELECT @dblLine1_2_Col1_Gasoline = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2A' AND strType = 'Gasoline'
		SELECT @dblLine1_2_Col1_Gasohol = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2A' AND strType = 'Gasohol'
		SELECT @dblLine1_2_Col2_Aviation = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2A' AND strType = 'Aviation'
		SELECT @dblLine1_2_Col2_Jetfuel = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2A' AND strType = 'Jet Fuel'
		SELECT @dblLine1_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2A' AND strType = 'Clear Diesel'
		SELECT @dblLine1_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2A' AND strType = 'Dyed Diesel'

		SELECT @dblLine2_2_Col1_Gasoline = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2' AND strType = 'Gasoline'
		SELECT @dblLine2_2_Col1_Gasohol = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2' AND strType = 'Gasohol'
		SELECT @dblLine2_2_Col2_Aviation = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2' AND strType = 'Aviation'
		SELECT @dblLine2_2_Col2_Jetfuel = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2' AND strType = 'Jet Fuel'
		SELECT @dblLine2_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2' AND strType = 'Clear Diesel'
		SELECT @dblLine2_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2' AND strType = 'Dyed Diesel'

		SELECT @dblLine3_2_Col1_Gasoline = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Gasoline'
		SELECT @dblLine3_2_Col1_Gasohol = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Gasohol'
		SELECT @dblLine3_2_Col2_Aviation = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Aviation'
		SELECT @dblLine3_2_Col2_Jetfuel = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Jet Fuel'
		SELECT @dblLine3_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Clear Diesel'
		SELECT @dblLine3_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '3' AND strType = 'Dyed Diesel'

		SET @dblLine1_2_Col1 = @dblLine1_2_Col1_Gasoline + @dblLine1_2_Col1_Gasohol
		SET @dblLine2_2_Col1 = @dblLine2_2_Col1_Gasoline + @dblLine2_2_Col1_Gasohol
		SET @dblLine3_2_Col1 = @dblLine3_2_Col1_Gasoline + @dblLine3_2_Col1_Gasohol

		SET @dblLine1_2_Col2 = @dblLine1_2_Col2_Aviation + @dblLine1_2_Col2_Jetfuel
		SET @dblLine2_2_Col2 = @dblLine2_2_Col2_Aviation + @dblLine2_2_Col2_Jetfuel
		SET @dblLine3_2_Col2 = @dblLine3_2_Col2_Aviation + @dblLine3_2_Col2_Jetfuel

		SET @dblLine4_2_Col1 = @dblLine1_2_Col1_Gasoline + @dblLine1_2_Col1_Gasohol + @dblLine2_2_Col1_Gasoline + @dblLine2_2_Col1_Gasohol + @dblLine3_2_Col1_Gasoline + @dblLine3_2_Col1_Gasohol
		SET @dblLine4_2_Col2 = @dblLine1_2_Col2_Aviation + @dblLine1_2_Col2_Jetfuel + @dblLine2_2_Col2_Aviation + @dblLine2_2_Col2_Jetfuel + @dblLine3_2_Col2_Aviation + @dblLine3_2_Col2_Jetfuel
		SET @dblLine4_2_Col3 = @dblLine1_2_Col3 + @dblLine2_2_Col3 + @dblLine3_2_Col3
		SET @dblLine4_2_Col4 = @dblLine1_2_Col4 + @dblLine2_2_Col4 + @dblLine3_2_Col4

		SELECT @dblLine5_2_Col1_Gasoline = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6' AND strType = 'Gasoline'
		SELECT @dblLine5_2_Col1_Gasohol = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6' AND strType = 'Gasohol'
		SELECT @dblLine5_2_Col2_Aviation = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6' AND strType = 'Aviation'
		SELECT @dblLine5_2_Col2_Jetfuel = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6' AND strType = 'Jet Fuel'
		SELECT @dblLine5_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6' AND strType = 'Clear Diesel'
		SELECT @dblLine5_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '6' AND strType = 'Dyed Diesel'

		SELECT @dblLine6_2_Col1_Gasoline = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7' AND strType = 'Gasoline'
		SELECT @dblLine6_2_Col1_Gasohol = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7' AND strType = 'Gasohol'
		SELECT @dblLine6_2_Col2_Aviation = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7' AND strType = 'Aviation'
		SELECT @dblLine6_2_Col2_Jetfuel = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7' AND strType = 'Jet Fuel'
		SELECT @dblLine6_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7' AND strType = 'Clear Diesel'
		SELECT @dblLine6_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7' AND strType = 'Dyed Diesel'

		SELECT @dblLine7_2_Col1_Gasoline = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Gasoline'
		SELECT @dblLine7_2_Col1_Gasohol = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Gasohol'
		SELECT @dblLine7_2_Col2_Aviation = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Aviation'
		SELECT @dblLine7_2_Col2_Jetfuel = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Jet Fuel'
		SELECT @dblLine7_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Clear Diesel'
		SELECT @dblLine7_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Dyed Diesel'

		SET @dblLine5_2_Col1 = @dblLine5_2_Col1_Gasoline + @dblLine5_2_Col1_Gasohol
		SET @dblLine6_2_Col1 = @dblLine6_2_Col1_Gasoline + @dblLine6_2_Col1_Gasohol
		SET @dblLine7_2_Col1 = @dblLine7_2_Col1_Gasoline + @dblLine7_2_Col1_Gasohol

		SET @dblLine5_2_Col2 = @dblLine5_2_Col2_Aviation + @dblLine5_2_Col2_Jetfuel
		SET @dblLine6_2_Col2 = @dblLine6_2_Col2_Aviation + @dblLine6_2_Col2_Jetfuel
		SET @dblLine7_2_Col2 = @dblLine7_2_Col2_Aviation + @dblLine7_2_Col2_Jetfuel

		SET @dblLine8_2_Col1 = @dblLine5_2_Col1_Gasoline + @dblLine5_2_Col1_Gasohol + @dblLine6_2_Col1_Gasoline + @dblLine6_2_Col1_Gasohol + @dblLine7_2_Col1_Gasoline + @dblLine7_2_Col1_Gasohol
		SET @dblLine8_2_Col2 = @dblLine5_2_Col2_Aviation + @dblLine5_2_Col2_Jetfuel + @dblLine6_2_Col2_Aviation + @dblLine6_2_Col2_Jetfuel + @dblLine7_2_Col2_Aviation + @dblLine7_2_Col2_Jetfuel
		SET @dblLine8_2_Col3 = @dblLine5_2_Col3 + @dblLine6_2_Col3 + @dblLine7_2_Col3
		SET @dblLine8_2_Col4 = @dblLine5_2_Col4 + @dblLine6_2_Col4 + @dblLine7_2_Col4

		SET @dblLine9_2_Col1 = @dblLine4_2_Col1 - @dblLine8_2_Col1
		SET @dblLine9_2_Col2 = @dblLine4_2_Col2 - @dblLine8_2_Col2
		SET @dblLine9_2_Col3 = @dblLine4_2_Col3 - @dblLine8_2_Col3
		SET @dblLine9_2_Col4 = @dblLine4_2_Col4 - @dblLine8_2_Col4

		SET @dblLine10_2_Col1 = (@dblLine1_2_Col1_Gasoline + @dblLine2_2_Col1_Gasoline + @dblLine3_2_Col1_Gasoline) - (@dblLine5_2_Col1_Gasoline + @dblLine6_2_Col1_Gasoline + @dblLine7_2_Col1_Gasoline)
		SET @dblLine11_2_Col2 = (@dblLine1_2_Col2_Aviation + @dblLine2_2_Col2_Aviation + @dblLine3_2_Col2_Aviation) - (@dblLine5_2_Col2_Aviation + @dblLine6_2_Col2_Aviation + @dblLine7_2_Col2_Aviation)
		SET @dblLine12_2_Col2 = (@dblLine1_2_Col2_Jetfuel + @dblLine2_2_Col2_Jetfuel + @dblLine3_2_Col2_Jetfuel) - (@dblLine5_2_Col2_Jetfuel + @dblLine6_2_Col2_Jetfuel + @dblLine7_2_Col2_Jetfuel) 

		SELECT @dblLine13_2_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType IN ('Aviation', 'Jet Fuel')
		SELECT @dblLine13_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Clear Diesel'
		SELECT @dblLine13_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '8' AND strType = 'Dyed Diesel'

		SELECT @dblLine14_2_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10Y' AND strType = 'Clear Diesel'
		SELECT @dblLine14_2_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '10Y' AND strType = 'Dyed Diesel'

		-- Section 1
		SET @dblLine1_1_Col1 = @dblLine9_2_Col1
		SET @dblLine1_1_Col2 = @dblLine9_2_Col2
		SET @dblLine1_1_Col3 = @dblLine9_2_Col3
		SET @dblLine1_1_Col4 = @dblLine9_2_Col4

		SELECT @strTaxRate_1_Col1 = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln2Gas'
		SELECT @strTaxRate_1_Col2 = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln2Avi'
		SELECT @strTaxRate_1_Col3 = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln2DieselClear'

		SET @dblTaxRate_1_Col1 = CONVERT(NUMERIC(18,8), @strTaxRate_1_Col1) 
		SET @dblTaxRate_1_Col2 = CONVERT(NUMERIC(18,8), @strTaxRate_1_Col2) 
		SET @dblTaxRate_1_Col3 = CONVERT(NUMERIC(18,8), @strTaxRate_1_Col3) 

		SET @dblLine2_1_Col1 = @dblLine1_1_Col1 * @dblTaxRate_1_Col1
		SET @dblLine2_1_Col2 = @dblLine1_1_Col2 * @dblTaxRate_1_Col2
		SET @dblLine2_1_Col3 = @dblLine1_1_Col3 * @dblTaxRate_1_Col3

		SELECT @strLine3_1_Rate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln3'	
		SET @dblLine3_1_Col2 = CONVERT(NUMERIC(18,8), @strLine3_1_Rate) 

		SET @dblLine4_1_Col1 = @dblLine2_1_Col1
		SET @dblLine4_1_Col2 = @dblLine2_1_Col2 - @dblLine3_1_Col2
		SET @dblLine4_1_Col3 = @dblLine2_1_Col3

		SET @dblLine5_1_Col1 = @dblLine1_1_Col1 + @dblLine7_2_Col1
		SET @dblLine5_1_Col2 = @dblLine1_1_Col2 + @dblLine7_2_Col2
		SET @dblLine5_1_Col3 = @dblLine1_1_Col3 + @dblLine7_2_Col3
		SET @dblLine5_1_Col4 = @dblLine1_1_Col4 + @dblLine7_2_Col4

		SET @dblLine6_1_Col2 = @dblLine13_2_Col2
		SET @dblLine6_1_Col3 = @dblLine13_2_Col3 + @dblLine14_2_Col3
		SET @dblLine6_1_Col4 = @dblLine13_2_Col4 + @dblLine14_2_Col4

		SET @dblLine7_1_Col1 = @dblLine5_1_Col1
		SET @dblLine7_1_Col2 = @dblLine5_1_Col2 - @dblLine6_1_Col2
		SET @dblLine7_1_Col3 = @dblLine5_1_Col3 - @dblLine6_1_Col3
		SET @dblLine7_1_Col4 = @dblLine5_1_Col4 - @dblLine6_1_Col4

		SELECT @strLine8_1_Rate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln8'
		SET @dblLine8_1_Rate = CONVERT(NUMERIC(18,8), @strLine8_1_Rate) 

		SET @dblLine8_1_Col1 = @dblLine7_1_Col1 * @dblLine8_1_Rate 
		SET @dblLine8_1_Col2 = @dblLine7_1_Col2 * @dblLine8_1_Rate 
		SET @dblLine8_1_Col3 = @dblLine7_1_Col3 * @dblLine8_1_Rate 
		SET @dblLine8_1_Col4 = @dblLine7_1_Col4 * @dblLine8_1_Rate 

		SELECT @strLine9_1_Rate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln9'
		SET @dblLine9_1_Rate = CONVERT(NUMERIC(18,8), @strLine9_1_Rate) 

		SET @dblLine10_1_Col1 = (@dblLine4_1_Col1 + @dblLine8_1_Col1) - @dblLine9_1_Rate
		SET @dblLine10_1_Col2 = (@dblLine4_1_Col2 + @dblLine8_1_Col2) - @dblLine9_1_Rate
		SET @dblLine10_1_Col3 = (@dblLine4_1_Col3 + @dblLine8_1_Col3) - @dblLine9_1_Rate
		SET @dblLine10_1_Col4 = @dblLine8_1_Col4 - @dblLine9_1_Rate

		SELECT @strLine11_1_Penalty = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln11'
		SELECT @strLine12_1_Interest = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MF32Form-Ln12'

		SET @dblLine11_1_Penalty = CONVERT(NUMERIC(18,8), @strLine11_1_Penalty) 
		SET @dblLine12_1_Interest = CONVERT(NUMERIC(18,8), @strLine12_1_Interest) 

		SET @strLine11_1_Penalty = '$' + @strLine11_1_Penalty
		SET @strLine12_1_Interest = '$' + @strLine12_1_Interest

		SET @dblLine13_1_Col1 = @dblLine10_1_Col1 + @dblLine10_1_Col2 + @dblLine10_1_Col3 + @dblLine10_1_Col4 + @dblLine11_1_Penalty +  @dblLine12_1_Interest

		INSERT INTO @Output VALUES( 
		@dblLine1_1_Col1 
		, @dblLine1_1_Col2 
		, @dblLine1_1_Col3 
		, @dblLine1_1_Col4 
		, @dblLine2_1_Col1 
		, @dblLine2_1_Col2 
		, @dblLine2_1_Col3 
		, @strTaxRate_1_Col1 
		, @strTaxRate_1_Col2 
		, @strTaxRate_1_Col3 
		, @strLine3_1_Rate 
		, @dblLine3_1_Col2 
		, @dblLine4_1_Col1 
		, @dblLine4_1_Col2 
		, @dblLine4_1_Col3 
		, @dblLine5_1_Col1 
		, @dblLine5_1_Col2 
		, @dblLine5_1_Col3 
		, @dblLine5_1_Col4 
		, @dblLine6_1_Col2 
		, @dblLine6_1_Col3 
		, @dblLine6_1_Col4 
		, @dblLine7_1_Col1 
		, @dblLine7_1_Col2 
		, @dblLine7_1_Col3 
		, @dblLine7_1_Col4 
		, @dblLine8_1_Col1 
		, @dblLine8_1_Col2 
		, @dblLine8_1_Col3 
		, @dblLine8_1_Col4 
		, @strLine8_1_Rate 
		, @strLine9_1_Rate 
		, @dblLine10_1_Col1 
		, @dblLine10_1_Col2 
		, @dblLine10_1_Col3 
		, @dblLine10_1_Col4 
		, @strLine11_1_Penalty 
		, @strLine12_1_Interest 
		, @dblLine13_1_Col1 
		, @dblLine1_2_Col1 
		, @dblLine1_2_Col2 
		, @dblLine1_2_Col3 
		, @dblLine1_2_Col4 
		, @dblLine2_2_Col1 
		, @dblLine2_2_Col2 
		, @dblLine2_2_Col3 
		, @dblLine2_2_Col4 		
		, @dblLine3_2_Col1 
		, @dblLine3_2_Col2 
		, @dblLine3_2_Col3 
		, @dblLine3_2_Col4 
		, @dblLine4_2_Col1 
		, @dblLine4_2_Col2 
		, @dblLine4_2_Col3 
		, @dblLine4_2_Col4 
		, @dblLine5_2_Col1 
		, @dblLine5_2_Col2 
		, @dblLine5_2_Col3 
		, @dblLine5_2_Col4 
		, @dblLine6_2_Col1 
		, @dblLine6_2_Col2 
		, @dblLine6_2_Col3 
		, @dblLine6_2_Col4 
		, @dblLine7_2_Col1 
		, @dblLine7_2_Col2 
		, @dblLine7_2_Col3 
		, @dblLine7_2_Col4 
		, @dblLine8_2_Col1 
		, @dblLine8_2_Col2 
		, @dblLine8_2_Col3 
		, @dblLine8_2_Col4 
		, @dblLine9_2_Col1 
		, @dblLine9_2_Col2 
		, @dblLine9_2_Col3 
		, @dblLine9_2_Col4 
		, @dblLine10_2_Col1 
		, @dblLine11_2_Col2 
		, @dblLine12_2_Col2 	
		, @dblLine13_2_Col2 
		, @dblLine13_2_Col3 
		, @dblLine13_2_Col4 
		, @dblLine14_2_Col3 	
		, @dblLine14_2_Col4 
		, @dtmFrom 
		, @dtmTo)

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
	)
END CATCH