CREATE PROCEDURE [dbo].[uspTFGenerateRMFT5]
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
		dblLine1_Col1 NUMERIC
		, dblLine1_Col2 NUMERIC
		, dblLine1_Col3 NUMERIC
		, dblLine2a_Col1 NUMERIC
		, dblLine2a_Col2 NUMERIC
		, dblLine2a_Col3 NUMERIC
		, dblLine2b_Col1 NUMERIC
		, dblLine2b_Col2 NUMERIC
		, dblLine2b_Col3 NUMERIC
		, dblLine2c_Col1 NUMERIC
		, dblLine2c_Col2 NUMERIC
		, dblLine2c_Col3 NUMERIC
		, dblLine3_Col1 NUMERIC
		, dblLine3_Col2 NUMERIC
		, dblLine3_Col3 NUMERIC
		, dblLine4_Col1 NUMERIC
		, dblLine4_Col2 NUMERIC
		, dblLine4_Col3 NUMERIC
		, dblLine5_Col1 NUMERIC
		, dblLine5_Col2 NUMERIC
		, dblLine5_Col3 NUMERIC
		, dblLine6_Col1 NUMERIC
		, dblLine6_Col2 NUMERIC
		, dblLine6_Col3 NUMERIC
		, dblLine7_Col1 NUMERIC
		, dblLine7_Col2 NUMERIC
		, dblLine7_Col3 NUMERIC
		, dblLine8a_Col1 NUMERIC
		, dblLine8a_Col2 NUMERIC
		, dblLine8a_Col3 NUMERIC
		, dblLine8b_Col1 NUMERIC
		, dblLine8b_Col2 NUMERIC
		, dblLine8b_Col3 NUMERIC
		, dblLine8c_Col1 NUMERIC
		, dblLine8c_Col2 NUMERIC
		, dblLine8c_Col3 NUMERIC
		, dblLine9_Col1 NUMERIC
		, dblLine9_Col2 NUMERIC
		, dblLine9_Col3 NUMERIC
		, dblLine10a_Col1 NUMERIC
		, dblLine10a_Col2 NUMERIC
		, dblLine10a_Col3 NUMERIC
		, dblLine10b_Col1 NUMERIC
		, dblLine10b_Col2 NUMERIC
		, dblLine10b_Col3 NUMERIC
		, dblLine11_Col1 NUMERIC
		, dblLine11_Col2 NUMERIC
		, dblLine11_Col3 NUMERIC
		, dblLine12_Col1 NUMERIC
		, dblLine12_Col2 NUMERIC
		, dblLine12_Col3 NUMERIC
		, dblLine13_Col1 NUMERIC
		, dblLine13_Col2 NUMERIC
		, dblLine14_Col1 NUMERIC
		, dblLine14_Col2 NUMERIC
		, dblLine15_Col1 NUMERIC
		, dblLine15_Col2 NUMERIC
		, dblLine16_Col1 NUMERIC
		, dblLine16_Col2 NUMERIC
		, dblLine17_Col1 NUMERIC
		, dblLine17_Col2 NUMERIC
		, dblLine18_Col1 NUMERIC
		, dblLine18_Col2 NUMERIC
		, dblLine19_Col1 NUMERIC(18,2)
		, dblLine19_Col2 NUMERIC(18,2)
		, dblLine20_Col1 NUMERIC(18,2)
		, dblLine20_Col2 NUMERIC(18,2)		
		, dblLine20a NUMERIC(18,2)
		, dblLine20b NUMERIC(18,2)		
		, dblLine21_Col1 NUMERIC(18,2)
		, dblLine21_Col2 NUMERIC(18,2)
		, dblLine22_Col1 NUMERIC(18,2)
		, dblLine23_Col1 NUMERIC(18,2)
		, dblLine24_Col1 NUMERIC(18,2)
		, dblTaxRateGas NUMERIC(18,2)
		, dblDiscGas NUMERIC(18,2)
		, dblTaxRateSpecialFuel  NUMERIC(18,2)
		, dblDiscSpecialFuel  NUMERIC(18,2)
		, strDistLicense NVARCHAR(50)
		, strSupplierLicense NVARCHAR(50)
		, dtmFrom DATE
		, dtmTo DATE)

	DECLARE @dblLine1_Col1 NUMERIC = 0
		, @dblLine1_Col2 NUMERIC = 0
		, @dblLine1_Col3 NUMERIC = 0
		, @dblLine2a_Col1 NUMERIC = 0
		, @dblLine2a_Col2 NUMERIC = 0
		, @dblLine2a_Col3 NUMERIC = 0
		, @dblLine2b_Col1 NUMERIC = 0
		, @dblLine2b_Col2 NUMERIC = 0
		, @dblLine2b_Col3 NUMERIC = 0
		, @dblLine2c_Col1 NUMERIC = 0
		, @dblLine2c_Col2 NUMERIC = 0
		, @dblLine2c_Col3 NUMERIC = 0
		, @dblLine3_Col1 NUMERIC = 0
		, @dblLine3_Col2 NUMERIC = 0
		, @dblLine3_Col3 NUMERIC = 0
		, @dblLine4_Col1 NUMERIC = 0
		, @dblLine4_Col2 NUMERIC = 0
		, @dblLine4_Col3 NUMERIC = 0
		, @dblLine5_Col1 NUMERIC = 0
		, @dblLine5_Col2 NUMERIC = 0
		, @dblLine5_Col3 NUMERIC = 0
		, @dblLine6_Col1 NUMERIC = 0
		, @dblLine6_Col2 NUMERIC = 0
		, @dblLine6_Col3 NUMERIC = 0
		, @dblLine7_Col1 NUMERIC = 0
		, @dblLine7_Col2 NUMERIC = 0
		, @dblLine7_Col3 NUMERIC = 0
		, @dblLine8a_Col1 NUMERIC = 0
		, @dblLine8a_Col2 NUMERIC = 0
		, @dblLine8a_Col3 NUMERIC = 0
		, @dblLine8b_Col1 NUMERIC = 0
		, @dblLine8b_Col2 NUMERIC = 0
		, @dblLine8b_Col3 NUMERIC = 0
		, @dblLine8c_Col1 NUMERIC = 0
		, @dblLine8c_Col2 NUMERIC = 0
		, @dblLine8c_Col3 NUMERIC = 0
		, @dblLine9_Col1 NUMERIC = 0
		, @dblLine9_Col2 NUMERIC = 0
		, @dblLine9_Col3 NUMERIC = 0
		, @dblLine10a_Col1 NUMERIC = 0
		, @dblLine10a_Col2 NUMERIC = 0
		, @dblLine10a_Col3 NUMERIC = 0
		, @dblLine10b_Col1 NUMERIC = 0
		, @dblLine10b_Col2 NUMERIC = 0
		, @dblLine10b_Col3 NUMERIC = 0
		, @dblLine11_Col1 NUMERIC = 0
		, @dblLine11_Col2 NUMERIC = 0
		, @dblLine11_Col3 NUMERIC = 0
		, @dblLine12_Col1 NUMERIC = 0
		, @dblLine12_Col2 NUMERIC = 0
		, @dblLine12_Col3 NUMERIC = 0
		, @dblLine13_Col1 NUMERIC = 0
		, @dblLine13_Col2 NUMERIC = 0
		, @dblLine14_Col1 NUMERIC = 0
		, @dblLine14_Col2 NUMERIC = 0
		, @dblLine15_Col1 NUMERIC = 0
		, @dblLine15_Col2 NUMERIC = 0
		, @dblLine16_Col1 NUMERIC = 0
		, @dblLine16_Col2 NUMERIC = 0
		, @dblLine17_Col1 NUMERIC = 0
		, @dblLine17_Col2 NUMERIC = 0
		, @dblLine18_Col1 NUMERIC = 0
		, @dblLine18_Col2 NUMERIC = 0
		, @dblLine19_Col1 NUMERIC(18,2) = 0
		, @dblLine19_Col2 NUMERIC(18,2) = 0
		, @dblLine20_Col1 NUMERIC(18,2) = 0
		, @dblLine20_Col2 NUMERIC(18,2) = 0
		, @dblLine20a NUMERIC(18,2) = 0
		, @dblLine20b NUMERIC(18,2) = 0
		, @dblLine21_Col1 NUMERIC(18,2) = 0
		, @dblLine21_Col2 NUMERIC(18,2) = 0
		, @dblLine22_Col1 NUMERIC(18,2) = 0
		, @dblLine23_Col1 NUMERIC(18,2) = 0
		, @dblLine24_Col1 NUMERIC(18,2) = 0
		, @dblTaxRateGas  NUMERIC(18,2) = 0
		, @dblDiscGas  NUMERIC(18,2) = 0
		, @dblTaxRateSpecialFuel  NUMERIC(18,2) = 0
		, @dblDiscSpecialFuel  NUMERIC(18,2) = 0
		, @strDistLicense NVARCHAR(50)
		, @strSupplierLicense NVARCHAR(50)
		, @dtmFrom DATE
		, @dtmTo DATE

	IF (ISNULL(@xmlParam,'') != '')
	BEGIN 
		DECLARE @Guid NVARCHAR(250),
			@idoc INT

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

		SELECT @dblTaxRateGas = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-TaxRateGas'
		SELECT @dblDiscGas = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-ColDiscGas'
		SELECT @dblTaxRateSpecialFuel = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-TaxRateSpecialFuel'
		SELECT @dblDiscSpecialFuel = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-ColDiscSpecialFuel'

		SELECT @strDistLicense = ISNULL(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-DistLicense'
		SELECT @strSupplierLicense = ISNULL(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-SupplierLicense'
		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		-- Line 1
		SELECT @dblLine1_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line1Col1'
		SELECT @dblLine1_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line1Col2'
		SELECT @dblLine1_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line1Col3'

		-- Line 2a
		SELECT @dblLine2a_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'A' AND strType IN ('Received, MFT-free Only','Received, Both MFT- and UST-/EIF-free','Imported, MFT-free Only', 'Imported, Both MFT- and UST-/EIF-free')
		SELECT @dblLine2a_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SA' AND strType IN ('Received, MFT-free Only','Received, Both MFT- and UST-/EIF-free','Imported, MFT-free Only', 'Imported, Both MFT- and UST-/EIF-free')
		SELECT @dblLine2a_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DA' AND strType IN ('Received, MFT-free Only','Received, Both MFT- and UST-/EIF-free','Imported, MFT-free Only', 'Imported, Both MFT- and UST-/EIF-free')

		-- Line 2b
		SELECT @dblLine2b_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'E' AND strType IN ('Gasoline, MFT-paid Only','Gasoline, Both MFT- and UST-/EIF-paid','Combustible Gases, MFT-paid Only', 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', 'Alcohol, MFT-paid Only', 'Alcohol, Both MFT- and UST-/EIF-paid')
		SELECT @dblLine2b_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SE' AND strType IN ('Special Fuel (Excluding Dyed Diesel), MFT-paid Only','Special Fuel (Excluding Dyed Diesel), Both MFT- and UST-/EIF-paid','1-K Kerosene, MFT-paid Only', '1-K Kerosene, Both MFT- and UST-/EIF-paid', 'Other, MFT-paid Only', 'Other, Both MFT- and UST-/EIF-paid')
		SET @dblLine2b_Col3 = null

		-- Line 2c
		SELECT @dblLine2c_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'GA-1' AND strType IN ('Alcohol','LP Gas','Other')
		SELECT @dblLine2c_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'GA-1' AND strType = '1-K Kerosene'
		SET @dblLine2c_Col3 = null

		-- Line 3
		SET @dblLine3_Col1 = ISNULL(@dblLine1_Col1, 0) +  ISNULL(@dblLine2a_Col1, 0) +  ISNULL(@dblLine2b_Col1, 0) +  ISNULL(@dblLine2c_Col1, 0)
		SET @dblLine3_Col2 =  ISNULL(@dblLine1_Col2, 0) +  ISNULL(@dblLine2a_Col2, 0) +  ISNULL(@dblLine2b_Col2, 0) +  ISNULL(@dblLine2c_Col2, 0)
		SET @dblLine3_Col3 = ISNULL(@dblLine1_Col3, 0) +  ISNULL(@dblLine2a_Col3, 0)

		-- Line 4
		SELECT @dblLine4_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line4Col1'
		SELECT @dblLine4_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line4Col2'
		SELECT @dblLine4_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line4Col3'

		-- Line 5
		SET @dblLine5_Col1 = ISNULL(@dblLine4_Col1, 0) -  ISNULL(@dblLine3_Col1, 0)
		SET @dblLine5_Col2 = ISNULL(@dblLine4_Col2, 0) -  ISNULL(@dblLine3_Col2, 0)
		SET @dblLine5_Col3 = ISNULL(@dblLine4_Col3, 0) -  ISNULL(@dblLine3_Col3, 0)

		-- Line 6
		SELECT @dblLine6_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'B'
		SELECT @dblLine6_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SB'
		SELECT @dblLine6_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DB'

		-- Line 7
		SELECT @dblLine7_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'C'
		SELECT @dblLine7_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SC'
		SELECT @dblLine7_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DC'

		-- Line 8a
		SELECT @dblLine8a_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'D' AND strType IN ('MFT-free Only','Both MFT- and UST-/EIF-free')
		SELECT @dblLine8a_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SD' AND strType IN ('MFT-free Only','Both MFT- and UST-/EIF-free')
		SELECT @dblLine8a_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DD' AND strType IN ('MFT-free Only','Both MFT- and UST-/EIF-free')

		-- Line 8b
		SET @dblLine8b_Col1 = null
		SET @dblLine8b_Col2 = null
		SELECT @dblLine8b_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DD-1'
		
		-- Line 8c
		SET @dblLine8c_Col1 = null
		SET @dblLine8c_Col2 = null
		SELECT @dblLine8c_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line8C'

		-- Line 9
		SELECT @dblLine9_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line9Col1'
		SELECT @dblLine9_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line9Col2' 
		SELECT @dblLine9_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line9Col3'
		
		-- Line 10a
		SELECT @dblLine10a_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line10Col1'
		SELECT @dblLine10a_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line10Col2'  
		SELECT @dblLine10a_Col3 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line10Col3'

		-- Line 10b
		SET @dblLine10b_Col1 = @dblLine10a_Col1
		SET @dblLine10b_Col2 = @dblLine10a_Col2
		SET @dblLine10b_Col3 = @dblLine10a_Col3

		-- Line 11
		SET @dblLine11_Col1 = ISNULL(@dblLine6_Col1, 0) +  ISNULL(@dblLine7_Col1, 0) +  ISNULL(@dblLine8a_Col1, 0) +  ISNULL(@dblLine8b_Col1, 0)  +  ISNULL(@dblLine8c_Col1, 0)  +  ISNULL(@dblLine9_Col1, 0) +  ISNULL(@dblLine10a_Col1, 0) +  ISNULL(@dblLine10b_Col1, 0)
		SET @dblLine11_Col2 = ISNULL(@dblLine6_Col2, 0) +  ISNULL(@dblLine7_Col2, 0) +  ISNULL(@dblLine8a_Col2, 0) +  ISNULL(@dblLine8b_Col2, 0)  +  ISNULL(@dblLine8c_Col2, 0)  +  ISNULL(@dblLine9_Col2, 0) +  ISNULL(@dblLine10a_Col2, 0) +  ISNULL(@dblLine10b_Col2, 0)
		SET @dblLine11_Col3 = ISNULL(@dblLine6_Col3, 0) +  ISNULL(@dblLine7_Col3, 0) +  ISNULL(@dblLine8a_Col3, 0) +  ISNULL(@dblLine8b_Col3, 0)  +  ISNULL(@dblLine8c_Col3, 0)  +  ISNULL(@dblLine9_Col3, 0) +  ISNULL(@dblLine10a_Col3, 0) +  ISNULL(@dblLine10b_Col3, 0)

		-- Line 12
		SET @dblLine12_Col1 = ISNULL(@dblLine5_Col1, 0) - ISNULL(@dblLine11_Col1, 0)
		SET @dblLine12_Col2 = ISNULL(@dblLine5_Col2, 0) - ISNULL(@dblLine11_Col2, 0)
		SET @dblLine12_Col3 = 0

		-- Line 13
		SELECT @dblLine13_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line13Col1'
		SELECT @dblLine13_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line13Col2'
		--SET @dblLine13_Col3 = null

		-- Line 14
		SELECT @dblLine14_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line14Col1'
		SELECT @dblLine14_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line14Col2'
		--SET @dblLine14_Col3 = null

		-- Line 15
		SELECT @dblLine15_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line15Col1'
		SELECT @dblLine15_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line15Col2'
		--SET @dblLine15_Col3 = null

		-- Line 16
		SET @dblLine16_Col1 = ISNULL(@dblLine13_Col1, 0) + ISNULL(@dblLine14_Col1, 0) + ISNULL(@dblLine15_Col1, 0)
		SET @dblLine16_Col2 =  ISNULL(@dblLine13_Col2, 0) + ISNULL(@dblLine14_Col2, 0) + ISNULL(@dblLine15_Col2, 0)
		--SET @dblLine16_Col3 = null

		-- Line 17
		SELECT @dblLine17_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'E'
		SELECT @dblLine17_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SE'
		--SET @dblLine17_Col3 = null

		-- Line 18
		SET @dblLine18_Col1 = ISNULL(@dblLine16_Col1, 0) - ISNULL(@dblLine17_Col1, 0)
		SET @dblLine18_Col2 = ISNULL(@dblLine16_Col2, 0) - ISNULL(@dblLine17_Col2, 0)


		IF  @dblLine18_Col1 > 0
		BEGIN
			SET @dblLine19_Col1  =  ISNULL(@dblLine18_Col1, 0) * ISNULL(@dblTaxRateGas, 0)
			SET @dblLine20a = ISNULL(@dblLine13_Col1, 0) - ISNULL(@dblLine17_Col1, 0)
			SET @dblLine20_Col1  = @dblLine20a * ISNULL(@dblTaxRateGas, 0) * ISNULL(@dblDiscGas, 0)
			SET @dblLine21_Col1  = ISNULL(@dblLine19_Col1, 0) - ISNULL(@dblLine20_Col1, 0)
		END

		IF  @dblLine18_Col2 > 0
		BEGIN
			SET @dblLine19_Col2  = ISNULL(@dblLine18_Col2, 0) * ISNULL(@dblTaxRateSpecialFuel, 0)
			SET @dblLine20b = ISNULL(@dblLine13_Col2, 0) - ISNULL(@dblLine17_Col2, 0)
			SET @dblLine20_Col2  = @dblLine20b * ISNULL(@dblTaxRateGas, 0) * ISNULL(@dblDiscGas, 0)
			SET @dblLine21_Col2  = ISNULL(@dblLine19_Col2, 0) - ISNULL(@dblLine20_Col2, 0)
		END

		-- Line 22
		SET @dblLine22_Col1  = ISNULL(@dblLine21_Col1, 0) + ISNULL(@dblLine21_Col2, 0)

		--Line 23
		SELECT @dblLine23_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-Line23'

		-- Line 24	
		SET @dblLine24_Col1  = ISNULL(@dblLine22_Col1, 0) - ISNULL(@dblLine23_Col1, 0)

	END

	-- INSERT
	INSERT INTO @Output VALUES(
		@dblLine1_Col1
		,@dblLine1_Col2
		,@dblLine1_Col3
		,@dblLine2a_Col1
		,@dblLine2a_Col2
		,@dblLine2a_Col3
		,@dblLine2b_Col1
		,@dblLine2b_Col2
		,@dblLine2b_Col3
		,@dblLine2c_Col1
		,@dblLine2c_Col2
		,@dblLine2c_Col3
		,@dblLine3_Col1
		,@dblLine3_Col2
		,@dblLine3_Col3
		,@dblLine4_Col1
		,@dblLine4_Col2
		,@dblLine4_Col3
		,@dblLine5_Col1
		,@dblLine5_Col2
		,@dblLine5_Col3
		,@dblLine6_Col1
		,@dblLine6_Col2
		,@dblLine6_Col3
		,@dblLine7_Col1
		,@dblLine7_Col2
		,@dblLine7_Col3
		,@dblLine8a_Col1
		,@dblLine8a_Col2
		,@dblLine8a_Col3
		,@dblLine8b_Col1
		,@dblLine8b_Col2
		,@dblLine8b_Col3
		,@dblLine8c_Col1
		,@dblLine8c_Col2
		,@dblLine8c_Col3
		,@dblLine9_Col1
		,@dblLine9_Col2
		,@dblLine9_Col3
		,@dblLine10a_Col1
		,@dblLine10a_Col2
		,@dblLine10a_Col3
		,@dblLine10b_Col1
		,@dblLine10b_Col2
		,@dblLine10b_Col3
		,@dblLine11_Col1
		,@dblLine11_Col2
		,@dblLine11_Col3
		,@dblLine12_Col1
		,@dblLine12_Col2
		,@dblLine12_Col3
		,@dblLine13_Col1
		,@dblLine13_Col2
		,@dblLine14_Col1
		,@dblLine14_Col2
		,@dblLine15_Col1
		,@dblLine15_Col2
		,@dblLine16_Col1
		,@dblLine16_Col2
		,@dblLine17_Col1
		,@dblLine17_Col2
		,@dblLine18_Col1
		,@dblLine18_Col2
		,@dblLine19_Col1
		,@dblLine19_Col2
		,@dblLine20_Col1
		,@dblLine20_Col2
		,@dblLine20a
		,@dblLine20b		
		,@dblLine21_Col1
		,@dblLine21_Col2
		,@dblLine22_Col1
		,@dblLine23_Col1
		,@dblLine24_Col1
		,@dblTaxRateGas
		,@dblDiscGas
		,@dblTaxRateSpecialFuel
		,@dblDiscSpecialFuel
		,@strDistLicense
		,@strSupplierLicense
		,@dtmFrom
		,@dtmTo
	)

	SELECT * FROM @Output

	Return;

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