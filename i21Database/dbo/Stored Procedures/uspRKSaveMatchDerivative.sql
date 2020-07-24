CREATE PROCEDURE [dbo].[uspRKSaveMatchDerivative]
	@intMatchFuturesPSHeaderId INT
	, @intUserId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg1 NVARCHAR(MAX)
	
	--EXEC uspRKMatchDerivativesPostRecap @intMatchFuturesPSHeaderId, @intUserId

	SELECT h.intMatchFuturesPSHeaderId
		, h.intMatchNo
		, h.dtmMatchDate
		, d.intMatchFuturesPSDetailId
		, d.intLFutOptTransactionId
		, d.intSFutOptTransactionId
		, d.dblMatchQty
	INTO #tmpDerivative
	FROM tblRKMatchFuturesPSDetail d
	JOIN tblRKMatchFuturesPSHeader h ON h.intMatchFuturesPSHeaderId = d.intMatchFuturesPSHeaderId
	WHERE h.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
	
	SELECT * INTO #History FROM vyuRKGetMatchDerivativesFromSummaryLog WHERE intMatchDerivativesHeaderId = @intMatchFuturesPSHeaderId AND strTransactionType = 'Match Derivatives' ORDER BY dtmCreatedDate DESC
	
	DECLARE @SummaryLog AS RKSummaryLog
	DECLARE @LogHelper AS RKMiscField

	DECLARE @strInstrumentType NVARCHAR(50)
		, @strBrokerAccount NVARCHAR(50)
		, @strBroker NVARCHAR(50)
		, @ysnPreCrush BIT
		, @strBrokerTradeNo NVARCHAR(50)
		, @strInternalTradeNo NVARCHAR(50)

	IF EXISTS(SELECT TOP 1 1 FROM #tmpDerivative)
	BEGIN
		SELECT strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intFutOptTransactionId
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
			, intCommodityUOMId
			, dblContractSize
			, strInstrumentType
			, strBrokerAccount
			, strBroker
			, ysnPreCrush
			, strBrokerTradeNo
			, strInternalTradeNo
		INTO #tmpFinalList
		FROM (
			SELECT strBucketType = 'Derivatives'
				, strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = md.intMatchFuturesPSDetailId
				, intTransactionRecordHeaderId = md.intMatchFuturesPSHeaderId
				, strTransactionNumber = md.intMatchNo
				, dtmTransactionDate = md.dtmMatchDate
				, intFutOptTransactionId = md.intLFutOptTransactionId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strDistributionType = de.strBuySell
				, dblNoOfLots = md.dblMatchQty
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, dblContractSize = FutMarket.dblContractSize
				, strInstrumentType = CASE WHEN (de.intInstrumentTypeId = 1) THEN N'Futures'
								WHEN (de.intInstrumentTypeId = 2) THEN N'Options'
								WHEN (de.intInstrumentTypeId = 3) THEN N'Currency Contract' END COLLATE Latin1_General_CI_AS
				, strBrokerAccount = BA.strAccountNumber
				, strBroker = e.strName
				, ysnPreCrush = de.ysnPreCrush
				, strBrokerTradeNo = de.strBrokerTradeNo
				, de.strInternalTradeNo
			FROM #tmpDerivative md
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = md.intLFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			LEFT JOIN tblRKOptionsMonth om ON om.intOptionMonthId = de.intOptionMonthId
			LEFT JOIN tblRKBrokerageAccount AS BA ON BA.intBrokerageAccountId = de.intBrokerageAccountId
			LEFT JOIN tblEMEntity e ON e.intEntityId = de.intEntityId

			UNION ALL SELECT strBucketType = 'Derivatives'
				, strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = md.intMatchFuturesPSDetailId
				, intTransactionRecordHeaderId = md.intMatchFuturesPSHeaderId
				, strTransactionNumber = md.intMatchNo
				, dtmTransactionDate = md.dtmMatchDate
				, intFutOptTransactionId = md.intSFutOptTransactionId
				, intCommodityId = de.intCommodityId
				, intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strDistributionType = de.strBuySell
				, dblNoOfLots = md.dblMatchQty * - 1
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, dblContractSize = FutMarket.dblContractSize
				, strInstrumentType = CASE WHEN (de.intInstrumentTypeId = 1) THEN N'Futures'
								WHEN (de.intInstrumentTypeId = 2) THEN N'Options'
								WHEN (de.intInstrumentTypeId = 3) THEN N'Currency Contract' END COLLATE Latin1_General_CI_AS
				, strBrokerAccount = BA.strAccountNumber
				, strBroker = e.strName
				, ysnPreCrush = de.ysnPreCrush
				, strBrokerTradeNo = de.strBrokerTradeNo
				, de.strInternalTradeNo
			FROM #tmpDerivative md
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = md.intSFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			LEFT JOIN tblRKOptionsMonth om ON om.intOptionMonthId = de.intOptionMonthId
			LEFT JOIN tblRKBrokerageAccount AS BA ON BA.intBrokerageAccountId = de.intBrokerageAccountId
			LEFT JOIN tblEMEntity e ON e.intEntityId = de.intEntityId
		) tbl

		DECLARE @intDetailId INT
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpFinalList)
		BEGIN
			SELECT TOP 1 @intDetailId = intTransactionRecordId
				, @strInstrumentType = strInstrumentType
				, @strBrokerAccount = strBrokerAccount
				, @strBroker = strBroker
				, @ysnPreCrush = ysnPreCrush
				, @strBrokerTradeNo = strBrokerTradeNo
				, @strInternalTradeNo = strInternalTradeNo
			FROM #tmpFinalList

			INSERT INTO @LogHelper(intRowId, strFieldName, strValue)
			SELECT intRowId = ROW_NUMBER() OVER (ORDER BY strFieldName),  * FROM (
				SELECT strFieldName = 'strInternalTradeNo', strValue = @strInternalTradeNo				
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
				, intFutOptTransactionId
				, intCommodityId
				, intLocationId
				, intBookId
				, intSubBookId
				, intFutureMarketId
				, intFutureMonthId
				, dblNoOfLots
				, dblPrice
				, dblContractSize
				, intEntityId
				, intUserId
				, intCommodityUOMId
				, strMiscFields
				, intActionId)
			SELECT strBucketType
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intFutOptTransactionId
				, intCommodityId
				, intLocationId
				, intBookId
				, intSubBookId
				, intFutureMarketId
				, intFutureMonthId
				, dblNoOfLots
				, dblPrice
				, dblContractSize
				, intEntityId
				, intUserId
				, intCommodityUOMId
				, strMiscFields = dbo.fnRKConvertMiscFieldString(@LogHelper)
				, intActionId = 36
			FROM #tmpFinalList WHERE intTransactionRecordId = @intDetailId

			DELETE FROM @LogHelper

			DELETE FROM #tmpFinalList WHERE intTransactionRecordId = @intDetailId
		END

		DROP TABLE #tmpFinalList
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
			SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = intTransactionRecordId
				, ysnDelete = 1
				, intUserId = @intUserId
				, strNotes = 'Delete record'
			FROM #History
		END
	END

	EXEC uspRKLogRiskPosition @SummaryLog
	
	DROP TABLE #tmpDerivative
	DROP TABLE #History
END TRY
BEGIN CATCH
	SET @ErrMsg1 = ERROR_MESSAGE()
	IF @ErrMsg1 != ''
	BEGIN
		RAISERROR(@ErrMsg1, 16, 1, 'WITH NOWAIT')
	END
END CATCH