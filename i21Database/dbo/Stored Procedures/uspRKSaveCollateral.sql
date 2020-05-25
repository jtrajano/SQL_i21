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
	SELECT col.*
		, con.*
	INTO #tmpCollateral
	FROM tblRKCollateral col
	OUTER APPLY (SELECT TOP 1 CD.intFutureMarketId
					, CD.intFutureMonthId
					, CH.intEntityId
				FROM tblCTContractDetail CD
				LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				WHERE CD.intContractHeaderId = col.intContractHeaderId) con
	WHERE intCollateralId = @intCollateralId


	SELECT * INTO #History FROM tblRKSummaryLog WHERE intTransactionRecordId = @intCollateralId AND strTransactionType = 'Collateral'
	DECLARE @SummaryLog AS RKSummaryLog

	select * from #tmpCollateral
	
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
				AND d.intContractHeaderId = h.intContractHeaderId
				AND d.intItemId = h.intItemId)
		BEGIN
			INSERT INTO @SummaryLog(strBucketType
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractHeaderId
				, intCommodityId
				, intItemId
				, intCommodityUOMId
				, intLocationId
				, dblQty
				, intEntityId
				, intUserId
				, strNotes
				, intFutureMarketId
				, intFutureMonthId
				, intActionId
				)
			SELECT strBucketType = 'Collateral'
				, strTransactionType = 'Collateral'
				, intTransactionRecordId = intCollateralId
				, intTransactionRecordHeaderId = intCollateralId
				, strDistributionType = strType
				, strTransactionNumber = strReceiptNo
				, dtmTransactionDate = dtmOpenDate
				, intContractHeaderId = intContractHeaderId
				, intCommodityId = C.intCommodityId
				, intItemId = intItemId
				, intCommodityUOMId =  CUM.intCommodityUnitMeasureId
				, intLocationId = intLocationId
				, dblQty = dblOriginalQuantity
				, intEntityId = intEntityId
				, intUserId = @intUserId
				, strComments
				, intFutureMarketId
				, intFutureMonthId
				, intActionId = 35
			FROM #tmpCollateral C
			LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = C.intUnitMeasureId AND CUM.intCommodityId = C.intCommodityId
		END

		-- Collateral Adjustments
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
			, intItemId
			, intCommodityUOMId
			, intLocationId
			, dblQty
			, intUserId
			, strNotes
			, intFutureMarketId
			, intFutureMonthId
			, intEntityId
			, intActionId)
		SELECT strBucketType = 'Collateral'
			, strTransactionType = 'Collateral Adjustments'
			, intTransactionRecordId = CA.intCollateralAdjustmentId
			, intTransactionRecordHeaderId = C.intCollateralId
			, strDistributionType = strType
			, strTransactionNumber = strAdjustmentNo
			, dtmTransactionDate = dtmAdjustmentDate
			, intContractDetailId = NULL
			, intContractHeaderId = C.intContractHeaderId
			, intCommodityId = C.intCommodityId
			, intItemId = intItemId
			, intCommodityUOMId =  CUM.intCommodityUnitMeasureId
			, intLocationId = intLocationId
			, dblQty = CA.dblAdjustmentAmount
			, intUserId = @intUserId
			, strNotes = CA.strComments
			, intFutureMarketId
			, intFutureMonthId
			, intEntityId
			, intActionId = 38
		FROM tblRKCollateralAdjustment CA
		JOIN #tmpCollateral C ON C.intCollateralId = CA.intCollateralId
		LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = C.intUnitMeasureId AND CUM.intCommodityId = C.intCommodityId
		WHERE intCollateralAdjustmentId NOT IN (SELECT DISTINCT adj.intCollateralAdjustmentId
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