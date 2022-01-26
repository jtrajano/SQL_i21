CREATE PROCEDURE [dbo].[uspRKFutOptTransactionHistory]
	@intFutOptTransactionId INT = NULL
	, @intFutOptTransactionHeaderId INT = NULL
	, @strScreenName NVARCHAR(100) = NULL
	, @intUserId INT = NULL
	, @action NVARCHAR(20)
	, @ysnLogRiskSummary BIT = 1

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @strUserName NVARCHAR(100)
		, @strOldBuySell NVARCHAR(10)

	DECLARE @SummaryLog AS RKSummaryLog

	SELECT TOP 1 @strUserName = strName FROM tblEMEntity WHERE intEntityId = @intUserId

	-- Will not log risk summary when OTC instrument types.
	SELECT TOP 1 @ysnLogRiskSummary = CASE WHEN derh.strSelectedInstrumentType = 'OTC' THEN 0 ELSE @ysnLogRiskSummary END 
		FROM  tblRKFutOptTransaction der
		INNER JOIN tblRKFutOptTransactionHeader derh
			ON derh.intFutOptTransactionHeaderId = der.intFutOptTransactionHeaderId
		WHERE der.intFutOptTransactionId = @intFutOptTransactionId

	IF @action = 'HEADER DELETE' --This scenario is when you delete the entire derivative entry. It will look for the history table to insert delete entry to those transaction that doesn't have. 
	BEGIN
		INSERT INTO tblRKFutOptTransactionHistory (intFutOptTransactionHeaderId
			, strSelectedInstrumentType
			, intFutOptTransactionId
			, strInternalTradeNo
			, strLocationName
			, dblContractSize
			, strInstrumentType
			, strFutureMarket
			, strCurrency
			, strCommodity
			, strBroker
			, strBrokerAccount
			, strTrader
			, strBrokerTradeNo
			, strFutureMonth
			, strOptionMonth
			, strOptionType
			, dblStrike
			, dblPrice
			, strStatus
			, dtmFilledDate
			, dblOldNoOfContract
			, dblNewNoOfContract
			, dblBalanceContract
			, strScreenName
			, strOldBuySell
			, strNewBuySell
			, dtmTransactionDate
			, intBookId
			, intSubBookId
			, ysnMonthExpired
			, intBuyBankId
			, intBuyBankAccountId
			, intBankTransferId
			, dblFinanceForwardRate
			, dblContractRate
			, strOrderType
			, strUserName
			, strAction)
		SELECT H.intFutOptTransactionHeaderId
			, H.strSelectedInstrumentType
			, T.intFutOptTransactionId
			, strInternalTradeNo
		    , strLocationName = Loc.strLocationName
			, dblContractSize = FMarket.dblContractSize
			, strInstrumentType = (CASE WHEN T.intInstrumentTypeId = 1 THEN 'Futures'
										WHEN T.intInstrumentTypeId = 2 THEN 'Options'
										WHEN T.intInstrumentTypeId = 3 THEN 'Spot'
										WHEN T.intInstrumentTypeId = 4 THEN 'Forward'
										WHEN T.intInstrumentTypeId = 5 THEN 'Swap'
										ELSE '' END)
			, strFutureMarket = FMarket.strFutMarketName
			, strCurrency = Curr.strCurrency
			, strCommodity = Comm.strCommodityCode
			, strBroker = B.strName
			, strBrokerAccount = BA.strAccountNumber
			, strTrader = Trader.strName
			, strBrokerTradeNo
			, strFutureMonth = FMonth.strFutureMonth
			, strOptionMonth = OM.strOptionMonth
			, strOptionType
			, dblStrike
			, dblPrice
			, strStatus
			, dtmFilledDate
			, NULL
			, 0
			, 0
			, @strScreenName
			, NULL
			, T.strBuySell
			, GETDATE()
			, intBookId
			, intSubBookId
			, ysnMonthExpired = FMonth.ysnExpired
			, intBuyBankId
			, intBuyBankAccountId
			, intBankTransferId
			, dblFinanceForwardRate
			, dblContractRate
			, strOrderType = (CASE WHEN T.intOrderTypeId = 1 THEN 'GTC'
								   WHEN T.intOrderTypeId = 2 THEN 'Limit'
								   WHEN T.intOrderTypeId = 3 THEN 'Market'
								   ELSE '' END)
			, strUserName = @strUserName
			, 'DELETE'
		FROM tblRKFutOptTransaction T
		JOIN tblRKFutOptTransactionHeader H ON T.intFutOptTransactionHeaderId = H.intFutOptTransactionHeaderId
		LEFT JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = T.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = T.intFutureMonthId
		LEFT JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = T.intLocationId
		LEFT JOIN tblSMCurrency Curr ON Curr.intCurrencyID = T.intCurrencyId
		LEFT JOIN tblEMEntity B ON B.intEntityId = T.intEntityId
		LEFT JOIN tblEMEntity Trader ON Trader.intEntityId = T.intTraderId
		LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = T.intCommodityId
		LEFT JOIN tblRKBrokerageAccount BA ON BA.intBrokerageAccountId = T.intBrokerageAccountId
		LEFT JOIN tblRKOptionsMonth OM ON OM.intOptionMonthId = T.intOptionMonthId
		WHERE T.intFutOptTransactionId IN (
			SELECT DISTINCT intFutOptTransactionId FROM (
				SELECT DISTINCT intFutOptTransactionId, strAction FROM tblRKFutOptTransactionHistory
				WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
				and intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKFutOptTransactionHistory WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId AND strAction = 'DELETE')
			) tbl
		)	--This filter will look into the history table to check entries that does not have delete entry.


		IF (ISNULL(@ysnLogRiskSummary, 1) = 1)
		BEGIN
			IF (@action = 'DELETE')
			BEGIN
				INSERT INTO @SummaryLog(strTransactionType
					, intTransactionRecordId
					, dtmTransactionDate
					, ysnDelete
					, intUserId
					, strNotes)
				SELECT strTransactionType = 'Derivatives'
					, intTransactionRecordId = intFutOptTransactionId
					, dtmTransactionDate
					, ysnDelete = 1
					, intUserId = @intUserId
					, strNotes = 'Delete record'
				FROM tblRKFutOptTransaction
				WHERE intFutOptTransactionId IN (
					SELECT DISTINCT intFutOptTransactionId FROM (
						SELECT DISTINCT intFutOptTransactionId, strAction FROM tblRKFutOptTransactionHistory
						WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
						and intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKFutOptTransactionHistory WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId AND strAction = 'DELETE')
					) tbl
				)
			END
		END
	END
	ELSE
	BEGIN
		-- Create the entry for Derivative Entry History
		INSERT INTO tblRKFutOptTransactionHistory (intFutOptTransactionHeaderId
			, strSelectedInstrumentType
			, intFutOptTransactionId
			, strInternalTradeNo
			, strLocationName
			, dblContractSize
			, strInstrumentType
			, strFutureMarket
			, strCurrency
			, strCommodity
			, strBroker
			, strBrokerAccount
			, strTrader
			, strBrokerTradeNo
			, strFutureMonth
			, strOptionMonth
			, strOptionType
			, dblStrike
			, dblPrice
			, strStatus
			, dtmFilledDate
			, dblOldNoOfContract
			, dblNewNoOfContract
			, dblBalanceContract
			, strScreenName
			, strOldBuySell
			, strNewBuySell
			, dtmTransactionDate
			, intBookId
			, intSubBookId
			, ysnMonthExpired
			, intBuyBankId
			, intBuyBankAccountId
			, intBankTransferId
			, dblFinanceForwardRate
			, dblContractRate
			, strOrderType
			, strUserName
			, strAction)
		SELECT H.intFutOptTransactionHeaderId
			, H.strSelectedInstrumentType
			, T.intFutOptTransactionId
			, strInternalTradeNo
		    , strLocationName = Loc.strLocationName
			, dblContractSize = FMarket.dblContractSize
			, strInstrumentType = (CASE WHEN T.intInstrumentTypeId = 1 THEN 'Futures'
										WHEN T.intInstrumentTypeId = 2 THEN 'Options'
										WHEN T.intInstrumentTypeId = 3 THEN 'Spot'
										WHEN T.intInstrumentTypeId = 4 THEN 'Forward'
										WHEN T.intInstrumentTypeId = 5 THEN 'Swap'
										ELSE '' END)
			, strFutureMarket = FMarket.strFutMarketName
			, strCurrency = Curr.strCurrency
			, strCommodity = Comm.strCommodityCode
			, strBroker = B.strName
			, strBrokerAccount = BA.strAccountNumber
			, strTrader = Trader.strName
			, strBrokerTradeNo
			, strFutureMonth = FMonth.strFutureMonth
			, strOptionMonth = OM.strOptionMonth
			, strOptionType
			, dblStrike
			, dblPrice
			, strStatus
			, dtmFilledDate
			, NULL
			, dblNoOfContract = (CASE WHEN @action = 'DELETE' THEN 0 ELSE T.dblNoOfContract END)
			, dblBalanceContract = (CASE WHEN @action = 'DELETE' THEN 0 ELSE T.dblNoOfContract END)
			, @strScreenName
			, NULL
			, T.strBuySell
			, CASE WHEN @action = 'ADD' THEN T.dtmTransactionDate ELSE GETDATE() END
			, intBookId
			, intSubBookId
			, ysnMonthExpired = FMonth.ysnExpired
			, intBuyBankId
			, intBuyBankAccountId
			, intBankTransferId
			, dblFinanceForwardRate
			, dblContractRate
			, strOrderType = (CASE WHEN T.intOrderTypeId = 1 THEN 'GTC'
								   WHEN T.intOrderTypeId = 2 THEN 'Limit'
								   WHEN T.intOrderTypeId = 3 THEN 'Market'
								   ELSE '' END)
			, strUserName = @strUserName
			, @action
		FROM tblRKFutOptTransaction T
		JOIN tblRKFutOptTransactionHeader H on T.intFutOptTransactionHeaderId = H.intFutOptTransactionHeaderId
		LEFT JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = T.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = T.intFutureMonthId
		LEFT JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = T.intLocationId
		LEFT JOIN tblSMCurrency Curr ON Curr.intCurrencyID = T.intCurrencyId
		LEFT JOIN tblEMEntity B ON B.intEntityId = T.intEntityId
		LEFT JOIN tblEMEntity Trader ON Trader.intEntityId = T.intTraderId
		LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = T.intCommodityId
		LEFT JOIN tblRKBrokerageAccount BA ON BA.intBrokerageAccountId = T.intBrokerageAccountId
		LEFT JOIN tblRKOptionsMonth OM ON OM.intOptionMonthId = T.intOptionMonthId
		WHERE T.intFutOptTransactionId = @intFutOptTransactionId

		IF (ISNULL(@ysnLogRiskSummary, 1) = 1)
		BEGIN
			IF (@action = 'DELETE')
			BEGIN
				INSERT INTO @SummaryLog(strTransactionType
				, intTransactionRecordId
				, dtmTransactionDate
				, ysnDelete
				, intUserId
				, strNotes)
			SELECT strTransactionType = 'Derivatives'
				, intTransactionRecordId = @intFutOptTransactionId
				, dtmTransactionDate = GETDATE()
				, ysnDelete = 1
				, intUserId = @intUserId
				, strNotes = 'Delete record'
			END
			ELSE
			BEGIN
				INSERT INTO @SummaryLog(
					  strBucketType
					, strTransactionType
					, intTransactionRecordId
					, intTransactionRecordHeaderId
					, strDistributionType
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intCommodityId
					, intBookId
					, intSubBookId
					, intFutureMarketId
					, intFutureMonthId
					, dblNoOfLots
					, dblContractSize
					, dblPrice
					, intEntityId
					, intUserId
					, intLocationId
					, strInOut
					, intCommodityUOMId
					, strNotes
					, strMiscFields
					, intOptionMonthId
					, strOptionMonth 
					, dblStrike
					, strOptionType 
					, strInstrumentType 
					, intBrokerageAccountId
					, strBrokerAccount
					, strBroker
					, strBuySell 
					, ysnPreCrush 
					, strBrokerTradeNo )
				SELECT
					  strBucketType = 'Derivatives' 
					, strTransactionType = 'Derivative Entry'
					, intTransactionRecordId = der.intFutOptTransactionId
					, intTransactionRecordHeaderId = der.intFutOptTransactionHeaderId
					, strDistributionType = der.strNewBuySell
					, strTransactionNumber = der.strInternalTradeNo
					, dtmTransactionDate = der.dtmTransactionDate
					, intContractDetailId = der.intContractDetailId
					, intContractHeaderId = der.intContractHeaderId
					, intCommodityId = der.intCommodityId
					, intBookId = der.intBookId
					, intSubBookId = der.intSubBookId
					, intFutureMarketId = der.intFutureMarketId
					, intFutureMonthId = der.intFutureMonthId
					, dblNoOfLots = der.dblNewNoOfLots
					, dblContractSize = m.dblContractSize
					, dblPrice = der.dblPrice
					, intEntityId = der.intEntityId
					, intUserId = der.intUserId
					, der.intLocationId
					, strInOut = CASE WHEN UPPER(der.strNewBuySell) = 'BUY' THEN 'IN' ELSE 'OUT' END
					, cUOM.intCommodityUnitMeasureId
					, strNotes = strNotes
					, strMiscFields = NULL
					, intOptionMonthId = intOptionMonthId
					, strOptionMonth = strOptionMonth
					, dblStrike =  dblStrike
					, strOptionType =  strOptionType
					, strInstrumentType =  strInstrumentType
					, intBrokerageAccountId =  intBrokerId
					, strBrokerAccount =  strBrokerAccount
					, strBroker =  strBroker
					, strBuySell =  strNewBuySell
					, ysnPreCrush =  ISNULL(ysnPreCrush,0)
					, strBrokerTradeNo =  strBrokerTradeNo
				FROM vyuRKGetFutOptTransactionHistory der
				LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
				LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
				WHERE der.intFutOptTransactionId = @intFutOptTransactionId
			END
		END
	END

	EXEC uspRKLogRiskPosition @SummaryLog, 0, 1

	
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH