CREATE FUNCTION [dbo].[fnFAGetAssetExport]
(
	@intAssetId INT
)
RETURNS  @tbl TABLE(
	strBook NVARCHAR(100),
	strLedger NVARCHAR(255),
	strDepreciationMethodId NVARCHAR(50),
	dtmPlacedInService VARCHAR(20),
	dblCost NUMERIC(18, 6),
	strCurrency NVARCHAR(40),
	strCurrencyExchangeRateType NVARCHAR(100),
	dblRate NUMERIC(18, 6),
	dblSalvageValue NUMERIC(18, 6),
	dblSection179 NUMERIC(18, 6),
	dblBonusDepreciation NUMERIC(18, 6),
	dblMarketValue NUMERIC(18, 6),
	dblInsuranceValue NUMERIC(18, 6),
	dtmImportDepThruDate VARCHAR(20)  ,
	dblImportDepreciationToDate NUMERIC(18, 6)
	
)
AS
BEGIN
	INSERT @tbl
	SELECT
		ISNULL(B.strBook, '')
		,ISNULL(L.strLedgerName, '')
		,ISNULL(DM.strDepreciationMethodId, '')
		,CONVERT(VARCHAR(20),BD.dtmPlacedInService,101)
		,BD.dblCost
		,ISNULL(C.strCurrency, '')
		,ISNULL(RT.strCurrencyExchangeRateType, '')
		,ISNULL(BD.dblRate, 1)
		,ISNULL(BD.dblSalvageValue, 0)
		,BD.dblSection179
		,BD.dblBonusDepreciation
		,BD.dblMarketValue
		,BD.dblInsuranceValue
		,CONVERT(VARCHAR(20),BD.dtmImportDepThruDate,101)  
		,BD.dblImportDepreciationToDate
	FROM tblFABookDepreciation BD
	LEFT JOIN tblFABook B ON B.intBookId = BD.intBookId
	LEFT JOIN tblGLLedger L ON L.intLedgerId = BD.intLedgerId
	LEFT JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = BD.intDepreciationMethodId
	LEFT JOIN tblSMCurrency C ON C.intCurrencyID = BD.intCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = BD.intCurrencyExchangeRateTypeId
	WHERE BD.intAssetId = @intAssetId

	RETURN
END
