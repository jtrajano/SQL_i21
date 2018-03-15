CREATE PROCEDURE [dbo].[uspTFGenerateOHTR2]
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
	
		, @Gasoline_14A NUMERIC(18, 6) = 0.00
		, @Gasoline_14B NUMERIC(18, 6) = 0.00
		, @Gasoline_14C NUMERIC(18, 6) = 0.00
		, @Gasoline_4 NUMERIC(18, 6) = 0.00
		
		, @ClearDiesel_14A NUMERIC(18, 6) = 0.00
		, @ClearDiesel_14B NUMERIC(18, 6) = 0.00
		, @ClearDiesel_14C NUMERIC(18, 6) = 0.00
		, @ClearDiesel_4 NUMERIC(18, 6) = 0.00

		, @LowSulfur_14A NUMERIC(18, 6) = 0.00
		, @LowSulfur_14B NUMERIC(18, 6) = 0.00
		, @LowSulfur_14C NUMERIC(18, 6) = 0.00
		, @LowSulfur_4 NUMERIC(18, 6) = 0.00

		, @HighSulfur_14A NUMERIC(18, 6) = 0.00
		, @HighSulfur_14B NUMERIC(18, 6) = 0.00
		, @HighSulfur_14C NUMERIC(18, 6) = 0.00
		, @HighSulfur_4 NUMERIC(18, 6) = 0.00

		, @Kerosene_14A NUMERIC(18, 6) = 0.00
		, @Kerosene_14B NUMERIC(18, 6) = 0.00
		, @Kerosene_14C NUMERIC(18, 6) = 0.00
		, @Kerosene_4 NUMERIC(18, 6) = 0.00

		, @CNG_14A NUMERIC(18, 6) = 0.00
		, @CNG_14B NUMERIC(18, 6) = 0.00
		, @CNG_14C NUMERIC(18, 6) = 0.00
		, @CNG_4 NUMERIC(18, 6) = 0.00

		, @LNG_14A NUMERIC(18, 6) = 0.00
		, @LNG_14B NUMERIC(18, 6) = 0.00
		, @LNG_14C NUMERIC(18, 6) = 0.00
		, @LNG_4 NUMERIC(18, 6) = 0.00

		, @Propane_14A NUMERIC(18, 6) = 0.00
		, @Propane_14B NUMERIC(18, 6) = 0.00
		, @Propane_14C NUMERIC(18, 6) = 0.00
		, @Propane_4 NUMERIC(18, 6) = 0.00

		, @Other_14A NUMERIC(18, 6) = 0.00
		, @Other_14B NUMERIC(18, 6) = 0.00
		, @Other_14C NUMERIC(18, 6) = 0.00
		, @Other_4 NUMERIC(18, 6) = 0.00

		, @Total_5 NUMERIC(18, 6) = 0.00

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
		SELECT @OhioAccountNo = strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'TR2' AND strTemplateItemId = 'TR2-OHTR2AcctNumber'	

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

		SELECT @Gasoline_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'Gasoline'
		SELECT @Gasoline_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'Gasoline'
		SELECT @Gasoline_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'Gasoline'
		SET @Gasoline_4 = @Gasoline_14A + @Gasoline_14B + @Gasoline_14C

		SELECT @ClearDiesel_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'Clear Diesel'
		SET @ClearDiesel_4 = @ClearDiesel_14A + @ClearDiesel_14B + @ClearDiesel_14C
		
		SELECT @LowSulfur_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'Low Sulfur Dyed Diesel'
		SET @LowSulfur_4 = @LowSulfur_14A + @LowSulfur_14B + @LowSulfur_14C

		SELECT @HighSulfur_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'High Sulfur Dyed Diesel'
		SET @HighSulfur_4 = @HighSulfur_14A + @HighSulfur_14B + @HighSulfur_14C

		SELECT @Kerosene_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'Kerosene'
		SELECT @Kerosene_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'Kerosene'
		SELECT @Kerosene_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'Kerosene'
		SET @Kerosene_4 = @Kerosene_14A + @Kerosene_14B + @Kerosene_14C

		SELECT @CNG_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'CNG'
		SELECT @CNG_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'CNG'
		SELECT @CNG_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'CNG'
		SET @CNG_4 = @CNG_14A + @CNG_14B + @CNG_14C

		SELECT @LNG_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'LNG'
		SELECT @LNG_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'LNG'
		SELECT @LNG_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'LNG'
		SET @LNG_4 = @LNG_14A + @LNG_14B + @LNG_14C

		SELECT @Propane_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'Propane'
		SELECT @Propane_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'Propane'
		SELECT @Propane_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'Propane'
		SET @Propane_4 = @Propane_14A + @Propane_14B + @Propane_14C

		SELECT @Other_14A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14A' AND strType = 'Other'
		SELECT @Other_14B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14B' AND strType = 'Other'
		SELECT @Other_14C = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'TR2' AND strScheduleCode = '14C' AND strType = 'Other'
		SET @Other_4 = @Other_14A + @Other_14B + @Other_14C

		SET @Total_5 = @Gasoline_4 + @ClearDiesel_4 + @LowSulfur_4 + @HighSulfur_4 + @Kerosene_4 + @CNG_4 + @LNG_4 + @Propane_4 + @Other_4

		DELETE @transaction

	END

	SELECT Name = @Name
		, TIN = @TIN
		, OhioAccountNo = @OhioAccountNo
		, dtmFrom = @dtmFrom
		, dtmTo = @dtmFrom
	
		, Gasoline_14A = @Gasoline_14A
		, Gasoline_14B = @Gasoline_14B
		, Gasoline_14C = @Gasoline_14C
		, Gasoline_4 = @Gasoline_4
		
		, ClearDiesel_14A = @ClearDiesel_14A
		, ClearDiesel_14B = @ClearDiesel_14B
		, ClearDiesel_14C = @ClearDiesel_14C
		, ClearDiesel_4 = @ClearDiesel_4

		, LowSulfur_14A = @LowSulfur_14A
		, LowSulfur_14B = @LowSulfur_14B
		, LowSulfur_14C = @LowSulfur_14C
		, LowSulfur_4 = @LowSulfur_4

		, HighSulfur_14A = @HighSulfur_14A
		, HighSulfur_14B = @HighSulfur_14B
		, HighSulfur_14C = @HighSulfur_14C
		, HighSulfur_4 = @HighSulfur_4

		, Kerosene_14A = @Kerosene_14A
		, Kerosene_14B = @Kerosene_14B
		, Kerosene_14C = @Kerosene_14C
		, Kerosene_4 = @Kerosene_4

		, CNG_14A = @CNG_14A
		, CNG_14B = @CNG_14B
		, CNG_14C = @CNG_14C
		, CNG_4 = @CNG_4

		, LNG_14A = @LNG_14A
		, LNG_14B = @LNG_14B
		, LNG_14C = @LNG_14C
		, LNG_4 = @LNG_4

		, Propane_14A = @Propane_14A
		, Propane_14B = @Propane_14B
		, Propane_14C = @Propane_14C
		, Propane_4 = @Propane_4

		, Other_14A = @Other_14A
		, Other_14B = @Other_14B
		, Other_14C = @Other_14C
		, Other_4 = @Other_4

		, Total_5 = @Total_5

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