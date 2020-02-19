﻿CREATE PROCEDURE [dbo].[uspRKFutOptTransactionHistory]
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
										WHEN T.intInstrumentTypeId = 3 THEN 'Currency Contract'
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
			, strUserName = @strUserName
			, 'DELETE'
		FROM tblRKFutOptTransaction T
		JOIN tblRKFutOptTransactionHeader H ON T.intFutOptTransactionHeaderId = H.intFutOptTransactionHeaderId
		JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = T.intFutureMarketId
		JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = T.intFutureMonthId
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
					, ysnDelete
					, intUserId
					, strNotes)
				SELECT strTransactionType = 'Derivatives'
					, intTransactionRecordId = intFutOptTransactionId
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
										WHEN T.intInstrumentTypeId = 3 THEN 'Currency Contract'
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
			, strUserName = @strUserName
			, @action
		FROM tblRKFutOptTransaction T
		JOIN tblRKFutOptTransactionHeader H on T.intFutOptTransactionHeaderId = H.intFutOptTransactionHeaderId
		JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = T.intFutureMarketId
		JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = T.intFutureMonthId
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
				, ysnDelete
				, intUserId
				, strNotes)
			SELECT strTransactionType = 'Derivatives'
				, intTransactionRecordId = @intFutOptTransactionId
				, ysnDelete = 1
				, intUserId = @intUserId
				, strNotes = 'Delete record'
			END
			ELSE
			BEGIN
				INSERT INTO @SummaryLog(strTransactionType
					, intTransactionRecordId
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intCommodityId
					, intLocationId
					, intBookId
					, intSubBookId
					, intFutureMarketId
					, intFutureMonthId
					, dblNoOfLots
					, dblPrice
					, intEntityId
					, intUserId
					, strNotes
					, intCommodityUOMId)
				SELECT strTransactionType = 'Derivatives'
					, intTransactionRecordId = der.intFutOptTransactionId
					, strTransactionNumber = der.strInternalTradeNo
					, dtmTransactionDate = der.dtmTransactionDate
					, intContractDetailId = der.intContractDetailId
					, intContractHeaderId = der.intContractHeaderId
					, intCommodityId = der.intCommodityId
					, intLocationId = der.intLocationId
					, intBookId = der.intBookId
					, intSubBookId = der.intSubBookId
					, intFutureMarketId = der.intFutureMarketId
					, intFutureMonthId = der.intFutureMonthId
					, dblNoOfLots = der.dblNoOfContract
					, dblPrice = der.dblPrice
					, intEntityId = der.intEntityId
					, intUserId = @intUserId
					, strNotes = der.strReference
					, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				FROM tblRKFutOptTransaction der
				JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
				LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
			END
		END
	END

	EXEC uspRKLogRiskPosition @SummaryLog, 0, 1

	
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH