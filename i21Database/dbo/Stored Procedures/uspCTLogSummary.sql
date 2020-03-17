CREATE PROCEDURE [dbo].[uspCTLogSummary]
	@intContractHeaderId	INT,
    @intContractDetailId	INT,
	@strSource				NVARCHAR(20),
	@strProcess				NVARCHAR(50),
	@contractDetail			AS ContractDetailTable READONLY,
	@intUserId				INT = NULL

AS

BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@ExistingHistory		AS RKSummaryLog,
			@cbLogPrev				AS CTContractBalanceLog,
			@cbLogCurrent			AS CTContractBalanceLog,
			@ysnDeleted				BIT = 0,
			@ysnMatched				BIT,
			@ysnDirect				BIT = 0

	--SELECT @strSource, @strProcess

	IF @strProcess = 'Scheduled Quantity'
	BEGIN
		RETURN
	END	

	IF @strSource = '' AND @strProcess = ''
	BEGIN
		SET @strSource = 'Contract'
		SET @strProcess = 'Contract Sequence'
	END

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
			AND sh.strPricingStatus = 'Unpriced'
			AND sh.strPricingType = 'Basis'
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
		IF @strProcess IN ('Voucher','Voucher Delete')
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
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
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
				SELECT dtmTransactionDate = dbo.fnRemoveTimeOnDate(b.dtmBillDate)
					, strTransactionType = 'Voucher'
					, intTransactionId = bd.intBillDetailId
					, strTransactionId = b.strBillId
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
					, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN bd.dblQtyReceived 
									ELSE cd.dblQuantityPerLoad END) --* -1
					, sh.intContractStatusId
					, sh.intBookId
					, sh.intSubBookId					
				FROM vyuCTSequenceUsageHistory suh
				INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				INNER JOIN tblAPBillDetail bd ON suh.intExternalId = bd.intInventoryReceiptItemId
				INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
				WHERE strFieldName = 'Balance'
				AND sh.strPricingStatus = 'Unpriced'
				AND sh.strPricingType = 'Basis'
				AND bd.intInventoryReceiptChargeId IS NULL
			) tbl
			WHERE intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		END
		ELSE IF @strProcess IN ('Invoice', 'Invoice Delete')
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
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
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
					dtmTransactionDate = dbo.fnRemoveTimeOnDate(i.dtmDate)
					, strTransactionType = 'Invoice'
					, intTransactionId = id.intInvoiceDetailId
					, strTransactionId = i.strInvoiceNumber
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
					, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad,0) = 0 THEN id.dblQtyShipped 
									ELSE cd.dblQuantityPerLoad END) --* -1
					, sh.intContractStatusId
					, sh.intBookId
					, sh.intSubBookId	
				FROM vyuCTSequenceUsageHistory suh
				INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				INNER JOIN tblARInvoiceDetail id ON suh.intExternalId = id.intInventoryShipmentItemId
				INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
				WHERE strFieldName = 'Balance'
				AND sh.strPricingStatus = 'Unpriced'
				AND sh.strPricingType = 'Basis'
				AND id.intInventoryShipmentChargeId IS NULL
			)tbl
			WHERE intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		END
		ELSE -- Price Fixation/Delete
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
					, dblFutures = CASE WHEN  sh.strPricingStatus = 'Partially Priced' THEN pf.dblFutures ELSE sh.dblFutures END
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
				FROM tblCTSequenceHistory sh
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				OUTER APPLY
				(
					SELECT dblFutures = AVG(a.dblFutures)
					FROM tblCTPriceFixationDetail a
					INNER JOIN tblCTPriceFixation b ON a.intPriceFixationId = b.intPriceFixationId
					WHERE b.intContractDetailId = sh.intContractDetailId
					GROUP BY b.intContractDetailId
				) pf
				WHERE intSequenceUsageHistoryId IS NULL
			) tbl
			WHERE Row_Num = 1
			AND intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		END
	END
	--ELSE IF @strSource = 'Invoice'
	--BEGIN
	--	-- Direct Invoice:
	--	-- 1. Posting
	--	-- 	1.1. Reduce balance
	--	-- 2. Unposting
	--	-- 	1.1. Increase balance
	--END
	
	DECLARE @currentContractDetalId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM @cbLogCurrent)
	BEGIN
		SELECT TOP 1 @currentContractDetalId 	=	 intContractDetailId
					,@intContractHeaderId		=	 intContractHeaderId			  		
		FROM @cbLogCurrent

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
				, strNotes)
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
			FROM tblCTContractBalanceLog
			WHERE intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = @currentContractDetalId	

			DECLARE @ysnNew BIT
			SELECT @ysnNew = CASE WHEN COUNT(*) = 0 THEN 1 ELSE 0 END FROM @cbLogPrev

			IF @ysnNew = 1
			BEGIN
				EXEC uspCTLogContractBalance @cbLogCurrent, 1
				DELETE FROM @cbLogCurrent WHERE intContractDetailId = @currentContractDetalId
				CONTINUE
			END
		END

		-- Get previous totals
		DECLARE @dblQtys 		NUMERIC(24, 10),
				@dblPriced 		NUMERIC(24, 10),
				@dblBasisDel 	NUMERIC(24, 10),
				@dblBasis 		NUMERIC(24, 10),
				@dblQty 		NUMERIC(24, 10),
				@total 			NUMERIC(24, 10)

		SELECT @dblQtys = SUM(dblQty)
		FROM @cbLogPrev
		GROUP BY intContractDetailId

		SELECT @dblPriced = SUM(dblQty)
		FROM @cbLogPrev
		WHERE intPricingTypeId = 1
		GROUP BY intPricingTypeId

		SELECT @dblBasisDel = SUM(dblQty)
		FROM @cbLogPrev
		WHERE strTransactionType LIKE '%Basis Deliveries'
		GROUP BY intContractDetailId

		SELECT @dblBasis = SUM(dblQty)
		FROM @cbLogPrev
		WHERE intPricingTypeId = 2
		AND strTransactionType NOT LIKE '%Basis Deliveries'
		GROUP BY intPricingTypeId

		SELECT @dblQty = dblQty
		FROM @cbLogCurrent	

		SET @total = (@dblQty - @dblQtys)
		
		IF @strSource = 'Contract'
		BEGIN			
			-- No changes with dblQty
			IF @total = 0
			BEGIN
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev ORDER BY intId DESC)

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

				EXEC uspCTLogContractBalance @cbLogPrev, 1

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

					EXEC uspCTLogContractBalance @cbLogCurrent, 1
				END
			END
			ELSE -- With changes with dblQty
			BEGIN
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev ORDER BY intId DESC)

				-- Compare previous AND current except the qty				
				SELECT @ysnMatched = CASE WHEN COUNT(dtmTransactionDate) = 1 THEN 1 ELSE 0 END
				FROM
				(
					SELECT dtmTransactionDate
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
					-- , dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes FROM @cbLogPrev
					UNION
					SELECT dtmTransactionDate
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
					EXEC uspCTLogContractBalance @cbLogPrev, 1
				END
				
				-- Add current record
				UPDATE  @cbLogCurrent SET dblQty = @total
				EXEC uspCTLogContractBalance @cbLogCurrent, 1		
			END
		END
		ELSE IF @strSource = 'Pricing'
		BEGIN					
			IF @strProcess = 'Price Delete'
			BEGIN			
				-- 	1.1. Increase basis
				-- 	1.2. Decrease priced
				-- Get the previous record	

				DECLARE @id INT
				SELECT TOP 1 @id = intId 
				FROM @cbLogPrev 
				WHERE strTransactionReference = 'Price Fixation' 
				AND intPricingTypeId = 1
				ORDER BY intId DESC

				IF @id IS NOT NULL
				BEGIN
					DELETE FROM @cbLogPrev 
					WHERE intId <> @id

					-- Negate AND add previous record
					UPDATE a
					SET dblQty = CASE WHEN ISNULL(b.dblQtyPriced,0) = 0 THEN @dblPriced ELSE (b.dblQtyPriced - @dblPriced) *-1 END,
						a.intPricingTypeId = 1
					FROM @cbLogPrev a
					OUTER APPLY
					(
						SELECT TOP 1 dblQtyPriced 
						FROM tblCTSequenceHistory 
						WHERE intContractDetailId = a.intContractDetailId
						ORDER BY intSequenceHistoryId DESC
					) b						

					EXEC uspCTLogContractBalance @cbLogPrev, 1
				END

				IF @dblQty <> 0
				BEGIN
					 --Add current basis record
					EXEC uspCTLogContractBalance @cbLogCurrent, 1
				END
			END
			ELSE IF @strProcess = 'Price Fixation' AND @dblBasisDel > 0
			BEGIN					
				DECLARE @priced NUMERIC(24, 10)
				SELECT @priced = dblQtyPriced - @dblBasisDel
				FROM @cbLogCurrent a				
				OUTER APPLY
				(
					SELECT TOP 1 dblQtyPriced 
					FROM tblCTSequenceHistory 
					WHERE intContractDetailId = a.intContractDetailId
					ORDER BY intSequenceHistoryId DESC
				) b			
				
				IF @priced > 0
				BEGIN					
					-- Negate basis
					UPDATE @cbLogCurrent SET dblQty = @dblBasis *-1, intPricingTypeId = 2
					EXEC uspCTLogContractBalance @cbLogCurrent, 1
					-- Add priced
					UPDATE @cbLogCurrent SET dblQty = @priced, intPricingTypeId = 1
					EXEC uspCTLogContractBalance @cbLogCurrent, 1
				END
			END
			ELSE IF @strProcess IN ('Voucher', 'Invoice')
			BEGIN
				UPDATE @cbLogCurrent SET dblQty = dblQty * -1
				EXEC uspCTLogContractBalance @cbLogCurrent, 1
			END
			ELSE IF @strProcess IN ('Voucher Delete', 'Invoice Delete')
			BEGIN
				UPDATE @cbLogCurrent SET dblQty = dblQty
				EXEC uspCTLogContractBalance @cbLogCurrent, 1
			END
			ELSE IF @strProcess = 'Fixation Detail Delete'
			BEGIN
				-- 	1.1. Increase basis
				-- 	1.2. Decrease priced
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> 
				(
					SELECT TOP 1 intId 
					FROM @cbLogPrev 
					WHERE strTransactionReference = 'Price Fixation' 
					AND intPricingTypeId = 1
					ORDER BY intId DESC
				)			

				-- Negate AND add previous record
				UPDATE a
				SET dblQty = CASE WHEN ISNULL(b.dblQtyPriced,0) = 0 THEN @dblPriced ELSE b.dblQtyPriced - @dblPriced END,
					a.intPricingTypeId = 1
				FROM @cbLogPrev a
				OUTER APPLY
				(
					SELECT TOP 1 dblQtyPriced 
					FROM tblCTSequenceHistory 
					WHERE intContractDetailId = a.intContractDetailId
					ORDER BY intSequenceHistoryId DESC
				) b	
				
				EXEC uspCTLogContractBalance @cbLogPrev, 1
			END
			ELSE
			BEGIN			
				-- No changes with dblQty
				IF @total = 0
				BEGIN
					-- Get the previous record
					DELETE FROM @cbLogPrev 
					WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev ORDER BY intId DESC)
					-- Negate AND add previous record
					UPDATE a
					SET dblQty = CASE WHEN ISNULL(@dblPriced,0) = 0 THEN b.dblQtyPriced *-1 ELSE @dblPriced - b.dblQtyPriced END,
						a.intPricingTypeId = 2
					FROM @cbLogPrev a
					OUTER APPLY
					(
						SELECT TOP 1 dblQtyPriced 
						FROM tblCTSequenceHistory 
						WHERE intContractDetailId = a.intContractDetailId
						ORDER BY intSequenceHistoryId DESC
					) b	

					EXEC uspCTLogContractBalance @cbLogPrev, 1

					-- Add current record
					IF @ysnDeleted = 0
					BEGIN
						UPDATE @cbLogCurrent
						SET dblQty = (SELECT TOP 1 dblQty *-1 FROM @cbLogPrev) 
							,intPricingTypeId = 1

						EXEC uspCTLogContractBalance @cbLogCurrent, 1
					END
				END
				ELSE -- With changes with dblQty
				BEGIN				
					-- Get the previous record
					DELETE FROM @cbLogPrev 
					WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev ORDER BY intId DESC)

					-- Compare previous AND current except the qty					
					SELECT @ysnMatched = CASE WHEN COUNT(dtmTransactionDate) = 1 THEN 1 ELSE 0 END
					FROM
					(
						SELECT dtmTransactionDate
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
						-- , dblQty
						, intContractStatusId
						, intBookId
						, intSubBookId
						, strNotes FROM @cbLogPrev
						UNION
						SELECT dtmTransactionDate
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
						EXEC uspCTLogContractBalance @cbLogPrev, 1
					END
					
					-- Add current record
					UPDATE  @cbLogCurrent SET dblQty = @total
					EXEC uspCTLogContractBalance @cbLogCurrent, 1		
				END
			END
		END
		ELSE IF @strSource = 'Inventory'
		BEGIN
			UPDATE @cbLogCurrent SET dblQty = dblQty * -1
			EXEC uspCTLogContractBalance @cbLogCurrent, 1

			IF @ysnDirect <> 1
			BEGIN
				-- Basis Deliveries
				UPDATE @cbLogCurrent SET dblQty = dblQty * -1, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
				EXEC uspCTLogContractBalance @cbLogCurrent, 1
			END
		END

		IF @strProcess = 'Voucher Delete'
		BEGIN
			DECLARE @billId INT,
					@billCreatedId INT

			SELECT @billId = intBillId 
			FROM tblAPBillDetail a
			INNER JOIN @cbLogCurrent b ON a.intBillDetailId = b.intTransactionReferenceId

			EXEC uspAPReverseTransaction @billId, @intUserId, @billCreatedId
		END
		ELSE IF @strProcess = 'Invoice Delete'
		BEGIN
			DECLARE @invoiceId INT,
					@intNewInvoiceId INT

			SELECT @invoiceId = intInvoiceId 
			FROM tblARInvoiceDetail a
			INNER JOIN @cbLogCurrent b ON a.intInvoiceDetailId = b.intTransactionReferenceId

			EXEC uspARReturnInvoice @invoiceId, @intNewInvoiceId
		END

		DELETE FROM @cbLogCurrent WHERE intContractDetailId = @currentContractDetalId
	END


	-- IF @strProcess = 'Skip'
	-- BEGIN
	-- 	RETURN
	-- END

    -- -- Get the lastest history for the current contract detail
	-- IF EXISTS (SELECT TOP 1 1 FROM @contractDetail)
	-- BEGIN
	-- 	-- Deleted contract detail
	-- 	INSERT INTO @cbLogCurrent (dtmTransactionDate
	-- 		, strTransactionType		
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq		
	-- 		, intContractTypeId
	-- 		, intPricingTypeId			
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intLocationId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strTransactionReference
	-- 		, intTransactionReferenceId
	-- 		, strTransactionReferenceNo
	-- 	)
	-- 	SELECT dtmTransactionDate
	-- 		, strTransactionType
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq
	-- 		, intContractTypeId
	-- 		, intPricingTypeId
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId = NULL
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intCompanyLocationId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strTransactionReference = ''
	-- 		, intTransactionReferenceId = -1
	-- 		, strTransactionReferenceNo = ''
	-- 	FROM
	-- 	(
	-- 		SELECT 
	-- 			ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
	-- 			, sh.intSequenceHistoryId
	-- 			, dtmTransactionDate = dbo.fnRemoveTimeOnDate(cd.dtmCreated)
	-- 			, sh.intContractHeaderId
	-- 			, ch.strContractNumber
	-- 			, sh.intContractDetailId
	-- 			, cd.intContractSeq
	-- 			, ch.intContractTypeId
	-- 			, dblQty = (sh.dblBalance * -1)
	-- 			, intQtyUOMId = ch.intCommodityUOMId
	-- 			, sh.intPricingTypeId
	-- 			, sh.strPricingType
	-- 			, strTransactionType = 'Contract Sequence'
	-- 			, intTransactionId = sh.intContractDetailId
	-- 			, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
	-- 			, sh.dblFutures
	-- 			, sh.dblBasis
	-- 			, cd.intBasisUOMId
	-- 			, cd.intBasisCurrencyId
	-- 			, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
	-- 			, sh.intContractStatusId
	-- 			, sh.intEntityId
	-- 			, sh.intCommodityId
	-- 			, sh.intItemId
	-- 			, sh.intCompanyLocationId
	-- 			, sh.intFutureMarketId
	-- 			, sh.intFutureMonthId
	-- 			, sh.dtmStartDate
	-- 			, sh.dtmEndDate
	-- 			, sh.intBookId
	-- 			, sh.intSubBookId
	-- 			, intOrderBy = 1
	-- 		FROM tblCTSequenceHistory sh
	-- 		INNER JOIN @contractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
	-- 		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	-- 		WHERE intSequenceUsageHistoryId IS NULL 
	-- 	) tbl
	-- 	WHERE Row_Num = 1
	-- END
	-- ELSE
	-- BEGIN
	-- 	-- Existing contract detail
	-- 	INSERT INTO @cbLogCurrent (dtmTransactionDate
	-- 		, strTransactionType		
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq		
	-- 		, intContractTypeId
	-- 		, intPricingTypeId			
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intLocationId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strTransactionReference
	-- 		, intTransactionReferenceId
	-- 		, strTransactionReferenceNo
	-- 	)
	-- 	SELECT dtmTransactionDate
	-- 		, strTransactionType
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq
	-- 		, intContractTypeId
	-- 		, intPricingTypeId
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId = NULL
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intCompanyLocationId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strTransactionReference = ''
	-- 		, intTransactionReferenceId = -1
	-- 		, strTransactionReferenceNo = ''
	-- 	FROM
	-- 	(
	-- 		SELECT 
	-- 			ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
	-- 			, sh.intSequenceHistoryId
	-- 			, dtmTransactionDate = dbo.fnRemoveTimeOnDate(cd.dtmCreated)
	-- 			, sh.intContractHeaderId
	-- 			, ch.strContractNumber
	-- 			, sh.intContractDetailId
	-- 			, cd.intContractSeq
	-- 			, ch.intContractTypeId
	-- 			, dblQty = sh.dblBalance
	-- 			, intQtyUOMId = ch.intCommodityUOMId
	-- 			, sh.intPricingTypeId
	-- 			, sh.strPricingType
	-- 			, strTransactionType = CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
	-- 			, intTransactionId = sh.intContractDetailId
	-- 			, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
	-- 			, sh.dblFutures
	-- 			, sh.dblBasis
	-- 			, cd.intBasisUOMId
	-- 			, cd.intBasisCurrencyId
	-- 			, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
	-- 			, sh.intContractStatusId
	-- 			, sh.intEntityId
	-- 			, sh.intCommodityId
	-- 			, sh.intItemId
	-- 			, sh.intCompanyLocationId
	-- 			, sh.intFutureMarketId
	-- 			, sh.intFutureMonthId
	-- 			, sh.dtmStartDate
	-- 			, sh.dtmEndDate
	-- 			, sh.intBookId
	-- 			, sh.intSubBookId
	-- 			, intOrderBy = 1
	-- 		FROM tblCTSequenceHistory sh
	-- 		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
	-- 		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	-- 		WHERE intSequenceUsageHistoryId IS NULL 
	-- 	) tbl
	-- 	WHERE Row_Num = 1
	-- 	AND intContractHeaderId = @intContractHeaderId
	-- 	AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		
	-- END

	-- DECLARE @currentContractDetalId INT

	-- WHILE EXISTS(SELECT TOP 1 1 FROM @cbLogCurrent)
	-- BEGIN
	-- 	SELECT TOP 1 @currentContractDetalId 	=	 intContractDetailId
	-- 				,@intContractHeaderId		=	 intContractHeaderId			  		
	-- 	FROM @cbLogCurrent

	-- 	-- GET THE PREVIOUS RECORD
	-- 	INSERT INTO @cbLogPrev (strBatchId
	-- 		, dtmTransactionDate
	-- 		, strTransactionType
	-- 		, strTransactionReference
	-- 		, intTransactionReferenceId
	-- 		, strTransactionReferenceNo
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq
	-- 		, intContractTypeId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intLocationId
	-- 		, intPricingTypeId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strNotes)
	-- 	SELECT strBatchId
	-- 		, dtmTransactionDate
	-- 		, strTransactionType
	-- 		, strTransactionReference
	-- 		, intTransactionReferenceId
	-- 		, strTransactionReferenceNo
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq
	-- 		, intContractTypeId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intLocationId
	-- 		, intPricingTypeId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId = NULL
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strNotes
	-- 	FROM
	-- 	(
	-- 		SELECT ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY intContractBalanceLogId DESC) AS Row_Num, *
	-- 		FROM tblCTContractBalanceLog
	-- 		WHERE intPricingTypeId = CASE WHEN @strProcess = 'Price Delete' THEN 1 ELSE intPricingTypeId END
	-- 	) tbl
	-- 	WHERE Row_Num = 1
	-- 	AND intContractHeaderId = @intContractHeaderId
	-- 	AND intContractDetailId = @currentContractDetalId

	-- 	DECLARE @ysnNew BIT
	-- 	SELECT @ysnNew = CASE WHEN COUNT(*) = 0 THEN 1 ELSE 0 END FROM @cbLogPrev

	-- 	IF @ysnNew = 1
	-- 	BEGIN
	-- 		EXEC uspCTLogContractBalance @cbLogCurrent, 1
	-- 		DELETE FROM @cbLogCurrent WHERE intContractDetailId = @currentContractDetalId
	-- 		CONTINUE
	-- 	END

	-- 	DECLARE @ysnNotExist BIT 
	-- 	SELECT @ysnNotExist = CASE WHEN COUNT(dtmTransactionDate) > 1 THEN 1 ELSE 0 END
	-- 	FROM
	-- 	(
	-- 		SELECT dtmTransactionDate
	-- 		, strTransactionType
	-- 		, strTransactionReference
	-- 		, intTransactionReferenceId
	-- 		, strTransactionReferenceNo
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq
	-- 		, intContractTypeId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intLocationId
	-- 		, intPricingTypeId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strNotes FROM @cbLogPrev
	-- 		UNION
	-- 		SELECT dtmTransactionDate
	-- 		, strTransactionType
	-- 		, strTransactionReference
	-- 		, intTransactionReferenceId
	-- 		, strTransactionReferenceNo
	-- 		, intContractDetailId
	-- 		, intContractHeaderId
	-- 		, strContractNumber
	-- 		, intContractSeq
	-- 		, intContractTypeId
	-- 		, intEntityId
	-- 		, intCommodityId
	-- 		, intItemId
	-- 		, intLocationId
	-- 		, intPricingTypeId
	-- 		, intFutureMarketId
	-- 		, intFutureMonthId
	-- 		, dblBasis
	-- 		, dblFutures
	-- 		, intQtyUOMId
	-- 		, intQtyCurrencyId
	-- 		, intBasisUOMId
	-- 		, intBasisCurrencyId
	-- 		, intPriceUOMId
	-- 		, dtmStartDate
	-- 		, dtmEndDate
	-- 		, dblQty
	-- 		, intContractStatusId
	-- 		, intBookId
	-- 		, intSubBookId
	-- 		, strNotes FROM @cbLogCurrent
	-- 	) tbl

	-- 	-- Negate the previous record
	-- 	IF @ysnNotExist = 1
	-- 	BEGIN
	-- 		UPDATE p SET dtmTransactionDate = CASE WHEN p.dtmTransactionDate <> c.dtmTransactionDate THEN p.dtmTransactionDate ELSE c.dtmTransactionDate END,
	-- 		strTransactionType = CASE WHEN p.strTransactionType <> c.strTransactionType THEN p.strTransactionType ELSE c.strTransactionType END,
	-- 		strTransactionReference = CASE WHEN p.strTransactionReference <> c.strTransactionReference THEN p.strTransactionReference ELSE c.strTransactionReference END,
	-- 		intTransactionReferenceId = CASE WHEN p.intTransactionReferenceId <> c.intTransactionReferenceId THEN p.intTransactionReferenceId ELSE c.intTransactionReferenceId END,
	-- 		strTransactionReferenceNo = CASE WHEN p.strTransactionReferenceNo <> c.strTransactionReferenceNo THEN p.strTransactionReferenceNo ELSE c.strTransactionReferenceNo END,
	-- 		intContractDetailId = CASE WHEN p.intContractDetailId <> c.intContractDetailId THEN p.intContractDetailId ELSE c.intContractDetailId END,
	-- 		intContractHeaderId = CASE WHEN p.intContractHeaderId <> c.intContractHeaderId THEN p.intContractHeaderId ELSE c.intContractHeaderId END,
	-- 		strContractNumber = CASE WHEN p.strContractNumber <> c.strContractNumber THEN p.strContractNumber ELSE c.strContractNumber END,
	-- 		intContractSeq = CASE WHEN p.intContractSeq <> c.intContractSeq THEN p.intContractSeq ELSE c.intContractSeq END,
	-- 		intContractTypeId = CASE WHEN p.intContractTypeId <> c.intContractTypeId THEN p.intContractTypeId ELSE c.intContractTypeId END,
	-- 		intEntityId = CASE WHEN p.intEntityId <> c.intEntityId THEN p.intEntityId ELSE c.intEntityId END,
	-- 		intCommodityId = CASE WHEN p.intCommodityId <> c.intCommodityId THEN p.intCommodityId ELSE c.intCommodityId END,
	-- 		intItemId = CASE WHEN p.intItemId <> c.intItemId THEN p.intItemId ELSE c.intItemId END,
	-- 		intLocationId = CASE WHEN p.intLocationId <> c.intLocationId THEN p.intLocationId ELSE c.intLocationId END,
	-- 		intPricingTypeId = CASE WHEN p.intPricingTypeId <> c.intPricingTypeId THEN p.intPricingTypeId ELSE c.intPricingTypeId END,
	-- 		intFutureMarketId = CASE WHEN p.intFutureMarketId <> c.intFutureMarketId THEN p.intFutureMarketId ELSE c.intFutureMarketId END,
	-- 		intFutureMonthId = CASE WHEN p.intFutureMonthId <> c.intFutureMonthId THEN p.intFutureMonthId ELSE c.intFutureMonthId END,
	-- 		dblBasis = CASE WHEN ISNULL(p.dblBasis,0) <> ISNULL(c.dblBasis,0) THEN p.dblBasis ELSE c.dblBasis END,
	-- 		dblFutures = CASE WHEN ISNULL(p.dblFutures, 0) <> ISNULL(c.dblFutures, 0) THEN p.dblFutures ELSE c.dblFutures END,
	-- 		intQtyUOMId = CASE WHEN p.intQtyUOMId <> c.intQtyUOMId THEN p.intQtyUOMId ELSE c.intQtyUOMId END,
	-- 		intQtyCurrencyId = CASE WHEN p.intQtyCurrencyId <> c.intQtyCurrencyId THEN p.intQtyCurrencyId ELSE c.intQtyCurrencyId END,
	-- 		intBasisUOMId = CASE WHEN p.intBasisUOMId <> c.intBasisUOMId THEN p.intBasisUOMId ELSE c.intBasisUOMId END,
	-- 		intBasisCurrencyId = CASE WHEN p.intBasisCurrencyId <> c.intBasisCurrencyId THEN p.intBasisCurrencyId ELSE c.intBasisCurrencyId END,
	-- 		intPriceUOMId = CASE WHEN p.intPriceUOMId <> c.intPriceUOMId THEN p.intPriceUOMId ELSE c.intPriceUOMId END,
	-- 		dtmStartDate = CASE WHEN p.dtmStartDate <> c.dtmStartDate THEN p.dtmStartDate ELSE c.dtmStartDate END,
	-- 		dtmEndDate = CASE WHEN p.dtmEndDate <> c.dtmEndDate THEN p.dtmEndDate ELSE c.dtmEndDate END,
	-- 		dblQty = CASE WHEN ISNULL(p.dblQty,0) <> ISNULL(c.dblQty,0)
	-- 							OR @strProcess IN ('Price Fixation', 'Price Delete')
	-- 							OR p.intPricingTypeId <> c.intPricingTypeId
	-- 						THEN p.dblQty * -1
	-- 						ELSE p.dblQty
	-- 				 END,
	-- 		intContractStatusId = CASE WHEN c.intContractStatusId <> c.intContractStatusId THEN p.intContractStatusId ELSE c.intContractStatusId END,
	-- 		intSubBookId = CASE WHEN p.intSubBookId <> c.intSubBookId THEN p.intSubBookId ELSE c.intSubBookId END,
	-- 		strNotes = CASE WHEN p.strNotes <> c.strNotes THEN p.strNotes ELSE c.strNotes END
	-- 		FROM @cbLogPrev p
	-- 		INNER JOIN @cbLogCurrent c ON p.intContractHeaderId = c.intContractHeaderId AND p.intContractDetailId = c.intContractDetailId

	-- 		EXEC uspCTLogContractBalance @cbLogPrev, 1

	-- 		-- When contract detail not deleted
	-- 		IF EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intContractDetailId = @currentContractDetalId)
	-- 		BEGIN

	-- 			IF @strProcess = 'Price Fixation'
	-- 			BEGIN
	-- 				UPDATE a
	-- 				SET a.dblQty = b.dblQtyPriced, a.intPricingTypeId = 1
	-- 				FROM @cbLogCurrent a
	-- 				OUTER APPLY
	-- 				(
	-- 					SELECT TOP 1 dblQtyPriced 
	-- 					FROM tblCTSequenceHistory 
	-- 					WHERE intContractDetailId = a.intContractDetailId
	-- 					ORDER BY intSequenceHistoryId DESC
	-- 				) b	
				
	-- 				EXEC uspCTLogContractBalance @cbLogCurrent, 1

	-- 				UPDATE a
	-- 				SET a.dblQty = b.dblQtyUnpriced, a.intPricingTypeId = 2
	-- 				FROM @cbLogCurrent a
	-- 				OUTER APPLY
	-- 				(
	-- 					SELECT TOP 1 dblQtyUnpriced 
	-- 					FROM tblCTSequenceHistory 
	-- 					WHERE intContractDetailId = a.intContractDetailId
	-- 					ORDER BY intSequenceHistoryId DESC
	-- 				) b	
	-- 			END

	-- 			IF NOT EXISTS (SELECT TOP 1 1 FROM @cbLogCurrent WHERE dblQty = 0)
	-- 			BEGIN
	-- 				EXEC uspCTLogContractBalance @cbLogCurrent, 1
	-- 			END			
				
	-- 		END			
	-- 	END

	-- 	DELETE FROM @cbLogCurrent WHERE intContractDetailId = @currentContractDetalId
	-- END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH