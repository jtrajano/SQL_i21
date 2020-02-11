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
	
	EXEC uspRKMatchDerivativesPostRecap @intMatchFuturesPSHeaderId, @intUserId

	SELECT h.intMatchFuturesPSHeaderId
		, h.intMatchNo
		, h.dtmMatchDate
		, d.intMatchFuturesPSDetailId
		, d.intLFutOptTransactionId
		, d.intSFutOptTransactionId
		, d.dblMatchQty
	INTO #tmpDerivative
	FROM tblRKMatchFuturesPSHeader h
	JOIN tblRKMatchFuturesPSDetail d ON d.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
	WHERE h.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

	SELECT * INTO #History FROM vyuRKGetMatchDerivativesFromSummaryLog WHERE intMatchDerivativesHeaderId = @intMatchFuturesPSHeaderId AND strTransactionType = 'Match Derivatives' ORDER BY dtmCreatedDate DESC
	DECLARE @SummaryLog AS RKSummaryLog
	
	IF EXISTS(SELECT TOP 1 1 FROM #tmpDerivative)
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
			, strNotes
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId)
		SELECT strTransactionType
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
			, strNotes
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
		FROM (
			SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = detail.intLFutOptTransactionId
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = header.dtmMatchDate
				, intContractDetailId = detail.intMatchFuturesPSDetailId
				, intContractHeaderId = header.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'IN'
				, dblNoOfLots = detail.dblMatchQty
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
			FROM tblRKMatchFuturesPSDetail detail
			JOIN tblRKMatchFuturesPSHeader header ON header.intMatchFuturesPSHeaderId = detail.intMatchFuturesPSHeaderId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = detail.intLFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			WHERE detail.intLFutOptTransactionId IN (SELECT DISTINCT intLFutOptTransactionId FROM #tmpDerivative)			

			UNION ALL SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = detail.intSFutOptTransactionId
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = header.dtmMatchDate
				, intContractDetailId = detail.intMatchFuturesPSDetailId
				, intContractHeaderId = header.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'OUT'
				, dblNoOfLots = detail.dblMatchQty * - 1
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
			FROM tblRKMatchDerivativesHistory detail
			JOIN tblRKMatchFuturesPSHeader header ON header.intMatchFuturesPSHeaderId = detail.intMatchFuturesPSHeaderId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = detail.intSFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			WHERE detail.intSFutOptTransactionId IN (SELECT DISTINCT intSFutOptTransactionId FROM #tmpDerivative)
		) tbl
		ORDER BY intMatchDerivativeHistoryId
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