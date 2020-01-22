CREATE PROCEDURE [dbo].[uspRKSaveCollateral]
	@intCollateralId INT
	, @intUserId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN	
	SELECT * INTO #tmpCollateral FROM tblRKCollateral WHERE intCollateralId = @intCollateralId
	SELECT * INTO #History FROM tblRKSummaryLog WHERE intTransactionRecordId = @intCollateralId AND strTransactionType = 'Collateral'
	DECLARE @SummaryLog AS RKSummaryLog
	
	IF EXISTS(SELECT TOP 1 1 FROM #tmpCollateral)
	BEGIN
		-- Collateral Headers
		IF NOT EXISTS(SELECT TOP 1 1
			FROM #tmpCollateral d
			JOIN #History h ON d.intCollateralId = h.intTransactionRecordId
				AND d.intCommodityId = h.intCommodityId
				AND d.intFutureMarketId = h.intFutureMarketId
				AND d.intFutureMonthId = h.intFutureMonthId
				AND d.dblOriginalQuantity = h.dblOrigQty
				AND d.dblPrice = h.dblPrice
				AND d.intContractDetailId = h.intContractDetailId
				AND d.intContractHeaderId = h.intContractHeaderId
				AND d.intItemId = h.intItemId)
		BEGIN
			INSERT INTO @SummaryLog(strTransactionType
				, intTransactionRecordId
				, strTransactionNumber
				, dtmTransactionDate
				, intContractHeaderId
				, intCommodityId
				, intItemId
				, intLocationId
				, dblQty
				, intEntityId
				, intUserId
				, strNotes)
			SELECT strTransactionType = 'Collateral'
				, intTransactionRecordId = intCollateralId
				, strTransactionNumber = strReceiptNo
				, dtmTransactionDate = dtmOpenDate
				, intContractHeaderId = intContractHeaderId
				, intCommodityId = intCommodityId
				, intItemId = intItemId
				, intLocationId = intLocationId
				, dblQty = dblOriginalQuantity
				, intEntityId = intEntityId
				, intUserId = @intUserId
				, strNotes = strType + ' Collateral'
			FROM #tmpCollateral
		END

		-- Collateral Adjustments
		INSERT INTO @SummaryLog(strTransactionType
			, intTransactionRecordId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intItemId
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
			, intItemId = intItemId
			, intLocationId = intLocationId
			, dblQty = CA.dblAdjustmentAmount
			, intUserId = @intUserId
			, strNotes = strType + ' Collateral'
		FROM tblRKCollateralAdjustment CA
		JOIN tblRKCollateral C ON C.intCollateralId = CA.intCollateralId
		WHERE C.intCollateralId = @intCollateralId
			AND intCollateralAdjustmentId NOT IN (SELECT DISTINCT adj.intCollateralAdjustmentId
				FROM tblRKCollateralAdjustment adj
				JOIN tblRKSummaryLog history ON history.intTransactionRecordId = adj.intCollateralId AND strTransactionType = 'Collateral Adjustments'
					AND adj.dtmAdjustmentDate = history.dtmTransactionDate
					AND adj.strAdjustmentNo = history.strTransactionNumber
					AND adj.dblAdjustmentAmount = history.dblOrigQty
				WHERE intCollateralId = @intCollateralId)
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
			SELECT strTransactionType = 'Collateral'
				, intTransactionRecordId = @intCollateralId
				, ysnDelete = 1
				, intUserId = @intUserId
				, strNotes = 'Delete record'
		END
	END

	EXEC uspRKLogRiskPosition @SummaryLog
	
	DROP TABLE #tmpCollateral
	DROP TABLE #History
END