CREATE PROCEDURE [dbo].[uspCTLogSummary]
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
			@cbLogTemp				AS CTContractBalanceLog,
			@ysnDeleted				BIT = 0,
			@ysnMatched				BIT,
			@ysnDirect				BIT = 0,
			@dblBasisDelOrig		NUMERIC(24, 10),
			@intHeaderId			INT,
			@intDetailId			INT,
			@ysnUnposted			BIT = 0,
			@ysnLoadBased			BIT = 0,
			@dblQuantityPerLoad		NUMERIC(24, 10),
			@ysnReopened			BIT = 0,
			@_transactionDate		DATETIME,
			@ysnInvoice				BIT = 0

	-- SELECT @strSource, @strProcess

	IF @strProcess = 'Update Scheduled Quantity' OR @strProcess = 'Update Sequence Status' OR @strProcess = 'Missing History' OR @strProcess = 'Update Sequence Balance - DWG (Load-based)'
	BEGIN
		RETURN
	END
		
	IF @strSource = 'Pricing' AND @strProcess = 'Save Contract'
	BEGIN
		RETURN
	END

	--  IF @strSource = 'Contract'
	--  BEGIN
	--  	SET @strProcess = 'Contract Sequence'
	--  END


	-- IF @strSource = '' AND @strProcess = ''
	-- BEGIN
	-- 	SET @strSource = 'Contract'
	-- 	SET @strProcess = 'Save Contract'
	-- END

	-- Get if load based and quantity per load
	SELECT @ysnLoadBased = ISNULL(ysnLoad,0), @dblQuantityPerLoad = dblQuantityPerLoad FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

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
				, intTransactionReferenceDetailId
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
				, strProcess
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId = intContractHeaderId
				, intTransactionReferenceDetailId = intContractDetailId
				, strTransactionReferenceNo = strContractNumber
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
				, intActionId = 44
				, strProcess = @strProcess
			FROM
			(
				SELECT 
					ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
					, sh.intSequenceHistoryId
					, dtmTransactionDate = getdate() --DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), cd.dtmCreated)
					, sh.intContractHeaderId
					, ch.strContractNumber
					, sh.intContractDetailId
					, cd.intContractSeq
					, ch.intContractTypeId
					, dblQty = sh.dblBalance
					, intQtyUOMId = ch.intCommodityUOMId
					, sh.intPricingTypeId
					, sh.strPricingType
					, strTransactionType = 'Contract Sequence'--CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
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
			WHERE Row_Num = 1
		END
		ELSE
		BEGIN -- Contract Balance
			INSERT INTO @cbLogTemp (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId = intContractHeaderId
				, intTransactionReferenceDetailId = intContractDetailId
				, strTransactionReferenceNo = strContractNumber
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
				, intActionId = 43	
				, strProcess  = @strProcess
			FROM
			(
				SELECT 
					ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
					, sh.intSequenceHistoryId
					, dtmTransactionDate = CASE WHEN cd.intContractStatusId IN (3,6) THEN sh.dtmHistoryCreated ELSE DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), cd.dtmCreated) END
					, sh.intContractHeaderId
					, ch.strContractNumber
					, sh.intContractDetailId
					, cd.intContractSeq
					, ch.intContractTypeId
					, dblQty = sh.dblBalance
					, intQtyUOMId = ch.intCommodityUOMId
					, sh.intPricingTypeId
					, sh.strPricingType
					, strTransactionType = 'Contract Sequence'--CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
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

			IF EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE intContractStatusId = 4)
			BEGIN
				SET @ysnReopened = 1
				
				SELECT @intHeaderId = intTransactionReferenceId, 
					@intDetailId = intTransactionReferenceDetailId, 
					@_transactionDate = dtmTransactionDate, 
					@intUserId = intUserId 
				FROM @cbLogTemp
			
				INSERT INTO @cbLogCurrent (strBatchId
					, dtmTransactionDate
					, strTransactionType
					, strTransactionReference
					, intTransactionReferenceId
					, intTransactionReferenceDetailId
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
					, strProcess
				)		
				SELECT TOP 1 strBatchId = NULL
					, dtmTransactionDate = @_transactionDate
					, strTransactionType
					, strTransactionReference
					, intTransactionReferenceId
					, intTransactionReferenceDetailId
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
					, intContractStatusId = 4
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId = @intUserId
					, intActionId
					, strProcess = @strProcess
				FROM tblCTContractBalanceLog 
				WHERE intTransactionReferenceId = @intHeaderId
				AND intTransactionReferenceDetailId = @intDetailId
				AND intContractHeaderId = @intContractHeaderId
				AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
				AND intContractStatusId IN (3,6)
				ORDER BY dtmCreatedDate DESC

				UPDATE CBL SET strNotes = 'Re-opened'
				FROM tblCTContractBalanceLog CBL
				WHERE intTransactionReferenceId = @intHeaderId
				AND intTransactionReferenceDetailId = @intDetailId
				AND intContractHeaderId = @intContractHeaderId
				AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
				AND intContractStatusId IN (3,6)				
			END
			ELSE
			BEGIN
				INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
				)
				SELECT strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
				FROM @cbLogTemp
			END
		END
	END
	ELSE IF @strSource = 'Inventory'
	BEGIN
		IF @strProcess = 'Post Load-based DWG' OR @strProcess = 'Unpost Load-based DWG'
		BEGIN
			 INSERT INTO @cbLogCurrent (strBatchId
			 	, dtmTransactionDate
			 	, strTransactionType
			 	, strTransactionReference
			 	, intTransactionReferenceId
			 	, intTransactionReferenceDetailId
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
			 	, strProcess
			 )		
			SELECT strBatchId = NULL
			, dtmTransactionDate
			, strTransactionType = 'Contract Balance'
			, strTransactionReference = strTransactionType
			, intTransactionReferenceId = intTransactionId
			, intTransactionReferenceDetailId = intTransactionDetailId
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
			, intActionId = NULL
			, strProcess = @strProcess
			FROM 
			(
				SELECT ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
				, dtmTransactionDate = CASE 
										WHEN strScreenName = 'Inventory Shipment' THEN shipment.dtmShipDate
										WHEN strScreenName = 'Inventory Receipt' THEN receipt.dtmReceiptDate
										ELSE suh.dtmTransactionDate 
									END
				, strTransactionType = strScreenName
				, intTransactionId = suh.intExternalHeaderId -- or intExternalHeaderId since this was used by basis deliveries on search screen
				, intTransactionDetailId = suh.intExternalId
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
				, sh.intUserId	
				FROM vyuCTSequenceUsageHistory suh
				INNER JOIN tblCTSequenceHistory sh on sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
				INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
				INNER JOIN tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
				LEFT JOIN tblICInventoryShipment shipment on suh.intExternalHeaderId = shipment.intInventoryShipmentId
				LEFT JOIN tblICInventoryReceipt receipt on suh.intExternalHeaderId = receipt.intInventoryReceiptId
				WHERE strFieldName = 'Balance'
				AND suh.intExternalId = @intTransactionId
			) tbl
			WHERE Row_Num = 1
			AND intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
		END
		ELSE
		BEGIN
			-- Inventory Receipt/Shipment:
			-- 1. Posting
			-- 	1.1. Reduce balance
			-- 	1.2. Increase deliveries (if unpriced)
			-- 2. Unposting
			-- 	1.1. Increase balance
			-- 	1.2. Increase deliveries (if unpriced)
			INSERT INTO @cbLogTemp (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
			)		
			SELECT strBatchId = NULL
			, dtmTransactionDate
			, strTransactionType = 'Contract Balance'
			, strTransactionReference = strTransactionType
			, intTransactionReferenceId = intTransactionId
			, intTransactionReferenceDetailId = intTransactionDetailId
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
			, intActionId = NULL
							-- CASE 
							-- 	WHEN intContractTypeId = 1 THEN 19 -- Inventory Received on Basis Delivery
							-- 	ELSE 18 -- Inventory Shipped on Basis Delivery
							-- END
			, strProcess = @strProcess
			FROM 
			(
				SELECT ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
				, dtmTransactionDate = CASE 
										WHEN strScreenName = 'Inventory Shipment' THEN shipment.dtmShipDate
										WHEN strScreenName = 'Inventory Receipt' THEN receipt.dtmReceiptDate
										ELSE suh.dtmTransactionDate 
									END
				, strTransactionType = strScreenName
				, intTransactionId = suh.intExternalHeaderId -- or intExternalHeaderId since this was used by basis deliveries on search screen
				, intTransactionDetailId = suh.intExternalId
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
			
			-- Check if invoice
			IF EXISTS
			(
				SELECT TOP 1 1
				FROM @cbLogTemp
				WHERE strTransactionReference = 'Invoice'
			)
			BEGIN		
				SET @ysnInvoice = 1
				INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
				)		
				SELECT strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
				FROM @cbLogTemp
			END
			ELSE IF EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE dblQty < 0 AND strTransactionReference <> 'Transfer Storage' AND intPricingTypeId <> 5 AND @strProcess <> 'Update Sequence Balance - DWG')
				OR EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE dblQty > 0 AND intPricingTypeId = 5 AND strTransactionReference <> 'Settle Storage' AND @strProcess <> 'Update Sequence Balance - DWG')
			BEGIN
				SET @ysnUnposted = 1
				
				SELECT @intHeaderId = intTransactionReferenceId, 
					@intDetailId = intTransactionReferenceDetailId, 
					@_transactionDate = dtmTransactionDate, 
					@intUserId = intUserId 
				FROM @cbLogTemp
				
				INSERT INTO @cbLogCurrent (strBatchId
					, dtmTransactionDate
					, strTransactionType
					, strTransactionReference
					, intTransactionReferenceId
					, intTransactionReferenceDetailId
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
					, strProcess
				)		
				SELECT strBatchId = NULL
					, dtmTransactionDate = @_transactionDate
					, strTransactionType
					, strTransactionReference
					, intTransactionReferenceId
					, intTransactionReferenceDetailId
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
					, strNotes-- = 'Unposted'
					, intUserId = @intUserId
					, intActionId
					, strProcess = @strProcess
				FROM tblCTContractBalanceLog 
				WHERE intTransactionReferenceId = @intHeaderId
				AND intTransactionReferenceDetailId = @intDetailId
				AND intContractHeaderId = @intContractHeaderId
				AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)

				UPDATE CBL SET strNotes = 'Unposted'
				FROM tblCTContractBalanceLog CBL
				WHERE intTransactionReferenceId = @intHeaderId
				AND intTransactionReferenceDetailId = @intDetailId
				AND intContractHeaderId = @intContractHeaderId
				AND intContractDetailId = ISNULL(@intContractDetailId, intContractDetailId)
			END
			ELSE
			BEGIN
				INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
				)		
				SELECT strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
				FROM @cbLogTemp

				IF NOT EXISTS (SELECT TOP 1 1 FROM @cbLogCurrent)
				BEGIN
					SET @ysnDirect = 1
					INSERT INTO @cbLogCurrent (strBatchId
						, dtmTransactionDate
						, strTransactionType
						, strTransactionReference
						, intTransactionReferenceId
						, intTransactionReferenceDetailId
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
						, strProcess
					)		
					SELECT strBatchId = NULL
						, dtmTransactionDate
						, strTransactionType = 'Contract Balance'
						, strTransactionReference = strTransactionType
						, intTransactionReferenceId = intTransactionId
						, intTransactionReferenceDetailId = intTransactionDetailId
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
						, intUserId = @intUserId
						, intActionId = NULL
								-- CASE 
								-- 	WHEN intContractTypeId = 1 THEN 19 -- Inventory Received on Basis Delivery
								-- 	ELSE 18 -- Inventory Shipped on Basis Delivery
								-- END
						, strProcess = @strProcess
					FROM 
					(
						SELECT  
							ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
							, dtmTransactionDate = (dtmTransactionDate)
							, strTransactionType = strScreenName
							, intTransactionId = suh.intExternalHeaderId -- or intExternalHeaderId since this was used by basis deliveries on search screen
							, intTransactionDetailId = suh.intExternalId
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
		IF @strProcess IN ('Price Delete','Fixation Detail Delete')
		BEGIN
			INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
				, strTransactionReferenceNo
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
				, intActionId = 55
				, strProcess = @strProcess
			FROM
			(
				SELECT intTransactionReferenceId = pc.intPriceContractId
				, intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
				, strTransactionReferenceNo = pc.strPriceContractNo
				, dtmTransactionDate = cast((convert(VARCHAR(10), pfd.dtmFixationDate, 111) + ' ' + convert(varchar(20), getdate(), 114)) as datetime)--cast((pfd.dtmFixationDate + convert(varchar(20), getdate(), 114)) as datetime)
				, ch.intContractHeaderId
				, ch.strContractNumber
				, cd.intContractDetailId
				, cd.intContractSeq
				, ch.intContractTypeId
				, dblQty = cbl.dblQty --pfd.dblQuantity
				, intQtyUOMId = ch.intCommodityUOMId
				, intPricingTypeId = 1
				, strPricingType = 'Priced'
				, strTransactionType = 'Price Fixation'--CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
				, intTransactionId = cd.intContractDetailId
				, strTransactionId = ch.strContractNumber + '-' + CAST(cd.intContractSeq AS NVARCHAR(10))
				, dblFutures = pfd.dblFutures
				, cd.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = qu.intCommodityUnitMeasureId
				, cd.intContractStatusId
				, ch.intEntityId
				, ch.intCommodityId
				, cd.intItemId
				, cd.intCompanyLocationId
				, cd.intFutureMarketId
				, cd.intFutureMonthId
				, cd.dtmStartDate
				, cd.dtmEndDate
				, cd.intBookId
				, cd.intSubBookId
				, intOrderBy = 1
				, intUserId = @intUserId
				FROM tblCTPriceFixationDetail pfd
				INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = ch.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
				OUTER APPLY
				(
					SELECT TOP 1 *
					FROM tblCTSequenceHistory
					WHERE intContractHeaderId = pf.intContractHeaderId
					AND intContractDetailId = pf.intContractDetailId
					AND intSequenceUsageHistoryId IS NULL
					ORDER BY dtmHistoryCreated DESC
				) sh
				OUTER APPLY
				(
					SELECT dblQty = MIN(dblQty) * -1
					FROM tblCTContractBalanceLog
					WHERE strProcess = 'Price Fixation'
					AND intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = ISNULL(@intContractDetailId, cd.intContractDetailId)
					AND intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
					GROUP BY intTransactionReferenceDetailId
				) cbl
				WHERE pfd.ysnToBeDeleted = 1		
				AND pfd.intPriceFixationDetailId NOT IN
				(
					SELECT intTransactionReferenceDetailId
					FROM tblCTContractBalanceLog
					WHERE strProcess = 'Fixation Detail Delete'
					AND intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = ISNULL(@intContractDetailId, cd.intContractDetailId)
				)			
			) tbl
			WHERE intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, tbl.intContractDetailId)
			AND dblQty <> 0
		END
		ELSE
		BEGIN

			/*CT-4833*/

			INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
				, strTransactionReferenceNo
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
				, strNotes = (case when dblQty = 0 then 'Change futures price.' else null end)
				, intUserId
				, intActionId
				, strProcess = @strProcess
			FROM
			(
				SELECT  intTransactionReferenceId = pc.intPriceContractId
				, intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
				, strTransactionReferenceNo = pc.strPriceContractNo
				, dtmTransactionDate = cast((convert(varchar(10), pfd.dtmFixationDate, 111) + ' ' + convert(varchar(20), getdate(), 114)) as datetime)--cast((pfd.dtmFixationDate + convert(varchar(20), getdate(), 114)) as datetime)
				, ch.intContractHeaderId
				, ch.strContractNumber
				, cd.intContractDetailId
				, cd.intContractSeq
				, ch.intContractTypeId
				, dblQty = (
							case
							when pfd.dblQuantity > extQty.dblQty
							then pfd.dblQuantity - extQty.dblQty
							when pfd.dblQuantity < extQty.dblQty
							then (extQty.dblQty - pfd.dblQuantity) * -1
							else 0
							end
							)
				, intQtyUOMId = ch.intCommodityUOMId
				, intPricingTypeId = 1
				, strPricingType = 'Priced'
				, strTransactionType = 'Price Fixation'--CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
				, intTransactionId = cd.intContractDetailId
				, strTransactionId = ch.strContractNumber + '-' + CAST(cd.intContractSeq AS NVARCHAR(10))
				, dblFutures = pfd.dblFutures
				, cd.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = qu.intCommodityUnitMeasureId
				, cd.intContractStatusId
				, ch.intEntityId
				, ch.intCommodityId
				, cd.intItemId
				, cd.intCompanyLocationId
				, cd.intFutureMarketId
				, cd.intFutureMonthId
				, cd.dtmStartDate
				, cd.dtmEndDate
				, cd.intBookId
				, cd.intSubBookId
				, intOrderBy = 1
				, intUserId = @intUserId
				, intActionId = 17
				FROM tblCTPriceFixationDetail pfd
				INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = ch.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
				INNER JOIN
				(
					SELECT intTransactionReferenceDetailId, dblQty = sum(dblQty)
					FROM tblCTContractBalanceLog
					WHERE strProcess = 'Price Fixation'
					and intPricingTypeId = 1
					group by intTransactionReferenceDetailId
				) extQty on extQty.intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
				OUTER APPLY
				(
					SELECT TOP 1 *
					FROM tblCTSequenceHistory
					WHERE intContractHeaderId = pf.intContractHeaderId
					AND intContractDetailId = pf.intContractDetailId
					AND intSequenceUsageHistoryId IS NULL
					ORDER BY dtmHistoryCreated DESC
				) sh
				WHERE pfd.intPriceFixationDetailId IN
				(
					SELECT intTransactionReferenceDetailId
					FROM tblCTContractBalanceLog
					WHERE strProcess = 'Price Fixation'
					AND intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = ISNULL(@intContractDetailId, cd.intContractDetailId)
					AND 
					(
						(case when ch.ysnLoad = 1 then pfd.dblLoadPriced else pfd.dblQuantity end) <> CAST(replace(REPLACE(strNotes, 'Priced Quantity is ', ''),'Priced Load is ','') AS NUMERIC(24, 10)) 
						OR 
						pfd.dblFutures <> dblFutures
					)
				)
			) tbl
			WHERE intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, tbl.intContractDetailId)

			/*End of CT-4833*/

			INSERT INTO @cbLogCurrent (strBatchId
				, dtmTransactionDate
				, strTransactionType
				, strTransactionReference
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
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
				, strProcess
			)
			SELECT strBatchId = NULL
				, dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId
				, intTransactionReferenceDetailId
				, strTransactionReferenceNo
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
				, strNotes
				, intUserId
				, intActionId
				, strProcess = @strProcess
			FROM
			(
				SELECT  intTransactionReferenceId = pc.intPriceContractId
				, intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
				, strTransactionReferenceNo = pc.strPriceContractNo
				, dtmTransactionDate = cast((convert(varchar(10), pfd.dtmFixationDate, 111) + ' ' + convert(varchar(20), getdate(), 114)) as datetime)--cast((pfd.dtmFixationDate + convert(varchar(20), getdate(), 114)) as datetime)
				, ch.intContractHeaderId
				, ch.strContractNumber
				, cd.intContractDetailId
				, cd.intContractSeq
				, ch.intContractTypeId
				, dblQty = pfd.dblQuantity
				, intQtyUOMId = ch.intCommodityUOMId
				, intPricingTypeId = 1
				, strPricingType = 'Priced'
				, strTransactionType = 'Price Fixation'--CASE WHEN @strProcess = 'Price Delete' THEN 'Price Fixation' ELSE @strProcess END
				, intTransactionId = cd.intContractDetailId
				, strTransactionId = ch.strContractNumber + '-' + CAST(cd.intContractSeq AS NVARCHAR(10))
				, dblFutures = pfd.dblFutures
				, cd.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = qu.intCommodityUnitMeasureId
				, cd.intContractStatusId
				, ch.intEntityId
				, ch.intCommodityId
				, cd.intItemId
				, cd.intCompanyLocationId
				, cd.intFutureMarketId
				, cd.intFutureMonthId
				, cd.dtmStartDate
				, cd.dtmEndDate
				, cd.intBookId
				, cd.intSubBookId
				, intOrderBy = 1
				, intUserId = @intUserId
				, intActionId = 17
				, strNotes = CASE WHEN @ysnLoadBased = 1 THEN 'Priced Load is ' + CAST(pfd.dblLoadPriced AS NVARCHAR(20)) ELSE 'Priced Quantity is ' + CAST(pfd.dblQuantity AS NVARCHAR(20)) END
				FROM tblCTPriceFixationDetail pfd
				INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = ch.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
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
					SELECT intTransactionReferenceDetailId
					FROM tblCTContractBalanceLog
					WHERE strProcess = 'Price Fixation'
					AND intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = ISNULL(@intContractDetailId, cd.intContractDetailId)
				)
			) tbl
			WHERE intContractHeaderId = @intContractHeaderId
			AND intContractDetailId = ISNULL(@intContractDetailId, tbl.intContractDetailId)
		END
	END
		
	DECLARE @currentContractDetalId INT,
			@cbLogSpecific AS CTContractBalanceLog,
			@intId INT,
			@_dblQty NUMERIC(24, 10) = 0

	SELECT @intId = MIN(intId) FROM @cbLogCurrent
	WHILE @intId > 0--EXISTS(SELECT TOP 1 1 FROM @cbLogCurrent)
	BEGIN
		DELETE FROM @cbLogPrev
	
		INSERT INTO @cbLogSpecific
		(
			strBatchId,							dtmTransactionDate,							strTransactionType,						strTransactionReference,
			intTransactionReferenceId,			intTransactionReferenceDetailId,			strTransactionReferenceNo,				intContractDetailId, 
			intContractHeaderId,				strContractNumber,							intContractSeq,							intContractTypeId, 
			intEntityId,						intCommodityId,								intItemId,								intLocationId,
			intPricingTypeId,					intFutureMarketId,							intFutureMonthId,						dblBasis, 
			dblFutures,							intQtyUOMId,								intQtyCurrencyId,						intBasisUOMId, 
			intBasisCurrencyId,					intPriceUOMId,								dtmStartDate,							dtmEndDate, 
			dblQty,								intContractStatusId,						intBookId,								intSubBookId, 
			strNotes,							intUserId,									intActionId,							strProcess
		)
		SELECT 
			strBatchId,							dtmTransactionDate,							strTransactionType,						strTransactionReference,
			intTransactionReferenceId,			intTransactionReferenceDetailId,			strTransactionReferenceNo,				intContractDetailId, 
			intContractHeaderId,				strContractNumber,							intContractSeq,							intContractTypeId, 
			intEntityId,						intCommodityId,								intItemId,								intLocationId,
			intPricingTypeId,					intFutureMarketId,							intFutureMonthId,						dblBasis, 
			dblFutures,							intQtyUOMId,								intQtyCurrencyId,						intBasisUOMId, 
			intBasisCurrencyId,					intPriceUOMId,								dtmStartDate,							dtmEndDate, 
			dblQty,								intContractStatusId,						intBookId,								intSubBookId, 
			strNotes,							intUserId,									intActionId,							strProcess
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
				, intTransactionReferenceDetailId
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
				, intTransactionReferenceDetailId
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
				UPDATE @cbLogSpecific SET intActionId = 42
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
				@dblDP 			NUMERIC(24, 10),
				@dblCash		NUMERIC(24, 10),
				@dblQty 		NUMERIC(24, 10),
				@dblAvrgFutures	NUMERIC(24, 10),
				@total 			NUMERIC(24, 10),
				@dblActual		NUMERIC(24, 10),
				@_action		INT

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

		SELECT @dblDP = SUM(dblQty)
		FROM @cbLogPrev
		WHERE intPricingTypeId = 5
		AND strTransactionType NOT LIKE '%Basis Deliveries'
		GROUP BY intPricingTypeId

		SELECT @dblCash = SUM(dblQty)
		FROM @cbLogPrev
		WHERE intPricingTypeId = 6
		GROUP BY intPricingTypeId

		SELECT @dblQty = dblQty
		FROM @cbLogSpecific	

		SET @total = (@dblQty - @dblQtys)
		

		IF @strSource = 'Contract'
		BEGIN		
			IF @ysnDeleted = 1
			BEGIN
				UPDATE @cbLogSpecific SET dblQty = dblQty * -1
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
				
				-- DP Contract
				IF EXISTS (SELECT TOP 1 1 FROM @cbLogSpecific WHERE intPricingTypeId = 5)
				BEGIN
					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
				END
			END
			
			IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intContractStatusId IN (3,6))
			BEGIN	
				IF ISNULL(@dblQty,0) = 0
				BEGIN
					SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
					FROM @cbLogSpecific

					UPDATE @cbLogSpecific SET intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				
				IF ISNULL(@dblBasis,0) > 0
				BEGIN
					SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
					FROM @cbLogSpecific

					UPDATE @cbLogSpecific SET dblQty = @dblBasis * -1, intPricingTypeId = 2, intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				IF ISNULL(@dblPriced,0) > 0
				BEGIN
					SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
					FROM @cbLogSpecific

					UPDATE @cbLogSpecific SET dblQty = @dblPriced * -1, intPricingTypeId = 1, intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				
				-- Reverse Basis Deliveries
				IF @dblBasisDel > 0
				BEGIN
					UPDATE @cbLogSpecific SET dblQty = @dblBasisDel * -1,
								strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
								intPricingTypeId = CASE WHEN ISNULL(@dblBasis,0) = 0 THEN 1 ELSE 2 END, intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0 
				END
			END			
			ELSE IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intContractStatusId = 4)
			BEGIN
				UPDATE @cbLogSpecific SET dblQty = dblQty * -1, intActionId = 61
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @total = 0-- No changes with dblQty
			BEGIN	
				-- Delete records not equals to 'Contract Balance'
				DELETE FROM @cbLogPrev   
				WHERE strTransactionType <> 'Contract Balance'
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev ORDER BY intId DESC)

				-- Compare previous AND current except the qty				
				SELECT @ysnMatched = CASE WHEN COUNT(intPricingTypeId) = 1 THEN 1 ELSE 0 END
				FROM
				(
					SELECT --dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
					--, strTransactionType
					--, intContractDetailId
					--, intContractHeaderId
					--, strContractNumber
					--, intContractSeq
					--, intContractTypeId
					--, intEntityId
					--, intCommodityId
					--, intItemId
					--, intLocationId
					--, 
					intPricingTypeId
					--, intFutureMarketId
					--, intFutureMonthId
					--, dblBasis
					--, dblFutures
					--, intQtyUOMId
					--, intQtyCurrencyId
					--, intBasisUOMId
					--, intBasisCurrencyId
					--, intPriceUOMId
					--, dtmStartDate
					--, dtmEndDate
					--, intContractStatusId
					--, intBookId
					--, intSubBookId
					, strNotes FROM @cbLogPrev
					UNION
					SELECT 
					--dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
					--, strTransactionType				
					--, intContractDetailId
					--, intContractHeaderId
					--, strContractNumber
					--, intContractSeq
					--, intContractTypeId
					--, intEntityId
					--, intCommodityId
					--, intItemId
					--, intLocationId
					--, 
					intPricingTypeId
					--, intFutureMarketId
					--, intFutureMonthId
					--, dblBasis
					--, dblFutures
					--, intQtyUOMId
					--, intQtyCurrencyId
					--, intBasisUOMId
					--, intBasisCurrencyId
					--, intPriceUOMId
					--, dtmStartDate
					--, dtmEndDate
					--, intContractStatusId
					--, intBookId
					--, intSubBookId
					, strNotes FROM @cbLogSpecific
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
											END,
						intActionId = 43
					FROM @cbLogPrev a
					OUTER APPLY
					(
						SELECT TOP 1 dblQtyPriced 
						FROM tblCTSequenceHistory 
						WHERE intContractDetailId = a.intContractDetailId
						ORDER BY intSequenceHistoryId DESC
					) b	

					-- Negate previous if the value is not 0
					IF NOT EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE dblQty = 0)
					BEGIN		
						declare @_dtmCurrent datetime
						select @_dtmCurrent = dtmTransactionDate from @cbLogSpecific			
						UPDATE @cbLogPrev SET strBatchId = NULL, strProcess = @strProcess, dtmTransactionDate = @_dtmCurrent
						EXEC uspCTLogContractBalance @cbLogPrev, 0
					END
					
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
						FROM @cbLogSpecific a				
						OUTER APPLY
						(
							SELECT TOP 1 dblQtyPriced 
							FROM tblCTSequenceHistory 
							WHERE intContractDetailId = a.intContractDetailId
							ORDER BY intSequenceHistoryId DESC
						) b	

						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
				END		
				ELSE
				BEGIN
					-- Check if the changes is with either Basis or Futures
					SELECT @ysnMatched = CASE WHEN COUNT(dblBasis) = 1 THEN 1 ELSE 0 END
					FROM
					(
						SELECT dblBasis
						, dblFutures
						FROM @cbLogPrev
						UNION
						SELECT dblBasis
						, dblFutures
						FROM @cbLogSpecific
					) tbl
					IF @ysnMatched <> 1
					BEGIN
						UPDATE @cbLogSpecific SET dblQty = 0
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
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
					, strNotes FROM @cbLogSpecific
				) tbl

				IF @ysnMatched <> 1
				BEGIN
					SET @total =  @total * -1
					-- Negate AND add previous record
					UPDATE @cbLogPrev SET dblQty = @dblQtys *-1
					EXEC uspCTLogContractBalance @cbLogPrev, 0
				END
				
				-- Add current record
				UPDATE  @cbLogSpecific SET dblQty = @total
				EXEC uspCTLogContractBalance @cbLogSpecific, 0		
			END
		END
		ELSE IF @strSource = 'Pricing'
		BEGIN		
			IF @strProcess = 'Price Delete'
			BEGIN			
				-- 	1.1. Increase basis
				-- 	1.2. Increase basis by priced quantities

				declare @_id INT
				select @_id = intTransactionReferenceId from @cbLogSpecific
				
				-- Get the previous record
				DELETE FROM @cbLogPrev
				WHERE intId <>
				(
					SELECT TOP 1 intId
					FROM @cbLogPrev
					WHERE intPricingTypeId = 2
					AND strTransactionType = 'Contract Balance'
					AND intTransactionReferenceId = @_id
					ORDER BY intId DESC
				)
				--IF @dblPriced <> 0
				--BEGIN
					-- Negate all the priced quantities
					UPDATE @cbLogSpecific SET dblQty = @dblQty *-1, intPricingTypeId = 1, strTransactionReference = 'Price Fixation', strBatchId = null
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					-- Add all the basis quantities
					UPDATE @cbLogSpecific SET dblQty = @dblQty, intPricingTypeId = 2
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				--END
			END
			ELSE IF @strProcess = 'Fixation Detail Delete'
			BEGIN				
				-- 	1.1. Increase basis
				-- 	1.2. Decrease priced				
				--IF @dblQtys <> 0
				--BEGIN
					-- Negate deleted the priced quantities
					UPDATE @cbLogSpecific SET dblQty = CASE WHEN @dblQtys > @dblQty THEN @dblQty ELSE @dblQtys END *-1, strTransactionReference = 'Price Fixation', strBatchId = null
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					-- Negate deleted the priced quantities
					UPDATE @cbLogSpecific SET dblQty = CASE WHEN @dblQtys > @dblQty THEN @dblQty ELSE @dblQtys END, strTransactionReference = 'Price Fixation', strBatchId = null, intPricingTypeId = 2
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				--END
			END
			ELSE IF @dblBasisDel > 0
			BEGIN
				-- Get the original basis delivery quantities
				IF @dblBasisDelOrig IS NULL
				BEGIN
					SET @dblBasisDelOrig = @dblBasisDel
				END

				-- Check if the running priced quantity less than basis delivery total
				SET @_dblQty = (@_dblQty + @dblQty)
				IF @_dblQty > @dblBasisDelOrig
				BEGIN					
					-- Negate basis using the current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = (CASE WHEN @_dblQty = @dblQty THEN (@_dblQty - (CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad ELSE @dblBasisDel END)) ELSE (CASE WHEN @dblQty > @dblBasis THEN @dblBasis ELSE @dblQty END) END) * -1, 
												intPricingTypeId = 2,
											   dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					-- Negate basis using the current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = (CASE WHEN @_dblQty = @dblQty THEN (@_dblQty - (CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad ELSE @dblBasisDel END)) ELSE (CASE WHEN @dblQty > @dblBasis THEN @dblBasis ELSE @dblQty END) END), 
												intPricingTypeId = 1,
												dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				ELSE
				BEGIN
					-- Negate basis using the current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = 0, intPricingTypeId = 2,
												dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					-- Negate basis using the current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = 0, intPricingTypeId = 1,
												dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END

				-- Check if the contract is destination weights and grades
				IF EXISTS 
				(
					select top 1 1 
					from tblCTContractHeader ch
					inner join tblCTWeightGrade wg on wg.intWeightGradeId in (ch.intWeightId, ch.intGradeId)
						and wg.strWhereFinalized = 'Destination'
					where intContractHeaderId = @intContractHeaderId
				)
				BEGIN
					-- Basis Deliveries  
					UPDATE @cbLogSpecific SET dblQty = @dblBasisDel * -1,
											  strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END--,
											  --intPricingTypeId = CASE WHEN ISNULL(@dblBasis,0) = 0 THEN 1 ELSE 2 END
					EXEC uspCTLogContractBalance @cbLogSpecific, 0  
				END
			END
			ELSE
			BEGIN
				IF @dblQtys > 0
				BEGIN
					---- Get the previous basis
					-- Negate basis using the current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = CASE WHEN @dblQtys > @dblQty THEN @dblQty ELSE @dblQtys END * -1, intPricingTypeId = 2,
											   dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					-- Add current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = CASE WHEN @dblQtys > @dblQty THEN @dblQty ELSE @dblQtys END, intPricingTypeId = 1,
											   dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
			END
		END
		ELSE IF @strSource = 'Inventory'
		BEGIN
			IF @ysnInvoice = 1
			BEGIN
				UPDATE @cbLogSpecific SET dblQty = dblQty * -1, intActionId = 16
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE
			BEGIN				
				-- Get previous totals
				DECLARE @_basis 		NUMERIC(24, 10) = 0,
						@_priced 		NUMERIC(24, 10) = 0,
						@_dp	 		NUMERIC(24, 10) = 0,
						@_cash	 		NUMERIC(24, 10) = 0,
						@_balance		NUMERIC(24, 10) = 0,
						@_actual 		NUMERIC(24, 10) = 0,
						--@_action		INT,
						@_unpost		BIT;			
			
				-- Get action types for Settle Storeage, IR and IS transactions	
				select @_action = case when strTransactionReference = 'Settle Storage' then 53 else (case when intContractTypeId = 1 then 19 else 18 end) end
				from @cbLogSpecific

				-- If DP/Transfer Storage disregard Update Sequence Balance and consider Update Sequence Quantity "or the other way around"
				IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intPricingTypeId = 5 AND @strProcess = 'Update Sequence Balance')
				BEGIN
					RETURN
				END

				IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE strTransactionReference = 'Transfer Storage')
				BEGIN
					UPDATE @cbLogSpecific SET dblQty = dblQty * -1, intActionId = 58
					EXEC uspCTLogContractBalance @cbLogSpecific, 0  
					RETURN
				END
				
				IF @strProcess = 'Update Sequence Balance - DWG'
				BEGIN
					IF @dblQty * -1 > 0
					BEGIN				
						DECLARE @_prevQty NUMERIC(24,10),
								@_prevType INT

						SELECT TOP 1 @_prevQty = prev.dblQty, @_prevType = prev.intPricingTypeId
						FROM @cbLogPrev prev
						INNER JOIN @cbLogSpecific spfc ON prev.intTransactionReferenceId = spfc.intTransactionReferenceId
							AND prev.intTransactionReferenceDetailId = spfc.intTransactionReferenceDetailId
						WHERE prev.strTransactionType = 'Contract Balance'
						ORDER BY prev.intId DESC
								
						UPDATE @cbLogSpecific SET dblQty = dblQty *-1, intPricingTypeId = @_prevType, intActionId = CASE WHEN @_prevType = 1 THEN 46 ELSE 18 END
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
					ELSE
					BEGIN
						IF ISNULL(@dblPriced,0) > 0
						BEGIN
							IF @dblPriced >= @dblQty
							BEGIN
								UPDATE @cbLogSpecific SET dblQty = dblQty *-1, intPricingTypeId = 1, intActionId = 46
								EXEC uspCTLogContractBalance @cbLogSpecific, 0
							END
						END
						IF ISNULL(@dblBasis,0) > 0
						BEGIN				
							IF @dblBasis >= @dblQty
							BEGIN									
								UPDATE @cbLogSpecific SET dblQty = dblQty *-1, intPricingTypeId = 2, intActionId = 18
								EXEC uspCTLogContractBalance @cbLogSpecific, 0
							END
						END
					END
									
					IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intPricingTypeId = 2)
					BEGIN						
						IF  @dblQty <> 0
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = @dblQty * -1, strTransactionType = 'Sales Basis Deliveries', intPricingTypeId = 2, intActionId = 18
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END
					END
					RETURN
				END			
				
				IF @strProcess = 'Post Load-based DWG' OR @strProcess = 'Unpost Load-based DWG'
				BEGIN
					declare @_origQty numeric(20,12),
							@_pricingType int
					SELECT @dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(a.intItemId, a.intItemUOMId, 
												CASE WHEN @strProcess = 'Unpost Load-based DWG'
														THEN ISNULL(a.dblDestinationNet,0) - ISNULL(a.dblQuantity,0)
														ELSE ISNULL(a.dblQuantity,0) - ISNULL(a.dblDestinationNet,0) 
												END))
						  ,@_origQty = MAX(b.dblQty)
						  ,@_pricingType = MAX(b.intPricingTypeId)
					FROM tblICInventoryShipmentItem a
					INNER JOIN @cbLogSpecific b ON a.intInventoryShipmentId = b.intTransactionReferenceId
					WHERE b.intContractHeaderId = a.intOrderId
					AND a.intLineNo = ISNULL(b.intContractDetailId, a.intLineNo)
					
					-- Basis
					-- 25 qty 25 dwg 0 adj 0 bd
					-- 25 qty 20 dwg 5 adj -5 bd
					-- 25 qty 30 dwg -5 adj 5 bd
					-- Partial
					-- 25 qty 25 dwg 0 adj 0 bd
					-- 25 qty 20 dwg 5 adj -5 bd
					-- 25 qty 30 dwg -5 adj 5 bd
					declare @_d numeric(20,12)
					IF @strProcess = 'Post Load-based DWG'
					BEGIN
						IF @dblQty > 0
						BEGIN
							SET @dblQty = CASE WHEN ABS(@dblQty) < @dblBasisDel THEN ABS(@dblQty) ELSE 0 END
						END
						ELSE
						BEGIN
							SET @_d = (ABS(@dblQty) - ISNULL(@dblPriced,0))
							SET @dblQty = (CASE WHEN @_d < 0 THEN 0 ELSE @_d END) * -1
						END						
					END
					-- Basis
					-- 25 dwg 25 qty 0 adj 0 bd
					-- 20 dwg 25 qty -5 adj 5 bd
					-- 30 dwg 25 qty 5 adj -5 bd
					-- Partial
					-- 25 dwg 25 qty 0 adj 0 bd
					-- 20 dwg 25 qty -5 adj 5 bd
					-- 30 dwg 25 qty 5 adj -5 bd
					ELSE --'Unpost Load-based DWG'
					BEGIN
						IF @dblQty > 0
						BEGIN
							SET @dblQty = CASE WHEN @dblQty < @dblBasis THEN @dblQty ELSE @dblBasis END
						END
						ELSE
						BEGIN
							SET @dblQty = (CASE WHEN ABS(@dblQty) < @dblBasisDel THEN ABS(@dblQty) ELSE 0 END) *-1
						END						
					END

					IF  @dblQty <> 0
					BEGIN
						UPDATE @cbLogSpecific SET dblQty = @dblQty * -1, strTransactionType = 'Sales Basis Deliveries', intPricingTypeId = 2, intActionId = 18
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
					RETURN
				END

				-- Posted: IR/IS/Settle Storage
				IF @ysnUnposted = 0--@dblQty > 0
				BEGIN					
					-- Get actual transaction quantity
					-- Inventory Shipment
					IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE strTransactionReference = 'Inventory Shipment')
					BEGIN
						SELECT @dblActual = SUM(ISNULL(ABS(dbo.fnICConvertUOMtoStockUnit(a.intItemId, a.intItemUOMId, ISNULL(a.dblDestinationQuantity,ISNULL(a.dblQuantity,0)))),0))
						FROM tblICInventoryShipmentItem a
						INNER JOIN @cbLogSpecific b ON a.intInventoryShipmentId = b.intTransactionReferenceId
						WHERE b.intContractHeaderId = a.intOrderId
						AND a.intLineNo = ISNULL(b.intContractDetailId, a.intLineNo)
					END
					-- Inventory Receipt
					IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE strTransactionReference = 'Inventory Receipt')
					BEGIN
						SELECT @dblActual = SUM(dblOpenReceive)
						FROM tblICInventoryReceiptItem a
						INNER JOIN @cbLogSpecific b ON a.intInventoryReceiptId = b.intTransactionReferenceId
					END
					-- Settle Storage
					IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE strTransactionReference = 'Settle Storage')
					BEGIN
						SELECT @dblActual = SUM(dblUnits)
						FROM tblGRSettleContract a
						INNER JOIN @cbLogSpecific b ON a.intSettleStorageId = b.intTransactionReferenceId
					END
					-- Reduce contract balance
					-- Scenario 1
					--  Transaction	  |    Pricing				|  Contract Balance
					-- IS/IR/SS: 1000 | Priced 1000 Basis -1000 | CB: P -1000 B 0 /
					-- IS/IR/SS: 1000 | Priced 500 Basis -500	| CB: P -500 B -500 /
					-- IS/IR/SS: 1000 | Priced 0 Basis 1000		| CB: P 0 B -1000 /
					-- Scenario 2
					-- IS/IR/SS 500 | Priced 1000 Basis 0 | CB: P -500 B 0 /
					-- IS/IR/SS 500 | Priced 500 Basis 500 | CB: P -500 B 0 /
					-- IS/IR/SS 500 | Priced 400 Basis 600 | CB: P -400 B -100 /
					IF ISNULL(@dblPriced,0) > 0
					BEGIN	
						-- Balance
						SET @_priced = (CASE WHEN @dblQty > ISNULL(@dblPriced,0) THEN ISNULL(@dblPriced,0) ELSE @dblQty END)
						UPDATE @cbLogSpecific SET dblQty = @_priced * -1, intPricingTypeId = 1, intActionId = CASE WHEN intContractTypeId = 1 THEN 47 ELSE 46 END
						EXEC uspCTLogContractBalance @cbLogSpecific, 0  
						SET @dblQty = @dblQty - @_priced
						IF @ysnLoadBased = 1
						BEGIN
							-- Basis Deliveries
							SET @_priced = (CASE WHEN @dblActual > ISNULL(@dblPriced,0) THEN ISNULL(@dblPriced,0) ELSE @dblActual END)
							SET @dblActual = @dblActual - @_priced
						END
					END				
					IF ISNULL(@dblBasis,0) > 0
					BEGIN
						IF @dblQty > 0
						BEGIN
							-- Balance
							SET @_basis = (CASE WHEN @dblQty > ISNULL(@dblBasis,0) THEN ISNULL(@dblBasis,0) ELSE @dblQty END)
							UPDATE @cbLogSpecific SET dblQty = @_basis * -1, intPricingTypeId = 2, intActionId = @_action
							EXEC uspCTLogContractBalance @cbLogSpecific, 0  
							SET @dblQty = @dblQty - @_basis
						END
						IF @ysnLoadBased = 1 AND @dblActual > 0
						BEGIN
							-- Basis Deliveries
							SET @_actual = (CASE WHEN @dblActual > ISNULL(@dblBasis,0) THEN ISNULL(@dblBasis,0) ELSE @dblActual END)
						END
					END
					IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intPricingTypeId = 5)--ISNULL(@dblDP,0) > 0
					BEGIN
						-- Balance
						SET @_dp = (CASE WHEN @dblQty > ISNULL(@dblDP,0) THEN ISNULL(@dblDP,0) ELSE @dblQty END)
						UPDATE a SET dblQty = @_dp * -1, intActionId = CASE WHEN a.intContractTypeId = 1 THEN 49 ELSE 50 END
						FROM @cbLogSpecific a
						EXEC uspCTLogContractBalance @cbLogSpecific, 0  
					END
					IF ISNULL(@dblCash,0) > 0
					BEGIN
						SET @_cash = (CASE WHEN @dblQty > ISNULL(@dblCash,0) THEN ISNULL(@dblCash,0) ELSE @dblQty END)
						UPDATE a SET dblQty = @_cash * -1, intActionId = CASE WHEN a.intContractTypeId = 1 THEN 52 ELSE 51 END
						FROM @cbLogSpecific a
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
					-- Increase basis deliveries based on the basis quantities
					-- Scenario 1
					-- Priced 1000 | BD 0 /
					-- Priced 500 Basis 500 | BD 500 /
					-- Priced 0 Basis 1000 | BD 1000 /
					-- Scenario 2
					-- Priced 1000 | BD 0 /
					-- Priced 500 | BD 0 /
					-- Priced 400 | BD 100 /
					IF (@_basis > 0 OR @_actual > 0) AND @ysnDirect <> 1
					BEGIN				
						-- Basis Deliveries  
						UPDATE @cbLogSpecific SET dblQty = CASE WHEN @ysnLoadBased = 1 THEN @_actual ELSE @_basis END,
												  strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
												  intPricingTypeId = CASE WHEN ISNULL(@dblBasis,0) = 0 THEN 1 ELSE 2 END, intActionId = @_action
						EXEC uspCTLogContractBalance @cbLogSpecific, 0  
					END
				END
				ELSE
				BEGIN
					-- Scenario 1
					-- IS/IR/SS: -1000 | Priced 0 Basis 0 | CB: P 0 B 0
					-- IS/IR/SS: -1000 | Priced 0 Basis 0 | CB: P 0 B 0
					-- IS/IR/SS: -1000 | Priced 0 Basis 0 | CB: P 0 B 0
					-- Negate previous record
					UPDATE @cbLogSpecific SET dblQty = dblQty * -1--, intPricingTypeId = CASE WHEN intPricingTypeId IN (1,2) THEN 2 ELSE intPricingTypeId END, intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
			END

		END

		DELETE FROM @cbLogSpecific

		SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH