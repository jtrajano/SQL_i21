﻿CREATE PROCEDURE [dbo].[uspRKSaveDerivativeEntry]
	@intFutOptTransactionId INT
	, @intUserId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
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
		, strBuySell = der.strBuySell
		, dblContractSize = m.dblContractSize
		, intOptionMonthId = der.intOptionMonthId
		, strOptionMonth = om.strOptionMonth
		, dblStrike = der.dblStrike
		, strOptionType = der.strOptionType
		, strInstrumentType = CASE WHEN (der.[intInstrumentTypeId] = 1) THEN N'Futures'
						WHEN (der.[intInstrumentTypeId] = 2) THEN N'Options'
						WHEN (der.[intInstrumentTypeId] = 3) THEN N'Currency Contract' END COLLATE Latin1_General_CI_AS
		, strBrokerAccount = BA.strAccountNumber
		, strBroker = e.strName
		, intFutOptTransactionHeaderId = der.intFutOptTransactionHeaderId
		, ysnPreCrush = der.ysnPreCrush
		, strBrokerTradeNo = der.strBrokerTradeNo
	INTO #tmpDerivative
	FROM tblRKFutOptTransaction
	JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
	LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
	LEFT JOIN tblRKOptionsMonth om ON om.intOptionMonthId = der.intOptionMonthId
	LEFT JOIN tblRKBrokerageAccount AS BA ON BA.intBrokerageAccountId = der.intBrokerageAccountId
	LEFT JOIN tblEMEntity e ON e.intEntityId = der.intEntityId
	WHERE intFutOptTransactionId = @intFutOptTransactionId

	SELECT TOP 1 * INTO #History FROM tblRKSummaryLog WHERE intTransactionRecordId = @intFutOptTransactionId AND strTransactionType = 'Derivatives' ORDER BY dtmCreatedDate DESC

	DECLARE @SummaryLog AS RKSummaryLog
	DECLARE @LogHelper AS RKMiscField
	
	IF EXISTS(SELECT TOP 1 1 FROM #tmpDerivative)
	BEGIN
		DECLARE @strBuySell NVARCHAR(50)
			, @intOptionMonthId INT
			, @strOptionMonth NVARCHAR(50)
			, @dblStrike NUMERIC(24, 10)
			, @strOptionType NVARCHAR(50)
			, @intFutOptTransactionHeaderId INT
			, @dblContractSize NUMERIC(24, 10)
			, @strInstrumentType NVARCHAR(50)
			, @strBrokerAccount NVARCHAR(50)
			, @strBroker NVARCHAR(50)
			, @ysnPreCrush BIT
			, @strBrokerTradeNo NVARCHAR(50)
			
		SELECT TOP 1 @dblContractSize = dblContractSize
			, @intOptionMonthId = intOptionMonthId
			, @strOptionMonth = strOptionMonth
			, @dblStrike = dblStrike
			, @strOptionType = strOptionType
			, @strInstrumentType = strInstrumentType
			, @strBrokerAccount = strBrokerAccount
			, @strBroker = strBroker
			, @ysnPreCrush = ysnPreCrush
			, @strBrokerTradeNo = strBrokerTradeNo
		FROM #tmpDerivative der

		INSERT INTO @LogHelper(intRowId, strFieldName, strValue)
		SELECT intRowId = ROW_NUMBER() OVER (ORDER BY strFieldName),  * FROM (
			SELECT strFieldName = 'intOptionMonthId', CAST(@intOptionMonthId AS NVARCHAR)
			UNION ALL SELECT 'strOptionMonth', @strOptionMonth
			UNION ALL SELECT 'dblStrike', CAST(@dblStrike AS NVARCHAR)
			UNION ALL SELECT 'strOptionType', @strOptionType
			UNION ALL SELECT 'strInstrumentType', @strInstrumentType
			UNION ALL SELECT 'strBrokerAccount', @strBrokerAccount
			UNION ALL SELECT 'strBroker', @strBroker
			UNION ALL SELECT 'ysnPreCrush', CAST(@ysnPreCrush AS NVARCHAR)
			UNION ALL SELECT 'strBrokerTradeNo', @strBrokerTradeNo
		) t WHERE ISNULL(strValue, '') != ''

		INSERT INTO @SummaryLog(strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
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
			, dblContractSize
			, dblQty
			, intEntityId
			, intUserId
			, strNotes
			, intCommodityUOMId
			, strMiscFields)
		SELECT strBucketType = 'Derivatives'
			, strTransactionType = 'Derivatives'
			, intTransactionRecordId = der.intFutOptTransactionId
			, intTransactionRecordHeaderId = der.intFutOptTransactionHeaderId
			, strDistributionType = strBuySell
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
			, dblContractSize = der.dblContractSize
			, dblQty = der.dblNoOfContract * dblContractSize
			, intEntityId = der.intEntityId
			, intUserId = @intUserId
			, strNotes = der.strReference
			, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
			, strMiscFields = dbo.fnRKConvertMiscFieldString(@LogHelper)
		FROM #tmpDerivative der
		
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM #History)
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
	END

	EXEC uspRKLogRiskPosition @SummaryLog
	
	DROP TABLE #tmpDerivative
	DROP TABLE #History
END