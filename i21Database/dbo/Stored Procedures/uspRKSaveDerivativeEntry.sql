CREATE PROCEDURE [dbo].[uspRKSaveDerivativeEntry]
	@intFutOptTransactionId INT = NULL
	, @intFutOptTransactionHeaderId INT = NULL
	, @intUserId INT
	, @action NVARCHAR(20)

AS


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

DECLARE @SummaryLog AS RKSummaryLog
DECLARE @LogHelper AS RKMiscField
DECLARE @dblPreviousNoOfLots NUMERIC(24,10)

IF @action = 'HEADER DELETE' --This scenario is when you delete the entire derivative entry. 
BEGIN
	
	SELECT  dblPreviousNoOfLots = sum(dblOrigNoOfLots), intTransactionRecordId
	INTO #tempLogsToDelete
	FROM tblRKSummaryLog
	WHERE intTransactionRecordHeaderId = @intFutOptTransactionHeaderId
		and strTransactionType = 'Derivative Entry'
	GROUP BY intTransactionRecordId

	DELETE FROM #tempLogsToDelete WHERE dblPreviousNoOfLots = 0

	WHILE EXISTS (SELECT TOP 1 * FROM #tempLogsToDelete)
	BEGIN
		SELECT TOP 1 @dblPreviousNoOfLots = dblPreviousNoOfLots
			, @intFutOptTransactionId = intTransactionRecordId
		FROM #tempLogsToDelete

		INSERT INTO @SummaryLog(strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intFutOptTransactionId
			, intCommodityId
			, intLocationId
			, intCurrencyId
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
			, strMiscFields
			, intActionId)
		SELECT TOP 1  strBucketType = 'Derivatives'
			, strTransactionType = 'Derivative Entry'
			, intTransactionRecordId 
			, intTransactionRecordHeaderId 
			, strDistributionType
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractDetailId
			, intContractHeaderId 
			, intFutOptTransactionId 
			, intCommodityId 
			, intLocationId
			, intCurrencyId 
			, intBookId 
			, intSubBookId 
			, intFutureMarketId 
			, intFutureMonthId 
			, dblNoOfLots = ISNULL(@dblPreviousNoOfLots,0) * -1
			, dblPrice 
			, dblContractSize
			, dblQty = (ISNULL(@dblPreviousNoOfLots,0) * -1) * dblContractSize
			, intEntityId 
			, intUserId = @intUserId
			, strNotes 
			, intOrigUOMId 
			, strMiscField
			, intActionId = 57 --Delete Derivative
		FROM tblRKSummaryLog 
		WHERE intTransactionRecordId = @intFutOptTransactionId
		ORDER BY dtmCreatedDate DESC


		DELETE FROM #tempLogsToDelete WHERE intTransactionRecordId = @intFutOptTransactionId


	END

	DROP TABLE #tempLogsToDelete

END
ELSE
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
		, der.intBrokerageAccountId
		, strBrokerAccount = BA.strAccountNumber
		, strBroker = e.strName
		, intFutOptTransactionHeaderId = der.intFutOptTransactionHeaderId
		, ysnPreCrush = der.ysnPreCrush
		, strBrokerTradeNo = der.strBrokerTradeNo
		, m.intCurrencyId
		, cur.strCurrency
	INTO #tmpDerivative
	FROM tblRKFutOptTransaction der
	JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
	LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
	LEFT JOIN tblRKOptionsMonth om ON om.intOptionMonthId = der.intOptionMonthId
	LEFT JOIN tblRKBrokerageAccount AS BA ON BA.intBrokerageAccountId = der.intBrokerageAccountId
	LEFT JOIN tblEMEntity e ON e.intEntityId = der.intEntityId
	LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = m.intCurrencyId
	WHERE intFutOptTransactionId = @intFutOptTransactionId




	IF EXISTS(SELECT TOP 1 1 FROM #tmpDerivative)
	BEGIN
		DECLARE @strBuySell NVARCHAR(50)
			, @intOptionMonthId INT
			, @strOptionMonth NVARCHAR(50)
			, @dblStrike NUMERIC(24, 10)
			, @strOptionType NVARCHAR(50)
			, @dblContractSize NUMERIC(24, 10)
			, @strInstrumentType NVARCHAR(50)
			, @intBrokerageAccountId INT
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
			SELECT strFieldName = 'intOptionMonthId', strValue = CAST(@intOptionMonthId AS NVARCHAR)
			UNION ALL SELECT 'strOptionMonth', @strOptionMonth
			UNION ALL SELECT 'dblStrike', CAST(@dblStrike AS NVARCHAR)
			UNION ALL SELECT 'strOptionType', @strOptionType
			UNION ALL SELECT 'strInstrumentType', @strInstrumentType
			UNION ALL SELECT 'intBrokerageAccountId', CAST(@intBrokerageAccountId AS NVARCHAR)
			UNION ALL SELECT 'strBrokerAccount', @strBrokerAccount
			UNION ALL SELECT 'strBroker', @strBroker
			UNION ALL SELECT 'ysnPreCrush', CAST(@ysnPreCrush AS NVARCHAR)
			UNION ALL SELECT 'strBrokerTradeNo', @strBrokerTradeNo
		) t WHERE ISNULL(strValue, '') != ''

		select @dblPreviousNoOfLots = sum(dblOrigNoOfLots)
		from tblRKSummaryLog
		where intTransactionRecordId = @intFutOptTransactionId
		and strTransactionType = 'Derivative Entry'

		INSERT INTO @SummaryLog(strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intFutOptTransactionId
			, intCommodityId
			, intLocationId
			, intCurrencyId
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
			, strMiscFields
			, intActionId)
		SELECT strBucketType = 'Derivatives'
			, strTransactionType = 'Derivative Entry'
			, intTransactionRecordId = der.intTransactionRecordId
			, intTransactionRecordHeaderId = der.intFutOptTransactionHeaderId
			, strDistributionType = strBuySell
			, strTransactionNumber = der.strTransactionNumber
			, dtmTransactionDate = der.dtmTransactionDate
			, intContractDetailId = der.intContractDetailId
			, intContractHeaderId = der.intContractHeaderId
			, intFutOptTransactionId = der.intTransactionRecordId
			, intCommodityId = der.intCommodityId
			, intLocationId = der.intLocationId
			, intCurrencyId = der.intCurrencyId
			, intBookId = der.intBookId
			, intSubBookId = der.intSubBookId
			, intFutureMarketId = der.intFutureMarketId
			, intFutureMonthId = der.intFutureMonthId
			, dblNoOfLots = CASE WHEN UPPER(strBuySell) = 'BUY' THEN (der.dblNoOfLots - ABS(ISNULL(@dblPreviousNoOfLots,0))) ELSE (der.dblNoOfLots - ABS(ISNULL(@dblPreviousNoOfLots,0))) * -1 END 
			, dblPrice = der.dblPrice
			, dblContractSize = der.dblContractSize
			, dblQty = (CASE WHEN UPPER(strBuySell) = 'BUY' THEN (der.dblNoOfLots - ABS(ISNULL(@dblPreviousNoOfLots,0))) ELSE (der.dblNoOfLots - ABS(ISNULL(@dblPreviousNoOfLots,0))) * -1 END ) * dblContractSize
			, intEntityId = der.intEntityId
			, intUserId = @intUserId
			, strNotes = der.strNotes
			, intCommodityUOMId = der.intCommodityUOMId
			, strMiscFields = dbo.fnRKConvertMiscFieldString(@LogHelper)
			, intActionId = CASE WHEN @dblPreviousNoOfLots IS NULL THEN 34 ELSE 56 END
		FROM #tmpDerivative der		
	END
	ELSE
	BEGIN
		--For Delete
		select @dblPreviousNoOfLots = sum(dblOrigNoOfLots)
		from tblRKSummaryLog
		where intTransactionRecordId = @intFutOptTransactionId
		and strTransactionType = 'Derivative Entry'

		INSERT INTO @SummaryLog(strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intFutOptTransactionId
			, intCommodityId
			, intLocationId
			, intCurrencyId
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
			, strMiscFields
			, intActionId)
		SELECT TOP 1  strBucketType = 'Derivatives'
			, strTransactionType = 'Derivative Entry'
			, intTransactionRecordId 
			, intTransactionRecordHeaderId 
			, strDistributionType
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractDetailId
			, intContractHeaderId 
			, intFutOptTransactionId 
			, intCommodityId 
			, intLocationId
			, intCurrencyId 
			, intBookId 
			, intSubBookId 
			, intFutureMarketId 
			, intFutureMonthId 
			, dblNoOfLots = ISNULL(@dblPreviousNoOfLots,0) * -1
			, dblPrice 
			, dblContractSize
			, dblQty = (ISNULL(@dblPreviousNoOfLots,0) * -1) * dblContractSize
			, intEntityId 
			, intUserId = @intUserId
			, strNotes 
			, intOrigUOMId 
			, strMiscField
			, intActionId = 57 --Delete Derivative
		FROM tblRKSummaryLog 
		WHERE intTransactionRecordId = @intFutOptTransactionId
		ORDER BY dtmCreatedDate DESC
		
	END

	
	
	DROP TABLE #tmpDerivative
END

EXEC uspRKLogRiskPosition @SummaryLog

END