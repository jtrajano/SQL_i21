CREATE PROCEDURE [dbo].[uspRKRebuildSummaryLog]
	
AS

BEGIN

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKSummaryLog')
	BEGIN
		DECLARE @ExistingHistory AS RKSummaryLog

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKSummaryLog WHERE strTransactionType = 'Derivatives')
		BEGIN
			PRINT 'Populate RK Summary Log - Derivatives'
		
			INSERT INTO @ExistingHistory(strTransactionType
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
				, intLocationId
				, intCommodityUOMId
				, strNotes)
			SELECT strTransactionType = 'Derivatives'
				, intTransactionRecordId = der.intFutOptTransactionId
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
				, dblPrice = der.dblPrice
				, intEntityId = der.intEntityId
				, intUserId = der.intUserId
				, der.intLocationId
				, cUOM.intCommodityUnitMeasureId
				, strNotes = strNotes
			FROM vyuRKGetFutOptTransactionHistory der
			JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId

			EXEC uspRKLogRiskPosition @ExistingHistory, 1

			PRINT 'End Populate RK Summary Log'
		END

		DELETE FROM @ExistingHistory

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKSummaryLog WHERE strTransactionType = 'Match Derivatives')
		BEGIN
			PRINT 'Populate RK Summary Log - Match Derivatives'
		
			INSERT INTO @ExistingHistory(strTransactionType
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
			SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = history.intLFutOptTransactionId
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = history.dtmMatchDate
				, intContractDetailId = history.intMatchFuturesPSDetailId
				, intContractHeaderId = history.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, dblNoOfLots = de.dblNoOfContract - dbo.fnRKGetMatchedQtyAsOf(de.intFutOptTransactionId, history.dtmMatchDate)
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = intUserId
				, strNotes = ''
			FROM tblRKMatchDerivativesHistory history
			LEFT JOIN tblRKMatchFuturesPSHeader header ON header.intMatchFuturesPSHeaderId = history.intMatchFuturesPSHeaderId
			LEFT JOIN tblRKMatchFuturesPSDetail detail ON detail.intMatchFuturesPSDetailId = history.intMatchFuturesPSDetailId
			LEFT JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = history.intLFutOptTransactionId

			EXEC uspRKLogRiskPosition @ExistingHistory, 1

			PRINT 'End Populate RK Summary Log'
		END

		DELETE FROM @ExistingHistory

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKSummaryLog WHERE strTransactionType IN ('Collateral', 'Collateral Adjustments'))
		BEGIN
			PRINT 'Populate RK Summary Log - Collateral'
			DECLARE @intUserId INT
		
			SELECT TOP 1 @intUserId = intEntityId FROM tblSMUserSecurity where strUserName = 'irelyadmin'
		
			INSERT INTO @ExistingHistory(strTransactionType
				, intTransactionRecordId
				, strTransactionNumber
				, dtmTransactionDate
				, intContractHeaderId
				, intCommodityId
				, intLocationId
				, dblQty
				, intUserId
				, strNotes)
			SELECT strTransactionType = 'Collateral'
				, intTransactionRecordId = intCollateralId
				, strTransactionNumber = strReceiptNo
				, dtmTransactionDate = dtmOpenDate
				, intContractHeaderId = intContractHeaderId
				, intCommodityId = intCommodityId
				, intLocationId = intLocationId
				, dblQty = dblOriginalQuantity
				, intUserId = @intUserId
				, strNotes = strType + ' Collateral'
			FROM tblRKCollateral
		
			INSERT INTO @ExistingHistory(strTransactionType
				, intTransactionRecordId
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intCommodityId
				, intLocationId
				, dblQty
				, intUserId
				, strNotes)
			SELECT strTransactionType = 'Collateral Adjustments'
				, intTransactionRecordId = C.intCollateralId
				, strTransactionNumber = strAdjustmentNo
				, dtmTransactionDate = dtmAdjustmentDate
				, intContractDetailId = CA.intCollateralAdjustmentId
				, intContractHeaderId = C.intContractHeaderId
				, intCommodityId = intCommodityId
				, intLocationId = intLocationId
				, dblQty = CA.dblAdjustmentAmount
				, intUserId = @intUserId
				, strNotes = strType + ' Collateral'
			FROM tblRKCollateralAdjustment CA
			JOIN tblRKCollateral C ON C.intCollateralId = CA.intCollateralId
			WHERE intCollateralAdjustmentId NOT IN (SELECT DISTINCT adj.intCollateralAdjustmentId
					FROM tblRKCollateralAdjustment adj
					JOIN tblRKSummaryLog history ON history.intTransactionRecordId = adj.intCollateralId AND strTransactionType = 'Collateral Adjustments'
						AND adj.dtmAdjustmentDate = history.dtmTransactionDate
						AND adj.strAdjustmentNo = history.strTransactionNumber
						AND adj.dblAdjustmentAmount = history.dblOrigQty
					WHERE adj.intCollateralId = C.intCollateralId)
		
			EXEC uspRKLogRiskPosition @ExistingHistory, 1

			PRINT 'End Populate RK Summary Log'
		END
	END
	
END