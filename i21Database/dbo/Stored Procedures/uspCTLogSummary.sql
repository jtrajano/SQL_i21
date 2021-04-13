CREATE PROCEDURE [dbo].[uspCTLogSummary]
	@intContractHeaderId	INT,
    @intContractDetailId	INT,
	@strSource				NVARCHAR(20),
	@strProcess				NVARCHAR(50),
	@contractDetail			AS ContractDetailTable READONLY,
	@intUserId				INT = NULL,
	@intTransactionId		INT = NULL,
	@dblTransactionQty		NUMERIC(24, 10) = 0

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
			@ysnInvoice				BIT = 0,
			@ysnSplit				BIT = 0,
			@ysnReturn				BIT = 0,
			@ysnMultiPrice			BIT = 0,
			@ysnDWGPriceOnly		BIT = 0;

	-------------------------------------------
	--- Uncomment line below when debugging ---
	-------------------------------------------
	-- SELECT strSource = @strSource, strProcess = @strProcess

	IF @strProcess IN 
	(
		'Update Scheduled Quantity',
		'Update Sequence Status',
		'Missing History',
		'Update Sequence Balance - DWG (Load-based)'
	)
	BEGIN
		RETURN
	END

	IF (@strSource = 'Pricing' AND @strProcess = 'Save Contract') 
	OR (@strSource = 'Pricing-Old' AND @strProcess = 'Price Delete')
	BEGIN
		RETURN
	END

	-- Get if load based and quantity per load
	SELECT @ysnLoadBased = ISNULL(ysnLoad,0), @dblQuantityPerLoad = dblQuantityPerLoad, @ysnMultiPrice = isnull(ysnMultiplePriceFixation,0) FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

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
				AND sh.intContractHeaderId = @intContractHeaderId
				AND sh.intContractDetailId = ISNULL(@intContractDetailId, sh.intContractDetailId)
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
					, intContractStatusId = 4
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId = @intUserId
					, intActionId
					, strProcess = @strProcess
				FROM tblCTContractBalanceLog  WITH (UPDLOCK)
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
				AND suh.intContractHeaderId = @intContractHeaderId
				AND suh.intContractDetailId = ISNULL(@intContractDetailId, suh.intContractDetailId)
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
					AND suh.intContractDetailId = (case when @ysnMultiPrice = 1 then suh.intContractDetailId else pf.intContractDetailId end)
				) price
				WHERE strFieldName = 'Balance'
				AND suh.intContractHeaderId = @intContractHeaderId
				AND suh.intContractDetailId = ISNULL(@intContractDetailId, suh.intContractDetailId)
				AND suh.intExternalHeaderId is not null
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
				SELECT lt.strBatchId
				, lt.dtmTransactionDate
				, lt.strTransactionType
				, lt.strTransactionReference
				, lt.intTransactionReferenceId
				, lt.intTransactionReferenceDetailId
				, lt.strTransactionReferenceNo
				, lt.intContractDetailId
				, lt.intContractHeaderId
				, lt.strContractNumber
				, lt.intContractSeq
				, lt.intContractTypeId
				, lt.intEntityId
				, lt.intCommodityId
				, lt.intItemId
				, lt.intLocationId
				, intPricingTypeId = cd.intPricingTypeId
				, lt.intFutureMarketId
				, lt.intFutureMonthId
				, lt.dblBasis
				, lt.dblFutures
				, lt.intQtyUOMId
				, lt.intQtyCurrencyId
				, lt.intBasisUOMId
				, lt.intBasisCurrencyId
				, lt.intPriceUOMId
				, lt.dtmStartDate
				, lt.dtmEndDate
				, lt.dblQty
				, lt.intContractStatusId
				, lt.intBookId
				, lt.intSubBookId
				, lt.strNotes
				, lt.intUserId
				, lt.intActionId
				, lt.strProcess
				FROM @cbLogTemp lt
				join tblCTContractDetail cd on cd.intContractDetailId = lt.intContractDetailId
			END
			ELSE IF EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE strTransactionReference = 'Receipt Return')
			BEGIN	
				IF EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE dblQty > 0)
				BEGIN
					SET @ysnUnposted = 1
				END

				SET @ysnReturn = 1

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
				, dblQty *-1
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
				FROM tblCTContractBalanceLog WITH (UPDLOCK)
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
			ELSE IF EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE strTransactionReference = 'Split')
			BEGIN
				IF @strProcess = 'Update Sequence Quantity'
				BEGIN
					RETURN
				END

				SET @ysnSplit = 1

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
				, strTransactionReference = 'Contract Sequence'
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
				, dblQty * -1
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId = 54
				, strProcess = 'Update Sequence Balance - Split'
				FROM @cbLogTemp		
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
						AND suh.intContractHeaderId = @intContractHeaderId
						AND suh.intContractDetailId = ISNULL(@intContractDetailId, suh.intContractDetailId)
	  					AND suh.intExternalHeaderId is not null
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
				, dblDynamic
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
				, intActionId = 55
				, strProcess = @strProcess
				, dblDynamic
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
				, dblQty = CASE WHEN @ysnLoadBased = 1 THEN 0
								ELSE (CASE WHEN @strProcess = 'Price Delete' THEN pfd.dblQuantity - ISNULL(dblQuantityAppliedAndPriced, 0)
											WHEN @strProcess = 'Fixation Detail Delete' THEN pfd.dblQuantity
											ELSE 0 END) END
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
				, strNotes = CASE WHEN @ysnLoadBased = 1 THEN 'Priced Load is ' + CAST(pfd.dblLoadPriced AS NVARCHAR(20)) ELSE 'Priced Quantity is ' + CAST(pfd.dblQuantity AS NVARCHAR(20)) END
				, dblDynamic =  isnull(dblQuantityAppliedAndPriced,0)
				FROM tblCTPriceFixationDetail pfd
				INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = (case when @ysnMultiPrice = 1 then cd.intContractDetailId else pf.intContractDetailId end)
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = ch.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
				OUTER APPLY
				(
					SELECT TOP 1 *
					FROM tblCTSequenceHistory
					WHERE intContractHeaderId = pf.intContractHeaderId
					AND intContractDetailId = (case when @ysnMultiPrice = 1 then intContractDetailId else pf.intContractDetailId end)
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
				AND pf.intContractHeaderId = @intContractHeaderId
				AND pf.intContractDetailId = ISNULL(@intContractDetailId, pf.intContractDetailId)	
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
		END
		ELSE IF @strProcess = 'Priced DWG'
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
				, strProcess)
			SELECT NULL
				, cbl.dtmTransactionDate
				, strTransactionType = 'Sales Basis Deliveries'
				, cbl.strTransactionReference
				, cbl.intTransactionReferenceId
				, cbl.intTransactionReferenceDetailId
				, cbl.strTransactionReferenceNo
				, cbl.intContractDetailId
				, cbl.intContractHeaderId
				, cbl.strContractNumber
				, cbl.intContractSeq
				, cbl.intContractTypeId
				, cbl.intEntityId
				, cbl.intCommodityId
				, cbl.intItemId
				, cbl.intLocationId
				, cbl.intPricingTypeId
				, cbl.intFutureMarketId
				, cbl.intFutureMonthId
				, cbl.dblBasis
				, cbl.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = @dblTransactionQty * -1
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, cbl.strNotes
				, cbl.intUserId
				, cbl.intActionId
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess <> 'Priced DWG'
			INNER JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationDetailId = cbl.intTransactionReferenceDetailId
			WHERE cbl.intPricingTypeId = 1			
			AND cbl.intContractHeaderId = @intContractHeaderId
			AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			AND cbl.intTransactionReferenceDetailId = @intTransactionId
			
		END
		ELSE IF @strProcess = 'Price Delete DWG'
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
				, strProcess)
			SELECT NULL
				, cbl.dtmTransactionDate
				, strTransactionType = 'Sales Basis Deliveries'
				, cbl.strTransactionReference
				, cbl.intTransactionReferenceId
				, cbl.intTransactionReferenceDetailId
				, cbl.strTransactionReferenceNo
				, cbl.intContractDetailId
				, cbl.intContractHeaderId
				, cbl.strContractNumber
				, cbl.intContractSeq
				, cbl.intContractTypeId
				, cbl.intEntityId
				, cbl.intCommodityId
				, cbl.intItemId
				, cbl.intLocationId
				, cbl.intPricingTypeId
				, cbl.intFutureMarketId
				, cbl.intFutureMonthId
				, cbl.dblBasis
				, cbl.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = @dblTransactionQty * -1
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, cbl.strNotes
				, cbl.intUserId
				, intActionId = 55
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess <> 'Priced DWG'
			INNER JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationDetailId = cbl.intTransactionReferenceDetailId
			WHERE cbl.intPricingTypeId = 1			
			AND cbl.intContractHeaderId = @intContractHeaderId
			AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			AND cbl.intTransactionReferenceDetailId = @intTransactionId
		END
		ELSE IF @strProcess = 'Price Update'
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
				, strProcess)
			SELECT TOP 1 NULL
				, cbl.dtmTransactionDate
				, strTransactionType = 'Sales Basis Deliveries'
				, cbl.strTransactionReference
				, cbl.intTransactionReferenceId
				, cbl.intTransactionReferenceDetailId
				, cbl.strTransactionReferenceNo
				, cbl.intContractDetailId
				, cbl.intContractHeaderId
				, cbl.strContractNumber
				, cbl.intContractSeq
				, cbl.intContractTypeId
				, cbl.intEntityId
				, cbl.intCommodityId
				, cbl.intItemId
				, cbl.intLocationId
				, cbl.intPricingTypeId
				, cbl.intFutureMarketId
				, cbl.intFutureMonthId
				, cbl.dblBasis
				, cbl.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = @dblTransactionQty
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, cbl.strNotes
				, cbl.intUserId
				, intActionId = 17
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess = 'Price Fixation'
			INNER JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationDetailId = cbl.intTransactionReferenceDetailId
			WHERE cbl.intPricingTypeId = 1			
			AND cbl.intContractHeaderId = @intContractHeaderId
			AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			AND cbl.intTransactionReferenceDetailId = @intTransactionId
			AND cbl.dblQty > 0
			ORDER BY cbl.intContractBalanceLogId DESC
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
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = (case when @ysnMultiPrice = 1 then cd.intContractDetailId else pf.intContractDetailId end)
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
					AND intContractDetailId = ISNULL(pf.intContractDetailId,intContractDetailId)
					AND intSequenceUsageHistoryId IS NULL
					ORDER BY dtmHistoryCreated DESC
				) sh
				WHERE pf.intContractHeaderId = @intContractHeaderId
				AND pf.intContractDetailId = ISNULL(@intContractDetailId, pf.intContractDetailId)
				AND pfd.intPriceFixationDetailId IN
				(
					SELECT intTransactionReferenceDetailId
					FROM tblCTContractBalanceLog
					WHERE strProcess = 'Price Fixation'
					AND intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = ISNULL(@intContractDetailId, cd.intContractDetailId)
					AND (strNotes like 'Priced Quantity is%' or strNotes like 'Priced Load is%')
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
			AND dblQty <> 0
			/*End of CT-4833*/

			/*CT-5179*/
			/*If DWG and Ticket DWG is not yet posted, log Sales Basis Delivery (negative)*/
			if exists (
				select top 1 1
				from
					tblCTContractHeader ch
					left join tblCTWeightGrade w on w.intWeightGradeId = ch.intWeightId
					left join tblCTWeightGrade g on g.intWeightGradeId = ch.intGradeId
					left join tblCTContractType ct on ct.intContractTypeId = ch.intContractTypeId
				where
					ch.intContractHeaderId = @intContractHeaderId
					and (w.strWhereFinalized = 'Destination' or g.strWhereFinalized = 'Destination')
					and ct.strContractType = 'Sale'
			)
			BEGIN

				set @ysnDWGPriceOnly = 1;

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
					, strTransactionType = 'Sales Basis Deliveries'
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
					, dblQty = pfd.dblQuantity * -1
					, intQtyUOMId = ch.intCommodityUOMId
					, intPricingTypeId = 1
					, strPricingType = 'Priced'
					, strTransactionType = 'Price Fixation'
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
					, strNotes = null
					FROM tblCTPriceFixationDetail pfd
					INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
					INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = (case when @ysnMultiPrice = 1 then cd.intContractDetailId else pf.intContractDetailId end)
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = ch.intCommodityId
						AND qu.intUnitMeasureId = cd.intUnitMeasureId
					OUTER APPLY
					(
						SELECT TOP 1 *
						FROM tblCTSequenceHistory
						WHERE intContractHeaderId = pf.intContractHeaderId
						AND intContractDetailId = ISNULL(pf.intContractDetailId,intContractDetailId)
						AND intSequenceUsageHistoryId IS NULL
						ORDER BY dtmHistoryCreated DESC
					) sh
					WHERE pf.intContractHeaderId = @intContractHeaderId
					AND pf.intContractDetailId = ISNULL(@intContractDetailId, pf.intContractDetailId)
					AND pfd.intPriceFixationDetailId NOT IN
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
			/*End of CT-5179*/

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
				, dblQty = CASE WHEN ISNULL(ch.ysnLoad, 0) = 1 THEN (pfd.dblLoadPriced - ISNULL(pfd.dblLoadAppliedAndPriced, 0)) * ch.dblQuantityPerLoad ELSE pfd.dblQuantity - ISNULL(dblQuantityAppliedAndPriced, 0) END
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
				INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = (case when @ysnMultiPrice = 1 then cd.intContractDetailId else pf.intContractDetailId end)
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = ch.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
				OUTER APPLY
				(
					SELECT TOP 1 *
					FROM tblCTSequenceHistory
					WHERE intContractHeaderId = pf.intContractHeaderId
					AND intContractDetailId = ISNULL(pf.intContractDetailId,intContractDetailId)
					AND intSequenceUsageHistoryId IS NULL
					ORDER BY dtmHistoryCreated DESC
				) sh
				WHERE pf.intContractHeaderId = @intContractHeaderId
				AND pf.intContractDetailId = ISNULL(@intContractDetailId, pf.intContractDetailId)
				AND pfd.intPriceFixationDetailId NOT IN
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
			strNotes,							intUserId,									intActionId,							strProcess,
			dblDynamic
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
			strNotes,							intUserId,									intActionId,							strProcess,
			dblDynamic
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
			SELECT @ysnNew = CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 END FROM @cbLogPrev

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
				@dblReturn		NUMERIC(24, 10),
				@dblBasisQty	NUMERIC(24, 10),
				@dblPricedQty	NUMERIC(24, 10),
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

		IF @ysnReturn = 1
		BEGIN			
			SELECT @dblReturn = SUM(dblQty)
			FROM @cbLogPrev
			WHERE strTransactionReference = 'Receipt Return'
			GROUP BY intPricingTypeId
			
			IF @ysnMultiPrice = 1
			BEGIN
				SELECT @dblBasisQty = (MAX(dbTotallQuantity) - SUM(dblQuantity))
				,@dblPricedQty = SUM(dblQuantity)
				FROM
				(
					SELECT pf.intContractHeaderId, dbTotallQuantity = ch.dblQuantity, pfd.dblQuantity
					FROM tblCTPriceFixationDetail pfd
					INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
					INNER JOIN tblCTContractHeader ch ON pf.intContractHeaderId = ch.intContractHeaderId
					WHERE pf.intContractHeaderId = @intContractHeaderId
				) pricing
				WHERE intContractHeaderId = @intContractHeaderId
				GROUP BY intContractHeaderId
			END
			ELSE
			BEGIN
				SELECT @dblBasisQty = (MAX(dbTotallQuantity) - SUM(dblQuantity))
				,@dblPricedQty = SUM(dblQuantity)
				FROM
				(
					SELECT pf.intContractHeaderId, pf.intContractDetailId, dbTotallQuantity = cd.dblQuantity, pfd.dblQuantity
					FROM tblCTPriceFixationDetail pfd
					INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
					INNER JOIN tblCTContractDetail cd ON ISNULL(pf.intContractDetailId,0) = cd.intContractDetailId
					WHERE pf.intContractHeaderId = @intContractHeaderId			
				) pricing
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @intContractDetailId
				GROUP BY intContractHeaderId,intContractDetailId
			END
		END

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
					-- Short Closing sequence should not deduct Basis Delivery
					delete from @cbLogSpecific where intContractStatusId = 6;
					if exists (select top 1 1 from @cbLogSpecific)
					begin
						UPDATE @cbLogSpecific SET dblQty = @dblBasisDel * -1,
									strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
									intPricingTypeId = CASE WHEN ISNULL(@dblBasis,0) = 0 THEN 1 ELSE 2 END, intActionId = @_action
						EXEC uspCTLogContractBalance @cbLogSpecific, 0 
					end
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
					ELSE
					BEGIN
						-- From Unconfirmed to Open (or when the contract status changed from contract screen)
						SELECT @ysnMatched = CASE WHEN COUNT(intContractStatusId) = 1 THEN 1 ELSE 0 END
						FROM
						(
							SELECT intContractStatusId
							FROM @cbLogPrev
							UNION
							SELECT intContractStatusId
							FROM @cbLogSpecific
						) tbl
						IF @ysnMatched <> 1
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = 0
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END
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
				-- 	1.1. Decrease available priced quantities
				-- 	1.2. Increase available basis quantities
				--  1.3. Increase basis deliveries if DWG

				-- Get available priced quantities based on the deleted pricing layer
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

				---- Check if the contract is destination weights and grades
				--IF EXISTS 
				--(
				--	select top 1 1 
				--	from tblCTContractHeader ch
				--	inner join tblCTWeightGrade wg on wg.intWeightGradeId in (ch.intWeightId, ch.intGradeId)
				--		and wg.strWhereFinalized = 'Destination'
				--	where intContractHeaderId = @intContractHeaderId
				--)
				--BEGIN
				--	-- Basis Deliveries  
				--	UPDATE @cbLogSpecific SET dblQty = dblDynamic, strNotes = '',
				--							  strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END--,
				--							  --intPricingTypeId = CASE WHEN ISNULL(@dblBasis,0) = 0 THEN 1 ELSE 2 END
				--	EXEC uspCTLogContractBalance @cbLogSpecific, 0  
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
			ELSE IF @strProcess IN ('Priced DWG','Price Delete DWG', 'Price Update')
			BEGIN
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
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
					UPDATE  @cbLogSpecific SET dblQty = (CASE WHEN @_dblQty >= @dblQty THEN (@_dblQty - (CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad ELSE @dblBasisDel END)) ELSE (CASE WHEN @dblQty > @dblBasis THEN @dblBasis ELSE @dblQty END) END) * -1, 
												intPricingTypeId = 2,
											   dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					-- Negate basis using the current priced quantities
					UPDATE  @cbLogSpecific SET dblQty = (CASE WHEN @_dblQty >= @dblQty THEN (@_dblQty - (CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad ELSE @dblBasisDel END)) ELSE (CASE WHEN @dblQty > @dblBasis THEN @dblBasis ELSE @dblQty END) END), 
												intPricingTypeId = 1,
												dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				ELSE
				BEGIN

					if (@ysnDWGPriceOnly = 1)
					begin
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
					else
					begin
						-- Negate basis using the current priced quantities
						UPDATE  @cbLogSpecific SET dblQty = 0, intPricingTypeId = 2,
													dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
						EXEC uspCTLogContractBalance @cbLogSpecific, 0

						-- Negate basis using the current priced quantities
						UPDATE  @cbLogSpecific SET dblQty = 0, intPricingTypeId = 1,
													dblFutures = ISNULL(@dblAvrgFutures, dblFutures)
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					end
				END

				---- Check if the contract is destination weights and grades
				--IF EXISTS 
				--(
				--	select top 1 1 
				--	from tblCTContractHeader ch
				--	inner join tblCTWeightGrade wg on wg.intWeightGradeId in (ch.intWeightId, ch.intGradeId)
				--		and wg.strWhereFinalized = 'Destination'
				--	where intContractHeaderId = @intContractHeaderId
				--)
				--BEGIN
				--	-- Basis Deliveries  
				--	UPDATE @cbLogSpecific SET dblQty = @dblBasisDel * -1,
				--							  strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END--,
				--							  --intPricingTypeId = CASE WHEN ISNULL(@dblBasis,0) = 0 THEN 1 ELSE 2 END
				--	EXEC uspCTLogContractBalance @cbLogSpecific, 0  
				--END
			END
			ELSE
			BEGIN
				IF @dblQtys > 0 OR @ysnLoadBased = 1
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
			ELSE IF @ysnReturn = 1
			BEGIN				
			
				declare @_dblRemaining numeric(24, 10),
						@_dblBasis numeric(24, 10),
						@_dblPriced numeric(24, 10),
						@_dblActualQty numeric(24, 10),
						@_dblBasisDeliveries numeric(24, 10)

				set @_dblRemaining = ABS(@dblQty)
				set @_dblBasis = ISNULL(@dblBasisQty,0) --- ISNULL(@dblReturn,0)
				set @_dblPriced = ISNULL(@dblPricedQty,0) --- ISNULL(@dblReturn,0)

				select '@_dblPriced',@dblPricedQty,@dblReturn
				
				-- Return 1000 | Basis 500 | Priced 500 | PrevReturn 0				
				-- Log basis
				IF @_dblBasis > 0
				BEGIN
					 select '@_dblActualQty',@ysnUnposted, @_dblBasis, @_dblRemaining
					SET @_dblActualQty = (CASE WHEN @_dblBasis > @_dblRemaining THEN @_dblRemaining ELSE @_dblBasis END)
					UPDATE @cbLogSpecific SET dblQty = (CASE WHEN @ysnUnposted = 1 THEN @_dblActualQty *-1 ELSE @_dblActualQty END), intPricingTypeId = 2, intActionId = 19
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
					SET @_dblRemaining = @_dblRemaining - @_dblActualQty
					SET @_dblBasisDeliveries = @_dblActualQty
				END

				-- Log priced
				IF @_dblPriced > 0					
				BEGIN						
					SET @_dblActualQty = (CASE WHEN @_dblPriced > @_dblRemaining THEN @_dblRemaining ELSE @_dblPriced END)
					UPDATE @cbLogSpecific SET dblQty = (CASE WHEN @ysnUnposted = 1 THEN @_dblActualQty *-1 ELSE @_dblActualQty END), intPricingTypeId = 1, intActionId = 47
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END

				IF @_dblBasisDeliveries > 0
				BEGIN
					-- Basis Deliveries  
					UPDATE @cbLogSpecific SET dblQty = (CASE WHEN @ysnUnposted = 1 THEN @_dblBasisDeliveries ELSE @_dblBasisDeliveries *-1 END),
												strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
												intActionId = 19
					EXEC uspCTLogContractBalance @cbLogSpecific, 0  
				END
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
					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
				END

				IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE strTransactionReference = 'Transfer Storage')
				BEGIN
					UPDATE @cbLogSpecific SET dblQty = dblQty * -1, intActionId = 58
					EXEC uspCTLogContractBalance @cbLogSpecific, 0  

					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
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

					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
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
							
					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
				END

				IF @ysnSplit = 1
				BEGIN
					EXEC uspCTLogContractBalance @cbLogSpecific, 0						
					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE					
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
							SET @_actual = @dblActual
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
					IF (@_basis > 0 OR @_actual > 0) AND @ysnDirect <> 1 AND isnull(@ysnLoadBased,0) = 0
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
