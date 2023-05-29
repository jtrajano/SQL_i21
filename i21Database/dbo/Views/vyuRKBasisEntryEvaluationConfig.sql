CREATE VIEW [dbo].[vyuRKBasisEntryEvaluationConfig]
AS
SELECT TOP 1 
	  intCompanyPreferenceId = rk.intCompanyPreferenceId
	, ysnIncludeProductInformation = rk.ysnIncludeProductInformation
	, ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = rk.ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell
	, ysnEnterForwardCurveForMarketBasisDifferential = rk.ysnEnterForwardCurveForMarketBasisDifferential
	, strEvaluationBy = rk.strEvaluationBy
	, ysnEvaluationByLocation = rk.ysnEvaluationByLocation
	, ysnEvaluationByMarketZone = rk.ysnEvaluationByMarketZone
	, ysnEvaluationByOriginPort = rk.ysnEvaluationByOriginPort
	, ysnEvaluationByDestinationPort = rk.ysnEvaluationByDestinationPort
	, ysnEvaluationByCropYear = rk.ysnEvaluationByCropYear
	, ysnEvaluationByStorageLocation = rk.ysnEvaluationByStorageLocation
	, ysnEvaluationByStorageUnit = rk.ysnEvaluationByStorageUnit
	, ysnEnableMTMPoint = ct.ysnEnableMTMPoint 
FROM tblRKCompanyPreference rk
OUTER APPLY (
	SELECT TOP 1 
		ysnEnableMTMPoint
	FROM tblCTCompanyPreference
) ct