CREATE VIEW [dbo].[vyuRKM2MBasisForNotMapping]

AS

SELECT 
	  basis.intM2MBasisId
	, basis.dtmM2MBasisDate
	, basis.strPricingType
	, basis.intConcurrencyId
	, basis.intCompanyId
	, basis.intM2MBasisRefId
	, ysnEvaluationByLocation = ISNULL(companyConfig.ysnEvaluationByLocation, CAST(0 AS BIT))
	, ysnEvaluationByMarketZone = ISNULL(companyConfig.ysnEvaluationByMarketZone , CAST(0 AS BIT))
	, ysnEvaluationByOriginPort = ISNULL(companyConfig.ysnEvaluationByOriginPort , CAST(0 AS BIT))
	, ysnEvaluationByDestinationPort = ISNULL(companyConfig.ysnEvaluationByDestinationPort, CAST(0 AS BIT))
	, ysnEvaluationByCropYear = ISNULL(companyConfig.ysnEvaluationByCropYear , CAST(0 AS BIT))
	, ysnEvaluationByStorageLocation = ISNULL(companyConfig.ysnEvaluationByStorageLocation , CAST(0 AS BIT))
	, ysnEvaluationByStorageUnit = ISNULL(companyConfig.ysnEvaluationByStorageUnit , CAST(0 AS BIT))
	, ysnIncludeProductInformation = ISNULL(companyConfig.ysnIncludeProductInformation , CAST(0 AS BIT))
	, ysnEnableMTMPoint = ISNULL(companyConfigCT.ysnEnableMTMPoint, CAST(0 AS BIT))
FROM tblRKM2MBasis basis
OUTER APPLY (
	SELECT TOP 1 
			ysnEvaluationByLocation 
		, ysnEvaluationByMarketZone 
		, ysnEvaluationByOriginPort 
		, ysnEvaluationByDestinationPort 
		, ysnEvaluationByCropYear 
		, ysnEvaluationByStorageLocation 
		, ysnEvaluationByStorageUnit 
		, ysnIncludeProductInformation
	FROM tblRKCompanyPreference
) companyConfig
OUTER APPLY (
	SELECT TOP 1 
		  ysnEnableMTMPoint
	FROM tblCTCompanyPreference
) companyConfigCT