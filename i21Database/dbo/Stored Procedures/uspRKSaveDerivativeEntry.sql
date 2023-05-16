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
			, strInOut
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
			, strBrokerTradeNo
			, intMatchNo
			, intMatchDerivativesHeaderId
			, intMatchDerivativesDetailId
			, strStorageTypeCode
			, ysnReceiptedStorage
			, intTypeId
			, strStorageType
			, intDeliverySheetId
			, strTicketStatus
			, strOwnedPhysicalStock
			, strStorageTypeDescription
			, ysnActive
			, ysnExternal
			, intStorageHistoryId
			, intInventoryReceiptItemId
			, intLoadDetailId
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
			, strInOut = CASE WHEN strInOut = 'IN' THEN 'OUT' ELSE 'IN' END 
			, strMiscField
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
			, strBrokerTradeNo
			, intMatchNo
			, intMatchDerivativesHeaderId
			, intMatchDerivativesDetailId
			, strStorageTypeCode
			, ysnReceiptedStorage
			, intTypeId
			, strStorageType
			, intDeliverySheetId
			, strTicketStatus
			, strOwnedPhysicalStock
			, strStorageTypeDescription
			, ysnActive
			, ysnExternal
			, intStorageHistoryId
			, intInventoryReceiptItemId
			, intLoadDetailId
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
		, der.intTraderId
		, m.intCurrencyId
		, cur.strCurrency
		, der.strStatus
		, der.dtmFilledDate
		, der.intRollingMonthId
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
			, @dblNoOfLots NUMERIC(24, 10)
			, @dblPrice NUMERIC(24, 10)
			, @strInstrumentType NVARCHAR(50)
			, @intBrokerageAccountId INT
			, @strBrokerAccount NVARCHAR(50)
			, @strBroker NVARCHAR(50)
			, @ysnPreCrush BIT
			, @strBrokerTradeNo NVARCHAR(50)
			, @intCommodityId INT
			, @intFutureMarketId INT
			, @strTransactionNumber NVARCHAR(50)
			, @strBatchId NVARCHAR(50)
			, @intFutureMonthId INT
			, @intBookId INT
			, @intSubBookId INT
			, @intLocationId INT
			, @strNotes NVARCHAR(250)
			, @intTraderId INT
			, @strStatus NVARCHAR(250)
			, @dtmFilledDate DATETIME
			, @intRollingMonthId INT


			
		SELECT TOP 1 @dblContractSize = dblContractSize
			, @dblNoOfLots = dblNoOfLots
			, @dblPrice = dblPrice
			, @intOptionMonthId = intOptionMonthId
			, @strOptionMonth = strOptionMonth
			, @dblStrike = dblStrike
			, @strOptionType = strOptionType
			, @strInstrumentType = strInstrumentType
			, @strBrokerAccount = strBrokerAccount
			, @strBroker = strBroker
			, @ysnPreCrush = ISNULL(ysnPreCrush,0)
			, @strBrokerTradeNo = strBrokerTradeNo
			, @strBuySell = strBuySell
			, @intCommodityId = intCommodityId
			, @intFutureMarketId = intFutureMarketId
			, @strTransactionNumber = strTransactionNumber
			, @intFutureMonthId = intFutureMonthId
			, @intBookId = intBookId
			, @intSubBookId = intSubBookId
			, @intLocationId = intLocationId
			, @strNotes = strNotes
			, @intTraderId = intTraderId
			, @strStatus = strStatus
			, @dtmFilledDate = dtmFilledDate
			, @intRollingMonthId = intRollingMonthId
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
			UNION ALL SELECT 'intTraderId', CAST(@intTraderId AS NVARCHAR)
			UNION ALL SELECT 'strStatus', @strStatus
			UNION ALL SELECT 'dtmFilledDate', CAST(@dtmFilledDate AS NVARCHAR)
			UNION ALL SELECT 'intRollingMonthId', CAST(@intRollingMonthId AS NVARCHAR)
		) t WHERE ISNULL(strValue, '') != ''

		select @dblPreviousNoOfLots = sum(dblOrigNoOfLots)
		from tblRKSummaryLog
		where intTransactionRecordId = @intFutOptTransactionId
		and strTransactionType = 'Derivative Entry'

		EXEC uspSMGetStartingNumber 148, @strBatchId OUTPUT

		IF EXISTS(SELECT TOP 1 1
			FROM tblRKSummaryLog
			WHERE intTransactionRecordId = @intFutOptTransactionId
				AND strBucketType = 'Derivatives'
				AND strTransactionType = 'Derivative Entry'
				AND strTransactionNumber = @strTransactionNumber
				AND (intCommodityId <> @intCommodityId 
					OR strDistributionType <> @strBuySell 
					OR intFutureMarketId <> @intFutureMarketId 
					OR dblOrigNoOfLots <> @dblNoOfLots
					OR dblPrice <> @dblPrice
					OR intFutureMonthId <> @intFutureMonthId
					OR intBookId <> @intBookId
					OR intSubBookId <> @intSubBookId
					OR intLocationId <> @intLocationId
					OR strNotes <> @strNotes
				)
				AND ysnNegate IS NULL)
		BEGIN
				INSERT INTO tblRKSummaryLog(strBatchId
					, dtmCreatedDate
					, strBucketType
					, intActionId
					, strAction
					, strTransactionType
					, intTransactionRecordId
					, intTransactionRecordHeaderId
					, strDistributionType
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intFutureMarketId
					, intFutureMonthId
					, intFutOptTransactionId
					, intCommodityId
					, intLocationId
					, intItemId
					, intProductTypeId
					, intOrigUOMId
					, intBookId
					, intSubBookId
					, strInOut
					, dblOrigNoOfLots
					, dblContractSize
					, dblOrigQty
					, dblPrice
					, intEntityId
					, intTicketId
					, intUserId
					, strNotes
					, ysnNegate
					, intRefSummaryLogId
					, strMiscField
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
					, strBrokerTradeNo)
				SELECT 
					  @strBatchId
					, dtmCreatedDate = GETUTCDATE()
					, strBucketType
					, intActionId = 56
					, strAction = 'Updated Derivative'
					, strTransactionType
					, intTransactionRecordId
					, intTransactionRecordHeaderId
					, strDistributionType
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intFutureMarketId
					, intFutureMonthId
					, intFutOptTransactionId
					, intCommodityId
					, intLocationId
					, intItemId
					, intProductTypeId
					, intOrigUOMId
					, intBookId
					, intSubBookId
					, strInOut = CASE WHEN strInOut = 'IN' THEN 'OUT' ELSE 'IN' END
					, dblOrigNoOfLots * -1
					, dblContractSize
					, dblOrigQty * -1
					, dblPrice
					, intEntityId
					, intTicketId
					, intUserId
					, strNotes
					, ysnNegate = 1
					, intRefSummaryLogId
					, strMiscField
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
					, strBrokerTradeNo
				FROM tblRKSummaryLog
				WHERE intTransactionRecordId = @intFutOptTransactionId
					AND strBucketType = 'Derivatives'
					AND strTransactionType = 'Derivative Entry'
					AND strTransactionNumber = @strTransactionNumber
						AND (intCommodityId <> @intCommodityId 
						OR strDistributionType <> @strBuySell 
						OR intFutureMarketId <> @intFutureMarketId 
						OR dblOrigNoOfLots <> @dblNoOfLots
						OR dblPrice <> @dblPrice
						OR intFutureMonthId <> @intFutureMonthId
						OR intBookId <> @intBookId
						OR intSubBookId <> @intSubBookId
						OR intLocationId <> @intLocationId
						OR strNotes <> @strNotes
					)
					AND ysnNegate IS NULL 

				UPDATE tblRKSummaryLog SET ysnNegate = 1
				WHERE intTransactionRecordId = @intFutOptTransactionId
					AND strBucketType = 'Derivatives'
					AND strTransactionType = 'Derivative Entry'
					AND strTransactionNumber = @strTransactionNumber
					AND (intCommodityId <> @intCommodityId 
						OR strDistributionType <> @strBuySell 
						OR intFutureMarketId <> @intFutureMarketId 
						OR dblOrigNoOfLots <> @dblNoOfLots
						OR dblPrice <> @dblPrice
						OR intFutureMonthId <> @intFutureMonthId
						OR intBookId <> @intBookId
						OR intSubBookId <> @intSubBookId
						OR intLocationId <> @intLocationId
						OR strNotes <> @strNotes
					)
					AND ysnNegate IS NULL 

		END


		INSERT INTO @SummaryLog(strBatchId
			, strBucketType
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
			, strInOut
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
			, strBrokerTradeNo
			, intActionId)
		SELECT @strBatchId 
			, strBucketType = 'Derivatives'
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
			, strInOut = CASE WHEN UPPER(strBuySell) = 'BUY' THEN 'IN' ELSE 'OUT' END
			, intCurrencyId = der.intCurrencyId
			, intBookId = der.intBookId
			, intSubBookId = der.intSubBookId
			, intFutureMarketId = der.intFutureMarketId
			, intFutureMonthId = der.intFutureMonthId
			, dblNoOfLots = CASE WHEN UPPER(strBuySell) = 'BUY' THEN der.dblNoOfLots  ELSE der.dblNoOfLots  * -1 END 
			, dblPrice = der.dblPrice
			, dblContractSize = der.dblContractSize
			, dblQty = (CASE WHEN UPPER(strBuySell) = 'BUY' THEN der.dblNoOfLots ELSE der.dblNoOfLots * -1 END ) * dblContractSize
			, intEntityId = der.intEntityId
			, intUserId = @intUserId
			, strNotes = der.strNotes
			, intCommodityUOMId = der.intCommodityUOMId
			, strMiscFields = NULL
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
			, strBrokerTradeNo
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
			, strInOut
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
			, strBrokerTradeNo
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
			, strInOut = CASE WHEN strInOut = 'IN' THEN 'OUT' ELSE 'IN' END
			, strMiscField
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
			, strBrokerTradeNo
			, intActionId = 57 --Delete Derivative
		FROM tblRKSummaryLog 
		WHERE intTransactionRecordId = @intFutOptTransactionId
		ORDER BY dtmCreatedDate DESC
		
	END

	
	
	DROP TABLE #tmpDerivative
END

EXEC uspRKLogRiskPosition @SummaryLog

END