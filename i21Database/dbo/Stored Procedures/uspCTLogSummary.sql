﻿CREATE PROCEDURE [dbo].[uspCTLogSummary]
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
			@ysnMatched				BIT,
			@ysnDirect				BIT = 0,
			@intHeaderId			INT,
			@intDetailId			INT,
			@ysnUnposted			BIT = 0,
			@ysnLoadBased			BIT = 0,
			@dblQuantityPerLoad		NUMERIC(24, 10),
			@dblContractQty			NUMERIC(24, 10),
			@_transactionDate		DATETIME,
			@ysnInvoice				BIT = 0,
			@ysnSplit				BIT = 0,
			@ysnNew					BIT = 0,
			@ysnReturn				BIT = 0,
			@ysnMultiPrice			BIT = 0,
			@ysnDWGPriceOnly		BIT = 0,
			@ysnReassign			BIT = 0,
			@intCurrStatusId		INT = 0,
   			@ysnWithPriceFix BIT;

	-------------------------------------------
	--- Uncomment line below when debugging ---
	-------------------------------------------
	-- SELECT strSource = @strSource, strProcess = @strProcess

	IF @strProcess IN 
	(
		'Update Scheduled Quantity',
		'Update Sequence Status',
		'Missing History',
		'Update Sequence Balance - DWG (Load-based)',
		'Reassign Save'
	)
	BEGIN
		RETURN
	END

	IF (@strSource = 'Pricing' AND @strProcess = 'Save Contract') 
	OR (@strSource = 'Pricing-Old' AND @strProcess = 'Price Delete')
	BEGIN
		RETURN
	END

	IF (@strProcess LIKE  '% - Reassign')
	BEGIN
		RETURN
		--SET @ysnReassign = 1
		--SET @strProcess = REPLACE(@strProcess, '% - Reassign', '')
	END

	DECLARE @strBatchId NVARCHAR(50)
	EXEC uspSMGetStartingNumber 148, @strBatchId OUTPUT

	DECLARE @tmpContractDetail TABLE (
		  intContractHeaderId INT
		, intContractDetailId INT
		, intContractTypeId INT
		, intHeaderPricingTypeId INT
		, intEntityId INT
		, intCommodityId INT
		, intCommodityUOMId INT
		, strContractNumber NVARCHAR(50)
		, ysnLoadBased BIT
		, dblQuantity NUMERIC(18, 6)
		, intNoOfLoad INT
		, dblQuantityPerLoad NUMERIC(18, 6)
		, ysnMultiPrice BIT
		, dtmCreated DATETIME
		, intContractSeq INT
		, intPricingTypeId INT
		, intContractStatusId INT
		, intBasisUOMId INT
		, intBasisCurrencyId INT
		, intItemId INT
		, intItemUOMId INT
		, intUnitMeasureId INT
		, intCompanyLocationId INT
		, intFutureMarketId INT
		, intFutureMonthId INT
		, dtmStartDate DATETIME
		, dtmEndDate DATETIME
		, dblBasis NUMERIC(18, 6)
		, intBookId INT
		, intSubBookId INT
  		, ysnWithPriceFix bit
	)

	-- Get Contract Details
	INSERT INTO @tmpContractDetail
	SELECT ch.intContractHeaderId
		, cd.intContractDetailId
		, ch.intContractTypeId
		, intHeaderPricingTypeId = ch.intPricingTypeId
		, ch.intEntityId
		, ch.intCommodityId
		, ch.intCommodityUOMId
		, ch.strContractNumber
		, ysnLoadBased = ISNULL(ch.ysnLoad, CAST(0 AS BIT))
		, cd.dblQuantity
		, intNoOfLoad = CASE WHEN ISNULL(ch.ysnLoad, CAST(0 AS BIT)) = 0 THEN NULL ELSE cd.intNoOfLoad END
		, dblQuantityPerLoad = CASE WHEN ISNULL(ch.ysnLoad, CAST(0 AS BIT)) = 0 THEN NULL ELSE ch.dblQuantityPerLoad END
		, ysnMultiPrice = ISNULL(ysnMultiplePriceFixation, CAST(0 AS BIT))
		, cd.dtmCreated
		, cd.intContractSeq
		, cd.intPricingTypeId
		, cd.intContractStatusId
		, cd.intBasisUOMId
		, cd.intBasisCurrencyId
		, cd.intItemId
		, cd.intItemUOMId
		, cd.intUnitMeasureId
		, cd.intCompanyLocationId
		, cd.intFutureMarketId
		, cd.intFutureMonthId
		, cd.dtmStartDate
		, cd.dtmEndDate
		, cd.dblBasis
		, cd.intBookId
		, cd.intSubBookId
  		, ysnWithPriceFix = case when priceFix.intPriceFixationId is null then 0 else 1 end
	FROM tblCTContractHeader ch
	JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
	 outer apply (
		select pf.intPriceFixationId from tblCTPriceFixation pf where pf.intContractDetailId = @intContractDetailId
	 ) priceFix
	WHERE cd.intContractHeaderId = @intContractHeaderId
		AND cd.intContractDetailId = @intContractDetailId

	INSERT INTO @cbLogPrev (strBatchId
		, strProcess
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
		, dblOrigQty
		, intContractStatusId
		, intBookId
		, intSubBookId
		, strNotes
		, intUserId
		, intActionId)
	SELECT strBatchId
		, strProcess
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
		, dblOrigQty
		, intContractStatusId
		, intBookId
		, intSubBookId
		, strNotes
		, intUserId
		, intActionId
	FROM tblCTContractBalanceLog
	WHERE intContractHeaderId = @intContractHeaderId

	-- Deleted Contract Sequence
	IF EXISTS (SELECT TOP 1 1 FROM @contractDetail) OR NOT EXISTS (SELECT TOP 1 1 FROM @tmpContractDetail)
	BEGIN
		SELECT TOP 1 @intContractHeaderId = intContractHeaderId
			, @intContractDetailId = intContractDetailId
		FROM @contractDetail

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
			, dblOrigQty
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
			, dblQty = ISNULL(dblQty, 0) * - 1
			, dblOrigQty = ISNULL(dblQty, 0) * - 1
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId
			, strProcess
		FROM (
			SELECT intRowNo = ROW_NUMBER() OVER (PARTITION BY intPricingTypeId ORDER BY dtmTransactionDate DESC)
				, strBatchId = @strBatchId
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
				, intLocationId
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
				, dblQty = SUM(dblQty) OVER (PARTITION BY intPricingTypeId ORDER BY dtmTransactionDate DESC)
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes = ''
				, intUserId
				, intActionId = 44
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog
			WHERE intContractDetailId = @intContractDetailId
				AND intContractHeaderId = @intContractHeaderId
				AND strTransactionType = 'Contract Balance'
		) tbl
		WHERE intRowNo = 1

		EXEC uspCTLogContractBalance @cbLogCurrent, 0

		RETURN
	END

	SELECT @ysnLoadBased = ISNULL(ysnLoadBased, 0), @dblQuantityPerLoad = dblQuantityPerLoad, @ysnMultiPrice = ISNULL(ysnMultiPrice, 0), @dblContractQty = dblQuantity, @ysnWithPriceFix = ysnWithPriceFix, @intCurrStatusId = intContractStatusId FROM @tmpContractDetail

	IF EXISTS(SELECT TOP 1 1
				FROM tblCTContractHeader ch
				LEFT JOIN tblCTWeightGrade w ON w.intWeightGradeId = ch.intWeightId
				LEFT JOIN tblCTWeightGrade g ON g.intWeightGradeId = ch.intGradeId
				LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
				WHERE ch.intContractHeaderId = @intContractHeaderId
					AND (w.strWhereFinalized = 'Destination' OR g.strWhereFinalized = 'Destination')
					AND ct.strContractType = 'Sale')
	BEGIN
		SET @ysnDWGPriceOnly = 1
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
			, dblOrigQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId
			, strProcess
		)
		SELECT strBatchId = @strBatchId
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
			, dblOrigQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes = ''
			, intUserId			
			, intActionId = 43	
			, strProcess  = @strProcess
		FROM
		(
			SELECT ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.intSequenceHistoryId DESC) AS Row_Num
				, sh.intSequenceHistoryId
				, dtmTransactionDate = CASE WHEN cd.intContractStatusId IN (3,6) THEN sh.dtmHistoryCreated ELSE DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), cd.dtmCreated) END
				, sh.intContractHeaderId
				, cd.strContractNumber
				, sh.intContractDetailId
				, cd.intContractSeq
				, cd.intContractTypeId
				, dblQty = sh.dblBalance
				, dblOrigQty = sh.dblBalance
				, intQtyUOMId = cd.intCommodityUOMId
				, sh.intPricingTypeId
				, sh.strPricingType
				, strTransactionType = 'Contract Sequence'
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
			INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
			WHERE intSequenceUsageHistoryId IS NULL
		) tbl
		WHERE Row_Num = 1

		IF (SELECT COUNT(*) FROM @cbLogPrev WHERE intContractDetailId = @intContractDetailId) >= 1
		BEGIN
			IF EXISTS(SELECT intContractDetailId
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
						, dblOrigQty
						, intContractStatusId
						, COUNT (*)
					FROM (
						SELECT TOP 1 intRowId = 1, * FROM @cbLogTemp
						UNION ALL SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY intId DESC) intRowId, * FROM @cbLogPrev WHERE intContractDetailId = @intContractDetailId) tbl WHERE intRowId = 1
					) tbl
					GROUP BY intContractDetailId
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
						, dblOrigQty
						, intContractStatusId
					HAVING COUNT(*) > 1)
			BEGIN
				DELETE FROM @cbLogTemp
			END
		END

		IF EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE intContractStatusId = 4)
		BEGIN
			SELECT @intHeaderId = intTransactionReferenceId, 
				@intDetailId = intTransactionReferenceDetailId, 
				@_transactionDate = dtmTransactionDate, 
				@intUserId = intUserId 
			FROM @cbLogTemp

			DECLARE @prevStatus INT
			SELECT TOP 1 @prevStatus = intContractStatusId
			FROM @cbLogPrev
			WHERE strTransactionType = 'Contract Balance'
				AND intContractDetailId = @intContractDetailId
			ORDER BY intId DESC

			IF (ISNULL(@prevStatus, 0) <> 4)
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
					, dblOrigQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess
				)		
				SELECT strBatchId = @strBatchId
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
					, dblOrigQty
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
				, dblOrigQty
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess)
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
				, dblOrigQty
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
				, dblOrigQty
			 	, intContractStatusId
			 	, intBookId
			 	, intSubBookId
			 	, strNotes
			 	, intUserId
			 	, intActionId
			 	, strProcess
			 )		
			SELECT strBatchId = @strBatchId
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
				, dblOrigQty
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
					, dtmTransactionDate = CASE WHEN strScreenName = 'Inventory Shipment' THEN shipment.dtmShipDate
												WHEN strScreenName = 'Inventory Receipt' THEN receipt.dtmReceiptDate
												ELSE suh.dtmTransactionDate END
					, strTransactionType = strScreenName
					, intTransactionId = suh.intExternalHeaderId -- OR intExternalHeaderId since this was used by basis deliveries ON search screen
					, intTransactionDetailId = suh.intExternalId
					, strTransactionId = suh.strNumber
					, sh.intContractDetailId
					, sh.intContractHeaderId				
					, sh.strContractNumber
					, sh.intContractSeq
					, cd.intContractTypeId
					, sh.intEntityId
					, cd.intCommodityId
					, sh.intItemId
					, sh.intCompanyLocationId
					, sh.intPricingTypeId
					, sh.intFutureMarketId  
					, sh.intFutureMonthId  
					, sh.dblBasis  
					, sh.dblFutures
					, intQtyUOMId = cd.intCommodityUOMId
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
					, sh.dtmStartDate
					, sh.dtmEndDate
					, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN suh.dblTransactionQuantity ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * - 1
					, dblOrigQty = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN suh.dblTransactionQuantity ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * - 1
					, sh.intContractStatusId
					, sh.intBookId
					, sh.intSubBookId		
					, sh.intUserId	
				FROM vyuCTSequenceUsageHistory suh
				INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
				LEFT JOIN tblICInventoryShipment shipment ON suh.intExternalHeaderId = shipment.intInventoryShipmentId
				LEFT JOIN tblICInventoryReceipt receipt ON suh.intExternalHeaderId = receipt.intInventoryReceiptId
				WHERE strFieldName = 'Balance'
				AND suh.intExternalId = @intTransactionId
			) tbl
			WHERE Row_Num = 1
		END
		ELSE IF @strProcess = 'Create Invoice'
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
				, dblOrigQty
				, dblDynamic
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
				, strTransactionReference = 'Invoice'
				, intTransactionReferenceId = id.intInvoiceId
				, intTransactionReferenceDetailId = id.intInvoiceDetailId
				, strTransactionReferenceNo = i.strInvoiceNumber
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
				, dblBasis = pfd.dblBasis
				, dblFutures = pfd.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = @dblTransactionQty
				, dblOrigQty = @dblTransactionQty
				, dblDynamic = @dblTransactionQty
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, strNotes = ''
				, cbl.intUserId
				, intActionId = 16
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess = 'Price Fixation'
			INNER JOIN tblARInvoiceDetail id ON id.intInvoiceDetailId = @intTransactionId
			INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
			LEFT JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationDetailId = id.intPriceFixationDetailId
			WHERE cbl.intPricingTypeId = 1			
				AND cbl.intContractHeaderId = @intContractHeaderId
				AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			ORDER BY cbl.intContractBalanceLogId DESC
		END
		ELSE IF @strProcess = 'Delete Invoice'
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
				, dblOrigQty
				, dblDynamic
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
				, strTransactionReference = 'Invoice'
				, intTransactionReferenceId = pLog.intTransactionReferenceId
				, intTransactionReferenceDetailId = pLog.intTransactionReferenceDetailId
				, strTransactionReferenceNo = pLog.strTransactionReferenceNo
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
				, dblFutures = pLog.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = @dblTransactionQty
				, dblOrigQty = @dblTransactionQty
				, dblDynamic = @dblTransactionQty
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, strNotes = ''
				, cbl.intUserId
				, intActionId = 17
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess = 'Price Fixation'
			INNER JOIN @cbLogPrev pLog ON pLog.strTransactionReference = 'Invoice' AND pLog.strProcess = 'Create Invoice' AND pLog.intTransactionReferenceDetailId = @intTransactionId
			WHERE cbl.intPricingTypeId = 1			
				AND cbl.intContractHeaderId = @intContractHeaderId
				AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			ORDER BY cbl.intContractBalanceLogId DESC
		END
		ELSE IF @strProcess = 'Create Credit Memo'
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess)
			SELECT TOP 1 NULL
				, cbl.dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = 'Credit Memo'
				, intTransactionReferenceId = id.intInvoiceId
				, intTransactionReferenceDetailId = id.intInvoiceDetailId
				, strTransactionReferenceNo = i.strInvoiceNumber
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
				, dblBasis = pfd.dblBasis
				, dblFutures = pfd.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad ELSE @dblTransactionQty END
				, dblOrigQty = CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad ELSE @dblTransactionQty END
				, dblDynamic = CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad ELSE @dblTransactionQty END
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, strNotes = ''
				, cbl.intUserId
				, intActionId = 64
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess = 'Price Fixation'
			INNER JOIN tblARInvoiceDetail id ON id.intInvoiceDetailId = @intTransactionId
			INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
			LEFT JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationDetailId = id.intPriceFixationDetailId
			WHERE cbl.intPricingTypeId = 1			
				AND cbl.intContractHeaderId = @intContractHeaderId
				AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			ORDER BY cbl.intContractBalanceLogId DESC
		END
		ELSE IF @strProcess = 'Delete Credit Memo'
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess)
			SELECT TOP 1 NULL
				, cbl.dtmTransactionDate
				, strTransactionType = 'Contract Balance'
				, strTransactionReference = 'Credit Memo'
				, intTransactionReferenceId = pLog.intTransactionReferenceId
				, intTransactionReferenceDetailId = pLog.intTransactionReferenceDetailId
				, strTransactionReferenceNo = pLog.strTransactionReferenceNo
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
				, dblFutures = pLog.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad * - 1 ELSE @dblTransactionQty END
				, dblOrigQty = CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad * - 1 ELSE @dblTransactionQty END
				, dblDynamic = CASE WHEN @ysnLoadBased = 1 THEN @dblQuantityPerLoad * - 1 ELSE @dblTransactionQty END
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, strNotes = ''
				, cbl.intUserId
				, intActionId = 65
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess = 'Price Fixation'
			INNER JOIN @cbLogPrev pLog ON pLog.strTransactionReference = 'Credit Memo' AND pLog.strProcess = 'Create Credit Memo' AND pLog.intTransactionReferenceDetailId = @intTransactionId
			WHERE cbl.intPricingTypeId = 1			
				AND cbl.intContractHeaderId = @intContractHeaderId
				AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			ORDER BY cbl.intContractBalanceLogId DESC
		END
		ELSE IF @strProcess = 'Create Voucher'
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess)
			SELECT TOP 1 NULL
				, cbl.dtmTransactionDate
				, strTransactionType = 'Purchase Basis Deliveries'
				, strTransactionReference = 'Voucher'
				, intTransactionReferenceId = bd.intBillId
				, intTransactionReferenceDetailId = bd.intBillDetailId
				, strTransactionReferenceNo = b.strBillId
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
				, dblBasis = pfd.dblBasis
				, dblFutures = pfd.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = @dblTransactionQty
				, dblOrigQty = @dblTransactionQty
				, dblDynamic = @dblTransactionQty
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, strNotes = ''
				, cbl.intUserId
				, intActionId = 15
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess = 'Price Fixation'
			INNER JOIN tblAPBillDetail bd ON bd.intBillDetailId = @intTransactionId
			INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
			LEFT JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationDetailId = bd.intPriceFixationDetailId
			WHERE cbl.intPricingTypeId = 1			
				AND cbl.intContractHeaderId = @intContractHeaderId
				AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId) 
				and (select top 1 intHeaderPricingTypeId from @tmpContractDetail) <> 3
			ORDER BY cbl.intContractBalanceLogId DESC
		END
		ELSE IF @strProcess = 'Delete Voucher'
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess)
			SELECT TOP 1 NULL
				, cbl.dtmTransactionDate
				, strTransactionType = 'Purchase Basis Deliveries'
				, strTransactionReference = 'Voucher'
				, intTransactionReferenceId = pLog.intTransactionReferenceId
				, intTransactionReferenceDetailId = pLog.intTransactionReferenceDetailId
				, strTransactionReferenceNo = pLog.strTransactionReferenceNo
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
				, dblFutures = pLog.dblFutures
				, cbl.intQtyUOMId
				, cbl.intQtyCurrencyId
				, cbl.intBasisUOMId
				, cbl.intBasisCurrencyId
				, cbl.intPriceUOMId
				, cbl.dtmStartDate
				, cbl.dtmEndDate
				, dblQty = @dblTransactionQty
				, dblOrigQty = @dblTransactionQty
				, dblDynamic = @dblTransactionQty
				, cbl.intContractStatusId
				, cbl.intBookId
				, cbl.intSubBookId
				, strNotes = ''
				, cbl.intUserId
				, intActionId = 62
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strProcess = 'Price Fixation'
			INNER JOIN @cbLogPrev pLog ON pLog.strTransactionReference = 'Voucher' AND pLog.strProcess = 'Create Voucher' AND pLog.intTransactionReferenceDetailId = @intTransactionId
			WHERE cbl.intPricingTypeId = 1			
				AND cbl.intContractHeaderId = @intContractHeaderId
				AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			ORDER BY cbl.intContractBalanceLogId DESC
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess
			)		
			SELECT strBatchId = @strBatchId
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
				, dblOrigQty
				, dblDynamic
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
					, dtmTransactionDate = CASE WHEN strScreenName = 'Inventory Shipment' THEN shipment.dtmShipDate
												WHEN strScreenName = 'Inventory Receipt' THEN receipt.dtmReceiptDate
												ELSE suh.dtmTransactionDate END
					, strTransactionType = strScreenName
					, intTransactionId = suh.intExternalHeaderId -- OR intExternalHeaderId since this was used by basis deliveries ON search screen
					, intTransactionDetailId = suh.intExternalId
					, strTransactionId = suh.strNumber
					, sh.intContractDetailId
					, sh.intContractHeaderId				
					, sh.strContractNumber
					, sh.intContractSeq
					, cd.intContractTypeId
					, sh.intEntityId
					, cd.intCommodityId
					, sh.intItemId
					, sh.intCompanyLocationId
					, intPricingTypeId = CASE WHEN suh.strScreenName IN ('Voucher', 'Invoice') THEN 1 ELSE sh.intPricingTypeId END
					, sh.intFutureMarketId  
					, sh.intFutureMonthId  
					, sh.dblBasis  
					, dblFutures = CASE WHEN suh.strScreenName IN ('Voucher', 'Invoice') THEN price.dblFutures ELSE sh.dblFutures END
					, intQtyUOMId = cd.intCommodityUOMId
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
					, sh.dtmStartDate
					, sh.dtmEndDate
					, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN suh.dblTransactionQuantity ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * - 1
					, dblOrigQty = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN suh.dblTransactionQuantity ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * - 1
					, dblDynamic = suh.dblTransactionQuantity
					, sh.intContractStatusId
					, sh.intBookId
					, sh.intSubBookId		
					, sh.intUserId	
				FROM vyuCTSequenceUsageHistory suh
				INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = suh.intContractDetailId
				LEFT JOIN tblICInventoryShipment shipment ON suh.intExternalHeaderId = shipment.intInventoryShipmentId
				LEFT JOIN tblICInventoryReceipt receipt ON suh.intExternalHeaderId = receipt.intInventoryReceiptId
				OUTER APPLY 
				(
					SELECT dblFutures = AVG(pfd.dblFutures)
					FROM tblCTPriceFixation pf 
					INNER JOIN tblCTPriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId
					WHERE pf.intContractHeaderId = suh.intContractHeaderId 
					AND suh.intContractDetailId = (CASE WHEN @ysnMultiPrice = 1 THEN suh.intContractDetailId ELSE pf.intContractDetailId END)
				) price
				WHERE strFieldName = 'Balance'
				AND suh.intExternalHeaderId is not null
			) tbl
			WHERE Row_Num = 1

			-- Check if invoice
			IF EXISTS (SELECT TOP 1 1 FROM @cbLogTemp WHERE strTransactionReference = 'Invoice')
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
					, dblOrigQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess)		
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
					, lt.intPricingTypeId
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
					, lt.dblOrigQty
					, lt.intContractStatusId
					, lt.intBookId
					, lt.intSubBookId
					, lt.strNotes
					, lt.intUserId
					, lt.intActionId
					, lt.strProcess
				FROM @cbLogTemp lt
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
					, dblOrigQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess)		
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
					, dblQty * - 1
					, dblOrigQty = dblOrigQty * - 1 
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
					, dblOrigQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess
				)	
				SELECT strBatchId = @strBatchId
					, dtmTransactionDate = @_transactionDate
					, CBL.strTransactionType
					, CBL.strTransactionReference
					, CBL.intTransactionReferenceId
					, CBL.intTransactionReferenceDetailId
					, CBL.strTransactionReferenceNo
					, CBL.intContractDetailId
					, CBL.intContractHeaderId
					, CBL.strContractNumber		
					, CBL.intContractSeq
					, CBL.intContractTypeId
					, CBL.intEntityId
					, CBL.intCommodityId
					, CBL.intItemId
					, CBL.intLocationId
					, intPricingTypeId =
											case
												when
													CBL.strTransactionType = 'Contract Balance'
													and CBL.strTransactionReference = 'Inventory Shipment'
													and isnull(shipmentItem.ysnAllowInvoice,0) = 1
												then 1
												else CBL.intPricingTypeId
											end
					, CBL.intFutureMarketId
					, CBL.intFutureMonthId
					, CBL.dblBasis
					, CBL.dblFutures
					, CBL.intQtyUOMId
					, CBL.intQtyCurrencyId
					, CBL.intBasisUOMId
					, CBL.intBasisCurrencyId
					, CBL.intPriceUOMId
					, CBL.dtmStartDate
					, CBL.dtmEndDate
					, CBL.dblQty
					, CBL.dblOrigQty
					, intContractStatusId = @intCurrStatusId
					, CBL.intBookId
					, CBL.intSubBookId
					, CBL.strNotes-- = 'Unposted'
					, intUserId = @intUserId
					, CBL.intActionId
					, strProcess = @strProcess
				FROM tblCTContractBalanceLog CBL WITH (UPDLOCK)
				left join tblICInventoryShipmentItem shipmentItem on shipmentItem.intInventoryShipmentItemId = CBL.intTransactionReferenceDetailId
				WHERE CBL.intTransactionReferenceId = @intHeaderId
				AND CBL.intTransactionReferenceDetailId = @intDetailId
				AND CBL.intContractHeaderId = @intContractHeaderId
				AND CBL.intContractDetailId = ISNULL(@intContractDetailId, CBL.intContractDetailId)

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
					, dblOrigQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess)		
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
					, dblQty * - 1
					, dblOrigQty * - 1
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
					, dblOrigQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess)		
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
					, dblOrigQty
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
						, dblOrigQty
						, intContractStatusId
						, intBookId
						, intSubBookId
						, strNotes
						, intUserId
						, intActionId
						, strProcess
					)		
					SELECT strBatchId = @strBatchId
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
						, dblOrigQty
						, intContractStatusId
						, intBookId
						, intSubBookId
						, strNotes = ''
						, intUserId = @intUserId
						, intActionId = NULL
						, strProcess = @strProcess
					FROM 
					(
						SELECT ROW_NUMBER() OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated DESC) AS Row_Num
							, dtmTransactionDate = (dtmTransactionDate)
							, strTransactionType = strScreenName
							, intTransactionId = suh.intExternalHeaderId -- OR intExternalHeaderId since this was used by basis deliveries ON search screen
							, intTransactionDetailId = suh.intExternalId
							, strTransactionId = suh.strNumber
							, sh.intContractDetailId
							, sh.intContractHeaderId				
							, sh.strContractNumber
							, sh.intContractSeq
							, cd.intContractTypeId
							, sh.intEntityId
							, cd.intCommodityId
							, sh.intItemId
							, sh.intCompanyLocationId
							, sh.intPricingTypeId
							, sh.intFutureMarketId
							, sh.intFutureMonthId
							, sh.dblBasis
							, sh.dblFutures
							, intQtyUOMId = cd.intCommodityUOMId
							, cd.intBasisUOMId
							, cd.intBasisCurrencyId
							, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
							, sh.dtmStartDate
							, sh.dtmEndDate
							, dblQty = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN suh.dblTransactionQuantity ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * - 1
							, dblOrigQty = (CASE WHEN ISNULL(cd.intNoOfLoad, 0) = 0 THEN suh.dblTransactionQuantity ELSE suh.dblTransactionQuantity * cd.dblQuantityPerLoad END) * - 1
							, sh.intContractStatusId
							, sh.intBookId
							, sh.intSubBookId							
						FROM vyuCTSequenceUsageHistory suh
						INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
						INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
						WHERE strFieldName = 'Balance'
						AND suh.intExternalHeaderId is not null
					) tbl
					WHERE Row_Num = 1
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
		IF @strProcess IN ('Price Delete', 'Fixation Detail Delete')
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess
			)
			SELECT strBatchId = @strBatchId
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId = 55
				, strProcess = @strProcess
			FROM
			(
				SELECT intTransactionReferenceId = pc.intPriceContractId
					, intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
					, strTransactionReferenceNo = pc.strPriceContractNo
					, dtmTransactionDate = CAST((CONVERT(VARCHAR(10), pfd.dtmFixationDate, 111) + ' ' + CONVERT(VARCHAR(20), GETDATE(), 114)) AS DATETIME)
					, cd.intContractHeaderId
					, cd.strContractNumber
					, cd.intContractDetailId
					, cd.intContractSeq
					, cd.intContractTypeId
					, dblQty = CASE WHEN @ysnLoadBased = 1 THEN (ISNULL(pfd.dblLoadPriced, 0) - ISNULL(pfd.dblLoadAppliedAndPriced, 0)) * cd.dblQuantityPerLoad
									ELSE ISNULL(pfd.dblQuantity, 0) - ISNULL(dblQuantityAppliedAndPriced, 0) END
					, dblOrigQty = pfd.dblQuantity
					, dblDynamic =  CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * cd.dblQuantityPerLoad
										ELSE ISNULL(dblQuantityAppliedAndPriced, 0) END
					, intQtyUOMId = cd.intCommodityUOMId
					, intPricingTypeId = 1
					, strPricingType = 'Priced'
					, strTransactionType = 'Price Fixation'
					, intTransactionId = cd.intContractDetailId
					, strTransactionId = cd.strContractNumber + '-' + CAST(cd.intContractSeq AS NVARCHAR(10))
					, dblFutures = pfd.dblFutures
					, dblBasis = pfd.dblBasis
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = qu.intCommodityUnitMeasureId
					, cd.intContractStatusId
					, cd.intEntityId
					, cd.intCommodityId
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
				FROM tblCTPriceFixationDetail pfd
				INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = (CASE WHEN @ysnMultiPrice = 1 THEN cd.intContractDetailId ELSE pf.intContractDetailId END) AND cd.intContractHeaderId = pf.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = cd.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess)
			SELECT @strBatchId
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
				, dblQty = @dblTransactionQty * - 1
				, dblOrigQty = pfd.dblQuantity * - 1
				, dblDynamic = CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * @dblQuantityPerLoad
									ELSE ISNULL(pfd.dblQuantityAppliedAndPriced, 0) END
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
				, dblOrigQty
				, dblDynamic
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
				, dblQty = @dblTransactionQty * - 1
				, dblOrigQty = pfd.dblQuantity * - 1
				, dblDynamic = CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * @dblQuantityPerLoad
									ELSE ISNULL(pfd.dblQuantityAppliedAndPriced, 0) END
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
			ORDER BY cbl.intContractBalanceLogId DESC
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
				, dblOrigQty
				, dblDynamic
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
				, dblOrigQty = pfd.dblQuantity - @dblTransactionQty
				, dblDynamic = CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * @dblQuantityPerLoad
									ELSE ISNULL(pfd.dblQuantityAppliedAndPriced, 0) END
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
				AND cbl.dblQty <> 0
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess
			)
			SELECT strBatchId = @strBatchId
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess = @strProcess
			FROM
			(
				SELECT intTransactionReferenceId = pc.intPriceContractId
					, intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
					, strTransactionReferenceNo = pc.strPriceContractNo
					, dtmTransactionDate = CAST((CONVERT(VARCHAR(10), pfd.dtmFixationDate, 111) + ' ' + CONVERT(VARCHAR(20), GETDATE(), 114)) AS DATETIME2)
					, cd.intContractHeaderId
					, cd.strContractNumber
					, cd.intContractDetailId
					, cd.intContractSeq
					, cd.intContractTypeId
					, dblQty = CASE WHEN @ysnLoadBased = 1 THEN (ISNULL(pfd.dblLoadPriced, 0) - ISNULL(pfd.dblLoadAppliedAndPriced, 0)) * cd.dblQuantityPerLoad
									ELSE ISNULL(pfd.dblQuantity, 0) - ISNULL(dblQuantityAppliedAndPriced, 0) END
					, dblOrigQty = pfd.dblQuantity
					, dblDynamic =  CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * cd.dblQuantityPerLoad
										ELSE ISNULL(dblQuantityAppliedAndPriced, 0) END
					, intQtyUOMId = cd.intCommodityUOMId
					, intPricingTypeId = 1
					, strPricingType = 'Priced'
					, strTransactionType = 'Price Fixation'
					, intTransactionId = cd.intContractDetailId
					, strTransactionId = cd.strContractNumber + '-' + CAST(cd.intContractSeq AS NVARCHAR(10))
					, dblFutures = pfd.dblFutures
					, dblBasis = pfd.dblBasis
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = qu.intCommodityUnitMeasureId
					, cd.intContractStatusId
					, cd.intEntityId
					, cd.intCommodityId
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
					, strNotes = (CASE WHEN ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) <> pfd.dblQuantity
										THEN (CASE WHEN ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures THEN 'Change Quantity. Change Futures Price.' ELSE 'Change Quantity.' END)
										ELSE (CASE WHEN ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures THEN 'Change Quantity' ELSE NULL END) END)
				FROM tblCTPriceFixationDetail pfd
				INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = (CASE WHEN @ysnMultiPrice = 1 THEN cd.intContractDetailId ELSE pf.intContractDetailId END) AND cd.intContractHeaderId = pf.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = cd.intCommodityId AND qu.intUnitMeasureId = cd.intUnitMeasureId
				OUTER APPLY (
					SELECT TOP 1 pl.dblOrigQty, pl.dblFutures
					FROM @cbLogPrev pl
					WHERE strProcess = 'Price Fixation'
						AND intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
						AND intContractDetailId = @intContractDetailId
					ORDER BY dtmTransactionDate DESC
				) prevLog
				WHERE ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) <> pfd.dblQuantity OR ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures
			) tbl
			/*End of CT-4833*/

			/*CT-5179*/
			/*If DWG and Ticket DWG is not yet posted, log Sales Basis Delivery (negative)*/
			IF (@ysnDWGPriceOnly = 1)
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
					, dblOrigQty
					, dblDynamic
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess)
				SELECT strBatchId = @strBatchId
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
					, dblOrigQty
					, dblDynamic
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess = @strProcess
				FROM
				(
					SELECT intTransactionReferenceId = pc.intPriceContractId
						, intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
						, strTransactionReferenceNo = pc.strPriceContractNo
						, dtmTransactionDate = CAST((CONVERT(VARCHAR(10), pfd.dtmFixationDate, 111) + ' ' + CONVERT(VARCHAR(20), GETDATE(), 114)) AS DATETIME2)
						, cd.intContractHeaderId
						, cd.strContractNumber
						, cd.intContractDetailId
						, cd.intContractSeq
						, cd.intContractTypeId
						, dblQty = pfd.dblQuantity * - 1
						, dblOrigQty = pfd.dblQuantity * - 1
						, dblDynamic =  CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * cd.dblQuantityPerLoad
											ELSE ISNULL(dblQuantityAppliedAndPriced, 0) END
						, intQtyUOMId = cd.intCommodityUOMId
						, intPricingTypeId = 1
						, strPricingType = 'Priced'
						, strTransactionType = 'Price Fixation'
						, intTransactionId = cd.intContractDetailId
						, strTransactionId = cd.strContractNumber + '-' + CAST(cd.intContractSeq AS NVARCHAR(10))
						, dblFutures = pfd.dblFutures
						, dblBasis = pfd.dblBasis
						, cd.intBasisUOMId
						, cd.intBasisCurrencyId
						, intPriceUOMId = qu.intCommodityUnitMeasureId
						, cd.intContractStatusId
						, cd.intEntityId
						, cd.intCommodityId
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
					INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = (CASE WHEN @ysnMultiPrice = 1 THEN cd.intContractDetailId ELSE pf.intContractDetailId END) AND cd.intContractHeaderId = pf.intContractHeaderId
					LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = cd.intCommodityId AND qu.intUnitMeasureId = cd.intUnitMeasureId
					WHERE pfd.intPriceFixationDetailId NOT IN
					(
						SELECT DISTINCT intTransactionReferenceDetailId
						FROM @cbLogPrev
						WHERE strProcess = 'Price Fixation'
							AND intContractDetailId = @intContractDetailId
					)
				) tbl
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess)
			SELECT strBatchId = @strBatchId
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
				, dblOrigQty
				, dblDynamic
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess = @strProcess
			FROM
			(
				SELECT intTransactionReferenceId = pc.intPriceContractId
					, intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
					, strTransactionReferenceNo = pc.strPriceContractNo
					, dtmTransactionDate = CAST((CONVERT(VARCHAR(10), pfd.dtmFixationDate, 111) + ' ' + CONVERT(VARCHAR(20), GETDATE(), 114)) AS DATETIME2)
					, cd.intContractHeaderId
					, cd.strContractNumber
					, cd.intContractDetailId
					, cd.intContractSeq
					, cd.intContractTypeId
					, dblQty = CASE WHEN @ysnLoadBased = 1 THEN (ISNULL(pfd.dblLoadPriced, 0) - ISNULL(pfd.dblLoadAppliedAndPriced, 0)) * cd.dblQuantityPerLoad
									ELSE ISNULL(pfd.dblQuantity, 0) - ISNULL(dblQuantityAppliedAndPriced, 0) END
					, dblOrigQty = pfd.dblQuantity
					, dblDynamic =  CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * cd.dblQuantityPerLoad
										ELSE ISNULL(dblQuantityAppliedAndPriced, 0) END
					, intQtyUOMId = cd.intCommodityUOMId
					, intPricingTypeId = 1
					, strPricingType = 'Priced'
					, strTransactionType = 'Price Fixation'
					, intTransactionId = cd.intContractDetailId
					, strTransactionId = cd.strContractNumber + '-' + CAST(cd.intContractSeq AS NVARCHAR(10))
					, dblFutures = pfd.dblFutures
					, dblBasis = pfd.dblBasis
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = qu.intCommodityUnitMeasureId
					, cd.intContractStatusId
					, cd.intEntityId
					, cd.intCommodityId
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
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = (CASE WHEN @ysnMultiPrice = 1 THEN cd.intContractDetailId ELSE pf.intContractDetailId END) AND cd.intContractHeaderId = pf.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = cd.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
				WHERE pfd.intPriceFixationDetailId NOT IN
				(
					SELECT DISTINCT intTransactionReferenceDetailId
					FROM @cbLogPrev
					WHERE strProcess = 'Price Fixation'
						AND intContractDetailId = @intContractDetailId
				)
			) tbl
		END
	END

	DECLARE @currentContractDetalId INT,
			@cbLogSpecific AS CTContractBalanceLog,
			@intId INT,
			@dblRunningQty NUMERIC(24, 10) = 0

	SELECT @intId = MIN(intId) FROM @cbLogCurrent
	WHILE @intId > 0--EXISTS(SELECT TOP 1 1 FROM @cbLogCurrent)
	BEGIN
		DELETE FROM @cbLogPrev

		INSERT INTO @cbLogSpecific (strBatchId
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
			, dblOrigQty
			, dblDynamic
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId
			, strProcess)
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
			, dblOrigQty
			, dblDynamic
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId
			, strProcess
		FROM @cbLogCurrent
		WHERE intId = @intId

		SELECT TOP 1 @currentContractDetalId = intContractDetailId
			, @intContractHeaderId = intContractHeaderId
		FROM @cbLogSpecific
		WHERE intId = @intId

		INSERT INTO @cbLogPrev (strBatchId
			, strProcess
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
			, dblOrigQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId)
		SELECT strBatchId
			, strProcess
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
			, dblOrigQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId
		FROM tblCTContractBalanceLog
		WHERE intContractHeaderId = @intContractHeaderId
		AND intContractDetailId = @currentContractDetalId
		ORDER BY intContractBalanceLogId

		SELECT @ysnNew = CASE WHEN COUNT(1) = 0 THEN 1 ELSE 0 END FROM @cbLogPrev

		IF @ysnNew = 1
		BEGIN
			UPDATE @cbLogSpecific SET intActionId = 42
			EXEC uspCTLogContractBalance @cbLogSpecific, 0
			SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
			CONTINUE
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
				@dblOrigQty		NUMERIC(24, 10),
				@dblAppliedQty	NUMERIC(24, 10),
				@dblAvrgFutures	NUMERIC(24, 10),
				@total 			NUMERIC(24, 10),
				@dblActual		NUMERIC(24, 10),
				@dblReturn		NUMERIC(24, 10),
				@dblBasisQty	NUMERIC(24, 10),
				@dblPricedQty	NUMERIC(24, 10),
				@_dblActual		NUMERIC(24, 10),
				@_action		INT

		DECLARE @TotalBasis NUMERIC(24, 10) = 0
			, @TotalPriced NUMERIC(24, 10) = 0
			, @TotalOrigBasis NUMERIC(24, 10) = 0
			, @TotalOrigPriced NUMERIC(24, 10) = 0
			, @TotalConsumed NUMERIC(18, 6)
			, @FinalQty NUMERIC(24, 10) = 0
			, @intContractTypeId INT
			, @currPricingTypeId INT
			, @prevPricingTypeId INT
			, @strNotes NVARCHAR(MAX)
			, @strTransactionType NVARCHAR(100)
			, @strTransactionReference NVARCHAR(100)
			, @intPriceFixationDetailId INT
			, @intContractStatusId INT
			, @prevContractStatusId INT

		SELECT @TotalBasis = ABS(SUM(dblQty)), @TotalOrigBasis = ABS(SUM(dblOrigQty))
		FROM @cbLogPrev
		WHERE strTransactionType = 'Contract Balance'
			AND intPricingTypeId = 2
		GROUP BY intContractDetailId

		SELECT @TotalPriced = SUM(dblQty), @TotalOrigPriced = SUM(dblOrigQty)
		FROM @cbLogPrev
		WHERE strTransactionType = 'Contract Balance'
			AND intPricingTypeId = 1
		GROUP BY intContractDetailId

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

		SELECT @dblPricedDel = SUM(dblQty) *- 1
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
			, @dblOrigQty = ISNULL(dblOrigQty, 0)
			, @dblAppliedQty = ISNULL(dblDynamic, 0)
			, @currPricingTypeId = intPricingTypeId
			, @intContractTypeId = intContractTypeId
			, @strNotes = strNotes
			, @intPriceFixationDetailId = intTransactionReferenceDetailId
			, @strTransactionType = strTransactionType
			, @strTransactionReference = strTransactionReference
			, @intContractStatusId = intContractStatusId
		FROM @cbLogSpecific	

		SET @TotalConsumed = @dblContractQty - (@TotalPriced + @TotalBasis)

		--Validate HTA Contract
		SELECT TOP 1 @prevPricingTypeId = ISNULL(intPricingTypeId, @currPricingTypeId)
			, @prevContractStatusId = ISNULL(intContractStatusId, @intContractStatusId)
		FROM @cbLogPrev
		WHERE strTransactionType = 'Contract Balance'
			AND intActionId IN (42, 43)
		ORDER BY intId

		IF (@prevPricingTypeId = 3)
		BEGIN
			SET @currPricingTypeId = 3
		END

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
					, @dblPricedQty = SUM(dblQuantity)
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
					, @dblPricedQty = SUM(dblQuantity)
				FROM
				(
					SELECT pf.intContractHeaderId, pf.intContractDetailId, dbTotallQuantity = cd.dblQuantity, pfd.dblQuantity
					FROM tblCTPriceFixationDetail pfd
					INNER JOIN tblCTPriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId
					INNER JOIN tblCTContractDetail cd ON ISNULL(pf.intContractDetailId, 0) = cd.intContractDetailId
					WHERE pf.intContractHeaderId = @intContractHeaderId			
				) pricing
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @intContractDetailId
				GROUP BY intContractHeaderId,intContractDetailId
			END
		END

		IF @strSource = 'Contract'
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intContractStatusId IN (3,6))
			BEGIN
				IF ISNULL(@dblQty, 0) = 0
				BEGIN
					SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
					FROM @cbLogSpecific

					UPDATE @cbLogSpecific SET intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				
				IF ISNULL(@dblBasis, 0) > 0
				BEGIN
					SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
					FROM @cbLogSpecific

					UPDATE @cbLogSpecific SET dblQty = @dblBasis * - 1, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END, intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				IF ISNULL(@dblPriced, 0) > 0
				BEGIN
					SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
					FROM @cbLogSpecific

					UPDATE @cbLogSpecific SET dblQty = @dblPriced * - 1, intPricingTypeId = 1, intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				IF ISNULL(@dblBasis, 0) <= 0 AND ISNULL(@dblPriced, 0) <= 0
				BEGIN
					SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
					FROM @cbLogSpecific

					UPDATE @cbLogSpecific SET dblQty = dblQty * - 1, intActionId = @_action
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				
				-- Reverse Basis Deliveries
				IF @dblBasisDel > 0
				BEGIN
					-- Short Closing sequence should not deduct Basis Delivery
					delete FROM @cbLogSpecific where intContractStatusId = 6;
					if exists (SELECT top 1 1 FROM @cbLogSpecific)
					begin
						UPDATE @cbLogSpecific SET dblQty = @dblBasisDel * - 1,
									strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
									intPricingTypeId = CASE WHEN ISNULL(@dblBasis, 0) = 0 THEN 1 ELSE 2 END, intActionId = @_action
						EXEC uspCTLogContractBalance @cbLogSpecific, 0 
					end
				END
			END			
			ELSE IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intContractStatusId = 4)
			BEGIN
				UPDATE @cbLogSpecific SET dblQty = dblQty * - 1, intActionId = 61
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @total = 0-- No changes with dblQty
			BEGIN
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev WHERE strTransactionType = 'Contract Balance' ORDER BY intId DESC)

				-- Compare previous AND current except the qty				
				SELECT @ysnMatched = CASE WHEN COUNT(intPricingTypeId) = 1 THEN 1 ELSE 0 END
				FROM
				(
					SELECT intPricingTypeId, strNotes FROM @cbLogPrev
					UNION ALL
					SELECT intPricingTypeId, strNotes FROM @cbLogSpecific
				) tbl

				IF @ysnMatched <> 1
				BEGIN		
					-- Negate AND add previous record
					UPDATE a
					SET dblQty = CASE
									WHEN @strProcess = 'Price Fixation' --previous priced
										THEN CASE WHEN ISNULL(@dblPriced, 0) = 0 THEN b.dblQtyPriced *- 1 ELSE @dblPriced - b.dblQtyPriced END							
										ELSE @dblQtys *- 1
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

					IF (@dblQtys != 0 OR @strProcess = 'Price Fixation')
					BEGIN
						-- Negate previous if the value is not 0
						IF NOT EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE dblQty = 0)
						BEGIN		
							DECLARE @_dtmCurrent datetime
							SELECT @_dtmCurrent = dtmTransactionDate FROM @cbLogSpecific			
							UPDATE @cbLogPrev SET strBatchId = @strBatchId, strProcess = @strProcess, dtmTransactionDate = @_dtmCurrent
							EXEC uspCTLogContractBalance @cbLogPrev, 0
						END

						UPDATE a
						SET a.dblQty = CASE WHEN @strProcess = 'Price Fixation' THEN (SELECT dblQty *- 1 FROM @cbLogPrev)
											ELSE @dblQtys END
							, a.intPricingTypeId = CASE WHEN @strProcess = 'Price Fixation' THEN 1
														ELSE a.intPricingTypeId END
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
					-- Check if the changes is with either Basis OR Futures
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
						-- FROM Unconfirmed to Open (or when the contract status changed FROM contract screen)
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
				-- Add current record
				UPDATE  @cbLogSpecific SET dblQty = @total * CASE WHEN @prevContractStatusId <> 3 AND @intContractStatusId = 3 THEN - 1 ELSE 1 END
				EXEC uspCTLogContractBalance @cbLogSpecific, 0		
			END
		END
		ELSE IF @strSource = 'Pricing'
		BEGIN
			IF @strProcess = 'Price Delete' OR @strProcess = 'Fixation Detail Delete'
			BEGIN
				-- 	1.1. Decrease available priced quantities
				-- 	1.2. Increase available basis quantities
				--  1.3. Increase basis deliveries if DWG
				IF (@dblContractQty = @TotalConsumed)
				BEGIN
					SET @FinalQty = 0.00
				END
				ELSE
				BEGIN
					IF (@strProcess = 'Price Delete')
					BEGIN
						SET @FinalQty = @dblQty
					END
					ELSE
					BEGIN
						IF ((@dblContractQty - @TotalConsumed) < @dblOrigQty)
						BEGIN
							SET @FinalQty = @dblContractQty - @TotalConsumed
						END
						ELSE
						BEGIN
							SET @FinalQty = @dblOrigQty
						END
					END
				END
				
				-- Negate all the priced quantities
				UPDATE @cbLogSpecific SET dblQty = @FinalQty * - 1, intPricingTypeId = 1, strTransactionReference = 'Price Fixation'
				EXEC uspCTLogContractBalance @cbLogSpecific, 0

				-- Add all the basis quantities
				UPDATE @cbLogSpecific SET dblQty = @FinalQty, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @strProcess IN ('Priced DWG','Price Delete DWG', 'Price Update')
			BEGIN
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE
			BEGIN
				DECLARE @prevOrigQty NUMERIC(18, 6)
					, @qtyDiff NUMERIC(18, 6)
					, @unloggedBasis NUMERIC(18, 6)
					, @tmpTotal NUMERIC(18, 6)

				SET @dblRunningQty += @dblOrigQty

				SELECT TOP 1 @prevOrigQty = ISNULL(dblOrigQty, 0)
					, @qtyDiff = @dblOrigQty - ISNULL(dblOrigQty, 0)
				FROM @cbLogPrev
				WHERE strProcess = 'Price Fixation'
					AND strTransactionType = 'Contract Balance'
					AND intTransactionReferenceDetailId = @intPriceFixationDetailId
				ORDER BY intId DESC

				IF (@intContractTypeId = 1)
				BEGIN
					IF (@qtyDiff > 0)
					BEGIN
						-- Qty increased
						SET @FinalQty = CASE WHEN @TotalBasis - @qtyDiff > 0 THEN @qtyDiff ELSE @TotalBasis END
					END
					ELSE IF (@qtyDiff < 0)
					BEGIN
						-- Qty decreased
						SET @FinalQty = CASE WHEN @TotalPriced + @dblQty > @TotalConsumed THEN @qtyDiff ELSE 0 END
					END
					ELSE
					BEGIN
						-- New Price or No change
						SET @FinalQty = @dblQty
					END
				END
				ELSE
				BEGIN
					IF (@qtyDiff > 0)
					BEGIN
						-- Qty increased
						SET @FinalQty = CASE WHEN @TotalBasis - @qtyDiff > 0 THEN @qtyDiff ELSE @TotalBasis END
					END
					ELSE IF (@qtyDiff < 0)
					BEGIN
						-- Qty decreased
						IF @dblAppliedQty = 0 BEGIN
							SET @FinalQty = @qtyDiff
						END
						ELSE
						BEGIN
							SET @FinalQty = CASE WHEN @TotalPriced + @qtyDiff > 0 THEN @TotalPriced + @qtyDiff ELSE @TotalPriced * - 1 END
						END
					END
					ELSE
					BEGIN
						-- New Price or No change
						SET @FinalQty = @dblQty
					END
				END

				IF (@strTransactionType LIKE '%Basis Deliveries%' AND @FinalQty < 0)
				BEGIN
					-- Decrease Priced
					UPDATE  @cbLogSpecific SET dblQty = @FinalQty, intPricingTypeId = 1
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				ELSE
				BEGIN
					-- If Reassign prices, do not bring back Basis qty
					IF (@ysnReassign = 0)
					BEGIN
						-- Increase basis, qtyDiff is negative so multiply to -1
						UPDATE  @cbLogSpecific SET dblQty = @FinalQty * - 1, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END

					-- Decrease Priced
					UPDATE  @cbLogSpecific SET dblQty = @FinalQty, intPricingTypeId = 1
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
			END
		END
		ELSE IF @strSource = 'Inventory'
		BEGIN
			IF @strProcess IN ('Create Invoice', 'Delete Invoice', 'Create Credit Memo', 'Delete Credit Memo', 'Create Voucher', 'Delete Voucher')
			BEGIN
				EXEC uspCTLogContractBalance @cbLogSpecific, 0  

				SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
				CONTINUE
			END

			IF @ysnInvoice = 1
			BEGIN
				UPDATE @cbLogSpecific SET dblQty = dblQty * - 1, intActionId = 16
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @ysnReturn = 1
			BEGIN				
			
				DECLARE @_dblRemaining NUMERIC(24, 10),
						@_dblBasis NUMERIC(24, 10),
						@_dblPriced NUMERIC(24, 10),
						@_dblActualQty NUMERIC(24, 10),
						@_dblBasisDeliveries NUMERIC(24, 10)

				SET @_dblRemaining = ABS(@dblQty)
				SET @_dblBasis = ISNULL(@dblBasisQty, 0)
				SET @_dblPriced = ISNULL(@dblPricedQty, 0)

				-- Return 1000 | Basis 500 | Priced 500 | PrevReturn 0				
				-- Log basis
				IF @_dblBasis > 0
				BEGIN
					SET @_dblActualQty = (CASE WHEN @_dblBasis > @_dblRemaining THEN @_dblRemaining ELSE @_dblBasis END)
					UPDATE @cbLogSpecific SET dblQty = (CASE WHEN @ysnUnposted = 1 THEN @_dblActualQty *- 1 ELSE @_dblActualQty END), intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END, intActionId = 19
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
					SET @_dblRemaining = @_dblRemaining - @_dblActualQty
					SET @_dblBasisDeliveries = @_dblActualQty
				END

				-- Log priced
				IF @_dblPriced > 0					
				BEGIN						
					SET @_dblActualQty = (CASE WHEN @_dblPriced > @_dblRemaining THEN @_dblRemaining ELSE @_dblPriced END)
					UPDATE @cbLogSpecific SET dblQty = (CASE WHEN @ysnUnposted = 1 THEN @_dblActualQty *- 1 ELSE @_dblActualQty END), intPricingTypeId = 1, intActionId = 47
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END

				IF @_dblBasisDeliveries > 0
				BEGIN
					-- Basis Deliveries  
					UPDATE @cbLogSpecific SET dblQty = (CASE WHEN @ysnUnposted = 1 THEN @_dblBasisDeliveries ELSE @_dblBasisDeliveries *- 1 END),
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
				SELECT @_action = CASE WHEN @strTransactionReference = 'Settle Storage' THEN 53 ELSE (CASE WHEN @intContractTypeId = 1 THEN 19 ELSE 18 END) END

				-- If DP/Transfer Storage disregard Update Sequence Balance and consider Update Sequence Quantity "or the other way around"
				IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intPricingTypeId = 5 AND @strProcess = 'Update Sequence Balance')
				BEGIN
					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
				END

				IF (@strTransactionReference = 'Transfer Storage')
				BEGIN
					UPDATE @cbLogSpecific SET dblQty = dblQty * - 1, intActionId = 58
					EXEC uspCTLogContractBalance @cbLogSpecific, 0  

					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
				END

				IF @strProcess = 'Update Sequence Balance - DWG'
				BEGIN
					IF @dblQty * - 1 > 0
					BEGIN				
						DECLARE @_prevQty NUMERIC(24,10)

						SELECT TOP 1 @_prevQty = prev.dblQty
						FROM @cbLogPrev prev
						INNER JOIN @cbLogSpecific spfc ON prev.intTransactionReferenceId = spfc.intTransactionReferenceId
							AND prev.intTransactionReferenceDetailId = spfc.intTransactionReferenceDetailId
						WHERE prev.strTransactionType = 'Contract Balance'
							AND prev.intContractDetailId = @currentContractDetalId
						ORDER BY prev.intId DESC
								
						UPDATE @cbLogSpecific SET dblQty = dblQty *- 1, intPricingTypeId = @currPricingTypeId, intActionId = CASE WHEN @currPricingTypeId = 1 THEN 46 ELSE 18 END
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
					ELSE
					BEGIN
						IF ISNULL(@dblPriced, 0) > 0
						BEGIN
							IF @dblPriced >= @dblQty
							BEGIN
								UPDATE @cbLogSpecific SET dblQty = dblQty *- 1, intPricingTypeId = 1, intActionId = 46
								EXEC uspCTLogContractBalance @cbLogSpecific, 0
							END
						END
						IF ISNULL(@dblBasis, 0) > 0
						BEGIN				
							IF @dblBasis >= @dblQty
							BEGIN									
								UPDATE @cbLogSpecific SET dblQty = dblQty *- 1, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END, intActionId = 18
								EXEC uspCTLogContractBalance @cbLogSpecific, 0
							END
						END
					END
									
					IF (@currPricingTypeId = 2)
					BEGIN						
						IF  @dblQty <> 0
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = @dblQty, strTransactionType = 'Sales Basis Deliveries', intPricingTypeId = 2, intActionId = 18
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END
					END
					ELSE IF (@currPricingTypeId = 1)
					BEGIN						
						IF  @dblQty <> 0
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = @dblQty, strTransactionType = 'Sales Basis Deliveries', intPricingTypeId = 1, intActionId = 46
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END
					END

					SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
					CONTINUE
				END			
				
				IF @strProcess = 'Post Load-based DWG' OR @strProcess = 'Unpost Load-based DWG'
				BEGIN
					DECLARE @_origQty NUMERIC(20,12),
							@_pricingType int
					SELECT @dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(a.intItemId, a.intItemUOMId, 
												CASE WHEN @strProcess = 'Unpost Load-based DWG'
														THEN ISNULL(a.dblDestinationNet, 0) - ISNULL(a.dblQuantity, 0)
														ELSE ISNULL(a.dblQuantity, 0) - ISNULL(a.dblDestinationNet, 0) 
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
					DECLARE @_d NUMERIC(20,12)
					IF @strProcess = 'Post Load-based DWG'
					BEGIN
						IF @dblQty > 0
						BEGIN
							SET @dblQty = CASE WHEN ABS(@dblQty) < @dblBasisDel THEN ABS(@dblQty) ELSE 0 END
						END
						ELSE
						BEGIN
							SET @_d = (ABS(@dblQty) - ISNULL(@dblPriced, 0))
							SET @dblQty = (CASE WHEN @_d < 0 THEN 0 ELSE @_d END) * - 1
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
							SET @dblQty = (CASE WHEN ABS(@dblQty) < @dblBasisDel THEN ABS(@dblQty) ELSE 0 END) *- 1
						END						
					END

					IF (@currPricingTypeId IN (1, 2))
					BEGIN
						IF  @dblQty <> 0
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = @dblQty * - 1, strTransactionType = 'Sales Basis Deliveries', intPricingTypeId = 2, intActionId = 18
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END
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
					IF (@strTransactionReference = 'Inventory Shipment')
					BEGIN
						SELECT @dblActual = SUM(ISNULL(ABS(dbo.fnCTConvertQtyToTargetCommodityUOM(b.intCommodityId, siuom.intUnitMeasureId, cd.intUnitMeasureId, ISNULL(a.dblDestinationQuantity, ISNULL(a.dblQuantity, 0)))), 0))
						FROM tblICInventoryShipmentItem a
						INNER JOIN @cbLogSpecific b ON a.intInventoryShipmentId = b.intTransactionReferenceId
						LEFT JOIN tblICItemUOM siuom ON siuom.intItemUOMId = a.intItemUOMId
						LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = a.intLineNo AND cd.intContractHeaderId = a.intOrderId
						WHERE b.intContractHeaderId = a.intOrderId
						AND a.intLineNo = ISNULL(b.intContractDetailId, a.intLineNo)
					END
					-- Inventory Receipt
					ELSE IF (@strTransactionReference = 'Inventory Receipt')
					BEGIN
						SELECT @dblActual = SUM(dblOpenReceive)
						FROM tblICInventoryReceiptItem a
						INNER JOIN @cbLogSpecific b ON a.intInventoryReceiptId = b.intTransactionReferenceId
					END
					-- Settle Storage
					ELSE IF (@strTransactionReference = 'Settle Storage')
					BEGIN
						SELECT @dblActual = SUM(dblUnits)
						FROM tblGRSettleContract a
						INNER JOIN @cbLogSpecific b ON a.intSettleStorageId = b.intTransactionReferenceId
					END
					-- Reduce contract balance
					-- Scenario 1
					--  Transaction	  |    Pricing				|  Contract Balance
					-- IS/IR/SS: 1000 | Priced 1000 Basis - 1000 | CB: P - 1000 B 0 /
					-- IS/IR/SS: 1000 | Priced 500 Basis -500	| CB: P -500 B -500 /
					-- IS/IR/SS: 1000 | Priced 0 Basis 1000		| CB: P 0 B - 1000 /
					-- Scenario 2
					-- IS/IR/SS 500 | Priced 1000 Basis 0 | CB: P -500 B 0 /
					-- IS/IR/SS 500 | Priced 500 Basis 500 | CB: P -500 B 0 /
					-- IS/IR/SS 500 | Priced 400 Basis 600 | CB: P -400 B - 100 /
					IF ISNULL(@TotalPriced, 0) > 0
					BEGIN	
						-- Balance
						SET @_priced = (CASE WHEN @dblQty > ISNULL(@TotalPriced, 0) THEN ISNULL(@TotalPriced, 0) ELSE @dblQty END)
						UPDATE @cbLogSpecific SET dblQty = @_priced * - 1, intPricingTypeId = 1, intActionId = CASE WHEN intContractTypeId = 1 THEN 47 ELSE 46 END
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
						
						SET @_dblActual = @dblActual;

						SET @dblQty = @dblQty - @_priced

						IF @ysnLoadBased = 1
						BEGIN
							-- Basis Deliveries
							SET @_priced = (CASE WHEN @dblActual > ISNULL(@TotalPriced, 0) THEN ISNULL(@TotalPriced, 0) ELSE @dblActual END)
							SET @dblActual = @dblActual - @_priced
						END

						-- Increase SBD upon creation of IS
						IF (@strTransactionReference = 'Inventory Shipment')
						BEGIN
							if (@currPricingTypeId = 1)
							begin
								if (isnull(@ysnWithPriceFix,0) = 1 )
								begin
									UPDATE @cbLogSpecific SET dblQty = @_dblActual, intPricingTypeId = 1, strTransactionType = 'Sales Basis Deliveries'  
									EXEC uspCTLogContractBalance @cbLogSpecific, 0 
								end
							end
							else
							begin
								UPDATE @cbLogSpecific SET dblQty = @_dblActual, intPricingTypeId = 1, strTransactionType = 'Sales Basis Deliveries'  
								EXEC uspCTLogContractBalance @cbLogSpecific, 0 
							end
						END

					END				
					ELSE IF ISNULL(@dblBasis, 0) > 0
					BEGIN
						IF (@dblQty > 0)
						BEGIN
							-- Balance
							SET @_basis = (CASE WHEN @dblQty > ISNULL(@dblBasis, 0) THEN ISNULL(@dblBasis, 0) ELSE @dblQty END)
							UPDATE @cbLogSpecific SET dblQty = @_basis * - 1, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END, intActionId = @_action
							EXEC uspCTLogContractBalance @cbLogSpecific, 0  
							SET @dblQty = @dblQty - @_basis
						END
						IF @ysnLoadBased = 1 AND @dblActual > 0
						BEGIN
							-- Basis Deliveries
							SET @_actual = @dblActual
						END
					END
					IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intPricingTypeId = 5)
					BEGIN
						-- Balance
						SET @_dp = (CASE WHEN @dblQty > ISNULL(@dblDP, 0) THEN ISNULL(@dblDP, 0) ELSE @dblQty END)
						UPDATE a SET dblQty = @_dp * - 1, intActionId = CASE WHEN a.intContractTypeId = 1 THEN 49 ELSE 50 END
						FROM @cbLogSpecific a
						EXEC uspCTLogContractBalance @cbLogSpecific, 0  
					END
					IF ISNULL(@dblCash, 0) > 0
					BEGIN
						SET @_cash = (CASE WHEN @dblQty > ISNULL(@dblCash, 0) THEN ISNULL(@dblCash, 0) ELSE @dblQty END)
						UPDATE a SET dblQty = @_cash * - 1, intActionId = CASE WHEN a.intContractTypeId = 1 THEN 52 ELSE 51 END
						FROM @cbLogSpecific a
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
					
					-- Increase basis deliveries based ON the basis quantities
					-- Scenario 1
					-- Priced 1000 | BD 0 /
					-- Priced 500 Basis 500 | BD 500 /
					-- Priced 0 Basis 1000 | BD 1000 /
					-- Scenario 2
					-- Priced 1000 | BD 0 /
					-- Priced 500 | BD 0 /
					-- Priced 400 | BD 100 /
					IF ISNULL(@TotalPriced, 0) <= 0
					BEGIN
						IF (@_basis > 0 OR @_actual > 0) AND @ysnDirect <> 1
						BEGIN				
							-- Basis Deliveries  
							UPDATE @cbLogSpecific SET dblQty = CASE WHEN @ysnLoadBased = 1 THEN @_actual ELSE @_basis END,
													  strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
													  intPricingTypeId = CASE WHEN ISNULL(@dblBasis, 0) = 0 THEN 1 ELSE 2 END, intActionId = @_action
							EXEC uspCTLogContractBalance @cbLogSpecific, 0  
						END
					END
				END
				ELSE
				BEGIN
					-- Scenario 1
					-- IS/IR/SS: - 1000 | Priced 0 Basis 0 | CB: P 0 B 0
					-- IS/IR/SS: - 1000 | Priced 0 Basis 0 | CB: P 0 B 0
					-- IS/IR/SS: - 1000 | Priced 0 Basis 0 | CB: P 0 B 0
					-- Negate previous record
					IF @dblQty < 0
					BEGIN
						IF (@TotalBasis < @dblOrigQty)
						BEGIN
							if exists (select top 1 1 from @cbLogSpecific where strTransactionType = 'Contract Balance' and strTransactionReference Like 'Inventory%') and @TotalPriced = 0
							begin
								UPDATE @cbLogSpecific SET dblQty = dblQty * - 1
							end
							else
							begin
								UPDATE @cbLogSpecific SET dblQty = dblQty * - 1, intPricingTypeId = 1
							end
						END
						ELSE
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = dblQty * - 1
						END
					END
					ELSE
					BEGIN
						UPDATE @cbLogSpecific SET dblQty = dblQty * - 1
					END
					
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
