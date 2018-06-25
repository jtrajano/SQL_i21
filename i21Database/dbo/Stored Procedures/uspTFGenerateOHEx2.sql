CREATE PROCEDURE [dbo].[uspTFGenerateOHEx2]
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
	
		, @Gasoline_1B NUMERIC(18, 6) = 0.00
		, @Gasoline_2E NUMERIC(18, 6) = 0.00
		, @Gasoline_7A NUMERIC(18, 6) = 0.00
		, @Gasoline_7D NUMERIC(18, 6) = 0.00
		, @Gasoline_3 NUMERIC(18, 6) = 0.00
		, @Gasoline_6 NUMERIC(18, 6) = 0.00
		
		, @ClearDiesel_1B NUMERIC(18, 6) = 0.00
		, @ClearDiesel_2E NUMERIC(18, 6) = 0.00
		, @ClearDiesel_7A NUMERIC(18, 6) = 0.00
		, @ClearDiesel_7D NUMERIC(18, 6) = 0.00
		, @ClearDiesel_3 NUMERIC(18, 6) = 0.00
		, @ClearDiesel_6 NUMERIC(18, 6) = 0.00

		, @LowSulfur_1B NUMERIC(18, 6) = 0.00
		, @LowSulfur_2E NUMERIC(18, 6) = 0.00
		, @LowSulfur_7A NUMERIC(18, 6) = 0.00
		, @LowSulfur_7D NUMERIC(18, 6) = 0.00
		, @LowSulfur_3 NUMERIC(18, 6) = 0.00
		, @LowSulfur_6 NUMERIC(18, 6) = 0.00

		, @HighSulfur_1B NUMERIC(18, 6) = 0.00
		, @HighSulfur_2E NUMERIC(18, 6) = 0.00
		, @HighSulfur_7A NUMERIC(18, 6) = 0.00
		, @HighSulfur_7D NUMERIC(18, 6) = 0.00
		, @HighSulfur_3 NUMERIC(18, 6) = 0.00
		, @HighSulfur_6 NUMERIC(18, 6) = 0.00

		, @Kerosene_1B NUMERIC(18, 6) = 0.00
		, @Kerosene_2E NUMERIC(18, 6) = 0.00
		, @Kerosene_7A NUMERIC(18, 6) = 0.00
		, @Kerosene_7D NUMERIC(18, 6) = 0.00
		, @Kerosene_3 NUMERIC(18, 6) = 0.00
		, @Kerosene_6 NUMERIC(18, 6) = 0.00

		, @CNG_1B NUMERIC(18, 6) = 0.00
		, @CNG_2E NUMERIC(18, 6) = 0.00
		, @CNG_7A NUMERIC(18, 6) = 0.00
		, @CNG_7D NUMERIC(18, 6) = 0.00
		, @CNG_3 NUMERIC(18, 6) = 0.00
		, @CNG_6 NUMERIC(18, 6) = 0.00

		, @LNG_1B NUMERIC(18, 6) = 0.00
		, @LNG_2E NUMERIC(18, 6) = 0.00
		, @LNG_7A NUMERIC(18, 6) = 0.00
		, @LNG_7D NUMERIC(18, 6) = 0.00
		, @LNG_3 NUMERIC(18, 6) = 0.00
		, @LNG_6 NUMERIC(18, 6) = 0.00

		, @Propane_1B NUMERIC(18, 6) = 0.00
		, @Propane_2E NUMERIC(18, 6) = 0.00
		, @Propane_7A NUMERIC(18, 6) = 0.00
		, @Propane_7D NUMERIC(18, 6) = 0.00
		, @Propane_3 NUMERIC(18, 6) = 0.00
		, @Propane_6 NUMERIC(18, 6) = 0.00

		, @Other_1B NUMERIC(18, 6) = 0.00
		, @Other_2E NUMERIC(18, 6) = 0.00
		, @Other_7A NUMERIC(18, 6) = 0.00
		, @Other_7D NUMERIC(18, 6) = 0.00
		, @Other_3 NUMERIC(18, 6) = 0.00
		, @Other_6 NUMERIC(18, 6) = 0.00

		, @Total_7 NUMERIC(18, 6) = 0.00
		, @Total_8 NUMERIC(18, 6) = 0.00

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
		SELECT @OhioAccountNo = strConfiguration FROM vyuTFGetReportingComponentConfiguration WHERE intTaxAuthorityId = @TaxAuthorityId AND strFormCode = 'EX2' AND strTemplateItemId = 'EX2-OHEX2AcctNumber'
		
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

		SELECT @Gasoline_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'Gasoline'
		SELECT @Gasoline_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'Gasoline'
		SELECT @Gasoline_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'Gasoline'
		SELECT @Gasoline_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'Gasoline'
		SET @Gasoline_3 = @Gasoline_1B + @Gasoline_2E
		SET @Gasoline_6 = @Gasoline_7A + @Gasoline_7D

		SELECT @ClearDiesel_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'Clear Diesel'
		SELECT @ClearDiesel_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'Clear Diesel'
		SET @ClearDiesel_3 = @ClearDiesel_1B + @ClearDiesel_2E
		SET @ClearDiesel_6 = @ClearDiesel_7A + @ClearDiesel_7D

		SELECT @LowSulfur_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'Low Sulfur Dyed Diesel'
		SELECT @LowSulfur_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'Low Sulfur Dyed Diesel'
		SET @LowSulfur_3 = @LowSulfur_1B + @LowSulfur_2E
		SET @LowSulfur_6 = @LowSulfur_7A + @LowSulfur_7D

		SELECT @HighSulfur_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'High Sulfur Dyed Diesel'
		SELECT @HighSulfur_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'High Sulfur Dyed Diesel'
		SET @HighSulfur_3 = @HighSulfur_1B + @HighSulfur_2E
		SET @HighSulfur_6 = @HighSulfur_7A + @HighSulfur_7D

		SELECT @Kerosene_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'Kerosene'
		SELECT @Kerosene_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'Kerosene'
		SELECT @Kerosene_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'Kerosene'
		SELECT @Kerosene_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'Kerosene'
		SET @Kerosene_3 = @Kerosene_1B + @Kerosene_2E
		SET @Kerosene_6 = @Kerosene_7A + @Kerosene_7D

		SELECT @CNG_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'CNG'
		SELECT @CNG_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'CNG'
		SELECT @CNG_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'CNG'
		SELECT @CNG_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'CNG'
		SET @CNG_3 = @CNG_1B + @CNG_2E
		SET @CNG_6 = @CNG_7A + @CNG_7D

		SELECT @LNG_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'LNG'
		SELECT @LNG_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'LNG'
		SELECT @LNG_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'LNG'
		SELECT @LNG_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'LNG'
		SET @LNG_3 = @LNG_1B + @LNG_2E
		SET @LNG_6 = @LNG_7A + @LNG_7D

		SELECT @Propane_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'Propane'
		SELECT @Propane_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'Propane'
		SELECT @Propane_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'Propane'
		SELECT @Propane_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'Propane'
		SET @Propane_3 = @Propane_1B + @Propane_2E
		SET @Propane_6 = @Propane_7A + @Propane_7D

		SELECT @Other_1B = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '1B%' AND strType = 'Other'
		SELECT @Other_2E = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '2E%' AND strType = 'Other'
		SELECT @Other_7A = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7A%' AND strType = 'Other'
		SELECT @Other_7D = ISNULL(SUM(dblReceived),0) FROM @transaction WHERE strFormCode = 'EX2' AND strScheduleCode LIKE '7D%' AND strType = 'Other'
		SET @Other_3 = @Other_1B + @Other_2E
		SET @Other_6 = @Other_7A + @Other_7D

		SET @Total_7 = @Gasoline_3 + @ClearDiesel_3 + @LowSulfur_3 + @HighSulfur_3 + @Kerosene_3 + @CNG_3 + @LNG_3 + @Propane_3 + @Other_3
		SET @Total_8 = @Gasoline_6 + @ClearDiesel_6 + @LowSulfur_6 + @HighSulfur_6 + @Kerosene_6 + @CNG_6 + @LNG_6 + @Propane_6 + @Other_6

		DELETE @transaction

	END

	SELECT Name = @Name
		, TIN = @TIN
		, OhioAccountNo = @OhioAccountNo
		, dtmFrom = @dtmFrom
		, dtmTo = @dtmTo
		, Gasoline_1B = @Gasoline_1B
		, Gasoline_2E = @Gasoline_2E
		, Gasoline_7A = @Gasoline_7A
		, Gasoline_7D = @Gasoline_7D
		, Gasoline_3 = @Gasoline_3
		, Gasoline_6 = @Gasoline_6	
		, ClearDiesel_1B = @ClearDiesel_1B
		, ClearDiesel_2E = @ClearDiesel_2E
		, ClearDiesel_7A = @ClearDiesel_7A
		, ClearDiesel_7D = @ClearDiesel_7D
		, ClearDiesel_3 = @ClearDiesel_3
		, ClearDiesel_6 = @ClearDiesel_6
		, LowSulfur_1B = @LowSulfur_1B
		, LowSulfur_2E = @LowSulfur_2E
		, LowSulfur_7A = @LowSulfur_7A
		, LowSulfur_7D = @LowSulfur_7D
		, LowSulfur_3 = @LowSulfur_3
		, LowSulfur_6 = @LowSulfur_6
		, HighSulfur_1B = @HighSulfur_1B
		, HighSulfur_2E = @HighSulfur_2E
		, HighSulfur_7A = @HighSulfur_7A
		, HighSulfur_7D = @HighSulfur_7D
		, HighSulfur_3 = @HighSulfur_3
		, HighSulfur_6 = @HighSulfur_6
		, Kerosene_1B = @Kerosene_1B
		, Kerosene_2E = @Kerosene_2E
		, Kerosene_7A = @Kerosene_7A
		, Kerosene_7D = @Kerosene_7D
		, Kerosene_3 = @Kerosene_3
		, Kerosene_6 = @Kerosene_6
		, CNG_1B = @CNG_1B
		, CNG_2E = @CNG_2E
		, CNG_7A = @CNG_7A
		, CNG_7D = @CNG_7D
		, CNG_3 = @CNG_3
		, CNG_6 = @CNG_6
		, LNG_1B = @LNG_1B
		, LNG_2E = @LNG_2E
		, LNG_7A = @LNG_7A
		, LNG_7D = @LNG_7D
		, LNG_3 = @LNG_3
		, LNG_6 = @LNG_6
		, Propane_1B = @Propane_1B
		, Propane_2E = @Propane_2E
		, Propane_7A = @Propane_7A
		, Propane_7D = @Propane_7D
		, Propane_3 = @Propane_3
		, Propane_6 = @Propane_6
		, Other_1B = @Other_1B
		, Other_2E = @Other_2E
		, Other_7A = @Other_7A
		, Other_7D = @Other_7D
		, Other_3 = @Other_3
		, Other_6 = @Other_6
		, Total_7 = @Total_7
		, Total_8 = @Total_8

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