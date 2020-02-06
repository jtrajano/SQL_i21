CREATE PROCEDURE [dbo].[uspRKSaveMatchDerivative]
	@intMatchFuturesPSHeaderId INT
	, @intUserId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SELECT h.intMatchFuturesPSHeaderId
		, h.intMatchNo
		, h.dtmMatchDate
		, d.intMatchFuturesPSDetailId
		, d.intLFutOptTransactionId
		, d.intSFutOptTransactionId
		, d.dblMatchQty
	INTO #tmpDerivative
	FROM tblRKMatchFuturesPSHeader h
	LEFT JOIN tblRKMatchFuturesPSDetail d ON d.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
	WHERE h.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

	SELECT * INTO #History FROM vyuRKGetMatchDerivativesFromSummaryLog WHERE intMatchDerivativesHeaderId = @intMatchFuturesPSHeaderId AND strTransactionType = 'Match Derivatives' ORDER BY dtmCreatedDate DESC
	DECLARE @SummaryLog AS RKSummaryLog
	
	--IF EXISTS(SELECT TOP 1 1 FROM #tmpDerivative)
	--BEGIN
	--	INSERT INTO @SummaryLog(strTransactionType
	--		, intTransactionRecordId
	--		, strTransactionNumber
	--		, dtmTransactionDate
	--		, intContractDetailId
	--		, intContractHeaderId
	--		, intCommodityId
	--		, intLocationId
	--		, intBookId
	--		, intSubBookId
	--		, intFutureMarketId
	--		, intFutureMonthId
	--		, dblNoOfLots
	--		, dblPrice
	--		, intEntityId
	--		, intUserId
	--		, strNotes
	--		, intCommodityUOMId)
	--	SELECT strTransactionType = 'Derivatives'
	--		, intTransactionRecordId = der.intFutOptTransactionId
	--		, strTransactionNumber = der.strInternalTradeNo
	--		, dtmTransactionDate = der.dtmTransactionDate
	--		, intContractDetailId = der.intContractDetailId
	--		, intContractHeaderId = der.intContractHeaderId
	--		, intCommodityId = der.intCommodityId
	--		, intLocationId = der.intLocationId
	--		, intBookId = der.intBookId
	--		, intSubBookId = der.intSubBookId
	--		, intFutureMarketId = der.intFutureMarketId
	--		, intFutureMonthId = der.intFutureMonthId
	--		, dblNoOfLots = der.dblNoOfContract
	--		, dblPrice = der.dblPrice
	--		, intEntityId = der.intEntityId
	--		, intUserId = @intUserId
	--		, strNotes = der.strReference
	--		, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
	--	FROM #tmpDerivative der
	--	JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
	--	LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
	--END
	--ELSE
	--BEGIN
	--	IF EXISTS (SELECT TOP 1 1 FROM #History)
	--	BEGIN
	--		INSERT INTO @SummaryLog(strTransactionType
	--			, intTransactionRecordId
	--			, ysnDelete
	--			, intUserId
	--			, strNotes)
	--		SELECT strTransactionType = 'Derivatives'
	--			, intTransactionRecordId = @intFutOptTransactionId
	--			, ysnDelete = 1
	--			, intUserId = @intUserId
	--			, strNotes = 'Delete record'
	--	END
	--END

	--EXEC uspRKLogRiskPosition @SummaryLog
	
	--DROP TABLE #tmpDerivative
	--DROP TABLE #History
END