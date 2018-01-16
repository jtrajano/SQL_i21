CREATE PROCEDURE [dbo].[uspTFGenerateOR7351302]
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

	DECLARE @DealerGasoline_1 NUMERIC(18, 6) = 0
		, @DealerGasoline_2 NUMERIC(18, 6) = 0
		, @DealerGasoline_3 NUMERIC(18, 6) = 0
		, @DealerGasoline_4 NUMERIC(18, 6) = 0
		, @DealerGasoline_5 NUMERIC(18, 6) = 0
		, @DealerGasoline_6 NUMERIC(18, 6) = 0
		, @DealerGasoline_7 NUMERIC(18, 6) = 0
		, @DealerGasoline_8 NUMERIC(18, 6) = 0
		, @DealerGasoline_9 NUMERIC(18, 6) = 0
		, @DealerGasoline_10 NUMERIC(18, 6) = 0
		, @DealerGasoline_11 NUMERIC(18, 6) = 0

		, @DealerAviation_1 NUMERIC(18, 6) = 0
		, @DealerAviation_2 NUMERIC(18, 6) = 0
		, @DealerAviation_3 NUMERIC(18, 6) = 0
		, @DealerAviation_4 NUMERIC(18, 6) = 0
		, @DealerAviation_5 NUMERIC(18, 6) = 0
		, @DealerAviation_6 NUMERIC(18, 6) = 0
		, @DealerAviation_7 NUMERIC(18, 6) = 0
		, @DealerAviation_8 NUMERIC(18, 6) = 0
		, @DealerAviation_9 NUMERIC(18, 6) = 0
		, @DealerAviation_10 NUMERIC(18, 6) = 0
		, @DealerAviation_11 NUMERIC(18, 6) = 0

		, @DealerJet_1 NUMERIC(18, 6) = 0
		, @DealerJet_2 NUMERIC(18, 6) = 0
		, @DealerJet_3 NUMERIC(18, 6) = 0
		, @DealerJet_4 NUMERIC(18, 6) = 0
		, @DealerJet_5 NUMERIC(18, 6) = 0
		, @DealerJet_6 NUMERIC(18, 6) = 0
		, @DealerJet_7 NUMERIC(18, 6) = 0
		, @DealerJet_8 NUMERIC(18, 6) = 0
		, @DealerJet_9 NUMERIC(18, 6) = 0
		, @DealerJet_10 NUMERIC(18, 6) = 0
		, @DealerJet_11 NUMERIC(18, 6) = 0

		, @DealerEthanol_1 NUMERIC(18, 6) = 0
		, @DealerEthanol_2 NUMERIC(18, 6) = 0
		, @DealerEthanol_3 NUMERIC(18, 6) = 0
		, @DealerEthanol_4 NUMERIC(18, 6) = 0
		, @DealerEthanol_5 NUMERIC(18, 6) = 0
		, @DealerEthanol_6 NUMERIC(18, 6) = 0

		, @DealerDiesel_1 NUMERIC(18, 6) = 0
		, @DealerDiesel_2 NUMERIC(18, 6) = 0
		, @DealerDiesel_3 NUMERIC(18, 6) = 0
		, @DealerDiesel_4 NUMERIC(18, 6) = 0
		, @DealerDiesel_5 NUMERIC(18, 6) = 0
		, @DealerDiesel_6 NUMERIC(18, 6) = 0

		, @DealerTotal_11 NUMERIC(18, 6) = 0
		, @DealerTotal_12 NUMERIC(18, 6) = 0
		, @DealerTotal_13 NUMERIC(18, 6) = 0
		, @DealerTotal_14 NUMERIC(18, 6) = 0
		, @DealerTotal_15 NUMERIC(18, 6) = 0
		, @DealerTotal_16 NUMERIC(18, 6) = 0

		, @ReceiptGasoline_1 NUMERIC(18, 6) = 0
		, @ReceiptGasoline_2 NUMERIC(18, 6) = 0
		, @ReceiptGasoline_3 NUMERIC(18, 6) = 0
		, @ReceiptGasoline_4 NUMERIC(18, 6) = 0
		, @ReceiptGasoline_5 NUMERIC(18, 6) = 0
		, @ReceiptGasoline_6 NUMERIC(18, 6) = 0

		, @DisbursementGasoline_7 NUMERIC(18, 6) = 0
		, @DisbursementGasoline_8 NUMERIC(18, 6) = 0
		, @DisbursementGasoline_9 NUMERIC(18, 6) = 0
		, @DisbursementGasoline_10 NUMERIC(18, 6) = 0
		, @DisbursementGasoline_11 NUMERIC(18, 6) = 0
		, @DisbursementGasoline_12 NUMERIC(18, 6) = 0

		, @ReceiptAviation_1 NUMERIC(18, 6) = 0
		, @ReceiptAviation_2 NUMERIC(18, 6) = 0
		, @ReceiptAviation_3 NUMERIC(18, 6) = 0
		, @ReceiptAviation_4 NUMERIC(18, 6) = 0
		, @ReceiptAviation_5 NUMERIC(18, 6) = 0
		, @ReceiptAviation_6 NUMERIC(18, 6) = 0

		, @DisbursementAviation_7 NUMERIC(18, 6) = 0
		, @DisbursementAviation_8 NUMERIC(18, 6) = 0
		, @DisbursementAviation_9 NUMERIC(18, 6) = 0
		, @DisbursementAviation_10 NUMERIC(18, 6) = 0
		, @DisbursementAviation_11 NUMERIC(18, 6) = 0
		, @DisbursementAviation_12 NUMERIC(18, 6) = 0

		, @ReceiptJet_1 NUMERIC(18, 6) = 0
		, @ReceiptJet_2 NUMERIC(18, 6) = 0
		, @ReceiptJet_3 NUMERIC(18, 6) = 0
		, @ReceiptJet_4 NUMERIC(18, 6) = 0
		, @ReceiptJet_5 NUMERIC(18, 6) = 0
		, @ReceiptJet_6 NUMERIC(18, 6) = 0

		, @DisbursementJet_7 NUMERIC(18, 6) = 0
		, @DisbursementJet_8 NUMERIC(18, 6) = 0
		, @DisbursementJet_9 NUMERIC(18, 6) = 0
		, @DisbursementJet_10 NUMERIC(18, 6) = 0
		, @DisbursementJet_11 NUMERIC(18, 6) = 0
		, @DisbursementJet_12 NUMERIC(18, 6) = 0

		, @ReceiptEthanol_1 NUMERIC(18, 6) = 0	
		, @ReceiptEthanol_3 NUMERIC(18, 6) = 0
		, @ReceiptEthanol_4 NUMERIC(18, 6) = 0
		, @ReceiptEthanol_5 NUMERIC(18, 6) = 0
		, @ReceiptEthanol_6 NUMERIC(18, 6) = 0

		, @DisbursementEthanol_8 NUMERIC(18, 6) = 0
		, @DisbursementEthanol_9 NUMERIC(18, 6) = 0
		, @DisbursementEthanol_10 NUMERIC(18, 6) = 0
		, @DisbursementEthanol_11 NUMERIC(18, 6) = 0
		, @DisbursementEthanol_12 NUMERIC(18, 6) = 0

		, @ReceiptDiesel_1 NUMERIC(18, 6) = 0	
		, @ReceiptDiesel_3 NUMERIC(18, 6) = 0
		, @ReceiptDiesel_4 NUMERIC(18, 6) = 0
		, @ReceiptDiesel_5 NUMERIC(18, 6) = 0
		, @ReceiptDiesel_6 NUMERIC(18, 6) = 0

		, @DisbursementDiesel_8 NUMERIC(18, 6) = 0
		, @DisbursementDiesel_9 NUMERIC(18, 6) = 0
		, @DisbursementDiesel_10 NUMERIC(18, 6) = 0
		, @DisbursementDiesel_11 NUMERIC(18, 6) = 0
		, @DisbursementDiesel_12 NUMERIC(18, 6) = 0


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

		DECLARE @TaxAuthorityId INT, @Guid NVARCHAR(100)

		DECLARE @transaction TABLE(
			 strFormCode NVARCHAR(100)
			,strScheduleCode NVARCHAR(100)
			,strType  NVARCHAR(100)
			,dblReceived NUMERIC)

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OR'

		SELECT @ReceiptGasoline_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '735-1302-RefinaryGasoline'
		SELECT @ReceiptAviation_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '735-1302-RefinaryAviationGas'
		SELECT @ReceiptJet_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '735-1302-RefinaryJetJet'
		SELECT @ReceiptEthanol_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '735-1302-RefinaryEthanol'
		SELECT @ReceiptDiesel_1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,0), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = '735-1302-RefinaryDiesel'

		INSERT INTO @transaction		
		SELECT strFormCode, strScheduleCode, strType, dblReceived = SUM(ISNULL(dblReceived, 0.00))
		FROM vyuTFGetTransaction Trans
		WHERE Trans.uniqTransactionGuid = @Guid
		GROUP BY strFormCode, strScheduleCode, strType




	END

	SELECT DealerGasoline_1 = @DealerGasoline_1
		, DealerGasoline_2 = @DealerGasoline_2
		, DealerGasoline_3 = @DealerGasoline_3
		, DealerGasoline_4 = @DealerGasoline_4
		, DealerGasoline_5 = @DealerGasoline_5
		, DealerGasoline_6 = @DealerGasoline_6
		, DealerGasoline_7 = @DealerGasoline_7
		, DealerGasoline_8 = @DealerGasoline_8
		, DealerGasoline_9 = @DealerGasoline_9
		, DealerGasoline_10 = @DealerGasoline_10
		, DealerGasoline_11 = @DealerGasoline_11

		, DealerAviation_1 = @DealerAviation_1
		, DealerAviation_2 = @DealerAviation_2
		, DealerAviation_3 = @DealerAviation_3
		, DealerAviation_4 = @DealerAviation_4
		, DealerAviation_5 = @DealerAviation_5
		, DealerAviation_6 = @DealerAviation_6
		, DealerAviation_7 = @DealerAviation_7
		, DealerAviation_8 = @DealerAviation_8
		, DealerAviation_9 = @DealerAviation_9
		, DealerAviation_10 = @DealerAviation_10
		, DealerAviation_11 = @DealerAviation_11

		, DealerJet_1 = @DealerJet_1
		, DealerJet_2 = @DealerJet_2
		, DealerJet_3 = @DealerJet_3
		, DealerJet_4 = @DealerJet_4
		, DealerJet_5 = @DealerJet_5
		, DealerJet_6 = @DealerJet_6
		, DealerJet_7 = @DealerJet_7
		, DealerJet_8 = @DealerJet_8
		, DealerJet_9 = @DealerJet_9
		, DealerJet_10 = @DealerJet_10
		, DealerJet_11 = @DealerJet_11

		, DealerEthanol_1 = @DealerEthanol_1
		, DealerEthanol_2 = @DealerEthanol_2
		, DealerEthanol_3 = @DealerEthanol_3
		, DealerEthanol_4 = @DealerEthanol_4
		, DealerEthanol_5 = @DealerEthanol_5
		, DealerEthanol_6 = @DealerEthanol_6

		, DealerDiesel_1 = @DealerDiesel_1
		, DealerDiesel_2 = @DealerDiesel_2
		, DealerDiesel_3 = @DealerDiesel_3
		, DealerDiesel_4 = @DealerDiesel_4
		, DealerDiesel_5 = @DealerDiesel_5
		, DealerDiesel_6 = @DealerDiesel_6

		, DealerTotal_11 = @DealerTotal_11
		, DealerTotal_12 = @DealerTotal_12
		, DealerTotal_13 = @DealerTotal_13
		, DealerTotal_14 = @DealerTotal_14
		, DealerTotal_15 = @DealerTotal_15
		, DealerTotal_16 = @DealerTotal_16

		, ReceiptGasoline_1 = @ReceiptGasoline_1
		, ReceiptGasoline_2 = @ReceiptGasoline_2
		, ReceiptGasoline_3 = @ReceiptGasoline_3
		, ReceiptGasoline_4 = @ReceiptGasoline_4
		, ReceiptGasoline_5 = @ReceiptGasoline_5
		, ReceiptGasoline_6 = @ReceiptGasoline_6

		, DisbursementGasoline_7 = @DisbursementGasoline_7
		, DisbursementGasoline_8 = @DisbursementGasoline_8
		, DisbursementGasoline_9 = @DisbursementGasoline_9
		, DisbursementGasoline_10 = @DisbursementGasoline_10
		, DisbursementGasoline_11 = @DisbursementGasoline_11
		, DisbursementGasoline_12 = @DisbursementGasoline_12

		, ReceiptAviation_1 = @ReceiptAviation_1
		, ReceiptAviation_2 = @ReceiptAviation_2
		, ReceiptAviation_3 = @ReceiptAviation_3
		, ReceiptAviation_4 = @ReceiptAviation_4
		, ReceiptAviation_5 = @ReceiptAviation_5
		, ReceiptAviation_6 = @ReceiptAviation_6

		, DisbursementAviation_7 = @DisbursementAviation_7
		, DisbursementAviation_8 = @DisbursementAviation_8
		, DisbursementAviation_9 = @DisbursementAviation_9
		, DisbursementAviation_10 = @DisbursementAviation_10
		, DisbursementAviation_11 = @DisbursementAviation_11
		, DisbursementAviation_12 = @DisbursementAviation_12

		, ReceiptJet_1 = @ReceiptJet_1
		, ReceiptJet_2 = @ReceiptJet_2
		, ReceiptJet_3 = @ReceiptJet_3
		, ReceiptJet_4 = @ReceiptJet_4
		, ReceiptJet_5 = @ReceiptJet_5
		, ReceiptJet_6 = @ReceiptJet_6

		, DisbursementJet_7 = @DisbursementJet_7
		, DisbursementJet_8 = @DisbursementJet_8
		, DisbursementJet_9 = @DisbursementJet_9
		, DisbursementJet_10 = @DisbursementJet_10
		, DisbursementJet_11 = @DisbursementJet_11
		, DisbursementJet_12 = @DisbursementJet_12

		, ReceiptEthanol_1 = @ReceiptEthanol_1
		, ReceiptEthanol_3 = @ReceiptEthanol_3
		, ReceiptEthanol_4 = @ReceiptEthanol_4
		, ReceiptEthanol_5 = @ReceiptEthanol_5
		, ReceiptEthanol_6 = @ReceiptEthanol_6

		, DisbursementEthanol_8 = @DisbursementEthanol_8
		, DisbursementEthanol_9 = @DisbursementEthanol_9
		, DisbursementEthanol_10 = @DisbursementEthanol_10
		, DisbursementEthanol_11 = @DisbursementEthanol_11
		, DisbursementEthanol_12 = @DisbursementEthanol_12

		, ReceiptDiesel_1 = @ReceiptDiesel_1
		, ReceiptDiesel_3 = @ReceiptDiesel_3
		, ReceiptDiesel_4 = @ReceiptDiesel_4
		, ReceiptDiesel_5 = @ReceiptDiesel_5
		, ReceiptDiesel_6 = @ReceiptDiesel_6

		, DisbursementDiesel_8 = @DisbursementDiesel_8
		, DisbursementDiesel_9 = @DisbursementDiesel_9
		, DisbursementDiesel_10 = @DisbursementDiesel_10
		, DisbursementDiesel_11 = @DisbursementDiesel_11
		, DisbursementDiesel_12 = @DisbursementDiesel_12


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