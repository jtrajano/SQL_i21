CREATE PROCEDURE [dbo].[uspTFGenerateMNPDA49]
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
	, @dblSection2_4A_A NUMERIC(18,0) = 0
	, @dblSection2_4B_B NUMERIC(18,0) = 0
	, @dblSection2_5A NUMERIC(18,0) = 0
	, @dblSection2_5B NUMERIC(18,0) = 0
	, @dblSection2_6A NUMERIC(18,0) = 0
	, @dblSection2_6B NUMERIC(18,0) = 0
	, @dblSection2_7A NUMERIC(18,8) = 0
	, @dblSection2_7B NUMERIC(18,8) = 0
	, @dblSection2_8A NUMERIC(18,8) = 0
	, @dblSection2_8B NUMERIC(18,8) = 0
	, @dblSection3_10A NUMERIC(18,8) = 0
	, @dblSection3_10B NUMERIC(18,8) = 0
	, @dblSection3_12B NUMERIC(18,8) = 0
	, @dblSection4_13A_A NUMERIC(18,8) = 0
	, @dblSection3_13B_B NUMERIC(18,8) = 0
	, @dblSection4_14A NUMERIC(18,8) = 0
	, @dblSection5_0A NUMERIC(18,0) = 0
	, @dblSection5_1A NUMERIC(18,8) = 0
	, @dblSection5_2A NUMERIC(18,8) = 0
	, @dblSection5_3A NUMERIC(18,8) = 0
	, @dblSection5_4A NUMERIC(18,8) = 0
	, @dblSection5_5A NUMERIC(18,8) = 0
	, @dblSection6_3A NUMERIC(18,8) = 0
	, @dblSection6_5A NUMERIC(18,8) = 0

	, @strSection2_7_Loss NVARCHAR(25) = NULL
	, @strSection2_9A_TaxRate NVARCHAR(25) = NULL
	, @strSection2_9B_TaxRate NVARCHAR(25) = NULL
	, @strSection3_11A_TaxClaim NVARCHAR(25) = NULL
	, @strSection5_1A_AllowanceRate NVARCHAR(25) = NULL
	, @strSection6_1A_TaxRate NVARCHAR(25) = NULL
	, @strSection6_2A_OtherTaxRate NVARCHAR(25) = NULL
	, @strSection6_4A_QSSRate NVARCHAR(25) = NULL

	, @dblSection2_7_Loss NUMERIC(18,8) = 0
	, @dblSection2_9A_TaxRate NUMERIC(18,8) = 0
	, @dblSection2_9B_TaxRate NUMERIC(18,8) = 0
	, @dblSection3_11A_TaxClaim NUMERIC(18,8) = 0
	, @dblSection5_1A_AllowanceRate NUMERIC(18,8) = 0
	, @dblSection6_1A_TaxRate NUMERIC(18,8) = 0
	, @dblSection6_2A_OtherTaxRate NUMERIC(18,8) = 0
	, @dblSection6_4A_QSSRate NUMERIC(18,8) = 0


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
		SELECT @strSection2_7_Loss = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA49-Ln7'
		SELECT @strSection2_9A_TaxRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA49-Ln9JF'
		SELECT @strSection2_9B_TaxRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA49-Ln9TF'
		SELECT @strSection3_11A_TaxClaim = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA49-Ln11'
		SELECT @strSection5_1A_AllowanceRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = ''
		SELECT @strSection6_1A_TaxRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA49-46QQSSLn1'
		SELECT @strSection6_2A_OtherTaxRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA49-46QQSSLn2'
		SELECT @strSection6_4A_QSSRate = ISNULL(NULLIF(strConfiguration, ''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'PDA49-46QQSSLn4'
	
		SET @dblSection2_7_Loss = CONVERT(NUMERIC(18,8), @strSection2_7_Loss)
		SET @dblSection2_9A_TaxRate = CONVERT(NUMERIC(18,8), @strSection2_9A_TaxRate)
		SET @dblSection2_9B_TaxRate = CONVERT(NUMERIC(18,8), @strSection2_9B_TaxRate)
		SET @dblSection3_11A_TaxClaim = CONVERT(NUMERIC(18,8), @strSection3_11A_TaxClaim)
		SET @dblSection5_1A_AllowanceRate = CONVERT(NUMERIC(18,8), @strSection5_1A_AllowanceRate)
		SET @dblSection6_1A_TaxRate = CONVERT(NUMERIC(18,8), @strSection6_1A_TaxRate)
		SET @dblSection6_2A_OtherTaxRate = CONVERT(NUMERIC(18,8), @strSection6_2A_OtherTaxRate)
		SET @dblSection6_4A_QSSRate = CONVERT(NUMERIC(18,8), @strSection6_4A_QSSRate)

		-- Section 6
		SET @dblSection6_3A = @dblSection6_2A_OtherTaxRate - @dblSection6_1A_TaxRate
		SET @dblSection6_5A = @dblSection6_3A - @dblSection6_4A_QSSRate

		-- Section 5
		SELECT @dblSection5_0A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-49' AND strScheduleCode = 'PDA-49Q' AND strType = 'Qualifying Service Stations'
		
		SET @dblSection5_1A = @dblSection5_0A * @strSection5_1A_AllowanceRate
		SET @dblSection5_2A = @dblSection5_0A - @dblSection5_1A
		SET @dblSection5_3A = @dblSection6_5A
		SET @dblSection5_4A = @dblSection5_2A * @dblSection5_3A
		SET @dblSection5_5A = @dblSection5_3A - @dblSection5_4A

		-- Section 1
		SELECT @dblSection1_1A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-49' AND strScheduleCode like 'PDA-56%'	
		SELECT @dblSection1_2A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-49' AND strScheduleCode = 'PDA-49G' 	
		SELECT @dblSection1_3A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-49' AND strScheduleCode = 'PDA-49J'
		
		-- Section 2
		SET @dblSection2_4A_A = @dblSection1_3A
		SET @dblSection2_4B_B = @dblSection1_1A + @dblSection1_2A

		SELECT @dblSection2_5A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-49' AND strScheduleCode like 'PDA-49B%' and strType = 'Jet Fuel'
		SELECT @dblSection2_5B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'PDA-49' AND strScheduleCode like 'PDA-49B%' and strType = 'Undyed Diesel'

		SET @dblSection2_6A = @dblSection2_4A_A - @dblSection2_5A
		SET @dblSection2_6B = @dblSection2_4B_B - @dblSection2_5B

		SET @dblSection2_7A = @dblSection2_5A * @dblSection2_7_Loss
		SET @dblSection2_7B = @dblSection2_5B * @dblSection2_7_Loss
		
		SET @dblSection2_8A = @dblSection2_6A - @dblSection2_7A
		SET @dblSection2_8B = @dblSection2_6B - @dblSection2_7B

		-- Section 3
		SET @dblSection3_10A = @dblSection2_8A * @dblSection2_9A_TaxRate
		SET @dblSection3_10B = @dblSection2_8B * @dblSection2_9B_TaxRate
		SET @dblSection3_12B = @dblSection5_4A

		-- Section 4
		SET @dblSection4_13A_A = @dblSection3_10A - @dblSection3_11A_TaxClaim
		SET @dblSection3_13B_B = @dblSection3_10B - @dblSection3_12B
		SET @dblSection4_14A = @dblSection4_13A_A + @dblSection3_13B_B

	END

	SELECT dtmFrom = @dtmFrom
		, dtmTo = @dtmTo
		, dblSection1_1A = @dblSection1_1A
		, dblSection1_2A = @dblSection1_2A
		, dblSection1_3A = @dblSection1_3A
		, dblSection2_4A_A = @dblSection2_4A_A
		, dblSection2_4B_B = @dblSection2_4B_B
		, dblSection2_5A = @dblSection2_5A
		, dblSection2_5B = @dblSection2_5B
		, dblSection2_6A = @dblSection2_6A
		, dblSection2_6B = @dblSection2_6B
		, dblSection2_7A = @dblSection2_7A
		, dblSection2_7B = @dblSection2_7B
		, dblSection2_8A = @dblSection2_8A
		, dblSection2_8B = @dblSection2_8B
		, dblSection3_10A = @dblSection3_10A
		, dblSection3_10B = @dblSection3_10A
		, dblSection3_12B = @dblSection3_12B
		, dblSection4_13A_A = @dblSection4_13A_A
		, dblSection3_13B_B = @dblSection3_13B_B
		, dblSection4_14A = @dblSection4_14A
		, dblSection5_0A = @dblSection5_0A
		, dblSection5_1A = @dblSection5_1A
		, dblSection5_2A = @dblSection5_2A
		, dblSection5_3A = @dblSection5_3A
		, dblSection5_4A = @dblSection5_4A
		, dblSection5_5A = @dblSection5_5A
		, dblSection6_3A = @dblSection6_3A
		, dblSection6_5A = @dblSection6_5A
		, strSection2_7_Loss = @strSection2_7_Loss
		, strSection2_9A_TaxRate = @strSection2_9A_TaxRate
		, strSection2_9B_TaxRate = @strSection2_9B_TaxRate
		, strSection5_1A_AllowanceRate = @strSection5_1A_AllowanceRate
		, strSection6_1A_TaxRate = @strSection6_1A_TaxRate
		, strSection6_2A_OtherTaxRate = @strSection6_2A_OtherTaxRate
		, strSection6_4A_QSSRate = @strSection6_4A_QSSRate
		, strSection3_11A_TaxClaim  = @strSection3_11A_TaxClaim 

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