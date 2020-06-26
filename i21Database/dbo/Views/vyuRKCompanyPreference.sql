CREATE VIEW vyuRKCompanyPreference

AS

SELECT A.*
	, C.strInterfaceSystem
	, D.strCurrency
	, GL1.strAccountId strUnrealizedGainOnBasisId
	, GL2.strAccountId strUnrealizedGainOnFuturesId
	, GL3.strAccountId strUnrealizedGainOnCashId
	, GL4.strAccountId strUnrealizedLossOnBasisId
	, GL5.strAccountId strUnrealizedLossOnFuturesId
	, GL6.strAccountId strUnrealizedLossOnCashId
	, GL7.strAccountId strUnrealizedGainOnInventoryBasisIOSId
	, GL8.strAccountId strUnrealizedGainOnInventoryFuturesIOSId
	, GL9.strAccountId strUnrealizedGainOnInventoryCashIOSId
	, GL10.strAccountId strUnrealizedLossOnInventoryBasisIOSId
	, GL11.strAccountId strUnrealizedLossOnInventoryFuturesIOSId
	, GL12.strAccountId strUnrealizedLossOnInventoryCashIOSId
	, GL13.strAccountId strUnrealizedGainOnInventoryIntransitIOSId
	, GL14.strAccountId strUnrealizedLossOnInventoryIntransitIOSId
	, GL15.strAccountId strUnrealizedGainOnRatioId
	, GL16.strAccountId strUnrealizedLossOnRatioId
	, GL17.strAccountId strUnrealizedGainOnInventoryRatioIOSId
	, GL18.strAccountId strUnrealizedLossOnInventoryRatioIOSId
	, GL19.strAccountId strUnrealizedGainOnInventoryIOSId
	, GL20.strAccountId strUnrealizedLossOnInventoryIOSId
	, GL21.strAccountId strFuturesGainOrLossRealizedId
	, GL22.strAccountId strFuturesGainOrLossRealizedOffsetId
	, strDefaultInstrument = CASE WHEN intDefaultInstrumentId = 1 THEN 'Exchange Traded'
								WHEN intDefaultInstrumentId = 2 THEN 'OTC'
								WHEN intDefaultInstrumentId = 3 THEN 'OTC - Others' END COLLATE Latin1_General_CI_AS
	, strDefaultInstrumentType = CASE WHEN intDefaultInstrumentTypeId = 1 THEN 'Futures'
									WHEN intDefaultInstrumentTypeId = 2 THEN 'Options'
									WHEN intDefaultInstrumentTypeId = 3 THEN 'Currency Contract' END COLLATE Latin1_General_CI_AS
	, strPostToGL = CASE WHEN intPostToGLId = 1 THEN 'Company Configurations'
						WHEN intPostToGLId = 2 THEN 'Commodity GL' END COLLATE Latin1_General_CI_AS
	, strMarkExpiredMonthPosition = CASE WHEN intMarkExpiredMonthPositionId = 1 THEN 'Validate Expired'
								WHEN intMarkExpiredMonthPositionId = 2 THEN 'Spot Month'
								WHEN intMarkExpiredMonthPositionId = 3 THEN 'Nearby by Roll' END COLLATE Latin1_General_CI_AS
	, rv.strRiskView
	, strTonnageUOM = UOM.strUnitMeasure
FROM tblRKCompanyPreference A
LEFT JOIN tblRKInterfaceSystem C ON C.intInterfaceSystemId = A.intInterfaceSystemId
LEFT JOIN tblSMCurrency D ON D.intCurrencyID = A.intCurrencyId
LEFT JOIN tblGLAccount GL1 ON GL1.intAccountId = A.intUnrealizedGainOnBasisId
LEFT JOIN tblGLAccount GL2 ON GL2.intAccountId = A.intUnrealizedGainOnFuturesId
LEFT JOIN tblGLAccount GL3 ON GL3.intAccountId = A.intUnrealizedGainOnCashId
LEFT JOIN tblGLAccount GL4 ON GL4.intAccountId = A.intUnrealizedLossOnBasisId
LEFT JOIN tblGLAccount GL5 ON GL5.intAccountId = A.intUnrealizedLossOnFuturesId
LEFT JOIN tblGLAccount GL6 ON GL6.intAccountId = A.intUnrealizedLossOnCashId
LEFT JOIN tblGLAccount GL7 ON GL7.intAccountId = A.intUnrealizedGainOnInventoryBasisIOSId
LEFT JOIN tblGLAccount GL8 ON GL8.intAccountId = A.intUnrealizedGainOnInventoryFuturesIOSId
LEFT JOIN tblGLAccount GL9 ON GL9.intAccountId = A.intUnrealizedGainOnInventoryCashIOSId
LEFT JOIN tblGLAccount GL10 ON GL10.intAccountId = A.intUnrealizedLossOnInventoryBasisIOSId
LEFT JOIN tblGLAccount GL11 ON GL11.intAccountId = A.intUnrealizedLossOnInventoryFuturesIOSId
LEFT JOIN tblGLAccount GL12 ON GL12.intAccountId = A.intUnrealizedLossOnInventoryCashIOSId
LEFT JOIN tblGLAccount GL13 ON GL13.intAccountId = A.intUnrealizedGainOnInventoryIntransitIOSId
LEFT JOIN tblGLAccount GL14 ON GL14.intAccountId = A.intUnrealizedLossOnInventoryIntransitIOSId
LEFT JOIN tblGLAccount GL15 ON GL15.intAccountId = A.intUnrealizedGainOnRatioId
LEFT JOIN tblGLAccount GL16 ON GL16.intAccountId = A.intUnrealizedLossOnRatioId
LEFT JOIN tblGLAccount GL17 ON GL17.intAccountId = A.intUnrealizedGainOnInventoryRatioIOSId
LEFT JOIN tblGLAccount GL18 ON GL18.intAccountId = A.intUnrealizedLossOnInventoryRatioIOSId
LEFT JOIN tblGLAccount GL19 ON GL19.intAccountId = A.intUnrealizedGainOnInventoryIOSId
LEFT JOIN tblGLAccount GL20 ON GL20.intAccountId = A.intUnrealizedLossOnInventoryIOSId
LEFT JOIN tblGLAccount GL21 ON GL21.intAccountId = A.intFuturesGainOrLossRealizedId
LEFT JOIN tblGLAccount GL22 ON GL22.intAccountId = A.intFuturesGainOrLossRealizedOffsetId
LEFT JOIN tblRKRiskView rv ON rv.intRiskViewId = A.intRiskViewId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = A.intTonnageUOMId