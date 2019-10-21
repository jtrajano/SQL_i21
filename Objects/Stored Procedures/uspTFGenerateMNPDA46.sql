CREATE PROCEDURE [dbo].[uspTFGenerateMNPDA46]
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

	DECLARE  @dtmFrom DATE
	, @dtmTo DATE
	, @dblSection1_1A NUMERIC(18,0) = 0
	, @dblSection1_2A NUMERIC(18,0) = 0
	, @dblSection1_3A NUMERIC(18,0) = 0
	, @dblSection1_4A NUMERIC(18,0) = 0
	, @dblSection1_5A NUMERIC(18,0) = 0

	, @dblSection1_1B NUMERIC(18,0) = 0
	, @dblSection1_2B NUMERIC(18,0) = 0
	, @dblSection1_3B NUMERIC(18,0) = 0
	, @dblSection1_4B NUMERIC(18,0) = 0
	, @dblSection1_5B NUMERIC(18,0) = 0

	, @dblSection2_6A NUMERIC(18,0) = 0
	, @dblSection2_7A NUMERIC(18,0) = 0
	, @dblSection2_8A NUMERIC(18,8) = 0
	, @dblSection2_9A NUMERIC(18,8) = 0
	, @dblSection2_10A NUMERIC(18,8) = 0
	, @dblSection2_11A NUMERIC(18,8) = 0

	, @dblSection3_12A NUMERIC(18,0) = 0
	, @dblSection3_13A NUMERIC(18,8) = 0
	, @dblSection3_14A NUMERIC(18,8) = 0
	, @dblSection3_15A NUMERIC(18,8) = 0
	, @dblSection3_16A NUMERIC(18,8) = 0

	, @dblSection3_17A_A NUMERIC(18,8) = 0
	, @dblSection3_17A_A_Gallon NUMERIC(18,0) = 0
	, @dblSection3_17A_B NUMERIC(18,8) = 0
	, @dblSection3_17A_C NUMERIC(18,8) = 0
	, @dblSection3_17A_C_Gallon NUMERIC(18,0) = 0
	, @dblSection3_17A_Total NUMERIC(18,8) = 0
	, @dblSection3_18A NUMERIC(18,8) = 0

	, @dblSection4_0A NUMERIC(18,0) = 0
	, @dblSection4_1A NUMERIC(18,8) = 0
	, @dblSection4_2A NUMERIC(18,0) = 0
	--, @dblSection4_3A NUMERIC(18,8) = 0
	, @dblSection4_4A NUMERIC(18,8) = 0

	, @dblSection4_0B NUMERIC(18,0) = 0
	, @dblSection4_1B NUMERIC(18,8) = 0
	, @dblSection4_2B NUMERIC(18,0) = 0
	, @dblSection4_3B NUMERIC(18,8) = 0
	, @dblSection4_4B NUMERIC(18,8) = 0

	, @dblSection4_0C NUMERIC(18,0) = 0
	, @dblSection4_1C NUMERIC(18,8) = 0
	, @dblSection4_2C NUMERIC(18,0) = 0
	--, @dblSection4_3C NUMERIC(18,8) = 0
	, @dblSection4_4C NUMERIC(18,8) = 0

	, @dblSection5_1B NUMERIC(18,8) = 0
	, @dblSection5_2B NUMERIC(18,8) = 0
	, @dblSection5_3B NUMERIC(18,8) = 0
	, @dblSection5_4B NUMERIC(18,8) = 0
	, @dblSection5_5B NUMERIC(18,8) = 0

	, @strSection2_8_AllowanceRate NVARCHAR(25) = NULL
	, @strSection3_13_TaxDue NVARCHAR(25) = NULL
	, @strSection3_14_InspectionFee NVARCHAR(25) = NULL
	, @strSection3_15_CleanupFee NVARCHAR(25) = NULL
	, @strSection4_1_AllowanceRate NVARCHAR(25) = NULL
	, @strSection4_3A_ReductionRate NVARCHAR(25) = NULL
	, @strSection4_3C_ReductionRate NVARCHAR(25) = NULL
	, @strSection5_1_TaxRate NVARCHAR(25) = NULL
	, @strSection5_2_StateTaxRate NVARCHAR(25) = NULL
	, @strSection5_4_QSSRate NVARCHAR(25) = NULL

	, @dblSection2_8_AllowanceRate NUMERIC(18,8) = 0
	, @dblSection3_13_TaxDue NUMERIC(18,8) = 0
	, @dblSection3_14_InspectionFee NUMERIC(18,8) = 0
	, @dblSection3_15_CleanupFee NUMERIC(18,8) = 0
	, @dblSection4_1_AllowanceRate NUMERIC(18,8) = 0
	, @dblSection4_3A_ReductionRate NUMERIC(18,8) = 0
	, @dblSection4_3C_ReductionRate NUMERIC(18,8) = 0
	, @dblSection5_1_TaxRate NUMERIC(18,8) = 0
	, @dblSection5_2_StateTaxRate NUMERIC(18,8) = 0
	, @dblSection5_4_QSSRate NUMERIC(18,8) = 0


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

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		-- Configuration
		SELECT @strSection2_8_AllowanceRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-Ln8'
		SELECT @strSection3_13_TaxDue = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-Ln13'
		SELECT @strSection3_14_InspectionFee = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-Ln14'
		SELECT @strSection3_15_CleanupFee = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-Ln15'
		SELECT @strSection4_1_AllowanceRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-46QLn1'
		SELECT @strSection4_3A_ReductionRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-46QLn3AG'
		SELECT @strSection4_3C_ReductionRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-46QLn3E85'
		SELECT @strSection5_1_TaxRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-46QQSSLn1'
		SELECT @strSection5_2_StateTaxRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-46QQSSLn2'
		SELECT @strSection5_4_QSSRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA46-46QQSSLn4'

		SET @dblSection2_8_AllowanceRate = CONVERT(NUMERIC(18,8), @strSection2_8_AllowanceRate) 
		SET @dblSection3_13_TaxDue = CONVERT(NUMERIC(18,8), @strSection3_13_TaxDue) 
		SET @dblSection3_14_InspectionFee = CONVERT(NUMERIC(18,8), @strSection3_14_InspectionFee) 
		SET @dblSection3_15_CleanupFee = CONVERT(NUMERIC(18,8), @strSection3_15_CleanupFee) 
		SET @dblSection4_1_AllowanceRate = CONVERT(NUMERIC(18,8), @strSection4_1_AllowanceRate) 
		SET @dblSection4_3A_ReductionRate = CONVERT(NUMERIC(18,8), @strSection4_3A_ReductionRate) 
		SET @dblSection4_3C_ReductionRate = CONVERT(NUMERIC(18,8), @strSection4_3C_ReductionRate) 
		SET @dblSection5_1_TaxRate = CONVERT(NUMERIC(18,8), @strSection5_1_TaxRate) 
		SET @dblSection5_2_StateTaxRate = CONVERT(NUMERIC(18,8), @strSection5_2_StateTaxRate) 
		SET @dblSection5_4_QSSRate = CONVERT(NUMERIC(18,8), @strSection5_4_QSSRate) 


		-- SECTION 5
		SET @dblSection5_3B = @dblSection5_2_StateTaxRate - @dblSection5_1_TaxRate
		SET @dblSection5_5B = @dblSection5_3B - @dblSection5_4_QSSRate

		-- SECTION 4
		SELECT @dblSection4_0A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-46Q' AND strType = 'Aviation Gas'
		SELECT @dblSection4_0B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-46Q' AND strType = 'Qualifying Service Stations'
		SELECT @dblSection4_0C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-46Q' AND strType = 'E85'

		SET @dblSection4_1A = @dblSection4_0A * @dblSection4_1_AllowanceRate
		SET @dblSection4_1B = @dblSection4_0B * @dblSection4_1_AllowanceRate
		SET @dblSection4_1C = @dblSection4_0C * @dblSection4_1_AllowanceRate

		SET @dblSection4_2A	= @dblSection4_0A - @dblSection4_1A
		SET @dblSection4_2B	= @dblSection4_0B - @dblSection4_1B
		SET @dblSection4_2C = @dblSection4_0C - @dblSection4_1C
		
		SET @dblSection4_3B = @dblSection5_5B

		SET @dblSection4_4A = @dblSection4_2A * @dblSection4_3A_ReductionRate
		SET @dblSection4_4B = @dblSection4_2B * @dblSection4_3B
		SET @dblSection4_4C = @dblSection4_2C * @dblSection4_3C_ReductionRate

		-- SECTION 1
		SELECT @dblSection1_1A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-56_Rec' AND strType = 'Gasoline/Alcohol'
		SELECT @dblSection1_1B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-56_Rec' AND strType = 'Others'

		SELECT @dblSection1_2A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-56_IMP' AND strType = 'Gasoline/Alcohol'
		SELECT @dblSection1_2B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode IN ('PDA-56_Imp_WI','PDA-56_Imp_ND','PDA-56_Imp_SD') AND strType = 'Others'

		SET @dblSection1_3A = @dblSection1_1A + @dblSection1_2A
		SET @dblSection1_3B = @dblSection1_1B + @dblSection1_2B 

		SELECT @dblSection1_4A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-56_EXP' AND strType = 'Gasoline/Alcohol'
		SELECT @dblSection1_4B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode IN ('PDA-56_Exp_WI','PDA-56_Exp_ND','PDA-56_Exp_SD') AND strType = 'Others'

		SET @dblSection1_5A = @dblSection1_3A - @dblSection1_4A
		SET @dblSection1_5B = @dblSection1_3B - @dblSection1_4B

		-- SECTION 2
		SELECT @dblSection2_6A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-46F'
		SET @dblSection2_7A = @dblSection1_5A - @dblSection2_6A
		SET @dblSection2_8A = @dblSection2_7A * @dblSection2_8_AllowanceRate
		SET @dblSection2_9A = @dblSection2_7A - @dblSection2_8A
		SELECT @dblSection2_10A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-46E'
		SELECT @dblSection2_11A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-46' AND strScheduleCode = 'PDA-46H'

		-- SECTION 3
		SET @dblSection3_12A = @dblSection2_9A - @dblSection2_10A - @dblSection2_11A
		SET @dblSection3_13A = @dblSection3_12A * @dblSection3_13_TaxDue
		SET @dblSection3_14A = (@dblSection1_5A + @dblSection1_5B) * @dblSection3_14_InspectionFee
		SET @dblSection3_15A = (@dblSection1_5A + @dblSection1_5B) * @dblSection3_15_CleanupFee
		SET @dblSection3_16A = @dblSection3_13A + @dblSection3_14A + @dblSection3_15A

		SET @dblSection3_17A_A = @dblSection4_4A
		SET @dblSection3_17A_A_Gallon = @dblSection4_2A

		SET @dblSection3_17A_B = @dblSection4_4B

		SET @dblSection3_17A_C = @dblSection4_4C
		SET @dblSection3_17A_C_Gallon = @dblSection4_2C

		SET @dblSection3_17A_Total = @dblSection3_17A_A + @dblSection3_17A_B + @dblSection3_17A_C

		SET @dblSection3_18A = @dblSection3_16A - @dblSection3_17A_Total

	END

	SELECT dtmFrom = @dtmFrom
	, dtmTo = @dtmTo

	, dblSection1_1A = @dblSection1_1A
	, dblSection1_2A = @dblSection1_2A 
	, dblSection1_3A = @dblSection1_3A 
	, dblSection1_4A = @dblSection1_4A 
	, dblSection1_5A = @dblSection1_5A 
	, dblSection1_1B = @dblSection1_1B
	, dblSection1_2B = @dblSection1_2B 
	, dblSection1_3B = @dblSection1_3B 
	, dblSection1_4B = @dblSection1_4B 
	, dblSection1_5B = @dblSection1_5B 
	, dblSection2_6A = @dblSection2_6A
	, dblSection2_7A = @dblSection2_7A
	, dblSection2_8A = @dblSection2_8A 
	, dblSection2_9A = @dblSection2_9A
	, dblSection2_10A = @dblSection2_10A
	, dblSection2_11A = @dblSection2_11A 
	, dblSection3_12A = @dblSection3_12A 
	, dblSection3_13A = @dblSection3_13A 
	, dblSection3_14A = @dblSection3_14A
	, dblSection3_15A = @dblSection3_15A
	, dblSection3_16A = @dblSection3_16A
	, dblSection3_17A_A = @dblSection3_17A_A
	, dblSection3_17A_A_Gallon = @dblSection3_17A_A_Gallon
	, dblSection3_17A_B = @dblSection3_17A_B
	, dblSection3_17A_C = @dblSection3_17A_C
	, dblSection3_17A_C_Gallon = @dblSection3_17A_C_Gallon
	, dblSection3_17A_Total = @dblSection3_17A_Total
	, dblSection3_18A = @dblSection3_18A
	, dblSection4_0A = @dblSection4_0A
	, dblSection4_1A = @dblSection4_1A
	, dblSection4_2A = @dblSection4_2A
	--, dblSection4_3A = @dblSection4_3A
	, dblSection4_4A = @dblSection4_4A
	, dblSection4_0B = @dblSection4_0B
	, dblSection4_1B = @dblSection4_1B
	, dblSection4_2B = @dblSection4_2B
	, dblSection4_3B = @dblSection4_3B
	, dblSection4_4B = @dblSection4_4B
	, dblSection4_0C = @dblSection4_0C
	, dblSection4_1C = @dblSection4_1C
	, dblSection4_2C = @dblSection4_2C
	--, dblSection4_3C = @dblSection4_3C
	, dblSection4_4C = @dblSection4_4C
	, dblSection5_1B = @dblSection5_1B
	, dblSection5_2B = @dblSection5_2B
	, dblSection5_3B = @dblSection5_3B
	, dblSection5_4B = @dblSection5_4B
	, dblSection5_5B = @dblSection5_5B
	, strSection2_8_AllowanceRate = @strSection2_8_AllowanceRate
	, strSection3_13_TaxDue = @strSection3_13_TaxDue
	, strSection3_14_InspectionFee = @strSection3_14_InspectionFee
	, strSection3_15_CleanupFee = @strSection3_15_CleanupFee
	, strSection4_1_AllowanceRate = @strSection4_1_AllowanceRate
	, strSection4_3A_ReductionRate = @strSection4_3A_ReductionRate
	, strSection4_3C_ReductionRate = @strSection4_3C_ReductionRate
	, strSection5_1_TaxRate = @strSection5_1_TaxRate
	, strSection5_2_StateTaxRate = @strSection5_2_StateTaxRate
	, strSection5_4_QSSRate = @strSection5_4_QSSRate

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