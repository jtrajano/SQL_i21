-- --------------------------------------------------
-- Purpose: This script includes all the datafix needed after deployment of database 
-- --------------------------------------------------
-- Date Created: 01/31/2018
-- Created by: Smith de Jesus
-- --------------------------------------------------

print('/*******************  BEGIN Risk Management Data Fixes *******************/')


--This will migrate the data from tblRKFutureMarket to tblRKCommodityMarketMapping. This is related to this jira RM-735
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'RM data migration from Future Market to Commodity Market Mapping')
BEGIN

	UPDATE
    ComMarMap
	SET
		ComMarMap.strFutSymbol = FutMar.strFutSymbol,
		ComMarMap.intFutMonthsToOpen = FutMar.intFutMonthsToOpen,
		ComMarMap.intForecastWeeklyConsumption = 	FutMar.intForecastWeeklyConsumption,
		ComMarMap.intForecastWeeklyConsumptionUOMId = 	FutMar.intForecastWeeklyConsumptionUOMId,
		ComMarMap.ysnOptions = 	FutMar.ysnOptions,
		ComMarMap.ysnActive = 	FutMar.ysnActive,
		ComMarMap.dblContractSize = 	FutMar.dblContractSize,
		ComMarMap.intUnitMeasureId = 	FutMar.intUnitMeasureId,
		ComMarMap.intCurrencyId = 	FutMar.intCurrencyId,
		ComMarMap.ysnFutJan = 	FutMar.ysnFutJan,
		ComMarMap.ysnFutFeb = 	FutMar.ysnFutFeb,
		ComMarMap.ysnFutMar = 	FutMar.ysnFutMar,
		ComMarMap.ysnFutApr = 	FutMar.ysnFutApr,
		ComMarMap.ysnFutMay = 	FutMar.ysnFutMay,
		ComMarMap.ysnFutJun = 	FutMar.ysnFutJun,
		ComMarMap.ysnFutJul = 	FutMar.ysnFutJul,
		ComMarMap.ysnFutAug = 	FutMar.ysnFutAug,
		ComMarMap.ysnFutSep = 	FutMar.ysnFutSep,
		ComMarMap.ysnFutOct = 	FutMar.ysnFutOct,
		ComMarMap.ysnFutNov = 	FutMar.ysnFutNov,
		ComMarMap.ysnFutDec = 	FutMar.ysnFutDec,
		ComMarMap.strOptMarketName = 	FutMar.strOptMarketName,
		ComMarMap.intOptMonthsToOpen = 	FutMar.intOptMonthsToOpen,
		ComMarMap.strOptSymbol = 	FutMar.strOptSymbol,
		ComMarMap.ysnOptJan = 	FutMar.ysnOptJan,
		ComMarMap.ysnOptFeb = 	FutMar.ysnOptFeb,
		ComMarMap.ysnOptMar = 	FutMar.ysnOptMar,
		ComMarMap.ysnOptApr = 	FutMar.ysnOptApr,
		ComMarMap.ysnOptMay = 	FutMar.ysnOptMay,
		ComMarMap.ysnOptJun = 	FutMar.ysnOptJun,
		ComMarMap.ysnOptJul = 	FutMar.ysnOptJul,
		ComMarMap.ysnOptAug = 	FutMar.ysnOptAug,
		ComMarMap.ysnOptSep = 	FutMar.ysnOptSep,
		ComMarMap.ysnOptOct = 	FutMar.ysnOptOct,
		ComMarMap.ysnOptNov = 	FutMar.ysnOptNov,
		ComMarMap.ysnOptDec = 	FutMar.ysnOptDec,
		ComMarMap.intNoOfDecimal = 	FutMar.intNoOfDecimal,
		ComMarMap.intMarketExchangeId = 	FutMar.intMarketExchangeId,
		ComMarMap.strSymbolPrefix = 	FutMar.strSymbolPrefix,
		ComMarMap.dblConversionRate = 	FutMar.dblConversionRate,
		ComMarMap.intReturnCurrency = 	FutMar.intReturnCurrency,
		ComMarMap.intDisplayCurrency = 	FutMar.intDisplayCurrency,
		ComMarMap.strMarketSymbolCode = 	FutMar.strMarketSymbolCode,
		ComMarMap.strOptionSymbolPrefix = 	FutMar.strOptionSymbolPrefix
	FROM
		tblRKCommodityMarketMapping AS ComMarMap
		INNER JOIN tblRKFutureMarket AS FutMar
			ON ComMarMap.intFutureMarketId = FutMar.intFutureMarketId
	WHERE ComMarMap.strFutSymbol IS NULL 


	--We also need to adjust the Futures Month and Options Month since it is also affected of the change

	--For Futures Month
	UPDATE
	FM
	SET FM.intCommodityMarketId = ComMarMap.intCommodityMarketId
	FROM 
		tblRKFuturesMonth AS FM
		INNER JOIN tblRKCommodityMarketMapping AS ComMarMap
			ON FM.intFutureMarketId = ComMarMap.intFutureMarketId
	WHERE FM.intCommodityMarketId IS NULL

	--For Options Month
	UPDATE
	OM
	SET OM.intCommodityMarketId = ComMarMap.intCommodityMarketId
	FROM 
		tblRKOptionsMonth AS OM
		INNER JOIN tblRKCommodityMarketMapping AS ComMarMap
			ON OM.intFutureMarketId = ComMarMap.intFutureMarketId
	WHERE OM.intCommodityMarketId IS NULL



	--Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
	INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('RM data migration from Future Market to Commodity Market Mapping','1')
END


--This will fix all commission entry to include Commodity Market Id and Product Type.This is related to this jira RM-423 
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'RM data fix for Brokerage Commission')
BEGIN

	UPDATE
	BC
	SET BC.intCommodityMarketId = ComMarMap.intCommodityMarketId,
		BC.strProductType = ComMarMap.strCommodityAttributeId
	FROM 
		tblRKBrokerageCommission AS BC
		INNER JOIN tblRKCommodityMarketMapping AS ComMarMap
			ON BC.intFutureMarketId = ComMarMap.intFutureMarketId
	WHERE BC.intCommodityMarketId IS NULL

    --Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
    INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('RM data fix for Brokerage Commission','1')
END  

--This will fix  Future Settlement Price to include Commodity Market Id. This is related to this jira key RM-730
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'RM data fix for Future Settlement Price')
BEGIN

	
	UPDATE
	FSP
	SET FSP.intCommodityMarketId = ComMarMap.intCommodityMarketId
	FROM 
		tblRKFuturesSettlementPrice AS FSP
		INNER JOIN tblRKCommodityMarketMapping AS ComMarMap
			ON FSP.intFutureMarketId = ComMarMap.intFutureMarketId
	WHERE FSP.intCommodityMarketId IS NULL

    --Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
    INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('RM data fix for Future Settlement Price','1')
END   

-- Removes trailing comma (,) in tblRKCommodityMarketMapping.strCommodityAttributeId to avoid error in uspRKSyncCommodityMarketAttribute
UPDATE tblRKCommodityMarketMapping 
SET strCommodityAttributeId = SUBSTRING(RTRIM(strCommodityAttributeId),1,LEN(RTRIM(strCommodityAttributeId))-1)
FROM tblRKCommodityMarketMapping 
WHERE strCommodityAttributeId IS NOT NULL
AND RIGHT(RTRIM(strCommodityAttributeId),1) = ','

print('/*******************  END Risk Management Data Fixess *******************/')