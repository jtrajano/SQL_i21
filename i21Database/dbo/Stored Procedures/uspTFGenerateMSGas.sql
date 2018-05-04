CREATE PROCEDURE [dbo].[uspTFGenerateMSGas]
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

	DECLARE @AutomotiveGas_6D NUMERIC(18, 0) = 0
		, @AutomotiveGas_1 NUMERIC(18, 0) = 0
		, @AutomotiveGas_2 NUMERIC(18, 0) = 0
		, @AutomotiveGas_2A NUMERIC(18, 0) = 0
		, @AutomotiveGas_2B NUMERIC(18, 0) = 0
		, @AutomotiveGas_2C NUMERIC(18, 0) = 0
		, @AutomotiveGas_2X NUMERIC(18, 0) = 0
		, @AutomotiveGas_5B NUMERIC(18, 0) = 0
		, @AutomotiveGas_5D NUMERIC(18, 0) = 0
		, @AutomotiveGas_7 NUMERIC(18, 0) = 0
		, @AutomotiveGas_8 NUMERIC(18, 0) = 0
		, @AutomotiveGas_9 NUMERIC(18, 0) = 0
		, @AutomotiveGas_11  NUMERIC(18, 0) = 0
		, @AutomotiveGas_13H NUMERIC(18, 0) = 0
		, @AutomotiveGas_15 NUMERIC(18, 0) = 0
		, @AutomotiveGas_16 NUMERIC(18, 0) = 0
		, @AutomotiveGas_17 NUMERIC(18, 0) = 0
		, @AutomotiveGas_18 NUMERIC(18, 0) = 0
		, @AutomotiveGas_19 NUMERIC(18, 4) = 0
		, @AutomotiveGas_20 NUMERIC(18, 2) = 0
		, @AutomotiveGas_22 NUMERIC(18, 0) = 0
		, @AutomotiveGas_23 NUMERIC(18, 0) = 0
		, @AutomotiveGas_24 NUMERIC(18, 4) = 0
		, @AutomotiveGas_25 NUMERIC(18, 2) = 0
		, @AutomotiveGas_26 NUMERIC(18, 2) = 0

		, @AviationGas_6D NUMERIC(18, 0) = 0
		, @AviationGas_1 NUMERIC(18, 0) = 0
		, @AviationGas_2 NUMERIC(18, 0) = 0
		, @AviationGas_2A NUMERIC(18, 0) = 0
		, @AviationGas_2B NUMERIC(18, 0) = 0
		, @AviationGas_2C NUMERIC(18, 0) = 0
		, @AviationGas_2X NUMERIC(18, 0) = 0
		, @AviationGas_5B NUMERIC(18, 0) = 0
		, @AviationGas_5D NUMERIC(18, 0) = 0
		, @AviationGas_7 NUMERIC(18, 0) = 0
		, @AviationGas_8 NUMERIC(18, 0) = 0
		, @AviationGas_9 NUMERIC(18, 0) = 0
		, @AviationGas_11 NUMERIC(18, 0) = 0
		, @AviationGas_13H NUMERIC(18, 0) = 0
		, @AviationGas_15 NUMERIC(18, 0) = 0
		, @AviationGas_16 NUMERIC(18, 0) = 0
		, @AviationGas_17 NUMERIC(18, 0) = 0
		, @AviationGas_18 NUMERIC(18, 0) = 0
		, @AviationGas_19 NUMERIC(18, 4) = 0
		, @AviationGas_20 NUMERIC(18, 2) = 0
		, @AviationGas_22 NUMERIC(18, 0) = 0
		, @AviationGas_23 NUMERIC(18, 0) = 0
		, @AviationGas_24 NUMERIC(18, 4) = 0
		, @AviationGas_25 NUMERIC(18, 2) = 0
		, @AviationGas_26 NUMERIC(18, 2) = 0
		, @AutoAviationGas_27 NUMERIC(18, 2) = 0
		, @AutoAviationGas_28 NUMERIC(18, 2) = 0
		, @AutoAviationGas_29 NUMERIC(18, 2) = 0
		, @AutoAviationGas_30 NUMERIC(18, 2) = 0
		, @AutoAviationGas_31 NUMERIC(18, 2) = 0
		, @AutomotiveShrinkage NUMERIC(18, 4) = 0
		, @AviationShrinkage NUMERIC(18, 4) = 0

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

		DECLARE @transaction TABLE(
			 strFormCode NVARCHAR(100)
			,strScheduleCode NVARCHAR(100)
			,strType  NVARCHAR(100)
			,dblReceived NUMERIC
			,dblBillQty NUMERIC
			,dblQtyShipped NUMERIC
			,dblTax NUMERIC(18,2)
			,dblTaxExempt NUMERIC(18,2)
			)
		
		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS'

		-- Configuration
		SELECT @AutomotiveShrinkage = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line17Auto'
		SELECT @AviationShrinkage = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE  CONVERT(NUMERIC(18,4), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line17Aviation'

		INSERT INTO @transaction		
		SELECT strFormCode, strScheduleCode, strType, dblReceived = SUM(ISNULL(dblReceived, 0.00)), dblBillQty = SUM(ISNULL(dblBillQty, 0.00)), dblQtyShipped = SUM(ISNULL(dblQtyShipped, 0.00)), dblTax = SUM(ISNULL(dblTax, 0.00)), dblTaxExempt = SUM(ISNULL(dblTaxExempt, 0.00))
		FROM vyuTFGetTransaction Trans
		WHERE Trans.uniqTransactionGuid = @Guid
		GROUP BY strFormCode, strScheduleCode, strType
	
		SELECT @AutomotiveGas_6D =  ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_1 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_2 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_2A = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_2B = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2B' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_2C = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_2X = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_5B = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_5D = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_7 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_8 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Automotive Gas'
		SELECT @AutomotiveGas_13H = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Automotive Gas'


		SELECT @AviationGas_6D = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '6D' AND strType = 'Aviation Gas'
		SELECT @AviationGas_1 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '1' AND strType = 'Aviation Gas'
		SELECT @AviationGas_2 = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2' AND strType = 'Aviation Gas'
		SELECT @AviationGas_2A = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2A' AND strType = 'Aviation Gas'
		SELECT @AviationGas_2B = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2B' AND strType = 'Aviation Gas'
		SELECT @AviationGas_2C = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2C' AND strType = 'Aviation Gas'
		SELECT @AviationGas_2X = ISNULL(dblReceived, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '2X' AND strType = 'Aviation Gas'
		SELECT @AviationGas_5B = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '5B' AND strType = 'Aviation Gas'
		SELECT @AviationGas_5D = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '5D' AND strType = 'Aviation Gas'
		SELECT @AviationGas_7 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '7' AND strType = 'Aviation Gas'
		SELECT @AviationGas_8 = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '8' AND strType = 'Aviation Gas'
		SELECT @AviationGas_13H = ISNULL(dblBillQty, 0) FROM @transaction WHERE strFormCode = 'Gas' AND strScheduleCode = '13H' AND strType = 'Aviation Gas'	

		-- Line 9
		SET @AutomotiveGas_9 = @AutomotiveGas_1 + @AutomotiveGas_2 + @AutomotiveGas_2A +  @AutomotiveGas_2B + @AutomotiveGas_2C +  @AutomotiveGas_2X + @AutomotiveGas_5B +  @AutomotiveGas_5D
		SET @AviationGas_9 = @AviationGas_1 + @AviationGas_2 + @AviationGas_2A +  @AviationGas_2B + @AviationGas_2C + @AviationGas_2X + @AviationGas_5B + @AviationGas_5D

		--Line 11
		SELECT @AutomotiveGas_11 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END  FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line11Auto'
		SELECT @AviationGas_11 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line11Aviation'
		
		-- Line 15
		SET @AutomotiveGas_15 = @AutomotiveGas_1 + @AutomotiveGas_11 + @AutomotiveGas_2X + @AutomotiveGas_7 + @AutomotiveGas_8
		SET @AviationGas_15 = @AviationGas_1 + @AviationGas_11 + @AviationGas_2X + @AviationGas_7 + @AviationGas_8

		-- Line 16
		SET @AutomotiveGas_16 = @AutomotiveGas_9 - @AutomotiveGas_15
		SET @AviationGas_16 = @AviationGas_9 - @AviationGas_15

		-- Line 17
		SET @AutomotiveGas_17 = @AutomotiveGas_16 * @AutomotiveShrinkage
		SET @AviationGas_17 = @AviationGas_16 * @AviationShrinkage

		-- Line 18
		SET @AutomotiveGas_18 = @AutomotiveGas_16 - @AutomotiveGas_17
		SET @AviationGas_18 = @AviationGas_16 - @AviationGas_17

		-- Line 19
		SELECT @AutomotiveGas_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line19Auto'
		SELECT @AviationGas_19 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line19Aviation'

		-- Line 20
		SET @AutomotiveGas_20 = @AutomotiveGas_18 * @AutomotiveGas_19
		SET @AviationGas_20 = @AviationGas_18 * @AviationGas_19
		
		-- Line 22
		SET @AutomotiveGas_22 = @AutomotiveGas_13H * @AutomotiveShrinkage
		SET @AviationGas_22 = @AviationGas_13H * @AviationShrinkage

		-- Line 23
		SET @AutomotiveGas_23 = @AutomotiveGas_13H - @AutomotiveGas_22
		SET @AviationGas_23 = @AviationGas_13H  - @AviationGas_22

		-- Line 24
		SELECT @AutomotiveGas_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-LIne24Auto'
		SELECT @AviationGas_24 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,4), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line24Aviation'

		-- Line 25
		SET @AutomotiveGas_25 = @AutomotiveGas_23 * @AutomotiveGas_24
		SET @AviationGas_25 = @AviationGas_23 * @AviationGas_24

		-- Line 26
		SET @AutomotiveGas_26 = @AutomotiveGas_20 - @AutomotiveGas_25
		SET @AviationGas_26 = @AviationGas_20 - @AviationGas_25

		-- Line 27
		SET @AutoAviationGas_27 = @AutomotiveGas_26 + @AviationGas_26

		-- Line 28 29 30
		SELECT @AutoAviationGas_28 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line28'
		SELECT @AutoAviationGas_29 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line29'
		SELECT @AutoAviationGas_30 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'Gas-Line30'

		-- Line 31
		SET @AutoAviationGas_31 = @AutoAviationGas_27 + @AutoAviationGas_28 + @AutoAviationGas_29 + @AutoAviationGas_30
		
	END

	SELECT AutomotiveGas_6D = @AutomotiveGas_6D
		, AutomotiveGas_1 = @AutomotiveGas_1
		, AutomotiveGas_2 = @AutomotiveGas_2
		, AutomotiveGas_2A = @AutomotiveGas_2A
		, AutomotiveGas_2B = @AutomotiveGas_2B
		, AutomotiveGas_2C = @AutomotiveGas_2C
		, AutomotiveGas_2X = @AutomotiveGas_2X
		, AutomotiveGas_5B = @AutomotiveGas_5B
		, AutomotiveGas_5D = @AutomotiveGas_5D
		, AutomotiveGas_7 = @AutomotiveGas_7
		, AutomotiveGas_8 = @AutomotiveGas_8
		, AutomotiveGas_9 = @AutomotiveGas_9
		, AutomotiveGas_11 = @AutomotiveGas_11
		, AutomotiveGas_13H = @AutomotiveGas_13H
		, AutomotiveGas_15 = @AutomotiveGas_15
		, AutomotiveGas_16 = @AutomotiveGas_16
		, AutomotiveGas_17 = @AutomotiveGas_17
		, AutomotiveGas_18 = @AutomotiveGas_18
		, AutomotiveGas_19 = @AutomotiveGas_19
		, AutomotiveGas_20 = @AutomotiveGas_20
		, AutomotiveGas_22 = @AutomotiveGas_22
		, AutomotiveGas_23 = @AutomotiveGas_23
		, AutomotiveGas_24 = @AutomotiveGas_24
		, AutomotiveGas_25 = @AutomotiveGas_25
		, AutomotiveGas_26 = @AutomotiveGas_26
		, AviationGas_6D = @AviationGas_6D
		, AviationGas_1 = @AviationGas_1
		, AviationGas_2 = @AviationGas_2
		, AviationGas_2A = @AviationGas_2A
		, AviationGas_2B = @AviationGas_2B
		, AviationGas_2C = @AviationGas_2C
		, AviationGas_2X = @AviationGas_2X
		, AviationGas_5B = @AviationGas_5B
		, AviationGas_5D = @AviationGas_5D
		, AviationGas_7 = @AviationGas_7
		, AviationGas_8 = @AviationGas_8
		, AviationGas_9 = @AviationGas_9
		, AviationGas_11 = @AviationGas_11
		, AviationGas_13H = @AviationGas_13H
		, AviationGas_15 = @AviationGas_15
		, AviationGas_16 = @AviationGas_16
		, AviationGas_17 = @AviationGas_17
		, AviationGas_18 = @AviationGas_18
		, AviationGas_19 = @AviationGas_19
		, AviationGas_20 = @AviationGas_20
		, AviationGas_22 = @AviationGas_22
		, AviationGas_23 = @AviationGas_23
		, AviationGas_24 = @AviationGas_24
		, AviationGas_25 = @AviationGas_25
		, AviationGas_26 = @AviationGas_26
		, AutoAviationGas_27 = @AutoAviationGas_27
		, AutoAviationGas_28 = @AutoAviationGas_28
		, AutoAviationGas_29 = @AutoAviationGas_29
		, AutoAviationGas_30 = @AutoAviationGas_30
		, AutoAviationGas_31 = @AutoAviationGas_31
		, AutomotiveShrinkage = @AutomotiveShrinkage
		, AviationShrinkage = @AviationShrinkage

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