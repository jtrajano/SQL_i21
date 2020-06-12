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

--This will fix all commission entry to set blank Futures Rate Type to Half-turn.This is related to this jira RM-3672
IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'RM data fix for Brokerage Commission Futures Rate Type')
BEGIN

	UPDATE tblRKBrokerageCommission
	SET intFuturesRateType = 2
	FROM
	tblRKBrokerageAccount BA
	INNER JOIN tblRKBrokerageCommission BC ON BC.intBrokerageAccountId = BA.intBrokerageAccountId
	WHERE BA.intInstrumentTypeId IN(1,3)
	AND BC.intFuturesRateType IS NULL

    --Insert into EM Preferences. This will serve as the checking if the datafix will be executed or not.
    INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('RM data fix for Brokerage Commission Futures Rate Type','1')
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
GO
-- Fix invalid accounts set in company preference (not in correct category)
UPDATE pref SET intUnrealizedGainOnBasisId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedGainOnBasisId AND strAccountCategory = 'Mark to Market P&L'
UPDATE pref SET intUnrealizedGainOnFuturesId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedGainOnFuturesId AND strAccountCategory = 'Mark to Market P&L'
UPDATE pref SET intUnrealizedGainOnCashId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedGainOnCashId AND strAccountCategory = 'Mark to Market P&L'
UPDATE pref SET intUnrealizedLossOnBasisId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedLossOnBasisId AND strAccountCategory = 'Mark to Market P&L'
UPDATE pref SET intUnrealizedLossOnFuturesId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedLossOnFuturesId AND strAccountCategory = 'Mark to Market P&L'
UPDATE pref SET intUnrealizedLossOnCashId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedLossOnCashId AND strAccountCategory = 'Mark to Market P&L'
UPDATE pref SET intUnrealizedGainOnInventoryBasisIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedGainOnInventoryBasisIOSId AND strAccountCategory = 'Mark to Market Offset'
UPDATE pref SET intUnrealizedGainOnInventoryFuturesIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedGainOnInventoryFuturesIOSId AND strAccountCategory = 'Mark to Market Offset'
UPDATE pref SET intUnrealizedGainOnInventoryCashIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedGainOnInventoryCashIOSId AND strAccountCategory = 'Mark to Market Offset'
UPDATE pref SET intUnrealizedLossOnInventoryBasisIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedLossOnInventoryBasisIOSId AND strAccountCategory = 'Mark to Market Offset'
UPDATE pref SET intUnrealizedLossOnInventoryFuturesIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedLossOnInventoryFuturesIOSId AND strAccountCategory = 'Mark to Market Offset'
UPDATE pref SET intUnrealizedLossOnInventoryCashIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedLossOnInventoryCashIOSId AND strAccountCategory = 'Mark to Market Offset'
UPDATE pref SET intUnrealizedGainOnInventoryIntransitIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedGainOnInventoryIntransitIOSId AND strAccountCategory = 'Mark to Market Offset'
UPDATE pref SET intUnrealizedLossOnInventoryIntransitIOSId= GL.intAccountId FROM tblRKCompanyPreference pref LEFT JOIN vyuGLAccountDetail GL on GL.intAccountId=pref.intUnrealizedLossOnInventoryIntransitIOSId AND strAccountCategory = 'Mark to Market Offset'
GO
--REMOVES TRAILING COMMA (,) IN tblRKCommodityMarketMapping.strCommodityAttributeId TO AVOID ERROR IN uspRKSyncCommodityMarketAttribute
UPDATE tblRKCommodityMarketMapping 
SET strCommodityAttributeId = SUBSTRING(RTRIM(strCommodityAttributeId),1,LEN(RTRIM(strCommodityAttributeId))-1)
FROM tblRKCommodityMarketMapping 
WHERE strCommodityAttributeId IS NOT NULL
AND RIGHT(RTRIM(strCommodityAttributeId),1) = ','
GO

--- Cleaned up/delete the account ids in the GL Account Set up of Risk Management for 18.1 Customer  RM-1312
IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
BEGIN 
	UPDATE tblRKCompanyPreference
	SET intUnrealizedGainOnBasisId = NULL
		,intUnrealizedGainOnFuturesId = NULL
		,intUnrealizedGainOnCashId = NULL
		,intUnrealizedGainOnRatioId = NULL
		,intUnrealizedLossOnBasisId = NULL
		,intUnrealizedLossOnFuturesId = NULL
		,intUnrealizedLossOnCashId = NULL
		,intUnrealizedLossOnRatioId = NULL
		,intUnrealizedGainOnInventoryBasisIOSId = NULL
		,intUnrealizedGainOnInventoryFuturesIOSId = NULL
		,intUnrealizedGainOnInventoryCashIOSId = NULL
		,intUnrealizedGainOnInventoryRatioIOSId = NULL
		,intUnrealizedLossOnInventoryBasisIOSId = NULL
		,intUnrealizedLossOnInventoryFuturesIOSId = NULL
		,intUnrealizedLossOnInventoryCashIOSId = NULL
		,intUnrealizedLossOnInventoryRatioIOSId = NULL
		,intUnrealizedGainOnInventoryIntransitIOSId = NULL
		,intUnrealizedLossOnInventoryIntransitIOSId = NULL
END 
GO

---- Update all NULL dblNoOfContract in tblRKFutOptTransaction before inserting it to tblRKFutOptTransactionHistory ------ RM-2563
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblRKFutOptTransaction') 
BEGIN
	UPDATE tblRKFutOptTransaction 
	SET dblNoOfContract = 0
	WHERE dblNoOfContract IS NULL
END

---- Insert previously created Derivative Entry to tblRKFutOptTransactionHistory ------ RM-2563
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblRKFutOptTransaction') 
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblRKFutOptTransactionHistory')
BEGIN
	INSERT INTO tblRKFutOptTransactionHistory(intFutOptTransactionHeaderId
		,strSelectedInstrumentType
		,intFutOptTransactionId
		,strInternalTradeNo
		,strLocationName
		,dblContractSize
		,strInstrumentType
		,strFutureMarket
		,strCurrency
		,strCommodity
		,strBroker
		,strBrokerAccount
		,strTrader
		,strBrokerTradeNo
		,strFutureMonth
		,strOptionMonth
		,strOptionType
		,dblStrike
		,dblPrice
		,strStatus
		,dtmFilledDate
		,dblOldNoOfContract
		,dblNewNoOfContract
		,dblBalanceContract
		,strScreenName
		,strOldBuySell
		,strNewBuySell
		,dtmTransactionDate
		,intBookId
		,intSubBookId
		,ysnMonthExpired
		,strUserName
		,strAction)
	SELECT FOTH.intFutOptTransactionHeaderId
		,FOTH.strSelectedInstrumentType
		,FOT.intFutOptTransactionId
		,FOT.strInternalTradeNo
		,strLocationName = (SELECT TOP 1 strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = FOT.intLocationId)
		,dblContractSize = (SELECT TOP 1 dblContractSize FROM tblRKFutureMarket WHERE intFutureMarketId = FOT.intFutureMarketId)
		,strInstrumentType = (CASE WHEN intInstrumentTypeId = 1 THEN 'Futures'
				WHEN intInstrumentTypeId = 2 THEN 'Options'
				WHEN intInstrumentTypeId = 3 THEN 'Currency Contract'
				ELSE ''
			END)
		,strFutureMarket = (SELECT TOP 1 strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId = FOT.intFutureMarketId)
		,strCurrency = (SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = FOT.intCurrencyId)
		,strCommodity = (SELECT TOP 1 strCommodityCode FROM tblICCommodity WHERE intCommodityId = FOT.intCommodityId)
		,strBroker = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = FOT.intEntityId)
		,strBrokerAccount = (SELECT TOP 1 strAccountNumber FROM tblRKBrokerageAccount WHERE intBrokerageAccountId = FOT.intBrokerageAccountId)
		,strTrader = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = FOT.intTraderId)
		,strBrokerTradeNo
		,strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId = FOT.intFutureMonthId)
		,strOptionMonth = (SELECT TOP 1 strOptionMonth FROM tblRKOptionsMonth WHERE intOptionMonthId = FOT.intOptionMonthId)
		,strOptionType
		,dblStrike
		,dblPrice
		,strStatus
		,dtmFilledDate
		,NULL
		,dblNewNoOfContract = FOT.dblNoOfContract
		,dblBalanceContract = FOT.dblNoOfContract
		,'FutOptTransaction'
		,NULL
		,FOT.strBuySell
		,FOT.dtmTransactionDate
		,intBookId
		,intSubBookId
		,ysnMonthExpired = (SELECT TOP 1 ysnExpired FROM tblRKFuturesMonth a WHERE a.intFutureMonthId = FOT.intFutureMonthId)
		,strUserName = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = FOT.intEntityId)
		,'ADD'
	FROM tblRKFutOptTransaction FOT
	INNER JOIN tblRKFutOptTransactionHeader FOTH on FOT.intFutOptTransactionHeaderId = FOTH.intFutOptTransactionHeaderId
	WHERE FOT.intFutOptTransactionId NOT IN(
		SELECT DISTINCT intFutOptTransactionId FROM tblRKFutOptTransactionHistory
	)
END
GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKFutOptTransactionHistory' AND COLUMN_NAME = 'ysnPreCrush')
BEGIN
	UPDATE tblRKFutOptTransactionHistory
	SET ysnPreCrush = ISNULL(tblRKFutOptTransaction.ysnPreCrush, 0)
	FROM tblRKFutOptTransaction
	WHERE tblRKFutOptTransaction.intFutOptTransactionId = tblRKFutOptTransactionHistory.intFutOptTransactionId
END

GO

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKMatchDerivativesHistory')
BEGIN
	INSERT INTO tblRKMatchDerivativesHistory
	SELECT psd.intMatchFuturesPSHeaderId
		, intMatchFuturesPSDetailId
		, dblMatchQty
		, dtmMatchDate
		, dblFutCommission
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, dtmMatchDate
		, strUserName = 'irelyadmin'
	FROM tblRKMatchFuturesPSDetail psd
	LEFT JOIN tblRKMatchFuturesPSHeader psh ON psh.intMatchFuturesPSHeaderId = psd.intMatchFuturesPSHeaderId
	WHERE intLFutOptTransactionId NOT IN (SELECT intLFutOptTransactionId FROM tblRKMatchDerivativesHistory)
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKM2MConfiguration' AND COLUMN_NAME = 'intFreightTermId')
BEGIN
	UPDATE tblRKM2MConfiguration
	SET intFreightTermId = tblPatch.intFreightTermId
	FROM (
		SELECT FT.*
			, CB.intContractBasisId
		FROM tblCTContractBasis CB
		JOIN tblSMFreightTerms FT ON FT.strContractBasis = CB.strContractBasis
	) tblPatch 
	WHERE tblPatch.intContractBasisId = tblRKM2MConfiguration.intContractBasisId
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKFutOptTransactionHistory' AND COLUMN_NAME = 'dtmTransactionDate')
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKFutOptTransaction' AND COLUMN_NAME = 'dtmTransactionDate')
	BEGIN
		UPDATE tblRKFutOptTransactionHistory
		SET dtmTransactionDate = tblPatch.dtmTransactionDate
		FROM (
			SELECT * FROM tblRKFutOptTransaction
		) tblPatch
		WHERE tblPatch.intFutOptTransactionId = tblRKFutOptTransactionHistory.intFutOptTransactionId
		AND strAction = 'ADD'
		AND tblPatch.dtmTransactionDate != tblRKFutOptTransactionHistory.dtmTransactionDate
	END
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKCompanyPreference' AND COLUMN_NAME = 'ysnIncludeDerivatives')
BEGIN
	UPDATE tblRKCompanyPreference
	SET ysnIncludeDerivatives = 1
	WHERE ysnIncludeDerivatives IS NULL
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKCompanyPreference' AND COLUMN_NAME = 'intPostToGLId')
BEGIN
	UPDATE tblRKCompanyPreference
	SET intPostToGLId = 1
	WHERE ISNULL(intPostToGLId, 0) = 0
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKCompanyPreference' AND COLUMN_NAME = 'strRiskView')
BEGIN
	ALTER TABLE tblRKCompanyPreference DROP COLUMN strRiskView
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKM2MInquiryBasisDetail' AND COLUMN_NAME = 'intM2MBasisDetailId')
BEGIN
	UPDATE tblRKM2MInquiryBasisDetail
	SET intM2MBasisDetailId  = tblPatch.intM2MBasisDetailId
	FROM (
		SELECT ibd.intM2MInquiryBasisDetailId
			, bd.intM2MBasisDetailId
		FROM tblRKM2MInquiryBasisDetail ibd
		JOIN tblRKM2MInquiry inq ON inq.intM2MInquiryId = ibd.intM2MInquiryId
		JOIN tblRKM2MBasisDetail bd ON bd.intM2MBasisId = inq.intM2MBasisId
			AND ISNULL(bd.intCommodityId, 0) = ISNULL(ibd.intCommodityId, 0)
			AND ISNULL(bd.intItemId, 0) = ISNULL(ibd.intItemId, 0)
			AND ISNULL(bd.strOriginDest, '') = ISNULL(ibd.strOriginDest, '')
			AND ISNULL(bd.intFutureMarketId, 0) = ISNULL(ibd.intFutureMarketId, 0)
			AND ISNULL(bd.intFutureMonthId, 0) = ISNULL(ibd.intFutureMonthId, 0)
			AND ISNULL(bd.strPeriodTo, '') = ISNULL(ibd.strPeriodTo, '')
			AND ISNULL(bd.intCompanyLocationId, 0) = ISNULL(ibd.intCompanyLocationId, 0)
			AND ISNULL(bd.intMarketZoneId, 0) = ISNULL(ibd.intMarketZoneId, 0)
			AND ISNULL(bd.strContractInventory, 0) = ISNULL(ibd.strContractInventory, 0)
		WHERE ibd.intM2MBasisDetailId IS NULL
	) tblPatch
	WHERE tblPatch.intM2MInquiryBasisDetailId = tblRKM2MInquiryBasisDetail.intM2MInquiryBasisDetailId
END

print('/*******************  END Risk Management Data Fixess *******************/')
GO
