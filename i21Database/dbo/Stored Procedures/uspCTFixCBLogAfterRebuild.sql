CREATE PROCEDURE uspCTFixCBLogAfterRebuild 
	@strContractNumber NVARCHAR(50) = 'All' -->> Specify Contract Number, put All if you want to apply in all contracts
	, @strContractType NVARCHAR(50) = 'All' -->> Purchase or Sale

AS

BEGIN
	DECLARE @intContractTypeId INT
		, @intContractHeaderId INT

	SELECT @intContractTypeId = intContractTypeId FROM tblCTContractType WHERE strContractType = @strContractType
	SELECT @intContractHeaderId = intContractHeaderId FROM tblCTContractHeader WHERE strContractNumber = @strContractNumber

	-----------------------------------------------------
	-- UPDATE Null Transaction Reference Ids (CT-6094) --
	-----------------------------------------------------
	UPDATE cbLog
	SET cbLog.intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
		, cbLog.intTransactionReferenceId = pf.intPriceContractId
	FROM tblCTContractBalanceLog cbLog
	JOIN tblCTPriceFixation pf ON pf.intPriceFixationId = cbLog.intTransactionReferenceId
	CROSS APPLY (
		SELECT pfd.intPriceFixationDetailId FROM tblCTPriceFixationDetail pfd WHERE pfd.intPriceFixationId = pf.intPriceFixationId AND convert(nvarchar(10),pfd.dtmFixationDate,101) = convert(nvarchar(10),cbLog.dtmTransactionDate,101)
	) pfd
	WHERE cbLog.intActionId = 1
		AND cbLog.strTransactionReference = 'Price Fixation' 
		AND cbLog.intTransactionReferenceDetailId IS NULL
		AND cbLog.intContractHeaderId = (CASE WHEN @strContractNumber = 'All' THEN cbLog.intContractHeaderId ELSE @intContractHeaderId END)
		AND cbLog.intContractTypeId = (CASE WHEN @strContractType = 'All' THEN cbLog.intContractTypeId ELSE @intContractTypeId END)
	-----------------------------------------------
	-- END UPDATE Null Transaction Reference Ids --
	-----------------------------------------------


	------------------------------------------------------------
	-- Fix Basis Price of previous partial pricings (CT-6137) --
	------------------------------------------------------------
	IF OBJECT_ID('tempdb..#tmpHistoricalBasis') IS NOT NULL
		DROP TABLE #tmpHistoricalBasis
	IF OBJECT_ID('tempdb..#tmpLogs') IS NOT NULL
		DROP TABLE #tmpLogs

	SELECT cb.intContractBalanceLogId, cb.intContractDetailId, cb.dtmTransactionDate, dtmBasisChange = History.dtmHistoryCreated, pf.dblOriginalBasis, dblPFDBasis = pfd.dblBasis, dblCBBasis = cb.dblBasis, dblSequenceBasis = cd.dblBasis, History.dblOldBasis, dblHistoryBasis = History.dblBasis
	INTO #tmpHistoricalBasis
	FROM tblCTContractBalanceLog cb
	JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationDetailId = cb.intTransactionReferenceDetailId AND strTransactionReference = 'Price Fixation'
	JOIN tblCTPriceFixation pf ON pf.intPriceFixationId = pfd.intPriceFixationId
	JOIN tblCTContractDetail cd ON cd.intContractDetailId = cb.intContractDetailId
	CROSS APPLY (
		SELECT TOP 1 dblBasis, dblOldBasis, dtmHistoryCreated FROM tblCTSequenceHistory
		WHERE intContractDetailId = cb.intContractDetailId
			AND CAST(FLOOR(CAST(dtmHistoryCreated AS FLOAT)) AS DATETIME) >= cb.dtmTransactionDate
			AND ISNULL(ysnBasisChange, 0) = 1
		ORDER BY intSequenceHistoryId DESC
	) History
	WHERE intActionId = 1
		AND strTransactionType = 'Contract Balance'
		AND cb.dblBasis <> pfd.dblBasis
		AND History.dblOldBasis = pfd.dblBasis

	DECLARE @intContractBalanceLogId INT
		, @intContractDetailId INT
		, @dtmTransactionDate DATETIME
		, @dblHistoricalBasis NUMERIC(24, 10)
		, @dblNewBasis NUMERIC(24, 10)
		, @dblBasisBalance NUMERIC(24, 10)


	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpHistoricalBasis)
	BEGIN	
		SELECT TOP 1 @intContractBalanceLogId = intContractBalanceLogId
			, @intContractDetailId = intContractDetailId
			, @dtmTransactionDate = dtmBasisChange
			, @dblHistoricalBasis = dblOldBasis
			, @dblNewBasis = dblCBBasis
		FROM #tmpHistoricalBasis

		SELECT intRowNumber = ROW_NUMBER() OVER (ORDER BY dtmTransactionDate), *
		INTO #tmpLogs
		FROM tblCTContractBalanceLog
		WHERE intContractDetailId = @intContractDetailId
			AND dtmTransactionDate <= @dtmTransactionDate
			AND ISNULL(dblBasis, 0) <> 0
		ORDER BY dtmTransactionDate

		-- Update Basis Price for logs before Basis Change
		UPDATE tblCTContractBalanceLog
		SET dblBasis = @dblHistoricalBasis
			, strNotes = ISNULL(strNotes, '') + 'Data fix on ' + CAST(GETDATE() AS NVARCHAR(100)) + '. Refer to jira CT-6137.'
		WHERE intContractDetailId = @intContractDetailId
			AND dtmTransactionDate <= @dtmTransactionDate
			AND ISNULL(dblBasis, 0) <> 0

		-- Get As of Basis Balance 
		SELECT TOP 1 @dblBasisBalance = SUM(dblQty)
		FROM #tmpLogs
		WHERE intPricingTypeId = 2
		GROUP BY intPricingTypeId

		-- INSERT Change Basis logs - Counter Basis Balance with new Basis Price
		INSERT INTO tblCTContractBalanceLog (strBatchId
			, intActionId
			, strAction
			, dtmTransactionDate
			, dtmCreatedDate
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, intCommodityId
			, intItemId
			, intLocationId
			, intPricingTypeId
			, intFutureMarketId
			, intFutureMonthId
			, dblBasis
			, intQtyUOMId
			, intQtyCurrencyId
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, dtmStartDate
			, dtmEndDate
			, dblQty
			, dblOrigQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, ysnNegated
			, intUserId
			, ysnDeleted)
		SELECT strBatchId
			, intActionId
			, strAction
			, dtmTransactionDate = @dtmTransactionDate
			, dtmCreatedDate = @dtmTransactionDate
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, intCommodityId
			, intItemId
			, intLocationId
			, intPricingTypeId = 2
			, intFutureMarketId
			, intFutureMonthId
			, dblBasis = @dblHistoricalBasis
			, intQtyUOMId
			, intQtyCurrencyId
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, dtmStartDate
			, dtmEndDate
			, dblQty = @dblBasisBalance * - 1
			, dblOrigQty = @dblBasisBalance
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes = ISNULL(strNotes, '') + 'Data fix on ' + CAST(GETDATE() AS NVARCHAR(100)) + '. Refer to jira CT-6137.'
			, ysnNegated = 0
			, intUserId
			, ysnDeleted = 0
		FROM #tmpLogs
		WHERE intRowNumber = 1

		UNION ALL SELECT TOP 1 strBatchId
			, intActionId
			, strAction
			, dtmTransactionDate = @dtmTransactionDate
			, dtmCreatedDate = @dtmTransactionDate
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, intCommodityId
			, intItemId
			, intLocationId
			, intPricingTypeId = 2
			, intFutureMarketId
			, intFutureMonthId
			, dblBasis = @dblNewBasis
			, intQtyUOMId
			, intQtyCurrencyId
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, dtmStartDate
			, dtmEndDate
			, dblQty = @dblBasisBalance
			, dblOrigQty = @dblBasisBalance
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes = ISNULL(strNotes, '') + 'Data fix on ' + CAST(GETDATE() AS NVARCHAR(100)) + '. Refer to jira CT-6137.'
			, ysnNegated = 0
			, intUserId
			, ysnDeleted = 0
		FROM #tmpLogs
		WHERE intRowNumber = 1	

		DROP TABLE #tmpLogs

		DELETE FROM #tmpHistoricalBasis WHERE intContractDetailId = @intContractDetailId
	END
	------------------------------------------------------------
	-- End Fix Basis Price of previous partial pricings (CT-6137) --
	------------------------------------------------------------


	--------------------------------------------------------------------
	-- Fix Null intDtlQtyInCommodityUOMId From Sequence History Table --
	--------------------------------------------------------------------
	UPDATE sh
	SET sh.intDtlQtyInCommodityUOMId = cd.intCommodityUOMId
	--SELECT cd.intContractDetailId, cd.intCommodityId, cd.intItemUOMId, cd.intCommodityUOMId
	FROM tblCTSequenceHistory sh
	JOIN (
		SELECT sh.intContractDetailId, sh.intCommodityId, sh.intItemUOMId, intCommodityUOMId = MIN(sh.intDtlQtyInCommodityUOMId)
		FROM tblCTSequenceHistory sh
		JOIN (
			SELECT DISTINCT intContractDetailId, intCommodityId, intItemUOMId
			FROM tblCTSequenceHistory WHERE intDtlQtyInCommodityUOMId IS NULL
		) cd ON  cd.intContractDetailId = sh.intContractDetailId AND cd.intCommodityId = sh.intCommodityId AND cd.intItemUOMId = sh.intItemUOMId
		GROUP BY sh.intContractDetailId, sh.intCommodityId, sh.intItemUOMId
	) cd ON cd.intContractDetailId = sh.intContractDetailId AND cd.intCommodityId = sh.intCommodityId AND cd.intItemUOMId = sh.intItemUOMId
	WHERE sh.intDtlQtyInCommodityUOMId IS NULL


	UPDATE sh
	SET sh.intDtlQtyInCommodityUOMId = cd.intCommodityUOMId
	--SELECT cd.intContractDetailId, cd.intCommodityId, cd.intItemUOMId, cd.intCommodityUOMId
	FROM tblCTSequenceHistory sh
	JOIN (
		SELECT main.intContractDetailId, main.intCommodityId, main.intItemUOMId, intCommodityUOMId = cum.intCommodityUnitMeasureId
		FROM (
			SELECT DISTINCT intContractDetailId, intCommodityId, intItemUOMId
			FROM tblCTSequenceHistory
			GROUP BY intContractDetailId, intCommodityId, intItemUOMId
			HAVING MIN(intDtlQtyInCommodityUOMId) IS NULL
		) main
		JOIN tblICItemUOM iUOM ON iUOM.intItemUOMId = main.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = main.intCommodityId AND cum.intUnitMeasureId = iUOM.intUnitMeasureId
	) cd ON cd.intContractDetailId = sh.intContractDetailId AND cd.intCommodityId = sh.intCommodityId AND cd.intItemUOMId = sh.intItemUOMId
	WHERE sh.intDtlQtyInCommodityUOMId IS NULL
	------------------------------------------------------------------------
	-- End Fix Null intDtlQtyInCommodityUOMId From Sequence History Table --
	------------------------------------------------------------------------

END