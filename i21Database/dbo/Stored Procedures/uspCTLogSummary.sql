﻿CREATE PROCEDURE [dbo].[uspCTLogSummary]
	@intContractHeaderId	INT,
    @intContractDetailId	INT,
	@strSource				NVARCHAR(20),
	@strProcess				NVARCHAR(50),
	@contractDetail			AS ContractDetailTable READONLY,
	@intUserId				INT = NULL,
	@intTransactionId		INT = NULL

AS

BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@ExistingHistory		AS RKSummaryLog,
			@cbLogPrev				AS CTContractBalanceLog,
			@cbLogCurrent			AS CTContractBalanceLog,
			@ysnDeleted				BIT = 0,
			@ysnMatched				BIT,
			@ysnDirect				BIT = 0

	-- SELECT @strSource, @strProcess

	IF @strProcess = 'Update Scheduled Quantity'
	BEGIN
		RETURN
	END
		
	IF @strSource = 'Pricing' AND @strProcess = 'Save Contract'
	BEGIN
		RETURN
	END

	-- IF @strSource = '' AND @strProcess = ''
	-- BEGIN
	-- 	SET @strSource = 'Contract'
	-- 	SET @strProcess = 'Save Contract'
	-- END
	IF @strSource = 'Contract'
	BEGIN
	
		-- Contract Sequence:
		-- 1. Create contract
		-- 	1.1. Increase balance
		-- 2. Edit quantity contract
		-- 	1.1. Increase/Reduce balance
		-- 3. Edit pricing type
		-- 	1.1. Negate basis
		-- 	1.2. Increase priced
		-- 4. Splitting sequence
		-- 	1.1. Reduce balance
		-- 	1.2. Increase balance for additional sequence
		-- 5. Deleting sequence
		-- 	1.1. Negate balance of the sequence
		IF EXISTS (SELECT TOP 1 1 FROM @contractDetail)
		BEGIN
			SET @ysnDeleted = 1
			-- Deleted contract detail
			INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
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
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId = -1
				, strTransactionReferenceNo = ''
				, intContractDetailId
				, intContractHeaderId
				, strContractNumber		
				, intContractSeq
				, intContractTypeId
				, intEntityId
				, intCommodityId
				, intItemId
				, intCompanyLocationId
				, intPricingTypeId
				, intFutureMarketId
				, intFutureMonthId
				, dblBasis
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId = NULL
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes = ''
				, intUserId
			FROM
			(
				SELECT 
					ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
					, sh.intSequenceHistoryId
					, dtmTransactionDate = dbo.fnRemoveTimeOnDate(cd.dtmCreated)
					, sh.intContractHeaderId
					, ch.strContractNumber
					, sh.intContractDetailId
					, cd.intContractSeq
					, ch.intContractTypeId
					, dblQty = sh.dblBalance
					, intQtyUOMId = ch.intCommodityUOMId
					, sh.intPricingTypeId
					, sh.strPricingType
					, strTransactionType = CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
					, intTransactionId = sh.intContractDetailId
					, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
					, sh.dblFutures
					, sh.dblBasis
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
					, sh.intContractStatusId
					, sh.intEntityId
					, sh.intCommodityId
					, sh.intItemId
					, sh.intCompanyLocationId
					, sh.intFutureMarketId
					, sh.intFutureMonthId
					, sh.dtmStartDate
					, sh.dtmEndDate
					, sh.intBookId
					, sh.intSubBookId
					, intOrderBy = 1
					, intUserId
				FROM tblCTSequenceHistory sh
				INNER JOIN @contractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				WHERE intSequenceUsageHistoryId IS NULL
			) tbl
		END
		ELSE
		BEGIN -- Contract Balance
			INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
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
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId = -1
				, strTransactionReferenceNo = ''
				, intContractDetailId
				, intContractHeaderId
				, strContractNumber		
				, intContractSeq
				, intContractTypeId
				, intEntityId
				, intCommodityId
				, intItemId
				, intCompanyLocationId
				, intPricingTypeId
				, intFutureMarketId
				, intFutureMonthId
				, dblBasis
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId = NULL
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes = ''
				, intUserId			
				, intActionId = null	
			FROM
			(
				SELECT 
					ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
					, sh.intSequenceHistoryId
					, dtmTransactionDate = dbo.fnRemoveTimeOnDate(sh.dtmHistoryCreated)--cd.dtmCreated
					, sh.intContractHeaderId
					, ch.strContractNumber
					, sh.intContractDetailId
					, cd.intContractSeq
					, ch.intContractTypeId
					, dblQty = sh.dblBalance
					, intQtyUOMId = ch.intCommodityUOMId
					, sh.intPricingTypeId
					, sh.strPricingType
					, strTransactionType = CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
					, intTransactionId = sh.intContractDetailId
					, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
					, sh.dblFutures
					, sh.dblBasis
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
					, sh.intContractStatusId
					, sh.intEntityId
					, sh.intCommodityId
					, sh.intItemId
					, sh.intCompanyLocationId
					, sh.intFutureMarketId
					, sh.intFutureMonthId
					, sh.dtmStartDate
					, sh.dtmEndDate
					, sh.intBookId
					, sh.intSubBookId
					, intOrderBy = 1
					, sh.intUserId
				FROM tblCTSequenceHistory sh
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				WHERE intSequenceUsageHistoryId IS NULL 
			) tbl
			WHERE Row_Num = 1
			AND intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		END
	END
	ELSE IF @strSource = 'Inventory'
	BEGIN
		-- Inventory Receipt/Shipment:
		-- 1. Posting
		-- 	1.1. Reduce balance
		-- 	1.2. Increase deliveries (if unpriced)
		-- 2. Unposting
		-- 	1.1. Increase balance
		-- 	1.2. Increase deliveries (if unpriced)
		INSERT INTO @cbLogCurrent (strBatchId
			, dtmTransactionDate
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
			, dblFutures
			, intQtyUOMId
			, intQtyCurrencyId
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, dtmStartDate
			, dtmEndDate
			, dblQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId
		)		
		SELECT strBatchId = NULL
		, dtmTransactionDate
		, strTransactionType = 'Contract Balance'
		, strTransactionReference = strTransactionType
		, intTransactionReferenceId = intTransactionId
		, strTransactionReferenceNo = strTransactionId
		, intContractDetailId
		, intContractHeaderId
		, strContractNumber		
		, intContractSeq
		, intContractTypeId
		, intEntityId
		, intCommodityId
		, intItemId
		, intCompanyLocationId
		, intPricingTypeId
		, intFutureMarketId
		, intFutureMonthId
		, dblBasis
		, dblFutures
		, intQtyUOMId
		, intQtyCurrencyId = NULL
		, intBasisUOMId
		, intBasisCurrencyId
		, intPriceUOMId
		, dtmStartDate
		, dtmEndDate
		, dblQty
		, intContractStatusId
		, intBookId
		, intSubBookId
		, strNotes = ''
		, intUserId
		, intActionId = CASE 
							WHEN intContractTypeId = 1 THEN 19 -- Inventory Received on Basis Delivery
							ELSE 18 -- Inventory Shipped on Basis Delivery
						END
		FROM 
		(
			SELECT ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
			, dtmTransactionDate = dbo.fnRemoveTimeOnDate(CASE WHEN ch.intContractTypeId = 1 THEN receipt.dtmReceiptDate ELSE shipment.dtmShipDate END)
			, strTransactionType = strScreenName
			, intTransactionId = suh.intExternalId -- or intExternalHeaderId since this was used by basis deliveries on search screen
			, strTransactionId = suh.strNumber
			, sh.intContractDetailId
			, sh.intContractHeaderId				
			, sh.strContractNumber
			, sh.intContractSeq
			, ch.intContractTypeId
			, sh.intEntityId
			, ch.intCommodityId
			, sh.intItemId
			, sh.intCompanyLocationId
			, intPricingTypeId = CASE WHEN suh.strScreenName IN ('Voucher', 'Invoice') THEN 1 ELSE sh.intPricingTypeId END
			, sh.intFutureMarketId  
			, sh.intFutureMonthId  
			, sh.dblBasis  
			, dblFutures = CASE WHEN suh.strScreenName IN ('Voucher', 'Invoice') THEN price.dblFutures ELSE sh.dblFutures END
			, intQtyUOMId = ch.intCommodityUOMId
			, cd.intBasisUOMId
			, cd.intBasisCurrencyId
			, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
			, sh.dtmStartDate
			, sh.dtmEndDate
			, dblQty = (CASE WHEN isnull(cd.intNoOfLoad,0) = 0 THEN suh.dblTransactionQuantity 
							ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * -1
			, sh.intContractStatusId
			, sh.intBookId
			, sh.intSubBookId		
			, sh.intUserId					
			FROM vyuCTSequenceUsageHistory suh
			INNER JOIN tblCTSequenceHistory sh on sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
			INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
			INNER JOIN tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			LEFT JOIN tblICInventoryShipment shipment on suh.intExternalHeaderId = shipment.intInventoryShipmentId
			LEFT JOIN tblICInventoryReceipt receipt on suh.intExternalHeaderId = receipt.intInventoryReceiptId
			OUTER APPLY 
			(
				SELECT dblFutures = AVG(pfd.dblFutures)
				FROM tblCTPriceFixation pf 
				INNER JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId
				WHERE pf.intContractHeaderId = suh.intContractHeaderId 
				AND pf.intContractDetailId = suh.intContractDetailId
			) price
			WHERE strFieldName = 'Balance'
		) tbl
		WHERE Row_Num = 1
		AND intContractHeaderId = @intContractHeaderId
		AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)

		IF NOT EXISTS (SELECT TOP 1 1 FROM @cbLogCurrent)
		BEGIN
			SET @ysnDirect = 1
			INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
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
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
			)		
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId = intTransactionId
				, strTransactionReferenceNo = strTransactionId
				, intContractDetailId
				, intContractHeaderId
				, strContractNumber		
				, intContractSeq
				, intContractTypeId
				, intEntityId
				, intCommodityId
				, intItemId
				, intCompanyLocationId
				, intPricingTypeId
				, intFutureMarketId
				, intFutureMonthId
				, dblBasis
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId = NULL
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes = ''
			FROM 
			(
				SELECT  
					ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
					, dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
					, strTransactionType = strScreenName
					, intTransactionId = suh.intExternalId -- or intExternalHeaderId since this was used by basis deliveries on search screen
					, strTransactionId = suh.strNumber
					, sh.intContractDetailId
					, sh.intContractHeaderId				
					, sh.strContractNumber
					, sh.intContractSeq
					, ch.intContractTypeId
					, sh.intEntityId
					, ch.intCommodityId
					, sh.intItemId
					, sh.intCompanyLocationId
					, sh.intPricingTypeId
					, sh.intFutureMarketId
					, sh.intFutureMonthId
					, sh.dblBasis
					, sh.dblFutures
					, intQtyUOMId = ch.intCommodityUOMId
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
					, sh.dtmStartDate
					, sh.dtmEndDate
					, dblQty = (CASE WHEN isnull(cd.intNoOfLoad,0) = 0 THEN suh.dblTransactionQuantity 
									ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * -1
					, sh.intContractStatusId
					, sh.intBookId
					, sh.intSubBookId							
				FROM vyuCTSequenceUsageHistory suh
					INNER JOIN tblCTSequenceHistory sh on sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
					INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
					INNER JOIN tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
				WHERE strFieldName = 'Balance'
			) tbl
			WHERE Row_Num = 1
			AND intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		END		
	END
	ELSE IF @strSource = 'Pricing'
	BEGIN
		-- Contract Pricing:
		-- 1. Add pricing
		-- 	1.1. Reduce basis
		-- 	1.2. Increase price
		-- 	1.3. Reduce basis deliveries (with is/ir)
		-- 2. Delete pricing
		-- 	1.1. Increase basis
		-- 	1.2. Decrease priced
		-- 	1.3. Increase basis deliveries (with is/ir)
		--IF @strProcess IN ('Voucher','Voucher Delete', 'Reverse')
		--BEGIN
		--	IF @strProcess = 'Voucher'
		--	BEGIN
		--		IF NOT EXISTS
		--		(
		--			SELECT TOP 1 1  
		--			FROM vyuCTSequenceUsageHistory a
		--			INNER JOIN tblAPBillDetail b ON a.intContractHeaderId = b.intContractHeaderId
		--					AND a.intContractDetailId = b.intContractDetailId
		--			WHERE a.intContractHeaderId = @intContractHeaderId
		--				AND a.intContractDetailId = ISNULL(@intContractDetailId, a.intContractDetailId)
		--				AND b.intBillDetailId NOT IN 
		--				(
		--					SELECT intTransactionReferenceId
		--					FROM tblCTContractBalanceLog 
		--					WHERE intContractDetailId = a.intContractDetailId
		--					AND strTransactionReference = 'Voucher'
		--				)
		--				AND a.strScreenName = 'Settle Storage'
		--		)
		--		BEGIN
		--			INSERT INTO @cbLogCurrent (strBatchId
		--				, dtmTransactionDate
		--				, strTransactionType
		--				, strTransactionReference
		--				, intTransactionReferenceId
		--				, strTransactionReferenceNo
		--				, intContractDetailId
		--				, intContractHeaderId
		--				, strContractNumber
		--				, intContractSeq
		--				, intContractTypeId
		--				, intEntityId
		--				, intCommodityId
		--				, intItemId
		--				, intLocationId
		--				, intPricingTypeId
		--				, intFutureMarketId
		--				, intFutureMonthId
		--				, dblBasis
		--				, dblFutures
		--				, intQtyUOMId
		--				, intQtyCurrencyId
		--				, intBasisUOMId
		--				, intBasisCurrencyId
		--				, intPriceUOMId
		--				, dtmStartDate
		--				, dtmEndDate
		--				, dblQty
		--				, intContractStatusId
		--				, intBookId
		--				, intSubBookId
		--				, strNotes
		--			)
		--			SELECT strBatchId = NULL
		--				, dtmTransactionDate
		--				, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
		--				, strTransactionReference = strTransactionType
		--				, intTransactionReferenceId = intTransactionId
		--				, strTransactionReferenceNo = strTransactionId
		--				, intContractDetailId
		--				, intContractHeaderId
		--				, strContractNumber		
		--				, intContractSeq
		--				, intContractTypeId
		--				, intEntityId
		--				, intCommodityId
		--				, intItemId
		--				, intCompanyLocationId
		--				, intPricingTypeId
		--				, intFutureMarketId
		--				, intFutureMonthId
		--				, dblBasis
		--				, dblFutures
		--				, intQtyUOMId
		--				, intQtyCurrencyId = NULL
		--				, intBasisUOMId
		--				, intBasisCurrencyId
		--				, intPriceUOMId
		--				, dtmStartDate
		--				, dtmEndDate
		--				, dblQty
		--				, intContractStatusId
		--				, intBookId
		--				, intSubBookId
		--				, strNotes = ''
		--			FROM
		--			(
		--				SELECT dtmTransactionDate = dbo.fnRemoveTimeOnDate(b.dtmBillDate)
		--					, strTransactionType = 'Voucher'
		--					, intTransactionId = bd.intBillDetailId
		--					, strTransactionId = b.strBillId
		--					, sh.intContractDetailId
		--					, sh.intContractHeaderId		
		--					, sh.strContractNumber
		--					, sh.intContractSeq
		--					, ch.intContractTypeId
		--					, sh.intEntityId
		--					, ch.intCommodityId
		--					, sh.intItemId
		--					, sh.intCompanyLocationId
		--					, sh.intPricingTypeId
		--					, sh.intFutureMarketId
		--					, sh.intFutureMonthId
		--					, sh.dblBasis
		--					, dblFutures = ISNULL(sh.dblFutures, future.dblFutures)
		--					, intQtyUOMId = ch.intCommodityUOMId
		--					, cd.intBasisUOMId
		--					, cd.intBasisCurrencyId
		--					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
		--					, sh.dtmStartDate
		--					, sh.dtmEndDate
		--					, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN bd.dblQtyReceived 
		--									ELSE cd.dblQuantityPerLoad END) --* -1
		--					, sh.intContractStatusId
		--					, sh.intBookId
		--					, sh.intSubBookId					
		--				FROM vyuCTSequenceUsageHistory suh
		--				INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		--				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		--				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		--				INNER JOIN tblAPBillDetail bd ON suh.intExternalId = bd.intInventoryReceiptItemId
		--				INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
		--				OUTER APPLY
		--				(
		--					SELECT TOP 1 dblFutures 
		--					FROM tblCTSequenceHistory 
		--					WHERE intContractDetailId = sh.intContractDetailId
		--					AND intSequenceHistoryId > sh.intSequenceHistoryId
		--					AND dblFutures IS NOT NULL
		--				) future
		--				WHERE strFieldName = 'Balance'
		--				-- AND sh.strPricingStatus = 'Unpriced'
		--				-- AND sh.strPricingType = 'Basis'
		--				AND bd.intInventoryReceiptChargeId IS NULL
		--				AND bd.intBillDetailId NOT IN 
		--				(
		--					SELECT intTransactionReferenceId
		--					FROM tblCTContractBalanceLog 
		--					WHERE intContractDetailId = cd.intContractDetailId
		--					AND strTransactionReference = 'Voucher'
		--				)
		--			) tbl
		--			WHERE intContractHeaderId = @intContractHeaderId
		--			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		--		END
		--		ELSE
		--		BEGIN
		--			INSERT INTO @cbLogCurrent (strBatchId
		--				, dtmTransactionDate
		--				, strTransactionType
		--				, strTransactionReference
		--				, intTransactionReferenceId
		--				, strTransactionReferenceNo
		--				, intContractDetailId
		--				, intContractHeaderId
		--				, strContractNumber
		--				, intContractSeq
		--				, intContractTypeId
		--				, intEntityId
		--				, intCommodityId
		--				, intItemId
		--				, intLocationId
		--				, intPricingTypeId
		--				, intFutureMarketId
		--				, intFutureMonthId
		--				, dblBasis
		--				, dblFutures
		--				, intQtyUOMId
		--				, intQtyCurrencyId
		--				, intBasisUOMId
		--				, intBasisCurrencyId
		--				, intPriceUOMId
		--				, dtmStartDate
		--				, dtmEndDate
		--				, dblQty
		--				, intContractStatusId
		--				, intBookId
		--				, intSubBookId
		--				, strNotes
		--			)
		--			SELECT strBatchId = NULL
		--				, dtmTransactionDate
		--				, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
		--				, strTransactionReference = strTransactionType
		--				, intTransactionReferenceId = intTransactionId
		--				, strTransactionReferenceNo = strTransactionId
		--				, intContractDetailId
		--				, intContractHeaderId
		--				, strContractNumber		
		--				, intContractSeq
		--				, intContractTypeId
		--				, intEntityId
		--				, intCommodityId
		--				, intItemId
		--				, intCompanyLocationId
		--				, intPricingTypeId
		--				, intFutureMarketId
		--				, intFutureMonthId
		--				, dblBasis
		--				, dblFutures
		--				, intQtyUOMId
		--				, intQtyCurrencyId = NULL
		--				, intBasisUOMId
		--				, intBasisCurrencyId
		--				, intPriceUOMId
		--				, dtmStartDate
		--				, dtmEndDate
		--				, dblQty
		--				, intContractStatusId
		--				, intBookId
		--				, intSubBookId
		--				, strNotes = ''
		--			FROM
		--			(
		--				SELECT dtmTransactionDate = dbo.fnRemoveTimeOnDate(b.dtmBillDate)
		--					, strTransactionType = 'Voucher'
		--					, intTransactionId = bd.intBillDetailId
		--					, strTransactionId = b.strBillId
		--					, sh.intContractDetailId
		--					, sh.intContractHeaderId		
		--					, sh.strContractNumber
		--					, sh.intContractSeq
		--					, ch.intContractTypeId
		--					, sh.intEntityId
		--					, ch.intCommodityId
		--					, sh.intItemId
		--					, sh.intCompanyLocationId
		--					, sh.intPricingTypeId
		--					, sh.intFutureMarketId
		--					, sh.intFutureMonthId
		--					, sh.dblBasis
		--					, sh.dblFutures
		--					, intQtyUOMId = ch.intCommodityUOMId
		--					, cd.intBasisUOMId
		--					, cd.intBasisCurrencyId
		--					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
		--					, sh.dtmStartDate
		--					, sh.dtmEndDate
		--					, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN bd.dblQtyReceived 
		--									ELSE cd.dblQuantityPerLoad END) --* -1
		--					, sh.intContractStatusId
		--					, sh.intBookId
		--					, sh.intSubBookId					
		--				FROM vyuCTSequenceUsageHistory suh
		--				INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		--				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		--				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		--				INNER JOIN tblAPBillDetail bd ON suh.intContractHeaderId = bd.intContractHeaderId and suh.intContractDetailId = bd.intContractDetailId
		--				INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
		--				WHERE strFieldName = 'Balance'
		--				-- AND sh.strPricingStatus = 'Unpriced'
		--				-- AND sh.strPricingType = 'Basis'
		--				AND bd.intInventoryReceiptChargeId IS NULL
		--				AND bd.intBillDetailId NOT IN 
		--				(
		--					SELECT intTransactionReferenceId
		--					FROM tblCTContractBalanceLog 
		--					WHERE intContractDetailId = cd.intContractDetailId
		--					AND strTransactionReference = 'Voucher'
		--				)
		--			) tbl
		--			WHERE intContractHeaderId = @intContractHeaderId
		--			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		--		END
		--	END
		--	ELSE IF @strProcess = 'Reverse'
		--	BEGIN
		--		INSERT INTO @cbLogCurrent (strBatchId
		--			, dtmTransactionDate
		--			, strTransactionType
		--			, strTransactionReference
		--			, intTransactionReferenceId
		--			, strTransactionReferenceNo
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes
		--		)
		--		SELECT strBatchId = NULL
		--			, dtmTransactionDate
		--			, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
		--			, strTransactionReference = strTransactionType
		--			, intTransactionReferenceId = intTransactionId
		--			, strTransactionReferenceNo = strTransactionId
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber		
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intCompanyLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId = NULL
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes = ''
		--		FROM
		--		(
		--			SELECT dtmTransactionDate = dbo.fnRemoveTimeOnDate(b.dtmBillDate)
		--				, strTransactionType = 'Voucher'
		--				, intTransactionId = bd.intBillDetailId
		--				, strTransactionId = b.strBillId
		--				, sh.intContractDetailId
		--				, sh.intContractHeaderId		
		--				, sh.strContractNumber
		--				, sh.intContractSeq
		--				, ch.intContractTypeId
		--				, sh.intEntityId
		--				, ch.intCommodityId
		--				, sh.intItemId
		--				, sh.intCompanyLocationId
		--				, sh.intPricingTypeId
		--				, sh.intFutureMarketId
		--				, sh.intFutureMonthId
		--				, sh.dblBasis
		--				, sh.dblFutures
		--				, intQtyUOMId = ch.intCommodityUOMId
		--				, cd.intBasisUOMId
		--				, cd.intBasisCurrencyId
		--				, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
		--				, sh.dtmStartDate
		--				, sh.dtmEndDate
		--				, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN bd.dblQtyReceived 
		--								ELSE cd.dblQuantityPerLoad END) --* -1
		--				, sh.intContractStatusId
		--				, sh.intBookId
		--				, sh.intSubBookId					
		--			FROM vyuCTSequenceUsageHistory suh
		--			INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		--			INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		--			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		--			INNER JOIN tblAPBillDetail bd ON suh.intExternalId = bd.intInventoryReceiptItemId
		--			INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
		--			WHERE strFieldName = 'Balance'
		--			-- AND sh.strPricingStatus = 'Unpriced'
		--			-- AND sh.strPricingType = 'Basis'
		--			AND bd.intInventoryReceiptChargeId IS NULL
		--			AND bd.intBillDetailId NOT IN 
		--			(
		--				SELECT intTransactionReferenceId
		--				FROM tblCTContractBalanceLog 
		--				WHERE intContractDetailId = cd.intContractDetailId
		--				AND strTransactionReference = 'Voucher'
		--			)

		--		) tbl
		--		WHERE intContractHeaderId = @intContractHeaderId
		--		AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		--	END
		--	ELSE
		--	BEGIN
		--		INSERT INTO @cbLogCurrent (strBatchId
		--			, dtmTransactionDate
		--			, strTransactionType
		--			, strTransactionReference
		--			, intTransactionReferenceId
		--			, strTransactionReferenceNo
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes
		--		)
		--		SELECT strBatchId = NULL
		--			, dtmTransactionDate
		--			, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
		--			, strTransactionReference = strTransactionType
		--			, intTransactionReferenceId = intTransactionId
		--			, strTransactionReferenceNo = strTransactionId
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber		
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intCompanyLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId = NULL
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes = ''
		--		FROM
		--		(
		--			SELECT dtmTransactionDate = dbo.fnRemoveTimeOnDate(b.dtmBillDate)
		--				, strTransactionType = 'Voucher'
		--				, intTransactionId = bd.intBillDetailId
		--				, strTransactionId = b.strBillId
		--				, sh.intContractDetailId
		--				, sh.intContractHeaderId		
		--				, sh.strContractNumber
		--				, sh.intContractSeq
		--				, ch.intContractTypeId
		--				, sh.intEntityId
		--				, ch.intCommodityId
		--				, sh.intItemId
		--				, sh.intCompanyLocationId
		--				, sh.intPricingTypeId
		--				, sh.intFutureMarketId
		--				, sh.intFutureMonthId
		--				, sh.dblBasis
		--				, sh.dblFutures
		--				, intQtyUOMId = ch.intCommodityUOMId
		--				, cd.intBasisUOMId
		--				, cd.intBasisCurrencyId
		--				, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
		--				, sh.dtmStartDate
		--				, sh.dtmEndDate
		--				, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN bd.dblQtyReceived 
		--								ELSE cd.dblQuantityPerLoad END) --* -1
		--				, sh.intContractStatusId
		--				, sh.intBookId
		--				, sh.intSubBookId					
		--			FROM vyuCTSequenceUsageHistory suh
		--			INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		--			INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		--			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		--			INNER JOIN tblAPBillDetail bd ON suh.intExternalId = bd.intInventoryReceiptItemId
		--			INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
		--			WHERE strFieldName = 'Balance'
		--			-- AND sh.strPricingStatus = 'Unpriced'
		--			-- AND sh.strPricingType = 'Basis'
		--			AND bd.intInventoryReceiptChargeId IS NULL
		--		) tbl
		--		WHERE intContractHeaderId = @intContractHeaderId
		--		AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		--	END
		--END
		--ELSE IF @strProcess IN ('Invoice', 'Invoice Delete')
		--BEGIN
		--	IF @strProcess = 'Invoice'
		--	BEGIN
		--		INSERT INTO @cbLogCurrent (strBatchId
		--			, dtmTransactionDate
		--			, strTransactionType
		--			, strTransactionReference
		--			, intTransactionReferenceId
		--			, strTransactionReferenceNo
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes
		--		)
		--		SELECT strBatchId = NULL
		--			, dtmTransactionDate
		--			, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
		--			, strTransactionReference = strTransactionType
		--			, intTransactionReferenceId = intTransactionId
		--			, strTransactionReferenceNo = strTransactionId
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber		
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intCompanyLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId = NULL
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes = ''
		--		FROM
		--		(
		--			SELECT  
		--				dtmTransactionDate = dbo.fnRemoveTimeOnDate(i.dtmDate)
		--				, strTransactionType = 'Invoice'
		--				, intTransactionId = id.intInvoiceDetailId
		--				, strTransactionId = i.strInvoiceNumber
		--				, sh.intContractDetailId
		--				, sh.intContractHeaderId		
		--				, sh.strContractNumber
		--				, sh.intContractSeq
		--				, ch.intContractTypeId
		--				, sh.intEntityId
		--				, ch.intCommodityId
		--				, sh.intItemId
		--				, sh.intCompanyLocationId
		--				, sh.intPricingTypeId
		--				, sh.intFutureMarketId
		--				, sh.intFutureMonthId
		--				, sh.dblBasis
		--				, dblFutures = ISNULL(sh.dblFutures, future.dblFutures)
		--				, intQtyUOMId = ch.intCommodityUOMId
		--				, cd.intBasisUOMId
		--				, cd.intBasisCurrencyId
		--				, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
		--				, sh.dtmStartDate
		--				, sh.dtmEndDate
		--				, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN id.dblQtyShipped 
		--								ELSE cd.dblQuantityPerLoad END) --* -1
		--				, sh.intContractStatusId
		--				, sh.intBookId
		--				, sh.intSubBookId	
		--			FROM vyuCTSequenceUsageHistory suh
		--			INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		--			INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		--			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		--			INNER JOIN tblARInvoiceDetail id ON suh.intExternalId = id.intInventoryShipmentItemId
		--			INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
		--			OUTER APPLY
		--			(
		--				SELECT TOP 1 dblFutures 
		--				FROM tblCTSequenceHistory 
		--				WHERE intContractDetailId = sh.intContractDetailId
		--				AND intSequenceHistoryId > sh.intSequenceHistoryId
		--				AND dblFutures IS NOT NULL
		--			) future
		--			WHERE strFieldName = 'Balance'
		--			-- AND sh.strPricingStatus = 'Unpriced'
		--			-- AND sh.strPricingType = 'Basis'
		--			AND id.intInventoryShipmentChargeId IS NULL
		--			AND suh.intContractHeaderId = @intContractHeaderId
		--			AND id.intInvoiceDetailId NOT IN 
		--			(
		--				SELECT intTransactionReferenceId
		--				FROM tblCTContractBalanceLog 
		--				WHERE intContractDetailId = cd.intContractDetailId
		--				AND strTransactionReference = 'Invoice'
		--			)
		--		)tbl
		--		WHERE intContractHeaderId = @intContractHeaderId
		--		AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		--	END
		--	ELSE
		--	BEGIN
		--		INSERT INTO @cbLogCurrent (strBatchId
		--			, dtmTransactionDate
		--			, strTransactionType
		--			, strTransactionReference
		--			, intTransactionReferenceId
		--			, strTransactionReferenceNo
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes
		--		)
		--		SELECT strBatchId = NULL
		--			, dtmTransactionDate
		--			, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
		--			, strTransactionReference = strTransactionType
		--			, intTransactionReferenceId = intTransactionId
		--			, strTransactionReferenceNo = strTransactionId
		--			, intContractDetailId
		--			, intContractHeaderId
		--			, strContractNumber		
		--			, intContractSeq
		--			, intContractTypeId
		--			, intEntityId
		--			, intCommodityId
		--			, intItemId
		--			, intCompanyLocationId
		--			, intPricingTypeId
		--			, intFutureMarketId
		--			, intFutureMonthId
		--			, dblBasis
		--			, dblFutures
		--			, intQtyUOMId
		--			, intQtyCurrencyId = NULL
		--			, intBasisUOMId
		--			, intBasisCurrencyId
		--			, intPriceUOMId
		--			, dtmStartDate
		--			, dtmEndDate
		--			, dblQty
		--			, intContractStatusId
		--			, intBookId
		--			, intSubBookId
		--			, strNotes = ''
		--		FROM
		--		(
		--			SELECT  
		--				dtmTransactionDate = dbo.fnRemoveTimeOnDate(i.dtmDate)
		--				, strTransactionType = 'Invoice'
		--				, intTransactionId = id.intInvoiceDetailId
		--				, strTransactionId = i.strInvoiceNumber
		--				, sh.intContractDetailId
		--				, sh.intContractHeaderId		
		--				, sh.strContractNumber
		--				, sh.intContractSeq
		--				, ch.intContractTypeId
		--				, sh.intEntityId
		--				, ch.intCommodityId
		--				, sh.intItemId
		--				, sh.intCompanyLocationId
		--				, sh.intPricingTypeId
		--				, sh.intFutureMarketId
		--				, sh.intFutureMonthId
		--				, sh.dblBasis
		--				, sh.dblFutures
		--				, intQtyUOMId = ch.intCommodityUOMId
		--				, cd.intBasisUOMId
		--				, cd.intBasisCurrencyId
		--				, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
		--				, sh.dtmStartDate
		--				, sh.dtmEndDate
		--				, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN id.dblQtyShipped 
		--								ELSE cd.dblQuantityPerLoad END) --* -1
		--				, sh.intContractStatusId
		--				, sh.intBookId
		--				, sh.intSubBookId	
		--			FROM vyuCTSequenceUsageHistory suh
		--			INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		--			INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		--			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		--			INNER JOIN tblARInvoiceDetail id ON suh.intExternalId = id.intInventoryShipmentItemId
		--			INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
		--			WHERE strFieldName = 'Balance'
		--			-- AND sh.strPricingStatus = 'Unpriced'
		--			-- AND sh.strPricingType = 'Basis'
		--			AND id.intInventoryShipmentChargeId IS NULL
		--			AND suh.intContractHeaderId = @intContractHeaderId					
		--		)tbl
		--		WHERE intContractHeaderId = @intContractHeaderId
		--		AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		--	END
		--END
		--ELSE -- Price Fixation/Delete
		--BEGIN
			IF @strProcess = 'Price Delete'
			BEGIN
				INSERT INTO @cbLogCurrent (strBatchId
					, dtmTransactionDate
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
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
				)
				SELECT strBatchId = NULL
					, dtmTransactionDate
					, strTransactionType = 'Contract Balance'
					, strTransactionReference = strTransactionType
					, intTransactionReferenceId = -1
					, strTransactionReferenceNo = ''
					, intContractDetailId
					, intContractHeaderId
					, strContractNumber		
					, intContractSeq
					, intContractTypeId
					, intEntityId
					, intCommodityId
					, intItemId
					, intCompanyLocationId
					, intPricingTypeId
					, intFutureMarketId
					, intFutureMonthId
					, dblBasis
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId = NULL
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes = ''
					, intUserId
				FROM
				(
					SELECT 
						ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
						, sh.intSequenceHistoryId
						, dtmTransactionDate = dbo.fnRemoveTimeOnDate(sh.dtmHistoryCreated)
						, sh.intContractHeaderId
						, ch.strContractNumber
						, sh.intContractDetailId
						, cd.intContractSeq
						, ch.intContractTypeId
						, dblQty = sh.dblBalance
						, intQtyUOMId = ch.intCommodityUOMId
						, sh.intPricingTypeId
						, sh.strPricingType
						, strTransactionType = 'Price Delete'
						, intTransactionId = sh.intContractDetailId
						, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
						, sh.dblFutures
						, sh.dblBasis
						, cd.intBasisUOMId
						, cd.intBasisCurrencyId
						, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
						, sh.intContractStatusId
						, sh.intEntityId
						, sh.intCommodityId
						, sh.intItemId
						, sh.intCompanyLocationId
						, sh.intFutureMarketId
						, sh.intFutureMonthId
						, sh.dtmStartDate
						, sh.dtmEndDate
						, sh.intBookId
						, sh.intSubBookId
						, intOrderBy = 1
						, sh.intUserId
					FROM tblCTSequenceHistory sh
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId					
					WHERE intSequenceUsageHistoryId IS NULL
					-- Retest Price Delete without IS/IR
					--AND sh.strPricingStatus = 'Fully Priced'
				) tbl
				WHERE Row_Num = 1
				AND intContractHeaderId = @intContractHeaderId
				AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)						
			END
			IF @strProcess = 'Fixation Detail Delete'
			BEGIN
				INSERT INTO @cbLogCurrent (strBatchId
					, dtmTransactionDate
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
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
				  , intUserId
				)
				SELECT strBatchId = NULL
					, dtmTransactionDate
					, strTransactionType = 'Contract Balance'
					, strTransactionReference = strTransactionType
					, intTransactionReferenceId
					, strTransactionReferenceNo = ''
					, intContractDetailId
					, intContractHeaderId
					, strContractNumber		
					, intContractSeq
					, intContractTypeId
					, intEntityId
					, intCommodityId
					, intItemId
					, intCompanyLocationId
					, intPricingTypeId
					, intFutureMarketId
					, intFutureMonthId
					, dblBasis
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId = NULL
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes = ''
					, intUserId
				FROM
				(
					SELECT intTransactionReferenceId = pfd.intPriceFixationDetailId
					, dtmTransactionDate = dbo.fnRemoveTimeOnDate(pfd.dtmFixationDate)
					, sh.intContractHeaderId
					, ch.strContractNumber
					, sh.intContractDetailId
					, cd.intContractSeq
					, ch.intContractTypeId
					, dblQty = pfd.dblQuantity
					, intQtyUOMId = ch.intCommodityUOMId
					, intPricingTypeId = 1
					, strPricingType = 'Priced'
					, strTransactionType = CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
					, intTransactionId = sh.intContractDetailId
					, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
					, dblFutures = pfd.dblFutures
					, sh.dblBasis
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
					, sh.intContractStatusId
					, sh.intEntityId
					, sh.intCommodityId
					, sh.intItemId
					, sh.intCompanyLocationId
					, sh.intFutureMarketId
					, sh.intFutureMonthId
					, sh.dtmStartDate
					, sh.dtmEndDate
					, sh.intBookId
					, sh.intSubBookId
					, intOrderBy = 1
					, sh.intUserId
					FROM tblCTPriceFixationDetail pfd
					INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					OUTER APPLY
					(
						SELECT TOP 1 *
						FROM tblCTSequenceHistory
						WHERE intContractHeaderId = pf.intContractHeaderId
						AND intContractDetailId = pf.intContractDetailId
						AND intSequenceUsageHistoryId IS NULL
						ORDER BY dtmHistoryCreated DESC
					) sh
					WHERE pfd.ysnToBeDeleted = 1		
					AND pfd.intPriceFixationDetailId NOT IN
					(
						SELECT intTransactionReferenceId
						FROM tblCTContractBalanceLog
						WHERE strTransactionReference = 'Fixation Detail Delete'
						AND intContractHeaderId = @intContractHeaderId
						AND intContractDetailId = ISNULL(@intContractDetailId, cd.intContractDetailId)
					)			
				) tbl
				WHERE intContractHeaderId = @intContractHeaderId
				AND intContractDetailId = ISNULL(@intContractDetailId, tbl.intContractDetailId)
			END
			ELSE
			BEGIN
				INSERT INTO @cbLogCurrent (strBatchId
					, dtmTransactionDate
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
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
				    , intUserId
				)
				SELECT strBatchId = NULL
					, dtmTransactionDate
					, strTransactionType = 'Contract Balance'
					, strTransactionReference = strTransactionType
					, intTransactionReferenceId
					, strTransactionReferenceNo = ''
					, intContractDetailId
					, intContractHeaderId
					, strContractNumber		
					, intContractSeq
					, intContractTypeId
					, intEntityId
					, intCommodityId
					, intItemId
					, intCompanyLocationId
					, intPricingTypeId
					, intFutureMarketId
					, intFutureMonthId
					, dblBasis
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId = NULL
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes = ''
					, intUserId
				FROM
				(
					SELECT intTransactionReferenceId = pfd.intPriceFixationDetailId
					, dtmTransactionDate = dbo.fnRemoveTimeOnDate(pfd.dtmFixationDate)
					, sh.intContractHeaderId
					, ch.strContractNumber
					, sh.intContractDetailId
					, cd.intContractSeq
					, ch.intContractTypeId
					, dblQty = pfd.dblQuantity
					, intQtyUOMId = ch.intCommodityUOMId
					, intPricingTypeId = 1
					, strPricingType = 'Priced'
					, strTransactionType = CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
					, intTransactionId = sh.intContractDetailId
					, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
					, dblFutures = pfd.dblFutures
					, sh.dblBasis
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
					, sh.intContractStatusId
					, sh.intEntityId
					, sh.intCommodityId
					, sh.intItemId
					, sh.intCompanyLocationId
					, sh.intFutureMarketId
					, sh.intFutureMonthId
					, sh.dtmStartDate
					, sh.dtmEndDate
					, sh.intBookId
					, sh.intSubBookId
					, intOrderBy = 1
					, sh.intUserId
					FROM tblCTPriceFixationDetail pfd
					INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					OUTER APPLY
					(
						SELECT TOP 1 *
						FROM tblCTSequenceHistory
						WHERE intContractHeaderId = pf.intContractHeaderId
						AND intContractDetailId = pf.intContractDetailId
						AND intSequenceUsageHistoryId IS NULL
						ORDER BY dtmHistoryCreated DESC
					) sh
					WHERE pfd.intPriceFixationDetailId NOT IN
					(
						SELECT intTransactionReferenceId
						FROM tblCTContractBalanceLog
						WHERE strTransactionReference = 'Price Fixation'
						AND intContractHeaderId = @intContractHeaderId
						AND intContractDetailId = ISNULL(@intContractDetailId, cd.intContractDetailId)
					)
				) tbl
				WHERE intContractHeaderId = @intContractHeaderId
				AND intContractDetailId = ISNULL(@intContractDetailId, tbl.intContractDetailId)
			END
			
		--END
	END
	--ELSE IF @strSource = 'Invoice'
	--BEGIN
	--	-- Invoice/Detail:
	--	-- Should be called before deleting the invoice detail
	--	-- 1. Delete Invoice/Detail
	--	-- 	1.1. Reduce basis deliveries
	--	INSERT INTO @cbLogCurrent (strBatchId
	--		, dtmTransactionDate
	--		, strTransactionType
	--		, strTransactionReference
	--		, intTransactionReferenceId
	--		, strTransactionReferenceNo
	--		, intContractDetailId
	--		, intContractHeaderId
	--		, strContractNumber
	--		, intContractSeq
	--		, intContractTypeId
	--		, intEntityId
	--		, intCommodityId
	--		, intItemId
	--		, intLocationId
	--		, intPricingTypeId
	--		, intFutureMarketId
	--		, intFutureMonthId
	--		, dblBasis
	--		, dblFutures
	--		, intQtyUOMId
	--		, intQtyCurrencyId
	--		, intBasisUOMId
	--		, intBasisCurrencyId
	--		, intPriceUOMId
	--		, dtmStartDate
	--		, dtmEndDate
	--		, dblQty
	--		, intContractStatusId
	--		, intBookId
	--		, intSubBookId
	--		, strNotes
	--	)
	--	SELECT strBatchId = NULL
	--		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(GETDATE())
	--		, strTransactionType = 'Sales Basis Deliveries'
	--		, strTransactionReference
	--		, intTransactionReferenceId
	--		, strTransactionReferenceNo
	--		, intContractDetailId
	--		, intContractHeaderId
	--		, strContractNumber		
	--		, intContractSeq
	--		, intContractTypeId
	--		, intEntityId
	--		, intCommodityId
	--		, intItemId
	--		, intLocationId
	--		, intPricingTypeId
	--		, intFutureMarketId
	--		, intFutureMonthId
	--		, dblBasis
	--		, dblFutures
	--		, intQtyUOMId
	--		, intQtyCurrencyId = NULL
	--		, intBasisUOMId
	--		, intBasisCurrencyId
	--		, intPriceUOMId
	--		, dtmStartDate
	--		, dtmEndDate
	--		, dblQty
	--		, intContractStatusId
	--		, intBookId
	--		, intSubBookId
	--		, strNotes = ''
	--		FROM tblCTContractBalanceLog
	--		WHERE intContractHeaderId = @intContractHeaderId
	--		AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
	--		AND strTransactionReference = 'Invoice'
	--		AND intTransactionReferenceId = @intTransactionId
	--END
		
	DECLARE @currentContractDetalId INT,
			@cbLogSpecific AS CTContractBalanceLog,
			@intId INT

	SELECT @intId = MIN(intId) FROM @cbLogCurrent
	WHILE @intId > 0--EXISTS(SELECT TOP 1 1 FROM @cbLogCurrent)
	BEGIN

		INSERT INTO @cbLogSpecific(strBatchId, dtmTransactionDate, strTransactionType, strTransactionReference, intTransactionReferenceId, strTransactionReferenceNo, intContractDetailId, intContractHeaderId, strContractNumber, intContractSeq, intContractTypeId, intEntityId, intCommodityId, intItemId, intLocationId, intPricingTypeId, intFutureMarketId, intFutureMonthId, dblBasis, dblFutures, intQtyUOMId, intQtyCurrencyId, intBasisUOMId, intBasisCurrencyId, intPriceUOMId, dtmStartDate, dtmEndDate, dblQty, intContractStatusId, intBookId, intSubBookId, strNotes, intUserId, intActionId)
		SELECT strBatchId, dtmTransactionDate, strTransactionType, strTransactionReference, intTransactionReferenceId, strTransactionReferenceNo, intContractDetailId, intContractHeaderId, strContractNumber, intContractSeq, intContractTypeId, intEntityId, intCommodityId, intItemId, intLocationId, intPricingTypeId, intFutureMarketId, intFutureMonthId, dblBasis, dblFutures, intQtyUOMId, intQtyCurrencyId, intBasisUOMId, intBasisCurrencyId, intPriceUOMId, dtmStartDate, dtmEndDate, dblQty, intContractStatusId, intBookId, intSubBookId, strNotes, intUserId, intActionId
		FROM @cbLogCurrent
		WHERE intId = @intId

		SELECT TOP 1 @currentContractDetalId 	=	 intContractDetailId
					,@intContractHeaderId		=	 intContractHeaderId			  		
		FROM @cbLogSpecific
		WHERE intId = @intId

		
		IF @strSource IN ('Contract', 'Inventory', 'Pricing', 'Invoice')
		BEGIN
			INSERT INTO @cbLogPrev (strBatchId
				, dtmTransactionDate
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
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId)
			SELECT strBatchId
				, dtmTransactionDate
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
				, dblFutures
				, intQtyUOMId
				, intQtyCurrencyId
				, intBasisUOMId
				, intBasisCurrencyId
				, intPriceUOMId
				, dtmStartDate
				, dtmEndDate
				, dblQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
			FROM tblCTContractBalanceLog
			WHERE intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = @currentContractDetalId	

			DECLARE @ysnNew BIT
			SELECT @ysnNew = CASE WHEN COUNT(*) = 0 THEN 1 ELSE 0 END FROM @cbLogPrev

			IF @ysnNew = 1
			BEGIN
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
				SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
				--DELETE FROM @cbLogCurrent WHERE intContractDetailId = @currentContractDetalId
				CONTINUE
			END
		END

		-- Get previous totals
		DECLARE @dblQtys 		NUMERIC(24, 10),
				@dblPriced 		NUMERIC(24, 10),
				@dblBasisDel 	NUMERIC(24, 10),
				@dblPricedDel 	NUMERIC(24, 10),
				@dblBasis 		NUMERIC(24, 10),
				@dblQty 		NUMERIC(24, 10),
				@dblAvrgFutures	NUMERIC(24, 10),
				@total 			NUMERIC(24, 10)

		SELECT @dblQtys = SUM(dblQty)
		FROM @cbLogPrev
		WHERE strTransactionType = 'Contract Balance'
		GROUP BY intContractDetailId

		SELECT @dblPriced = SUM(dblQty)
		FROM @cbLogPrev
		WHERE strTransactionType = 'Contract Balance'
		AND intPricingTypeId = 1
		GROUP BY intPricingTypeId	
		
		SELECT @dblBasisDel = SUM(dblQty)
		FROM @cbLogPrev
		WHERE strTransactionType LIKE '%Basis Deliveries'
		GROUP BY intContractDetailId

		SELECT @dblPricedDel = SUM(dblQty) *-1
		FROM @cbLogPrev
		WHERE strTransactionType LIKE '%Basis Deliveries'
		AND strTransactionReference IN ('Invoice', 'Voucher')
		GROUP BY intContractDetailId

		SELECT @dblBasis = SUM(dblQty)
		FROM @cbLogPrev
		WHERE intPricingTypeId = 2
		AND strTransactionType NOT LIKE '%Basis Deliveries'
		GROUP BY intPricingTypeId

		SELECT @dblQty = dblQty
		FROM @cbLogSpecific	

		SET @total = (@dblQty - @dblQtys)
		
		IF @strSource = 'Contract'
		BEGIN		
			IF @ysnDeleted = 1
			BEGIN
				UPDATE @cbLogCurrent SET dblQty = dblQty * -1
				EXEC uspCTLogContractBalance @cbLogCurrent, 0
			END
			-- No changes with dblQty
			ELSE IF @total = 0
			BEGIN								
				-- Delete records not equals to 'Contract Balance'
				DELETE FROM @cbLogPrev   
				WHERE strTransactionType <> 'Contract Balance'
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev ORDER BY intId DESC)

				-- Compare previous AND current except the qty				
				SELECT @ysnMatched = CASE WHEN COUNT(dtmTransactionDate) = 1 THEN 1 ELSE 0 END
				FROM
				(
					SELECT dtmTransactionDate
					, strTransactionType
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
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes FROM @cbLogPrev
					UNION
					SELECT dtmTransactionDate
					, strTransactionType				
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
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes FROM @cbLogCurrent
				) tbl

				IF @ysnMatched <> 1
				BEGIN					
					-- Negate AND add previous record
					UPDATE a
					SET dblQty = CASE
									WHEN @strProcess = 'Price Fixation' --previous priced
										THEN CASE WHEN ISNULL(@dblPriced,0) = 0 THEN b.dblQtyPriced *-1 ELSE @dblPriced - b.dblQtyPriced END							
										ELSE @dblQtys *-1
								END,
						a.intPricingTypeId = CASE 
												WHEN @strProcess = 'Price Fixation' THEN 2
												ELSE a.intPricingTypeId
											END
					FROM @cbLogPrev a
					OUTER APPLY
					(
						SELECT TOP 1 dblQtyPriced 
						FROM tblCTSequenceHistory 
						WHERE intContractDetailId = a.intContractDetailId
						ORDER BY intSequenceHistoryId DESC
					) b	

					EXEC uspCTLogContractBalance @cbLogPrev, 0
					
					-- Add current record
					IF @ysnDeleted = 0
					BEGIN
						UPDATE a
						SET a.dblQty = CASE 
										WHEN @strProcess = 'Price Fixation' THEN (SELECT dblQty *-1 FROM @cbLogPrev) 
										ELSE @dblQtys 
									END
						,a.intPricingTypeId = CASE 
												WHEN @strProcess = 'Price Fixation' THEN 1 
												ELSE a.intPricingTypeId
											END
						FROM @cbLogCurrent a				
						OUTER APPLY
						(
							SELECT TOP 1 dblQtyPriced 
							FROM tblCTSequenceHistory 
							WHERE intContractDetailId = a.intContractDetailId
							ORDER BY intSequenceHistoryId DESC
						) b	

						EXEC uspCTLogContractBalance @cbLogCurrent, 0
					END
				END			
			END
			ELSE -- With changes with dblQty
			BEGIN
				-- Delete records not equals to 'Contract Balance'
				DELETE FROM @cbLogPrev   
				WHERE strTransactionType <> 'Contract Balance'
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev ORDER BY intId DESC)

				-- Compare previous AND current except the qty				
				SELECT @ysnMatched = CASE WHEN COUNT(strTransactionType) = 1 THEN 1 ELSE 0 END
				FROM
				(
					SELECT --dtmTransactionDate, 
					strTransactionType
					--, strTransactionReference --CT-4726
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
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					-- , dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes FROM @cbLogPrev
					UNION
					SELECT --dtmTransactionDate, 
					strTransactionType
					--, strTransactionReference --CT-4726
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
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					-- , dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes FROM @cbLogCurrent
				) tbl

				IF @ysnMatched <> 1
				BEGIN
					SET @total =  @total * -1
					-- Negate AND add previous record
					UPDATE @cbLogPrev SET dblQty = @dblQtys *-1
					EXEC uspCTLogContractBalance @cbLogPrev, 0
				END
				
				-- Add current record
				UPDATE  @cbLogCurrent SET dblQty = @total
				EXEC uspCTLogContractBalance @cbLogCurrent, 0		
			END
		END
		ELSE 
		IF @strSource = 'Pricing'
		BEGIN		
			IF @strProcess = 'Price Delete'
			BEGIN			
				-- 	1.1. Increase basis
				-- 	1.2. Increase basis by priced quantities
				
				-- Get the previous record
				DELETE FROM @cbLogPrev
				WHERE intId <>
				(
					SELECT TOP 1 intId
					FROM @cbLogPrev
					WHERE intPricingTypeId = 2
					AND strTransactionType = 'Contract Balance'
					ORDER BY intId DESC
				)
				IF @dblPriced <> 0
				BEGIN
					-- Negate all the priced quantities
					UPDATE @cbLogSpecific SET dblQty = ISNULL(@dblPriced,0) *-1, intPricingTypeId = 1
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					---- Add all the basis quantities
					--UPDATE @cbLogPrev SET dblQty = @dblPriced, strTransactionReference = 'Price Delete'
					--EXEC uspCTLogContractBalance @cbLogPrev, 0
				END

				-- Add create price event/log
				UPDATE @cbLogSpecific SET strTransactionType = @strSource, dblQty = 0, intActionId = 17
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @strProcess = 'Fixation Detail Delete'
			BEGIN
				-- 	1.1. Increase basis
				-- 	1.2. Decrease priced				
				IF @dblQtys <> 0
				BEGIN
					-- Get the previous record					
					DELETE FROM @cbLogPrev 
					WHERE intId <>
					(
						SELECT TOP 1 intId 
						FROM @cbLogPrev 
						WHERE intPricingTypeId = 2 
						ORDER BY intId DESC
					)
					-- Negate deleted the priced quantities
					UPDATE @cbLogSpecific SET dblQty = CASE WHEN @dblQtys > @dblQty THEN @dblQty ELSE @dblQtys END *-1
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
					---- Add all the basis quantities
					--UPDATE @cbLogPrev SET dblQty = @dblQty, strTransactionReference = 'Fixation Detail Delete'
					--EXEC uspCTLogContractBalance @cbLogPrev, 0
				END

				-- Add create price event/log
				UPDATE @cbLogSpecific SET strTransactionType = @strSource, dblQty = 0, intActionId = 17
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE
			BEGIN
				IF @dblQtys > 0
				BEGIN
					-- Get the previous basis
					DELETE FROM @cbLogPrev 
					WHERE intId <>
					(
						SELECT TOP 1 intId 
						FROM @cbLogPrev 
						WHERE intPricingTypeId = 2 
						AND strTransactionType = 'Contract Balance'
						ORDER BY intId DESC
					)			
					-- Negate basis using the current priced quantities
					UPDATE @cbLogPrev SET dblQty = CASE WHEN @dblQtys > @dblQty THEN @dblQty ELSE @dblQtys END *-1
					EXEC uspCTLogContractBalance @cbLogPrev, 0
					
					-- Add current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = CASE WHEN @dblQtys > @dblQty THEN @dblQty ELSE @dblQtys END, 
											   dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END

				-- Add create price event/log
				UPDATE @cbLogSpecific SET strTransactionType = @strSource, dblQty = 0, intActionId = 17
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			
				--IF @dblBasisDel > 0
				--BEGIN
				--	-- Decrease basis deliveries by current priced quantities
				--	UPDATE cls 
				--	SET strTransactionType = CASE 
				--								WHEN cls.intContractTypeId = 1 THEN 'Purchase Basis Deliveries' 
				--								ELSE 'Sales Basis Deliveries' 
				--							END,
				--		dblQty = CASE WHEN @dblBasisDel > @dblQty THEN @dblQty ELSE @dblBasisDel END *-1
				--	FROM @cbLogSpecific cls
				--	-- Add decrease basis deliveries
				--	EXEC uspCTLogContractBalance @cbLogSpecific, 0
				--END
			END
			--ELSE IF @strProcess = 'Price Fixation' AND @dblBasisDel > 0
			--BEGIN			
			--	DECLARE @priced NUMERIC(24, 10)
			--	SELECT @priced = dblQtyPriced - @dblBasisDel
			--	FROM @cbLogSpecific a				
			--	OUTER APPLY
			--	(
			--		SELECT TOP 1 dblQtyPriced 
			--		FROM tblCTSequenceHistory 
			--		WHERE intContractDetailId = a.intContractDetailId
			--		ORDER BY intSequenceHistoryId DESC
			--	) b			
				
			--	IF @priced > 0 AND @dblBasis > 0
			--	BEGIN
			--		-- Negate basis
			--		UPDATE @cbLogSpecific SET dblQty = @dblBasis *-1, intPricingTypeId = 2
			--		EXEC uspCTLogContractBalance @cbLogSpecific, 0
			--		-- Add priced
			--		UPDATE @cbLogSpecific SET dblQty = @priced - ISNULL(@dblPricedDel,0), intPricingTypeId = 1
			--		EXEC uspCTLogContractBalance @cbLogSpecific, 0
			--	END
			--END
			--ELSE IF @strProcess IN ('Voucher', 'Invoice')
			--BEGIN
			--	UPDATE @cbLogSpecific SET dblQty = dblQty * -1
			--	EXEC uspCTLogContractBalance @cbLogSpecific, 0
			--END
			--ELSE IF @strProcess IN ('Voucher Delete', 'Invoice Delete')
			--BEGIN
			--	--UPDATE @cbLogCurrent SET dblQty = @dblPricedDel - dblQty 
			--	EXEC uspCTLogContractBalance @cbLogSpecific, 0
			--END
			--ELSE IF @strProcess = 'Reverse'
			--BEGIN
			--	EXEC uspCTLogContractBalance @cbLogSpecific, 0
			--END
			
		END
		ELSE IF @strSource = 'Inventory'
		BEGIN
			UPDATE @cbLogSpecific SET dblQty = (CASE WHEN @dblQty > ISNULL(@dblPriced,0) THEN ISNULL(@dblPriced,0) ELSE @dblQty END) * -1, 
												 intPricingTypeId = CASE WHEN ISNULL(@dblPriced,0) <> 0 THEN 1 ELSE 2 END
			EXEC uspCTLogContractBalance @cbLogSpecific, 0  
			
			IF @ysnDirect <> 1
			BEGIN  
				-- Basis Deliveries  
				UPDATE @cbLogSpecific SET dblQty = @dblQty,
										  strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
										  intPricingTypeId = CASE WHEN ISNULL(@dblBasis,0) = 0 THEN 1 ELSE 2 END
				EXEC uspCTLogContractBalance @cbLogSpecific, 0  
			END  
		END
		--ELSE IF @strSource = 'Invoice'
		--BEGIN
		--	UPDATE @cbLogSpecific SET dblQty = dblQty * -1
		--	EXEC uspCTLogContractBalance @cbLogSpecific, 0
		--END	

		DELETE FROM @cbLogSpecific

		SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH