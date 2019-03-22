CREATE PROCEDURE [dbo].[uspTFGenerateOHMF2]
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

	DECLARE @Name NVARCHAR(100)
		, @TIN NVARCHAR(50)
		, @OhioAccountNo NVARCHAR(50)
		, @dtmFrom DATE
		, @dtmTo DATE
	
		, @Gasoline_1 NUMERIC(18, 6) = 0.00
		, @Gasoline_2 NUMERIC(18, 6) = 0.00
		, @Gasoline_3 NUMERIC(18, 6) = 0.00
		, @Gasoline_4 NUMERIC(18, 6) = 0.00
		, @Gasoline_5 NUMERIC(18, 6) = 0.00
		, @Gasoline_6 NUMERIC(18, 6) = 0.00
		, @Gasoline_7 NUMERIC(18, 6) = 0.00
		, @Gasoline_8 NUMERIC(18, 6) = 0.00
		, @Gasoline_9 NUMERIC(18, 6) = 0.00
		, @Gasoline_10 NUMERIC(18, 6) = 0.00
		, @Gasoline_11 NUMERIC(18, 6) = 0.00
		--, @Gasoline_12 NUMERIC(18, 6) = 0.00
		, @Gasoline_13 NUMERIC(18, 6) = 0.00
		, @Gasoline_14 NUMERIC(18, 6) = 0.00
		, @Gasoline_15 NUMERIC(18, 6) = 0.00
		, @Gasoline_16 NUMERIC(18, 6) = 0.00
		, @Gasoline_17 NUMERIC(18, 6) = 0.00
		, @Gasoline_18 NUMERIC(18, 6) = 0.00
		, @Gasoline_19 NUMERIC(18, 6) = 0.00	
		, @Gasoline_20 NUMERIC(18, 6) = 0.00		
		, @Gasoline_21 NUMERIC(18, 6) = 0.00		
		, @Gasoline_22 NUMERIC(18, 6) = 0.00	
		, @Gasoline_23 NUMERIC(18, 6) = 0.00			
		, @Gasoline_24 NUMERIC(18, 6) = 0.00
		, @Gasoline_25 NUMERIC(18, 6) = 0.00
		, @Gasoline_26 NUMERIC(18, 6) = 0.00
		, @Gasoline_27 NUMERIC(18, 6) = 0.00
		, @Gasoline_28 NUMERIC(18, 6) = 0.00

		, @ClearDiesel_1 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_2 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_3 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_4 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_5 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_6 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_7 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_8 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_9 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_10 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_11 NUMERIC(18, 6) = 0.00
		--, @ClearDiesel_12 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_13 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_14 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_15 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_16 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_17 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_18 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_19 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_20 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_21 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_22 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_23 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_24 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_25 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_26 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_27 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_28 NUMERIC(18, 6) = 0.00

		, @LowSulfur_1 NUMERIC(18, 6) = 0.00
		, @LowSulfur_2 NUMERIC(18, 6) = 0.00
		, @LowSulfur_3 NUMERIC(18, 6) = 0.00
		, @LowSulfur_4 NUMERIC(18, 6) = 0.00
		, @LowSulfur_5 NUMERIC(18, 6) = 0.00
		, @LowSulfur_6 NUMERIC(18, 6) = 0.00
		, @LowSulfur_7 NUMERIC(18, 6) = 0.00
		, @LowSulfur_8 NUMERIC(18, 6) = 0.00
		, @LowSulfur_9 NUMERIC(18, 6) = 0.00
		, @LowSulfur_10 NUMERIC(18, 6) = 0.00
		, @LowSulfur_11 NUMERIC(18, 6) = 0.00
		, @LowSulfur_12 NUMERIC(18, 6) = 0.00
		, @LowSulfur_13 NUMERIC(18, 6) = 0.00
		, @LowSulfur_14 NUMERIC(18, 6) = 0.00
		, @LowSulfur_15 NUMERIC(18, 6) = 0.00
		, @LowSulfur_16 NUMERIC(18, 6) = 0.00
		, @LowSulfur_17 NUMERIC(18, 6) = 0.00
		, @LowSulfur_18 NUMERIC(18, 6) = 0.00
		, @LowSulfur_19 NUMERIC(18, 6) = 0.00
		, @LowSulfur_20 NUMERIC(18, 6) = 0.00
		, @LowSulfur_21 NUMERIC(18, 6) = 0.00
		, @LowSulfur_22 NUMERIC(18, 6) = 0.00
		, @LowSulfur_23 NUMERIC(18, 6) = 0.00
		, @LowSulfur_24 NUMERIC(18, 6) = 0.00
		, @LowSulfur_25 NUMERIC(18, 6) = 0.00
		, @LowSulfur_26 NUMERIC(18, 6) = 0.00
		, @LowSulfur_27 NUMERIC(18, 6) = 0.00
		, @LowSulfur_28 NUMERIC(18, 6) = 0.00

		, @HighSulfur_1 NUMERIC(18, 6) = 0.00
		, @HighSulfur_2 NUMERIC(18, 6) = 0.00
		, @HighSulfur_3 NUMERIC(18, 6) = 0.00
		, @HighSulfur_4 NUMERIC(18, 6) = 0.00
		, @HighSulfur_5 NUMERIC(18, 6) = 0.00
		, @HighSulfur_6 NUMERIC(18, 6) = 0.00
		, @HighSulfur_7 NUMERIC(18, 6) = 0.00
		, @HighSulfur_8 NUMERIC(18, 6) = 0.00
		, @HighSulfur_9 NUMERIC(18, 6) = 0.00
		, @HighSulfur_10 NUMERIC(18, 6) = 0.00
		, @HighSulfur_11 NUMERIC(18, 6) = 0.00
		, @HighSulfur_12 NUMERIC(18, 6) = 0.00
		, @HighSulfur_13 NUMERIC(18, 6) = 0.00
		, @HighSulfur_14 NUMERIC(18, 6) = 0.00
		, @HighSulfur_15 NUMERIC(18, 6) = 0.00
		, @HighSulfur_16 NUMERIC(18, 6) = 0.00
		, @HighSulfur_17 NUMERIC(18, 6) = 0.00
		, @HighSulfur_18 NUMERIC(18, 6) = 0.00
		, @HighSulfur_19 NUMERIC(18, 6) = 0.00
		, @HighSulfur_20 NUMERIC(18, 6) = 0.00
		, @HighSulfur_21 NUMERIC(18, 6) = 0.00
		, @HighSulfur_22 NUMERIC(18, 6) = 0.00
		, @HighSulfur_23 NUMERIC(18, 6) = 0.00
		, @HighSulfur_24 NUMERIC(18, 6) = 0.00
		, @HighSulfur_25 NUMERIC(18, 6) = 0.00
		, @HighSulfur_26 NUMERIC(18, 6) = 0.00
		, @HighSulfur_27 NUMERIC(18, 6) = 0.00
		, @HighSulfur_28 NUMERIC(18, 6) = 0.00

		, @Kerosene_1 NUMERIC(18, 6) = 0.00
		, @Kerosene_2 NUMERIC(18, 6) = 0.00
		, @Kerosene_3 NUMERIC(18, 6) = 0.00
		, @Kerosene_4 NUMERIC(18, 6) = 0.00
		, @Kerosene_5 NUMERIC(18, 6) = 0.00
		, @Kerosene_6 NUMERIC(18, 6) = 0.00
		, @Kerosene_7 NUMERIC(18, 6) = 0.00
		, @Kerosene_8 NUMERIC(18, 6) = 0.00
		, @Kerosene_9 NUMERIC(18, 6) = 0.00
		, @Kerosene_10 NUMERIC(18, 6) = 0.00
		, @Kerosene_11 NUMERIC(18, 6) = 0.00
		, @Kerosene_12 NUMERIC(18, 6) = 0.00
		, @Kerosene_13 NUMERIC(18, 6) = 0.00
		, @Kerosene_14 NUMERIC(18, 6) = 0.00
		, @Kerosene_15 NUMERIC(18, 6) = 0.00
		, @Kerosene_16 NUMERIC(18, 6) = 0.00
		, @Kerosene_17 NUMERIC(18, 6) = 0.00
		, @Kerosene_18 NUMERIC(18, 6) = 0.00
		, @Kerosene_19 NUMERIC(18, 6) = 0.00
		, @Kerosene_20 NUMERIC(18, 6) = 0.00
		, @Kerosene_21 NUMERIC(18, 6) = 0.00
		, @Kerosene_22 NUMERIC(18, 6) = 0.00
		, @Kerosene_23 NUMERIC(18, 6) = 0.00
		, @Kerosene_24 NUMERIC(18, 6) = 0.00
		, @Kerosene_25 NUMERIC(18, 6) = 0.00
		, @Kerosene_26 NUMERIC(18, 6) = 0.00
		, @Kerosene_27 NUMERIC(18, 6) = 0.00
		, @Kerosene_28 NUMERIC(18, 6) = 0.00

		, @CNG_1 NUMERIC(18, 6) = 0.00
		, @CNG_2 NUMERIC(18, 6) = 0.00
		, @CNG_3 NUMERIC(18, 6) = 0.00
		, @CNG_4 NUMERIC(18, 6) = 0.00
		, @CNG_5 NUMERIC(18, 6) = 0.00
		, @CNG_6 NUMERIC(18, 6) = 0.00
		, @CNG_7 NUMERIC(18, 6) = 0.00
		, @CNG_8 NUMERIC(18, 6) = 0.00
		, @CNG_9 NUMERIC(18, 6) = 0.00
		, @CNG_10 NUMERIC(18, 6) = 0.00
		, @CNG_11 NUMERIC(18, 6) = 0.00
		, @CNG_12 NUMERIC(18, 6) = 0.00
		, @CNG_13 NUMERIC(18, 6) = 0.00
		, @CNG_14 NUMERIC(18, 6) = 0.00
		, @CNG_15 NUMERIC(18, 6) = 0.00
		, @CNG_16 NUMERIC(18, 6) = 0.00
		, @CNG_17 NUMERIC(18, 6) = 0.00
		, @CNG_18 NUMERIC(18, 6) = 0.00
		, @CNG_19 NUMERIC(18, 6) = 0.00
		, @CNG_20 NUMERIC(18, 6) = 0.00
		, @CNG_21 NUMERIC(18, 6) = 0.00
		, @CNG_22 NUMERIC(18, 6) = 0.00
		, @CNG_23 NUMERIC(18, 6) = 0.00
		, @CNG_24 NUMERIC(18, 6) = 0.00
		, @CNG_25 NUMERIC(18, 6) = 0.00
		, @CNG_26 NUMERIC(18, 6) = 0.00
		, @CNG_27 NUMERIC(18, 6) = 0.00
		, @CNG_28 NUMERIC(18, 6) = 0.00

		, @LNG_1 NUMERIC(18, 6) = 0.00
		, @LNG_2 NUMERIC(18, 6) = 0.00
		, @LNG_3 NUMERIC(18, 6) = 0.00
		, @LNG_4 NUMERIC(18, 6) = 0.00
		, @LNG_5 NUMERIC(18, 6) = 0.00
		, @LNG_6 NUMERIC(18, 6) = 0.00
		, @LNG_7 NUMERIC(18, 6) = 0.00
		, @LNG_8 NUMERIC(18, 6) = 0.00
		, @LNG_9 NUMERIC(18, 6) = 0.00
		, @LNG_10 NUMERIC(18, 6) = 0.00
		, @LNG_11 NUMERIC(18, 6) = 0.00
		, @LNG_12 NUMERIC(18, 6) = 0.00
		, @LNG_13 NUMERIC(18, 6) = 0.00
		, @LNG_14 NUMERIC(18, 6) = 0.00
		, @LNG_15 NUMERIC(18, 6) = 0.00
		, @LNG_16 NUMERIC(18, 6) = 0.00
		, @LNG_17 NUMERIC(18, 6) = 0.00
		, @LNG_18 NUMERIC(18, 6) = 0.00
		, @LNG_19 NUMERIC(18, 6) = 0.00
		, @LNG_20 NUMERIC(18, 6) = 0.00
		, @LNG_21 NUMERIC(18, 6) = 0.00
		, @LNG_22 NUMERIC(18, 6) = 0.00
		, @LNG_23 NUMERIC(18, 6) = 0.00
		, @LNG_24 NUMERIC(18, 6) = 0.00
		, @LNG_25 NUMERIC(18, 6) = 0.00
		, @LNG_26 NUMERIC(18, 6) = 0.00
		, @LNG_27 NUMERIC(18, 6) = 0.00
		, @LNG_28 NUMERIC(18, 6) = 0.00

		, @Propane_1 NUMERIC(18, 6) = 0.00
		, @Propane_2 NUMERIC(18, 6) = 0.00
		, @Propane_3 NUMERIC(18, 6) = 0.00
		, @Propane_4 NUMERIC(18, 6) = 0.00
		, @Propane_5 NUMERIC(18, 6) = 0.00
		, @Propane_6 NUMERIC(18, 6) = 0.00
		, @Propane_7 NUMERIC(18, 6) = 0.00
		, @Propane_8 NUMERIC(18, 6) = 0.00
		, @Propane_9 NUMERIC(18, 6) = 0.00
		, @Propane_10 NUMERIC(18, 6) = 0.00
		, @Propane_11 NUMERIC(18, 6) = 0.00
		, @Propane_12 NUMERIC(18, 6) = 0.00
		, @Propane_13 NUMERIC(18, 6) = 0.00
		, @Propane_14 NUMERIC(18, 6) = 0.00
		, @Propane_15 NUMERIC(18, 6) = 0.00
		, @Propane_16 NUMERIC(18, 6) = 0.00
		, @Propane_17 NUMERIC(18, 6) = 0.00
		, @Propane_18 NUMERIC(18, 6) = 0.00
		, @Propane_19 NUMERIC(18, 6) = 0.00
		, @Propane_20 NUMERIC(18, 6) = 0.00
		, @Propane_21 NUMERIC(18, 6) = 0.00
		, @Propane_22 NUMERIC(18, 6) = 0.00
		, @Propane_23 NUMERIC(18, 6) = 0.00
		, @Propane_24 NUMERIC(18, 6) = 0.00
		, @Propane_25 NUMERIC(18, 6) = 0.00
		, @Propane_26 NUMERIC(18, 6) = 0.00
		, @Propane_27 NUMERIC(18, 6) = 0.00
		, @Propane_28 NUMERIC(18, 6) = 0.00

		, @Other_1 NUMERIC(18, 6) = 0.00
		, @Other_2 NUMERIC(18, 6) = 0.00
		, @Other_3 NUMERIC(18, 6) = 0.00
		, @Other_4 NUMERIC(18, 6) = 0.00
		, @Other_5 NUMERIC(18, 6) = 0.00
		, @Other_6 NUMERIC(18, 6) = 0.00
		, @Other_7 NUMERIC(18, 6) = 0.00
		, @Other_8 NUMERIC(18, 6) = 0.00
		, @Other_9 NUMERIC(18, 6) = 0.00
		, @Other_10 NUMERIC(18, 6) = 0.00
		, @Other_11 NUMERIC(18, 6) = 0.00
		, @Other_12 NUMERIC(18, 6) = 0.00
		, @Other_13 NUMERIC(18, 6) = 0.00
		, @Other_14 NUMERIC(18, 6) = 0.00
		, @Other_15 NUMERIC(18, 6) = 0.00
		, @Other_16 NUMERIC(18, 6) = 0.00
		, @Other_17 NUMERIC(18, 6) = 0.00
		, @Other_18 NUMERIC(18, 6) = 0.00
		, @Other_19 NUMERIC(18, 6) = 0.00
		, @Other_20 NUMERIC(18, 6) = 0.00
		, @Other_21 NUMERIC(18, 6) = 0.00
		, @Other_22 NUMERIC(18, 6) = 0.00
		, @Other_23 NUMERIC(18, 6) = 0.00
		, @Other_24 NUMERIC(18, 6) = 0.00
		, @Other_25 NUMERIC(18, 6) = 0.00
		, @Other_26 NUMERIC(18, 6) = 0.00
		, @Other_27 NUMERIC(18, 6) = 0.00
		, @Other_28 NUMERIC(18, 6) = 0.00

		, @Total NUMERIC(18 , 6) = 0.00

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

		DECLARE @TaxAuthorityId INT
		, @Guid NVARCHAR(100)

		DECLARE @transaction TFReportTransaction

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OH'

		-- Configuration
		SELECT @OhioAccountNo = strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-OHAcctNumber'
		
		SELECT @Gasoline_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-GasolineBegin'
		SELECT @Gasoline_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-GasolineEnd'
		SELECT @Gasoline_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColA'
		SELECT @Gasoline_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColA'
		SELECT @Gasoline_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColA'

		SELECT @ClearDiesel_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-ClearDieselBegin'
		SELECT @ClearDiesel_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-ClearDieselEnd'
		SELECT @ClearDiesel_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColB'
		SELECT @ClearDiesel_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColB'
		SELECT @ClearDiesel_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColB'
		
		SELECT @LowSulfur_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-LowSulfurBegin'
		SELECT @LowSulfur_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-LowSulfurEnd'
		SELECT @LowSulfur_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColC'
		SELECT @LowSulfur_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColC'
		SELECT @LowSulfur_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColC'

		SELECT @HighSulfur_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-HighSulfurBegin'
		SELECT @HighSulfur_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-HighSulfurEnd'
		SELECT @HighSulfur_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColD'
		SELECT @HighSulfur_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColD'
		SELECT @HighSulfur_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColD'

		SELECT @Kerosene_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-KeroseneBegin'
		SELECT @Kerosene_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-KeroseneEnd'
		SELECT @Kerosene_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColE'
		SELECT @Kerosene_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColE'
		SELECT @Kerosene_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColE'

		SELECT @CNG_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-CNGBegin'
		SELECT @CNG_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-CNGEnd'
		SELECT @CNG_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColF'
		SELECT @CNG_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColF'
		SELECT @CNG_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColF'

		SELECT @LNG_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-LNGBegin'
		SELECT @LNG_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-LNGEnd'
		SELECT @LNG_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColG'
		SELECT @LNG_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColG'
		SELECT @LNG_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColG'

		SELECT @Propane_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-PropaneBegin'
		SELECT @Propane_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-PropaneEnd'
		SELECT @Propane_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColH'
		SELECT @Propane_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColH'
		SELECT @Propane_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColH'

		SELECT @Other_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-OtherBegin'
		SELECT @Other_16 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-OtherEnd'
		SELECT @Other_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line19ColI'
		SELECT @Other_21 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line21ColI'
		SELECT @Other_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'MF2' AND strTemplateItemId = 'MF2-Line24ColI'
		
		-- Transaction
		INSERT INTO @transaction (strFormCode, strScheduleCode, strType, dblReceived)
		SELECT strFormCode, strScheduleCode, strType, dblReceived = SUM(ISNULL(dblQtyShipped, 0.00))
		FROM vyuTFGetTransaction Trans
		WHERE Trans.uniqTransactionGuid = @Guid
		GROUP BY strFormCode, strScheduleCode, strType

		-- Transaction Info
		SELECT TOP 1  @Name = strTaxPayerName, @TIN = strTaxPayerFEIN FROM vyuTFGetTransaction Trans WHERE Trans.uniqTransactionGuid = @Guid
		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		
		SELECT @Gasoline_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Gasoline'
		SELECT @Gasoline_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Gasoline'
		SELECT @Gasoline_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Gasoline'
		SELECT @Gasoline_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Gasoline'
		SET @Gasoline_6 = @Gasoline_1 + @Gasoline_2 + @Gasoline_3 + @Gasoline_4 + @Gasoline_5
		SELECT @Gasoline_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Gasoline'
		SELECT @Gasoline_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Gasoline'
		SELECT @Gasoline_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Gasoline'
		SELECT @Gasoline_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Gasoline'
		SELECT @Gasoline_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Gasoline'
		SELECT @Gasoline_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Gasoline'
		SET @Gasoline_14 = @Gasoline_7 + @Gasoline_8 + @Gasoline_9 + @Gasoline_10 + @Gasoline_11 + @Gasoline_13
		SET @Gasoline_15 = @Gasoline_6 - @Gasoline_14
		SET @Gasoline_17 = @Gasoline_16 - @Gasoline_15
		SET @Gasoline_18 = @Gasoline_14 - (@Gasoline_9 + @Gasoline_10 + @Gasoline_11 + @Gasoline_13)
		SET @Gasoline_20 = @Gasoline_18 * @Gasoline_19
		SET @Gasoline_22 = @Gasoline_7 * @Gasoline_21
		SET @Gasoline_23 = (@Gasoline_18 - @Gasoline_20) + @Gasoline_22
		SET @Gasoline_25 = @Gasoline_23 * @Gasoline_24
		SELECT @Gasoline_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Gasoline'
		SELECT @Gasoline_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Gasoline'
		SELECT @Gasoline_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Gasoline'

		SELECT @ClearDiesel_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Clear Diesel'
		SET @ClearDiesel_6 = @ClearDiesel_1 + @ClearDiesel_2 + @ClearDiesel_3 + @ClearDiesel_4 + @ClearDiesel_5
		SELECT @ClearDiesel_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Clear Diesel'
		SET @ClearDiesel_14 = @ClearDiesel_7 + @ClearDiesel_8 + @ClearDiesel_9 + @ClearDiesel_10 + @ClearDiesel_11 + @ClearDiesel_13
		SET @ClearDiesel_15 = @ClearDiesel_6 - @ClearDiesel_14
		SET @ClearDiesel_17 = @ClearDiesel_16 - @ClearDiesel_15
		SET @ClearDiesel_18 = @ClearDiesel_14 - (@ClearDiesel_9 + @ClearDiesel_10 + @ClearDiesel_11 + @ClearDiesel_13)
		SET @ClearDiesel_20 = @ClearDiesel_18 * @ClearDiesel_19
		SET @ClearDiesel_22 = @ClearDiesel_7 * @ClearDiesel_21
		SET @ClearDiesel_23 = (@ClearDiesel_18 - @ClearDiesel_20) + @ClearDiesel_22
		SET @ClearDiesel_25 = @ClearDiesel_23 * @ClearDiesel_24
		SELECT @ClearDiesel_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Clear Diesel'

		SELECT @LowSulfur_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Low Sulfur Dyed Diesel'
		SET @LowSulfur_6 = @LowSulfur_1 + @LowSulfur_2 + @LowSulfur_3 + @LowSulfur_4 + @LowSulfur_5
		SELECT @LowSulfur_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_12 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Low Sulfur Dyed Diesel'
		SET @LowSulfur_14 = @LowSulfur_7 + @LowSulfur_8 + @LowSulfur_9 + @LowSulfur_10 + @LowSulfur_11 + @LowSulfur_13
		SET @LowSulfur_15 = @LowSulfur_6 - @LowSulfur_14
		SET @LowSulfur_17 = @LowSulfur_16 - @LowSulfur_15
		SET @LowSulfur_18 = @LowSulfur_14 - (@LowSulfur_9 + @LowSulfur_10 + @LowSulfur_11 + @LowSulfur_12 + @LowSulfur_13)
		SET @LowSulfur_20 = @LowSulfur_18 * @LowSulfur_19
		SET @LowSulfur_22 = @LowSulfur_7 * @LowSulfur_21
		SET @LowSulfur_23 = (@LowSulfur_18 - @LowSulfur_20) + @LowSulfur_22
		SET @LowSulfur_25 = @LowSulfur_23 * @LowSulfur_24
		SELECT @LowSulfur_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Low Sulfur Dyed Diesel'

		SELECT @HighSulfur_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'High Sulfur Dyed Diesel'
		SET @HighSulfur_6 = @HighSulfur_1 + @HighSulfur_2 + @HighSulfur_3 + @HighSulfur_4 + @HighSulfur_5
		SELECT @HighSulfur_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_12 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'High Sulfur Dyed Diesel'
		SET @HighSulfur_14 = @HighSulfur_7 + @HighSulfur_8 + @HighSulfur_9 + @HighSulfur_10 + @HighSulfur_11 + @HighSulfur_13
		SET @HighSulfur_15 = @HighSulfur_6 - @HighSulfur_14
		SET @HighSulfur_17 = @HighSulfur_16 - @HighSulfur_15
		SET @HighSulfur_18 = @HighSulfur_14 - (@HighSulfur_9 + @HighSulfur_10 + @HighSulfur_11 + @HighSulfur_12 + @HighSulfur_13)
		SET @HighSulfur_20 = @HighSulfur_18 * @HighSulfur_19
		SET @HighSulfur_22 = @HighSulfur_7 * @HighSulfur_21
		SET @HighSulfur_23 = (@HighSulfur_18 - @HighSulfur_20) + @HighSulfur_22
		SET @HighSulfur_25 = @HighSulfur_23 * @HighSulfur_24
		SELECT @HighSulfur_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'High Sulfur Dyed Diesel'

		SELECT @Kerosene_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Kerosene'
		SELECT @Kerosene_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Kerosene'
		SELECT @Kerosene_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Kerosene'
		SELECT @Kerosene_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Kerosene'
		SET @Kerosene_6 = @Kerosene_1 + @Kerosene_2 + @Kerosene_3 + @Kerosene_4 + @Kerosene_5
		SELECT @Kerosene_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Kerosene'
		SELECT @Kerosene_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Kerosene'
		SELECT @Kerosene_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Kerosene'
		SELECT @Kerosene_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Kerosene'
		SELECT @Kerosene_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Kerosene'
		SELECT @Kerosene_12 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Kerosene'
		SELECT @Kerosene_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Kerosene'
		SET @Kerosene_14 = @Kerosene_7 + @Kerosene_8 + @Kerosene_9 + @Kerosene_10 + @Kerosene_11 + @Kerosene_13
		SET @Kerosene_15 = @Kerosene_6 - @Kerosene_14
		SET @Kerosene_17 = @Kerosene_16 - @Kerosene_15
		SET @Kerosene_18 = @Kerosene_14 - (@Kerosene_9 + @Kerosene_10 + @Kerosene_11 + @Kerosene_12 + @Kerosene_13)
		SET @Kerosene_20 = @Kerosene_18 * @Kerosene_19
		SET @Kerosene_22 = @Kerosene_7 * @Kerosene_21
		SET @Kerosene_23 = (@Kerosene_18 - @Kerosene_20) + @Kerosene_22
		SET @Kerosene_25 = @Kerosene_23 * @Kerosene_24
		SELECT @Kerosene_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Kerosene'
		SELECT @Kerosene_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Kerosene'
		SELECT @Kerosene_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Kerosene'

		SELECT @CNG_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'CNG'
		SELECT @CNG_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'CNG'
		SELECT @CNG_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'CNG'
		SELECT @CNG_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'CNG'
		SET @CNG_6 = @CNG_1 + @CNG_2 + @CNG_3 + @CNG_4 + @CNG_5
		SELECT @CNG_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'CNG'
		SELECT @CNG_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'CNG'
		SELECT @CNG_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'CNG'
		SELECT @CNG_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'CNG'
		SELECT @CNG_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'CNG'
		SELECT @CNG_12 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'CNG'
		SELECT @CNG_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'CNG'
		SET @CNG_14 = @CNG_7 + @CNG_8 + @CNG_9 + @CNG_10 + @CNG_11 + @CNG_13
		SET @CNG_15 = @CNG_6 - @CNG_14
		SET @CNG_17 = @CNG_16 - @CNG_15
		SET @CNG_18 = @CNG_14 - (@CNG_9 + @CNG_10 + @CNG_11 + @CNG_12 + @CNG_13)
		SET @CNG_20 = @CNG_18 * @CNG_19
		SET @CNG_22 = @CNG_7 * @CNG_21
		SET @CNG_23 = (@CNG_18 - @CNG_20) + @CNG_22
		SET @CNG_25 = @CNG_23 * @CNG_24
		SELECT @CNG_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'CNG'
		SELECT @CNG_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'CNG'
		SELECT @CNG_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'CNG'

		SELECT @LNG_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'LNG'
		SELECT @LNG_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'LNG'
		SELECT @LNG_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'LNG'
		SELECT @LNG_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'LNG'
		SET @LNG_6 = @LNG_1 + @LNG_2 + @LNG_3 + @LNG_4 + @LNG_5
		SELECT @LNG_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'LNG'
		SELECT @LNG_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'LNG'
		SELECT @LNG_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'LNG'
		SELECT @LNG_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'LNG'
		SELECT @LNG_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'LNG'
		SELECT @LNG_12 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'LNG'
		SELECT @LNG_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'LNG'
		SET @LNG_14 = @LNG_7 + @LNG_8 + @LNG_9 + @LNG_10 + @LNG_11 + @LNG_13
		SET @LNG_15 = @LNG_6 - @LNG_14
		SET @LNG_17 = @LNG_16 - @LNG_15
		SET @LNG_18 = @LNG_14 - (@LNG_9 + @LNG_10 + @LNG_11 + @LNG_12 + @LNG_13)
		SET @LNG_20 = @LNG_18 * @LNG_19
		SET @LNG_22 = @LNG_7 * @LNG_21
		SET @LNG_23 = (@LNG_18 - @LNG_20) + @LNG_22
		SET @LNG_25 = @LNG_23 * @LNG_24
		SELECT @LNG_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'LNG'
		SELECT @LNG_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'LNG'
		SELECT @LNG_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'LNG'

		SELECT @Propane_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Propane'
		SELECT @Propane_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Propane'
		SELECT @Propane_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Propane'
		SELECT @Propane_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Propane'
		SET @Propane_6 = @Propane_1 + @Propane_2 + @Propane_3 + @Propane_4 + @Propane_5
		SELECT @Propane_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Propane'
		SELECT @Propane_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Propane'
		SELECT @Propane_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Propane'
		SELECT @Propane_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Propane'
		SELECT @Propane_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Propane'
		SELECT @Propane_12 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Propane'
		SELECT @Propane_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Propane'
		SET @Propane_14 = @Propane_7 + @Propane_8 + @Propane_9 + @Propane_10 + @Propane_11 + @Propane_13
		SET @Propane_15 = @Propane_6 - @Propane_14
		SET @Propane_17 = @Propane_16 - @Propane_15
		SET @Propane_18 = @Propane_14 - (@Propane_9 + @Propane_10 + @Propane_11 + @Propane_12 + @Propane_13)
		SET @Propane_20 = @Propane_18 * @Propane_19
		SET @Propane_22 = @Propane_7 * @Propane_21
		SET @Propane_23 = (@Propane_18 - @Propane_20) + @Propane_22
		SET @Propane_25 = @Propane_23 * @Propane_24
		SELECT @Propane_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Propane'
		SELECT @Propane_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Propane'
		SELECT @Propane_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Propane'

		SELECT @Other_2 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '1' AND strType = 'Other'
		SELECT @Other_3 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '2' AND strType = 'Other'
		SELECT @Other_4 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '3' AND strType = 'Other'
		SELECT @Other_5 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '4' AND strType = 'Other'
		SET @Other_6 = @Other_1 + @Other_2 + @Other_3 + @Other_4 + @Other_5
		SELECT @Other_7 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5AD' AND strType = 'Other'
		SELECT @Other_8 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '5' AND strType = 'Other'
		SELECT @Other_9 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '6' AND strType = 'Other'
		SELECT @Other_10 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '7' AND strType = 'Other'
		SELECT @Other_11 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '8' AND strType = 'Other'
		SELECT @Other_12 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10' AND strType = 'Other'
		SELECT @Other_13 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '10B' AND strType = 'Other'
		SET @Other_14 = @Other_7 + @Other_8 + @Other_9 + @Other_10 + @Other_11 + @Other_13
		SET @Other_15 = @Other_6 - @Other_14
		SET @Other_17 = @Other_16 - @Other_15
		SET @Other_18 = @Other_14 - (@Other_9 + @Other_10 + @Other_11 + @Other_12 + @Other_13)
		SET @Other_20 = @Other_18 * @Other_19
		SET @Other_22 = @Other_7 * @Other_21
		SET @Other_23 = (@Other_18 - @Other_20) + @Other_22
		SET @Other_25 = @Other_23 * @Other_24
		SELECT @Other_26 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14A' AND strType = 'Other'
		SELECT @Other_27 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14B' AND strType = 'Other'
		SELECT @Other_28 = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'MF2' AND strScheduleCode = '14C' AND strType = 'Other'

		DELETE @transaction

	END

	SELECT Name = @Name
		, TIN = @TIN
		, OhioAccountNo = @OhioAccountNo
		, dtmFrom = @dtmFrom
		, dtmTo = @dtmFrom
	
		, Gasoline_1 = @Gasoline_1
		, Gasoline_2 = @Gasoline_2
		, Gasoline_3 = @Gasoline_3
		, Gasoline_4 = @Gasoline_4
		, Gasoline_5 = @Gasoline_5
		, Gasoline_6 = @Gasoline_6
		, Gasoline_7 = @Gasoline_7
		, Gasoline_8 = @Gasoline_8
		, Gasoline_9 = @Gasoline_9
		, Gasoline_10 = @Gasoline_10
		, Gasoline_11 = @Gasoline_11
		, Gasoline_13 = @Gasoline_13
		, Gasoline_14 = @Gasoline_14
		, Gasoline_15 = @Gasoline_15
		, Gasoline_16 = @Gasoline_16
		, Gasoline_17 = @Gasoline_17
		, Gasoline_18 = @Gasoline_18
		, Gasoline_19 = @Gasoline_19
		, Gasoline_20 = @Gasoline_20
		, Gasoline_21 = @Gasoline_21
		, Gasoline_22 = @Gasoline_22
		, Gasoline_23 = @Gasoline_23
		, Gasoline_24 = @Gasoline_24
		, Gasoline_25 = @Gasoline_25
		, Gasoline_26 = @Gasoline_26
		, Gasoline_27 = @Gasoline_27
		, Gasoline_28 = @Gasoline_28

		, ClearDiesel_1 = @ClearDiesel_1
		, ClearDiesel_2 = @ClearDiesel_2
		, ClearDiesel_3 = @ClearDiesel_3
		, ClearDiesel_4 = @ClearDiesel_4
		, ClearDiesel_5 = @ClearDiesel_5
		, ClearDiesel_6 = @ClearDiesel_6
		, ClearDiesel_7 = @ClearDiesel_7
		, ClearDiesel_8 = @ClearDiesel_8
		, ClearDiesel_9 = @ClearDiesel_9
		, ClearDiesel_10 = @ClearDiesel_10
		, ClearDiesel_11 = @ClearDiesel_11
		, ClearDiesel_13 = @ClearDiesel_13
		, ClearDiesel_14 = @ClearDiesel_14
		, ClearDiesel_15 = @ClearDiesel_15
		, ClearDiesel_16 = @ClearDiesel_16
		, ClearDiesel_17 = @ClearDiesel_17
		, ClearDiesel_18 = @ClearDiesel_18
		, ClearDiesel_19 = @ClearDiesel_19
		, ClearDiesel_20 = @ClearDiesel_20
		, ClearDiesel_21 = @ClearDiesel_21
		, ClearDiesel_22 = @ClearDiesel_22
		, ClearDiesel_23 = @ClearDiesel_23
		, ClearDiesel_24 = @ClearDiesel_24
		, ClearDiesel_25 = @ClearDiesel_25
		, ClearDiesel_26 = @ClearDiesel_26
		, ClearDiesel_27 = @ClearDiesel_27
		, ClearDiesel_28 = @ClearDiesel_28

		, LowSulfur_1 = @LowSulfur_1
		, LowSulfur_2 = @LowSulfur_2
		, LowSulfur_3 = @LowSulfur_3
		, LowSulfur_4 = @LowSulfur_4
		, LowSulfur_5 = @LowSulfur_5
		, LowSulfur_6 = @LowSulfur_6
		, LowSulfur_7 = @LowSulfur_7
		, LowSulfur_8 = @LowSulfur_8
		, LowSulfur_9 = @LowSulfur_9
		, LowSulfur_10 = @LowSulfur_10
		, LowSulfur_11 = @LowSulfur_11
		, LowSulfur_12 = @LowSulfur_12
		, LowSulfur_13 = @LowSulfur_13
		, LowSulfur_14 = @LowSulfur_14
		, LowSulfur_15 = @LowSulfur_15
		, LowSulfur_16 = @LowSulfur_16
		, LowSulfur_17 = @LowSulfur_17
		, LowSulfur_18 = @LowSulfur_18
		, LowSulfur_19 = @LowSulfur_19
		, LowSulfur_20 = @LowSulfur_20
		, LowSulfur_21 = @LowSulfur_21
		, LowSulfur_22 = @LowSulfur_22
		, LowSulfur_23 = @LowSulfur_23
		, LowSulfur_24 = @LowSulfur_24
		, LowSulfur_25 = @LowSulfur_25
		, LowSulfur_26 = @LowSulfur_26
		, LowSulfur_27 = @LowSulfur_27
		, LowSulfur_28 = @LowSulfur_28

		, HighSulfur_1 = @HighSulfur_1
		, HighSulfur_2 = @HighSulfur_2
		, HighSulfur_3 = @HighSulfur_3
		, HighSulfur_4 = @HighSulfur_4
		, HighSulfur_5 = @HighSulfur_5
		, HighSulfur_6 = @HighSulfur_6
		, HighSulfur_7 = @HighSulfur_7
		, HighSulfur_8 = @HighSulfur_8
		, HighSulfur_9 = @HighSulfur_9
		, HighSulfur_10 = @HighSulfur_10
		, HighSulfur_11 = @HighSulfur_11
		, HighSulfur_12 = @HighSulfur_12
		, HighSulfur_13 = @HighSulfur_13
		, HighSulfur_14 = @HighSulfur_14
		, HighSulfur_15 = @HighSulfur_15
		, HighSulfur_16 = @HighSulfur_16
		, HighSulfur_17 = @HighSulfur_17
		, HighSulfur_18 = @HighSulfur_18
		, HighSulfur_19 = @HighSulfur_19
		, HighSulfur_20 = @HighSulfur_20
		, HighSulfur_21 = @HighSulfur_21
		, HighSulfur_22 = @HighSulfur_22
		, HighSulfur_23 = @HighSulfur_23
		, HighSulfur_24 = @HighSulfur_24
		, HighSulfur_25 = @HighSulfur_25
		, HighSulfur_26 = @HighSulfur_26
		, HighSulfur_27 = @HighSulfur_27
		, HighSulfur_28 = @HighSulfur_28

		, Kerosene_1 = @Kerosene_1
		, Kerosene_2 = @Kerosene_2
		, Kerosene_3 = @Kerosene_3
		, Kerosene_4 = @Kerosene_4
		, Kerosene_5 = @Kerosene_5
		, Kerosene_6 = @Kerosene_6
		, Kerosene_7 = @Kerosene_7
		, Kerosene_8 = @Kerosene_8
		, Kerosene_9 = @Kerosene_9
		, Kerosene_10 = @Kerosene_10
		, Kerosene_11 = @Kerosene_11
		, Kerosene_12 = @Kerosene_12
		, Kerosene_13 = @Kerosene_13
		, Kerosene_14 = @Kerosene_14
		, Kerosene_15 = @Kerosene_15
		, Kerosene_16 = @Kerosene_16
		, Kerosene_17 = @Kerosene_17
		, Kerosene_18 = @Kerosene_18
		, Kerosene_19 = @Kerosene_19
		, Kerosene_20 = @Kerosene_20
		, Kerosene_21 = @Kerosene_21
		, Kerosene_22 = @Kerosene_22
		, Kerosene_23 = @Kerosene_23
		, Kerosene_24 = @Kerosene_24
		, Kerosene_25 = @Kerosene_25
		, Kerosene_26 = @Kerosene_26
		, Kerosene_27 = @Kerosene_27
		, Kerosene_28 = @Kerosene_28

		, CNG_1 = @CNG_1
		, CNG_2 = @CNG_2
		, CNG_3 = @CNG_3
		, CNG_4 = @CNG_4
		, CNG_5 = @CNG_5
		, CNG_6 = @CNG_6
		, CNG_7 = @CNG_7
		, CNG_8 = @CNG_8
		, CNG_9 = @CNG_9
		, CNG_10 = @CNG_10
		, CNG_11 = @CNG_11
		, CNG_12 = @CNG_12
		, CNG_13 = @CNG_13
		, CNG_14 = @CNG_14
		, CNG_15 = @CNG_15
		, CNG_16 = @CNG_16
		, CNG_17 = @CNG_17
		, CNG_18 = @CNG_18
		, CNG_19 = @CNG_19
		, CNG_20 = @CNG_20
		, CNG_21 = @CNG_21
		, CNG_22 = @CNG_22
		, CNG_23 = @CNG_23
		, CNG_24 = @CNG_24
		, CNG_25 = @CNG_25
		, CNG_26 = @CNG_26
		, CNG_27 = @CNG_27
		, CNG_28 = @CNG_28

		, LNG_1 = @LNG_1
		, LNG_2 = @LNG_2
		, LNG_3 = @LNG_3
		, LNG_4 = @LNG_4
		, LNG_5 = @LNG_5
		, LNG_6 = @LNG_6
		, LNG_7 = @LNG_7
		, LNG_8 = @LNG_8
		, LNG_9 = @LNG_9
		, LNG_10 = @LNG_10
		, LNG_11 = @LNG_11
		, LNG_12 = @LNG_12
		, LNG_13 = @LNG_13
		, LNG_14 = @LNG_14
		, LNG_15 = @LNG_15
		, LNG_16 = @LNG_16
		, LNG_17 = @LNG_17
		, LNG_18 = @LNG_18
		, LNG_19 = @LNG_19
		, LNG_20 = @LNG_20
		, LNG_21 = @LNG_21
		, LNG_22 = @LNG_22
		, LNG_23 = @LNG_23
		, LNG_24 = @LNG_24
		, LNG_25 = @LNG_25
		, LNG_26 = @LNG_26
		, LNG_27 = @LNG_27
		, LNG_28 = @LNG_28

		, Propane_1 = @Propane_1
		, Propane_2 = @Propane_2
		, Propane_3 = @Propane_3
		, Propane_4 = @Propane_4
		, Propane_5 = @Propane_5
		, Propane_6 = @Propane_6
		, Propane_7 = @Propane_7
		, Propane_8 = @Propane_8
		, Propane_9 = @Propane_9
		, Propane_10 = @Propane_10
		, Propane_11 = @Propane_11
		, Propane_12 = @Propane_12
		, Propane_13 = @Propane_13
		, Propane_14 = @Propane_14
		, Propane_15 = @Propane_15
		, Propane_16 = @Propane_16
		, Propane_17 = @Propane_17
		, Propane_18 = @Propane_18
		, Propane_19 = @Propane_19
		, Propane_20 = @Propane_20
		, Propane_21 = @Propane_21
		, Propane_22 = @Propane_22
		, Propane_23 = @Propane_23
		, Propane_24 = @Propane_24
		, Propane_25 = @Propane_25
		, Propane_26 = @Propane_26
		, Propane_27 = @Propane_27
		, Propane_28 = @Propane_28

		, Other_1 = @Other_1
		, Other_2 = @Other_2
		, Other_3 = @Other_3
		, Other_4 = @Other_4
		, Other_5 = @Other_5
		, Other_6 = @Other_6
		, Other_7 = @Other_7
		, Other_8 = @Other_8
		, Other_9 = @Other_9
		, Other_10 = @Other_10
		, Other_11 = @Other_11
		, Other_12 = @Other_12
		, Other_13 = @Other_13
		, Other_14 = @Other_14
		, Other_15 = @Other_15
		, Other_16 = @Other_16
		, Other_17 = @Other_17
		, Other_18 = @Other_18
		, Other_19 = @Other_19
		, Other_20 = @Other_20
		, Other_21 = @Other_21
		, Other_22 = @Other_22
		, Other_23 = @Other_23
		, Other_24 = @Other_24
		, Other_25 = @Other_25
		, Other_26 = @Other_26
		, Other_27 = @Other_27
		, Other_28 = @Other_28

		, Total = @Total


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