CREATE PROCEDURE [dbo].[uspRKSaveDerivativeEntry]
	@intFutOptTransactionId INT
	, @intUserId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SELECT * INTO #tmpDerivative FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId
	SELECT TOP 1 * INTO #History FROM tblRKSummaryLog WHERE intTransactionRecordId = @intFutOptTransactionId AND strTransactionType = 'DERIVATIVES' ORDER BY dtmCreatedDate DESC
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
			, intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, strNotes)
		SELECT strTransactionType = 'DERIVATIVES'
			, intTransactionRecordId = intFutOptTransactionId
			, strTransactionNumber = strInternalTradeNo
			, dtmTransactionDate = dtmTransactionDate
			, intContractDetailId = intContractDetailId
			, intContractHeaderId = intContractHeaderId
			, intCommodityId = intCommodityId
			, intBookId = intBookId
			, intSubBookId = intSubBookId
			, intFutureMarketId = intFutureMarketId
			, intFutureMonthId = intFutureMonthId
			, dblNoOfLots = dblNoOfContract
			, dblPrice = dblPrice
			, intEntityId = intEntityId
			, intUserId = @intUserId
			, strNotes = ''
		FROM #tmpDerivative
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
			SELECT strTransactionType = 'DERIVATIVES'
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