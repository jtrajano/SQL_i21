CREATE PROCEDURE [dbo].[uspRKFutOptTransactionHistory] 
	 @intFutOptTransactionId INT = NULL
	,@intFutOptTransactionHeaderId INT = NULL
	,@strScreenName NVARCHAR(100) = NULL
	,@intUserId INT = NULL
	,@action NVARCHAR(20)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strUserName NVARCHAR(100)
		,@intOldNoOfContract INT
		,@strOldBuySell NVARCHAR(10)

	--SELECT TOP 1 @intOldNoOfContract = intNewNoOfContract
	--	,@strOldBuySell = strNewBuySell
	--FROM [tblRKFutOptTransactionHistory]
	--WHERE intFutOptTransactionId = @intFutOptTransactionId
	--ORDER BY intFutOptTransactionHistoryId DESC

	IF @action = 'HEADER DELETE' --This scenario is when you delete the entire derivative entry. It will look for the history table to insert delete entry to those transaction that doesn't have. 
	BEGIN
		INSERT INTO tblRKFutOptTransactionHistory
           (intFutOptTransactionHeaderId
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
           ,intOldNoOfContract
           ,intNewNoOfContract
           ,intBalanceContract
           ,strScreenName
           ,strOldBuySell
           ,strNewBuySell
           ,dtmTransactionDate
           ,strUserName
		   ,strAction)
		SELECT 
			 H.intFutOptTransactionHeaderId
			,H.strSelectedInstrumentType
			,T.intFutOptTransactionId
			,strInternalTradeNo
		    ,strLocationName=(select TOP 1 strLocationName from tblSMCompanyLocation where intLocationId=T.intLocationId)
			,dblContractSize=(select TOP 1 dblContractSize from tblRKFutureMarket where intFutureMarketId=T.intFutureMarketId)
			,strInstrumentType = (CASE WHEN intInstrumentTypeId = 1 THEN 'Futures'
				WHEN intInstrumentTypeId = 2 THEN 'Options'
				WHEN intInstrumentTypeId = 3 THEN 'Currency Contract'
				ELSE ''
			 END)
			,strFutureMarket = (SELECT TOP 1 strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId = T.intFutureMarketId)
			,strCurrency = (SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = T.intCurrencyId)
			,strCommodity = (SELECT TOP 1 strCommodityCode FROM tblICCommodity WHERE intCommodityId = T.intCommodityId)
			,strBroker = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = T.intEntityId)
			,strBrokerAccount = (SELECT TOP 1 strAccountNumber FROM tblRKBrokerageAccount WHERE intBrokerageAccountId = T.intBrokerageAccountId)
			,strTrader = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = T.intTraderId)
			,strBrokerTradeNo
			,strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId = T.intFutureMonthId)
			,strOptionMonth = (SELECT TOP 1 strOptionMonth FROM tblRKOptionsMonth WHERE intOptionMonthId = T.intOptionMonthId)
			,strOptionType
			,dblStrike
			,dblPrice
			,strStatus
			,dtmFilledDate
			,NULL--intOldNoOfContract
			,0
			,0
			,@strScreenName
			,NULL
			,T.strBuySell
			,GETDATE()
			,strUserName = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @intUserId)
			,'DELETE'
		FROM 
			tblRKFutOptTransaction T
		INNER JOIN tblRKFutOptTransactionHeader H on T.intFutOptTransactionHeaderId = H.intFutOptTransactionHeaderId
		WHERE T.intFutOptTransactionId IN (
			SELECT DISTINCT intFutOptTransactionId FROM (
				SELECT DISTINCT intFutOptTransactionId, strAction FROM tblRKFutOptTransactionHistory
				WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
				and intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKFutOptTransactionHistory WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId AND strAction = 'DELETE')
			) tbl
		)	--This filter will look into the history table to check entries that does not have delete entry.
	END
	ELSE
	-- Create the entry for Derivative Entry History
		INSERT INTO tblRKFutOptTransactionHistory
           (intFutOptTransactionHeaderId
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
           ,intOldNoOfContract
           ,intNewNoOfContract
           ,intBalanceContract
           ,strScreenName
           ,strOldBuySell
           ,strNewBuySell
           ,dtmTransactionDate
           ,strUserName
		   ,strAction)
		SELECT 
			 H.intFutOptTransactionHeaderId
			,H.strSelectedInstrumentType
			,T.intFutOptTransactionId
			,strInternalTradeNo
		    ,strLocationName=(select TOP 1 strLocationName from tblSMCompanyLocation where intLocationId=T.intLocationId)
			,dblContractSize=(select TOP 1 dblContractSize from tblRKFutureMarket where intFutureMarketId=T.intFutureMarketId)
			,strInstrumentType = (CASE WHEN intInstrumentTypeId = 1 THEN 'Futures'
				WHEN intInstrumentTypeId = 2 THEN 'Options'
				WHEN intInstrumentTypeId = 3 THEN 'Currency Contract'
				ELSE ''
			 END)
			,strFutureMarket = (SELECT TOP 1 strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId = T.intFutureMarketId)
			,strCurrency = (SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = T.intCurrencyId)
			,strCommodity = (SELECT TOP 1 strCommodityCode FROM tblICCommodity WHERE intCommodityId = T.intCommodityId)
			,strBroker = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = T.intEntityId)
			,strBrokerAccount = (SELECT TOP 1 strAccountNumber FROM tblRKBrokerageAccount WHERE intBrokerageAccountId = T.intBrokerageAccountId)
			,strTrader = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = T.intTraderId)
			,strBrokerTradeNo
			,strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId = T.intFutureMonthId)
			,strOptionMonth = (SELECT TOP 1 strOptionMonth FROM tblRKOptionsMonth WHERE intOptionMonthId = T.intOptionMonthId)
			,strOptionType
			,dblStrike
			,dblPrice
			,strStatus
			,dtmFilledDate
			,NULL--intOldNoOfContract
			,intNewNoOfContract = (CASE WHEN @action = 'DELETE' THEN 0 ELSE T.intNoOfContract END)
			,intBalanceContract = (CASE WHEN @action = 'DELETE' THEN 0 ELSE T.intNoOfContract END)
			,@strScreenName
			,NULL
			,T.strBuySell
			,GETDATE()
			,strUserName = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @intUserId)
			,@action
		FROM 
			tblRKFutOptTransaction T
		INNER JOIN tblRKFutOptTransactionHeader H on T.intFutOptTransactionHeaderId = H.intFutOptTransactionHeaderId
		WHERE T.intFutOptTransactionId = @intFutOptTransactionId
	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH