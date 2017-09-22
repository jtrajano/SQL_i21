CREATE PROCEDURE [dbo].[uspTFGenerateILMG]
	@XMLParam NVARCHAR(MAX) = NULL

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

	DECLARE @Guid NVARCHAR(250)
	, @FormCodeParam NVARCHAR(MAX)
	, @ScheduleCodeParam NVARCHAR(MAX)
	, @ReportingComponentId NVARCHAR(MAX)
	, @Refresh BIT

	IF (ISNULL(@XMLParam,'') = '')
	BEGIN 
		SELECT dtmDate = GETDATE()
			, dblPrimary_a = 0.000000
			, dblPrimary_b = 0.000000
			, dblPrimary_c = 0.000000
			, dblBlending_a = 0.000000
			, dblBlending_b = 0.000000
			, dblBlending_c = 0.000000
		RETURN
	END
	ELSE
	BEGIN
		
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XMLParam
		
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

		SELECT TOP 1 @FormCodeParam = [from] FROM @Params WHERE [fieldname] = 'FormCodeParam'
		SELECT TOP 1 @ScheduleCodeParam = [from] FROM @Params WHERE [fieldname] = 'ScheduleCodeParam'
		SELECT TOP 1 @ReportingComponentId = [from] FROM @Params WHERE [fieldname] = 'ReportingComponentId'
		SELECT TOP 1 @Refresh = [from] FROM @Params WHERE [fieldname] = 'Refresh'

		DECLARE @DateFrom DATETIME
			, @DateTo DATETIME
			, @TaxAuthorityId INT

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL'
		SELECT intProductCodeId
			, strProductCode
		INTO #tmpFGCodes
		FROM tblTFProductCode
		WHERE intTaxAuthorityId = @TaxAuthorityId
			AND (strProductCode LIKE 'E%'
			OR strProductCode IN ('124', '999'))

		SELECT intProductCodeId
			, strProductCode
		INTO #tmpRawMaterialCode
		FROM tblTFProductCode
		WHERE intTaxAuthorityId = @TaxAuthorityId
			AND strProductCode IN ('065', 'E00', '123', '999')

		SELECT TOP 1 @DateFrom = [from], @DateTo = [to]  FROM @Params WHERE [fieldname] = 'Date'
		
		SELECT Blend.intBlendTransactionId
			, Blend.strBlendTransactionNo
			, dtmBlendingDate = Blend.dtmBlendDate
			, Blend.intPrimaryItemId
			, Blend.strPrimaryItemNo
			, strPrimaryProductColAProductCode = CASE WHEN PrimaryCode.strProductCode != '065' THEN NULL ELSE PrimaryCode.strProductCode END
			, intPrimaryProductColAGallons = CASE WHEN PrimaryCode.strProductCode != '065' THEN NULL ELSE ROUND(Blend.dblPrimaryQty, 0) END 
			, strPrimaryProductColBProductCode = CASE WHEN (PrimaryCode.strProductCode != 'E00' AND PrimaryCode.strProductCode != '123') THEN NULL ELSE PrimaryCode.strProductCode END
			, intPrimaryProductColBGallons = CASE WHEN (PrimaryCode.strProductCode != 'E00' AND PrimaryCode.strProductCode != '123') THEN NULL ELSE ROUND(Blend.dblPrimaryQty, 0) END 
			, strPrimaryProductColCProductCode = CASE WHEN PrimaryCode.strProductCode != '999' THEN NULL ELSE PrimaryCode.strProductCode END
			, intPrimaryProductColCGallons = CASE WHEN PrimaryCode.strProductCode != '999' THEN NULL ELSE ROUND(Blend.dblPrimaryQty, 0) END 
			, Blend.intBlendAgendItemId
			, Blend.strBlendAgentItemNo
			, strBlendingAgentColAProductCode = CASE WHEN AgentCode.strProductCode != '065' THEN NULL ELSE AgentCode.strProductCode END
			, intBlendingAgentColAGallons = CASE WHEN AgentCode.strProductCode != '065' THEN NULL ELSE ROUND(Blend.dblBlendAgentQty, 0) END 
			, strBlendingAgentColBProductCode = CASE WHEN (AgentCode.strProductCode != 'E00' AND AgentCode.strProductCode != '123') THEN NULL ELSE AgentCode.strProductCode END
			, intBlendingAgentColBGallons = CASE WHEN (AgentCode.strProductCode != 'E00' AND AgentCode.strProductCode != '123') THEN NULL ELSE ROUND(Blend.dblBlendAgentQty, 0) END 
			, strBlendingAgentColCProductCode = CASE WHEN AgentCode.strProductCode != '999' THEN NULL ELSE AgentCode.strProductCode END
			, intBlendingAgentColCGallons = CASE WHEN AgentCode.strProductCode != '999' THEN NULL ELSE ROUND(Blend.dblBlendAgentQty, 0) END 
			, Blend.intFinishedGoodItemId
			, Blend.strFinishedGoodItemNo
			, strEndProductProductCode = FGCode.strProductCode
			, intEndProductGallons = ROUND(Blend.dblFinishedGoodQty, 0)
		FROM vyuMFGetBlendTransactions Blend
		INNER JOIN tblICItemMotorFuelTax PrimaryItem ON PrimaryItem.intItemId = Blend.intPrimaryItemId
		INNER JOIN tblTFProductCode PrimaryCode ON PrimaryCode.intProductCodeId = PrimaryItem.intProductCodeId
		INNER JOIN tblICItemMotorFuelTax AgentItem ON AgentItem.intItemId = Blend.intBlendAgendItemId
		INNER JOIN tblTFProductCode AgentCode ON AgentCode.intProductCodeId = AgentItem.intProductCodeId
		INNER JOIN tblICItemMotorFuelTax FGItem ON FGItem.intItemId = Blend.intFinishedGoodItemId
		INNER JOIN tblTFProductCode FGCode ON FGCode.intProductCodeId = FGItem.intProductCodeId
		WHERE CAST(FLOOR(CAST(Blend.dtmBlendDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(Blend.dtmBlendDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND FGItem.intProductCodeId IN (SELECT intProductCodeId FROM #tmpFGCodes)
			AND (PrimaryItem.intProductCodeId IN (SELECT intProductCodeId FROM #tmpRawMaterialCode)
			OR AgentItem.intProductCodeId IN (SELECT intProductCodeId FROM #tmpRawMaterialCode))

		DROP TABLE #tmpFGCodes
		DROP TABLE #tmpRawMaterialCode

	END

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