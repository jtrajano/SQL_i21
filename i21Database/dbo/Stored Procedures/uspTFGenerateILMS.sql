CREATE PROCEDURE [dbo].[uspTFGenerateILMS]
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
			dtmBlendedDate DATE
			, dblPrimary_a NUMERIC
			, dblPrimary_b NUMERIC
			, dblPrimary_c NUMERIC
			, dblBlending_a NUMERIC
			, dblBlending_b NUMERIC
			, dblBlending_c NUMERIC
			, dblTotalEnd NUMERIC
			, dtmFromDate DATE
			, dtmToDate DATE)

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

		DECLARE @DateFrom DATETIME
		, @DateTo DATETIME
		, @TaxAuthorityId INT
		DECLARE @RawMaterialCode TABLE(
			intProductCodeId INT
		)

		SELECT TOP 1 @DateFrom = [from],  @DateTo = [to] FROM @Params WHERE [fieldname] = 'dtmDate'

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL'

		INSERT INTO @RawMaterialCode
		SELECT intProductCodeId
		FROM tblTFProductCode
		WHERE intTaxAuthorityId = @TaxAuthorityId
			AND strProductCode IN ('160', '228', '285', '145', '073', '999')

		INSERT INTO @Output
		SELECT 
			--Blend.intBlendTransactionId
			--, Blend.strBlendTransactionNo
			dtmBlendingDate = Blend.dtmBlendDate
			--, Blend.intPrimaryItemId
			--, Blend.strPrimaryItemNo
			--, strPrimaryProductColAProductCode = CASE WHEN PrimaryCode.strProductCode != '160' THEN NULL ELSE PrimaryCode.strProductCode END
			, dblPrimary_a = CASE WHEN PrimaryCode.strProductCode != '160' THEN NULL ELSE ROUND(Blend.dblPrimaryQty, 0) END 
			--, strPrimaryProductColBProductCode = CASE WHEN PrimaryCode.strProductCode != '228' THEN NULL ELSE PrimaryCode.strProductCode END
			, dblPrimary_b = CASE WHEN PrimaryCode.strProductCode != '228' THEN NULL ELSE ROUND(Blend.dblPrimaryQty, 0) END 
			--, strPrimaryProductColCProductCode = CASE WHEN PrimaryCode.strProductCode != '999' THEN NULL ELSE PrimaryCode.strProductCode END
			, dblPrimary_c = CASE WHEN PrimaryCode.strProductCode != '999' THEN NULL ELSE ROUND(Blend.dblPrimaryQty, 0) END 
			--, Blend.intBlendAgendItemId
			--, Blend.strBlendAgentItemNo
			--, strBlendingAgentColAProductCode = CASE WHEN AgentCode.strProductCode != '285' THEN NULL ELSE AgentCode.strProductCode END
			, dblBlending_a = CASE WHEN AgentCode.strProductCode != '285' THEN NULL ELSE ROUND(Blend.dblBlendAgentQty, 0) END 
			--, strBlendingAgentColBProductCode = CASE WHEN (AgentCode.strProductCode != '145' AND AgentCode.strProductCode != '073') THEN NULL ELSE AgentCode.strProductCode END
			, dblBlending_b = CASE WHEN (AgentCode.strProductCode != '145' AND AgentCode.strProductCode != '073') THEN NULL ELSE ROUND(Blend.dblBlendAgentQty, 0) END 
			--, strBlendingAgentColCProductCode = CASE WHEN AgentCode.strProductCode != '999' THEN NULL ELSE AgentCode.strProductCode END
			, dblBlending_c = CASE WHEN AgentCode.strProductCode != '999' THEN NULL ELSE ROUND(Blend.dblBlendAgentQty, 0) END 
			--, Blend.intFinishedGoodItemId
			--, Blend.strFinishedGoodItemNo
			--, strEndProductProductCode = FGCode.strProductCode
			, dblTotalEnd = ROUND(Blend.dblFinishedGoodQty, 0)
			, dtmFromDate = @DateFrom
			, dtmToDate = @DateTo
		FROM vyuMFGetBlendTransactions Blend
		INNER JOIN tblICItemMotorFuelTax PrimaryItem ON PrimaryItem.intItemId = Blend.intPrimaryItemId
		INNER JOIN tblTFProductCode PrimaryCode ON PrimaryCode.intProductCodeId = PrimaryItem.intProductCodeId
		INNER JOIN tblICItemMotorFuelTax AgentItem ON AgentItem.intItemId = Blend.intBlendAgendItemId
		INNER JOIN tblTFProductCode AgentCode ON AgentCode.intProductCodeId = AgentItem.intProductCodeId
		INNER JOIN tblICItemMotorFuelTax FGItem ON FGItem.intItemId = Blend.intFinishedGoodItemId
		INNER JOIN tblTFProductCode FGCode ON FGCode.intProductCodeId = FGItem.intProductCodeId
		WHERE CAST(FLOOR(CAST(Blend.dtmBlendDate AS FLOAT))AS DATETIME) >= CAST(FLOOR(CAST(@DateFrom AS FLOAT))AS DATETIME)
			AND CAST(FLOOR(CAST(Blend.dtmBlendDate AS FLOAT))AS DATETIME) <= CAST(FLOOR(CAST(@DateTo AS FLOAT))AS DATETIME)
			AND FGItem.intProductCodeId IN (SELECT intProductCodeId FROM tblTFProductCode
				WHERE intTaxAuthorityId = @TaxAuthorityId
					AND (strProductCode LIKE 'B%'
					OR strProductCode LIKE 'D%'
					OR strProductCode IN ('999')))
			AND PrimaryItem.intProductCodeId IN (SELECT intProductCodeId FROM @RawMaterialCode)
			AND AgentItem.intProductCodeId IN (SELECT intProductCodeId FROM @RawMaterialCode)

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
	);
END CATCH