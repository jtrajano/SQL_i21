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
   			@ysnWithPriceFix 		BIT,
   			@intPricingTypeId       int,
   			@dblSeqHistoryPreviousQty		NUMERIC(24, 10),
			@intSeqHistoryPreviousFutMkt	INT,
			@intSeqHistoryPreviousFutMonth	INT,
			@dblCurrentBasis				NUMERIC(24, 10),
			@intHeaderPricingTypeId		INT,
			@ysnInvoicePosted			BIT = 0;

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
		, dblBalance NUMERIC(18, 6)
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
		, ysnWithPriceFix = case when priceFix.intPriceFixationId is null then (case when ch.intPricingTypeId = 2 and cd.intPricingTypeId = 1 then 1 else 0 end) else 1 end
		, dblBalance = CASE WHEN ISNULL(ch.ysnLoad, 0) = 0 THEN cd.dblBalance ELSE ch.dblQuantityPerLoad * cd.dblBalanceLoad END
	FROM tblCTContractHeader ch
	JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
	 outer apply (
		select pf.intPriceFixationId from vyuCTCombinePriceFixation pf where pf.intContractDetailId = @intContractDetailId
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
		FROM @contractDetail;

		WITH CTE AS (
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
				, dblQty
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
		)

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
			SELECT intRowNo
				, strBatchId
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
				, dblQty = (SELECT SUM(dblQty) FROM CTE Sub WHERE Main.intPricingTypeId = Sub.intPricingTypeId AND Main.intRowNo <= Sub.intRowNo)
				, intContractStatusId
				, intBookId
				, intSubBookId
				, strNotes
				, intUserId
				, intActionId
				, strProcess
			FROM CTE Main
		) tbl
		WHERE intRowNo = 1

		EXEC uspCTLogContractBalance @cbLogCurrent, 0

		RETURN
	END

	SELECT @ysnLoadBased = ISNULL(ysnLoadBased, 0)
		, @dblQuantityPerLoad = dblQuantityPerLoad
		, @ysnMultiPrice = ISNULL(ysnMultiPrice, 0)
		, @dblContractQty = dblQuantity
		, @ysnWithPriceFix = ysnWithPriceFix
		, @intCurrStatusId = intContractStatusId
		, @dblCurrentBasis = dblBasis
		, @intHeaderPricingTypeId = intHeaderPricingTypeId
	FROM @tmpContractDetail

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
		DECLARE @sequenceHistory TABLE (Row_Num INT
			, intSequenceHistoryId INT
			, dtmTransactionDate DATETIME
			, intContractHeaderId INT
			, strContractNumber NVARCHAR(50)
			, intContractDetailId INT
			, intContractSeq INT
			, intContractTypeId INT
			, dblQty NUMERIC(18, 6)
			, dblOrigQty NUMERIC(18, 6)
			, dblDynamicQty NUMERIC(18, 6)
			, intQtyUOMId INT
			, intPricingTypeId INT
			, strPricingType NVARCHAR(50)
			, strTransactionType NVARCHAR(50)
			, intTransactionId INT
			, strTransactionId NVARCHAR(50)
			, dblFutures NUMERIC(18, 6)
			, dblBasis NUMERIC(18, 6)
			, intBasisUOMId INT
			, intBasisCurrencyId INT
			, intPriceUOMId INT
			, intContractStatusId INT
			, intEntityId INT
			, intCommodityId INT
			, intItemId INT
			, intCompanyLocationId INT
			, intFutureMarketId INT
			, intFutureMonthId INT
			, dtmStartDate DATETIME
			, dtmEndDate DATETIME
			, intBookId INT
			, intSubBookId INT
			, intOrderBy INT
			, intUserId INT
			, dblQuantity NUMERIC(18, 6));

		INSERT INTO @sequenceHistory (Row_Num
			, intSequenceHistoryId
			, dtmTransactionDate
			, intContractHeaderId
			, strContractNumber
			, intContractDetailId
			, intContractSeq
			, intContractTypeId
			, dblQty
			, dblOrigQty
			, dblDynamicQty
			, intQtyUOMId
			, intPricingTypeId
			, strPricingType
			, strTransactionType
			, intTransactionId
			, strTransactionId
			, dblFutures
			, dblBasis
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, intContractStatusId
			, intEntityId
			, intCommodityId
			, intItemId
			, intCompanyLocationId
			, intFutureMarketId
			, intFutureMonthId
			, dtmStartDate
			, dtmEndDate
			, intBookId
			, intSubBookId
			, intOrderBy
			, intUserId
			, dblQuantity)
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
			, dblDynamicQty = sh.dblBalance - ISNULL(sh.dblOldBalance, 0)
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
			, sh.dblQuantity
		FROM tblCTSequenceHistory sh
		INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		WHERE intSequenceUsageHistoryId IS NULL

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
		FROM @sequenceHistory
		WHERE Row_Num = 1

		SELECT TOP 1 @intPricingTypeId = intPricingTypeId
			, @dblSeqHistoryPreviousQty = dblQuantity
			, @intSeqHistoryPreviousFutMkt = intFutureMarketId
			, @intSeqHistoryPreviousFutMonth = intFutureMonthId
		FROM @sequenceHistory
		WHERE Row_Num = 2

		IF (ISNULL(@intPricingTypeId, 0) NOT IN (0, 3))
		BEGIN
			UPDATE @cbLogTemp SET intPricingTypeId = @intPricingTypeId WHERE dblQty < @dblSeqHistoryPreviousQty;
		END

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
						, strTransactionReference
						, strTransactionReferenceNo
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
						, strTransactionReference
						, strTransactionReferenceNo
					HAVING COUNT(*) > 1)
			BEGIN
				DELETE FROM @cbLogTemp
			END
			ELSE IF NOT EXISTS(
						SELECT TOP 1 intRowId = 1, * FROM @cbLogTemp WHERE intContractStatusId <> 5
						UNION ALL SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY intId DESC) intRowId, * FROM @cbLogPrev WHERE intContractDetailId = @intContractDetailId) tbl WHERE intRowId = 1 AND intContractStatusId <> 5)
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
				, @dblBalanceChange NUMERIC(18, 6) = 0

			SELECT TOP 1 @prevStatus = intContractStatusId
			FROM @cbLogPrev
			WHERE strTransactionType = 'Contract Balance'
				AND intContractDetailId = @intContractDetailId
			ORDER BY intId DESC

			SELECT TOP 1 @dblBalanceChange = dblDynamicQty FROM @sequenceHistory WHERE Row_Num = 1
			
			IF (ISNULL(@prevStatus, 0) NOT IN (0, 4))
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
					, o.strTransactionType
					, o.strTransactionReference
					, o.intTransactionReferenceId
					, o.intTransactionReferenceDetailId
					, o.strTransactionReferenceNo
					, o.intContractDetailId
					, o.intContractHeaderId
					, o.strContractNumber		
					, o.intContractSeq
					, o.intContractTypeId
					, o.intEntityId
					, o.intCommodityId
					, o.intItemId
					, o.intLocationId
					, price.intPricingTypeId
					, o.intFutureMarketId
					, o.intFutureMonthId
					, o.dblBasis
					, o.dblFutures
					, o.intQtyUOMId
					, o.intQtyCurrencyId
					, o.intBasisUOMId
					, o.intBasisCurrencyId
					, o.intPriceUOMId
					, o.dtmStartDate
					, o.dtmEndDate
					, o.dblQty
					, o.dblOrigQty
					, intContractStatusId = 4
					, o.intBookId
					, o.intSubBookId
					, o.strNotes
					, intUserId = @intUserId
					, intActionId = 61
					, strProcess = @strProcess
				FROM tblCTContractBalanceLog  o WITH (UPDLOCK)
				cross apply (select top 1 p.intPricingTypeId from tblCTContractBalanceLog p where p.intContractHeaderId = o.intContractHeaderId and p.intContractDetailId = ISNULL(@intContractDetailId, o.intContractDetailId) order by p.intContractBalanceLogId desc) price
				WHERE o.intTransactionReferenceId = @intHeaderId
				AND o.intTransactionReferenceDetailId = @intDetailId
				AND o.intContractHeaderId = @intContractHeaderId
				AND o.intContractDetailId = ISNULL(@intContractDetailId, o.intContractDetailId)
				AND o.intContractStatusId IN (3,6)
				ORDER BY o.dtmCreatedDate DESC

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
					, CASE WHEN ISNULL(@prevStatus, 0) = 0 THEN dblQty ELSE @dblBalanceChange * -1 END
					, dblOrigQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId = CASE WHEN ISNULL(@prevStatus, 0) = 0 THEN 42 ELSE 43 END
					, strProcess
				FROM @cbLogTemp
			END
		END
		ELSE
		BEGIN
			-- Insert negating entry due to other changes besides Qty
			IF EXISTS(SELECT TOP 1 1 FROM @cbLogTemp WHERE (intFutureMarketId <> @intSeqHistoryPreviousFutMkt OR intFutureMonthId <> @intSeqHistoryPreviousFutMonth) AND dblQty <> @dblSeqHistoryPreviousQty) AND @strProcess <> 'Do Roll'
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
					, @dblSeqHistoryPreviousQty
					, @dblSeqHistoryPreviousQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes
					, intUserId
					, intActionId
					, strProcess
				FROM @cbLogTemp
			END

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
				, strProcess
				, ysnInvoicePosted)
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
				, ysnInvoicePosted = i.ysnPosted
			FROM tblCTContractBalanceLog cbl
			INNER JOIN tblARInvoiceDetail id ON id.intInvoiceDetailId = @intTransactionId
			INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
			LEFT JOIN vyuCTCombinePriceFixationDetail pfd ON pfd.intPriceFixationDetailId = id.intPriceFixationDetailId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
				, intActionId = 63
				, strProcess = @strProcess
			FROM tblCTContractBalanceLog cbl
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
			INNER JOIN tblARInvoiceDetail id ON id.intInvoiceDetailId = @intTransactionId
			INNER JOIN tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
			LEFT JOIN vyuCTCombinePriceFixationDetail pfd ON pfd.intPriceFixationDetailId = id.intPriceFixationDetailId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
			INNER JOIN @cbLogPrev pLog ON pLog.strTransactionReference = 'Credit Memo' AND pLog.strProcess = 'Create Credit Memo' AND pLog.intTransactionReferenceDetailId = @intTransactionId
			WHERE cbl.intPricingTypeId = 1			
				AND cbl.intContractHeaderId = @intContractHeaderId
				AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId)
			ORDER BY cbl.intContractBalanceLogId DESC
		END
		ELSE IF @strProcess = 'Create Voucher'
		BEGIN
			DECLARE @intSettleStorageId INT
			SELECT @intSettleStorageId = BD.intSettleStorageId FROM tblAPBillDetail BD
			JOIN tblGRSettleStorage SS ON SS. intSettleStorageId = BD.intSettleStorageId
			WHERE BD.intBillDetailId = @intTransactionId

			-- Check if settle storage transaction
			IF (ISNULL(@intSettleStorageId, 0) = 0)
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
				INNER JOIN tblAPBillDetail bd ON bd.intBillDetailId = @intTransactionId
				INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
				LEFT JOIN vyuCTCombinePriceFixationDetail pfd ON pfd.intPriceFixationDetailId = bd.intPriceFixationDetailId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
				WHERE cbl.intPricingTypeId = 1			
					AND cbl.intContractHeaderId = @intContractHeaderId
					AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId) 
					and (select top 1 intHeaderPricingTypeId from @tmpContractDetail) <> 3
				ORDER BY cbl.intContractBalanceLogId DESC
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE strTransactionReference = 'Settle Storage' AND intTransactionReferenceId = @intSettleStorageId AND strTransactionType = 'Purchase Basis Deliveries')
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
					INNER JOIN tblAPBillDetail bd ON bd.intBillDetailId = @intTransactionId
					INNER JOIN tblAPBill b ON b.intBillId = bd.intBillId
					LEFT JOIN vyuCTCombinePriceFixationDetail pfd ON pfd.intPriceFixationDetailId = bd.intPriceFixationDetailId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
					WHERE cbl.intPricingTypeId = 1			
						AND cbl.intContractHeaderId = @intContractHeaderId
						AND cbl.intContractDetailId = ISNULL(@intContractDetailId, cbl.intContractDetailId) 
						and (select top 1 intHeaderPricingTypeId from @tmpContractDetail) <> 3
					ORDER BY cbl.intContractBalanceLogId DESC
				END
			END
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
			INNER JOIN @cbLogPrev pLog ON pLog.strTransactionReference = 'Voucher' AND pLog.strProcess = 'Create Voucher' AND pLog.intTransactionReferenceDetailId = @intTransactionId AND pLog.strTransactionType = 'Purchase Basis Deliveries'
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
				, strInvoiceType
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
				, strInvoiceType
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
					, strInvoiceType = invoice.strTransactionType
				FROM vyuCTSequenceUsageHistory suh
				INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = suh.intContractDetailId
				LEFT JOIN tblICInventoryShipment shipment ON suh.intExternalHeaderId = shipment.intInventoryShipmentId
				LEFT JOIN tblICInventoryReceipt receipt ON suh.intExternalHeaderId = receipt.intInventoryReceiptId
				LEFT JOIN tblARInvoice invoice ON suh.intExternalHeaderId = invoice.intInvoiceId
				OUTER APPLY 
				(
					SELECT dblFutures = AVG(pfd.dblFutures)
					FROM vyuCTCombinePriceFixation pf 
					INNER JOIN vyuCTCombinePriceFixationDetail pfd ON pf.intPriceFixationId = pfd.intPriceFixationId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
					WHERE pf.intContractHeaderId = suh.intContractHeaderId 
					AND suh.intContractDetailId = pf.intContractDetailId
					AND pf.ysnMultiplePriceFixation = @ysnMultiPrice
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
					, strProcess
					, strInvoiceType)		
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
					, lt.strInvoiceType
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
					, intPricingTypeId = CASE WHEN CBL.strTransactionType = 'Contract Balance'
													AND CBL.strTransactionReference = 'Inventory Shipment'
													AND ISNULL(shipmentItem.ysnAllowInvoice, 0) = 1
													AND ISNULL(CBL.intPricingTypeId, 0) <> 6 THEN 1
											ELSE CBL.intPricingTypeId END
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
				FROM vyuCTCombinePriceFixationDetail pfd
				INNER JOIN vyuCTCombinePriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId AND pf.ysnMultiplePriceFixation = @ysnMultiPrice
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId AND cd.intContractHeaderId = pf.intContractHeaderId
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
				 AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
				, strTransactionType = CASE WHEN cbl.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sales' END + ' Basis Deliveries'
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
			INNER JOIN vyuCTCombinePriceFixationDetail pfd ON pfd.intPriceFixationDetailId = cbl.intTransactionReferenceDetailId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
				, strTransactionType = CASE WHEN cbl.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sales' END + ' Basis Deliveries'
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
			INNER JOIN vyuCTCombinePriceFixationDetail pfd ON pfd.intPriceFixationDetailId = cbl.intTransactionReferenceDetailId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
				, strTransactionType = CASE WHEN cbl.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sales' END + ' Basis Deliveries'
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
			INNER JOIN tblCTContractBalanceLog cbl1 ON cbl.intContractBalanceLogId = cbl1.intContractBalanceLogId AND cbl1.strTransactionReference = 'Price Fixation'
			INNER JOIN vyuCTCombinePriceFixationDetail pfd ON pfd.intPriceFixationDetailId = cbl.intTransactionReferenceDetailId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
					, dblQty = (
						case
						when ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) = pfd.dblQuantity
						then 0
						else
							CASE
							WHEN @ysnLoadBased = 1
							THEN (ISNULL(pfd.dblLoadPriced, 0) - ISNULL(pfd.dblLoadAppliedAndPriced, 0)) * cd.dblQuantityPerLoad
							ELSE ISNULL(pfd.dblQuantity, 0) - ISNULL(dblQuantityAppliedAndPriced, 0)
							END
						end
					)
					, dblOrigQty = pfd.dblQuantity
					, dblDynamic =  CASE WHEN ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) = pfd.dblQuantity AND ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures THEN 0 -- When change of price only.
										ELSE (CASE WHEN @ysnLoadBased = 1 THEN ISNULL(pfd.dblLoadAppliedAndPriced, 0) * cd.dblQuantityPerLoad
											ELSE ISNULL(dblQuantityAppliedAndPriced, 0) END) END
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
					, intActionId = CASE WHEN (ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) = pfd.dblQuantity AND ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures) or (ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) <> pfd.dblQuantity AND ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures) THEN 67 ELSE 17 END
					, strNotes = (CASE WHEN ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) <> pfd.dblQuantity
										THEN (CASE WHEN ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures THEN 'Change Quantity. Change Futures Price.' ELSE 'Change Quantity.' END)
										ELSE (CASE WHEN ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures THEN 'Change Futures Price' ELSE NULL END) END)
				FROM vyuCTCombinePriceFixationDetail pfd
				INNER JOIN vyuCTCombinePriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId AND pf.ysnMultiplePriceFixation = @ysnMultiPrice
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId AND cd.intContractHeaderId = pf.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = cd.intCommodityId AND qu.intUnitMeasureId = cd.intUnitMeasureId
				OUTER APPLY (
					SELECT TOP 1 dblOrigQty = CASE WHEN intActionId = 1 THEN ABS(pl.dblOrigQty) ELSE pl.dblOrigQty END, pl.dblFutures
					FROM @cbLogPrev pl
					WHERE strTransactionReference = 'Price Fixation'
						AND intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
						AND intContractDetailId = @intContractDetailId
					ORDER BY dtmTransactionDate DESC
				) prevLog
				WHERE ISNULL(prevLog.dblOrigQty, pfd.dblQuantity) <> pfd.dblQuantity OR ISNULL(prevLog.dblFutures, pfd.dblFutures) <> pfd.dblFutures AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
					, strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase' ELSE 'Sales' END + ' Basis Deliveries'
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
					FROM vyuCTCombinePriceFixationDetail pfd
					INNER JOIN vyuCTCombinePriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId AND pf.ysnMultiplePriceFixation = @ysnMultiPrice
					INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
					INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId AND cd.intContractHeaderId = pf.intContractHeaderId
					LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = cd.intCommodityId AND qu.intUnitMeasureId = cd.intUnitMeasureId
					WHERE pfd.intPriceFixationDetailId NOT IN
					(
						SELECT DISTINCT intTransactionReferenceDetailId
						FROM @cbLogPrev
						WHERE strTransactionReference = 'Price Fixation'
							AND intContractDetailId = @intContractDetailId
					)
					 AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
				FROM vyuCTCombinePriceFixationDetail pfd
				INNER JOIN vyuCTCombinePriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId AND pf.ysnMultiplePriceFixation = @ysnMultiPrice
				INNER JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				INNER JOIN @tmpContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId AND cd.intContractHeaderId = pf.intContractHeaderId
				LEFT JOIN tblICCommodityUnitMeasure	qu  ON  qu.intCommodityId = cd.intCommodityId
					AND qu.intUnitMeasureId = cd.intUnitMeasureId
				WHERE pfd.intPriceFixationDetailId NOT IN
				(
					SELECT DISTINCT intTransactionReferenceDetailId
					FROM @cbLogPrev
					WHERE strTransactionReference = 'Price Fixation'
						AND intContractDetailId = @intContractDetailId
				)
				 AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
			) tbl
		END
	END

	DECLARE @currentContractDetalId INT,
			@cbLogSpecific AS CTContractBalanceLog,
			@intId INT,
			@dblRunningQty NUMERIC(24, 10) = 0,
			@ysnAddToLogSpecific BIT = 1,
			@intNegatedCount int = 0

	SELECT @intId = MIN(intId) FROM @cbLogCurrent
	WHILE @intId > 0--EXISTS(SELECT TOP 1 1 FROM @cbLogCurrent)
	BEGIN

		--Check if the record is already negated and exit loop.
		if exists (
	  		select
				top 1 1
			from
				@cbLogCurrent curr
				join @cbLogCurrent cter on
					cter.strBatchId = curr.strBatchId
					and cter.strTransactionReference = curr.strTransactionReference
					and cter.intTransactionReferenceId = curr.intTransactionReferenceId
					and cter.intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
					and (cter.dblQty * -1) = curr.dblQty
					and cter.intId <> curr.intId
					and cter.strTransactionType = curr.strTransactionType
					and @ysnDWGPriceOnly = 1
					and cter.strProcess = curr.strProcess
			where
				curr.intId = @intId
		)
		begin
			SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
			continue;
		end
		
		DELETE FROM @cbLogPrev

		/*CT-5532 - If unposting and the contract is DWG, check the @cbLogCurrent if it's contains a self negated records*/

        if ((@ysnDWGPriceOnly = 1) and (@ysnUnposted = 1) and exists (select top 1 1 from @cbLogCurrent where intId = @intId and dblQty > 0))
        begin
            IF OBJECT_ID('tempdb..#tmpNegated') IS NOT NULL DROP TABLE #tmpNegated;

			select * into #tmpNegated from
			(
				SELECT 
					ext.*
				FROM @cbLogCurrent curr
				join @cbLogCurrent ext on (ext.dblQty * -1) = curr.dblQty
				WHERE curr.intId = @intId

				union all

				SELECT 
					curr.*
				FROM @cbLogCurrent curr
				WHERE curr.intId = @intId
			)tbl

			if ((select count(*) from #tmpNegated) = 2)
			begin

				select @intNegatedCount = count(*) from
				(
				select distinct
				strBatchId  
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
				, dblDynamic  
				, intContractStatusId  
				, intBookId  
				, intSubBookId  
				, strNotes  
				, intUserId  
				, intActionId  
				, strProcess  
				from #tmpNegated
				) tbl1

				if (@intNegatedCount = 1)
				begin
					set @ysnAddToLogSpecific = 0;
				end

			end

		end

		/**/

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
			, strProcess
			, strInvoiceType)
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
			, strInvoiceType
		FROM @cbLogCurrent
		WHERE intId = @intId and @ysnAddToLogSpecific = 1

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
				@dblUnit		NUMERIC(24, 10),
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
			, @TotalHTA NUMERIC(24, 10) = 0
			, @TotalOrigBasis NUMERIC(24, 10) = 0
			, @TotalOrigPriced NUMERIC(24, 10) = 0
			, @TotalConsumed NUMERIC(18, 6)
			, @FinalQty NUMERIC(24, 10) = 0
			, @intContractTypeId INT
			, @currPricingTypeId INT
			, @prevPricingTypeId INT
			, @truePricingTypeId INT
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

		SELECT @TotalHTA = ABS(SUM(dblQty))
		FROM @cbLogPrev
		WHERE strTransactionType = 'Contract Balance'
			AND intPricingTypeId = 3
		GROUP BY intContractDetailId

		SELECT @TotalPriced = SUM(dblQty)
		FROM @cbLogPrev
		WHERE strTransactionType = 'Contract Balance'
			AND intPricingTypeId = 1
		GROUP BY intContractDetailId
				
		SELECT @TotalOrigPriced = SUM(dblQty) FROM (
			SELECT intContractDetailId
				, intTransactionReferenceDetailId
				, dblQty = CASE WHEN intActionId = 17 THEN ABS(dblOrigQty)
					WHEN intActionId = 55 THEN 0
					WHEN intActionId = 1 THEN ABS(dblOrigQty) END
			FROM (
				SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY intContractDetailId, intTransactionReferenceDetailId ORDER BY dtmTransactionDate DESC)
					, intContractDetailId
					, intTransactionReferenceDetailId
					, intActionId
					, dblOrigQty
				FROM @cbLogPrev
				WHERE strTransactionType = 'Contract Balance'
					AND intPricingTypeId = 1
					AND strTransactionReference = 'Price Fixation'
			) tbl WHERE intRowId = 1
		) tbl

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

		SELECT @dblUnit = SUM(dblQty)
		FROM @cbLogPrev
		WHERE intPricingTypeId = 4
			AND strTransactionType NOT LIKE '%Basis Deliveries'
		GROUP BY intPricingTypeId
		
		SELECT @dblQty = dblQty
			, @dblOrigQty = ISNULL(dblOrigQty, 0)
			, @dblAppliedQty = ISNULL(dblDynamic, 0)
			, @currPricingTypeId = intPricingTypeId
			, @truePricingTypeId = intPricingTypeId
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
					FROM vyuCTCombinePriceFixationDetail pfd
					INNER JOIN vyuCTCombinePriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId AND pf.ysnMultiplePriceFixation = @ysnMultiPrice
					INNER JOIN tblCTContractHeader ch ON pf.intContractHeaderId = ch.intContractHeaderId
					WHERE pf.intContractHeaderId = @intContractHeaderId AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice
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
					FROM vyuCTCombinePriceFixationDetail pfd
					INNER JOIN vyuCTCombinePriceFixation pf ON pfd.intPriceFixationId = pf.intPriceFixationId AND pf.ysnMultiplePriceFixation = @ysnMultiPrice
					INNER JOIN tblCTContractDetail cd ON ISNULL(pf.intContractDetailId, 0) = cd.intContractDetailId
					WHERE pf.intContractHeaderId = @intContractHeaderId	 AND pfd.ysnMultiplePriceFixation = @ysnMultiPrice		
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
				IF (@intPricingTypeId NOT IN (5))
				BEGIN
					IF ISNULL(@dblBasis, 0) > 0
					BEGIN
						SELECT @_action = CASE WHEN intContractStatusId = 3 THEN 54 ELSE 59 END
						FROM @cbLogSpecific

						UPDATE @cbLogSpecific SET dblQty = @dblBasis * - 1, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3
																									WHEN @intHeaderPricingTypeId = 1 THEN 1
																									ELSE 2 END, intActionId = @_action
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
						DELETE FROM @cbLogSpecific WHERE intContractStatusId = 6;
						IF EXISTS (SELECT TOP 1 1 FROM @cbLogSpecific)
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = @dblBasisDel * - 1,
										strTransactionType = CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END,
										intPricingTypeId = CASE WHEN ISNULL(@dblBasis, 0) = 0 THEN 1 ELSE 2 END, intActionId = @_action
							EXEC uspCTLogContractBalance @cbLogSpecific, 0 
						END
					END
				END
			END			
			ELSE IF EXISTS(SELECT TOP 1 1 FROM @cbLogSpecific WHERE intContractStatusId = 4)
			BEGIN
				UPDATE @cbLogSpecific SET dblQty = dblQty * - 1 --, intActionId = 61
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @total = 0-- No changes with dblQty
			BEGIN
				-- Get the previous record
				DELETE FROM @cbLogPrev 
				WHERE intId <> (SELECT TOP 1 intId FROM @cbLogPrev WHERE strTransactionType = 'Contract Balance' ORDER BY intId DESC)

				DECLARE @_dtmCurrent DATETIME
					, @dblPreviousQtyPriced NUMERIC(24, 10)
					, @dblPreviousFutures NUMERIC(24, 10)

				SELECT TOP 1 @dblPreviousQtyPriced = dblQtyPriced
				FROM tblCTSequenceHistory
				WHERE intContractDetailId = @intContractDetailId
				ORDER BY intSequenceHistoryId DESC

				SELECT @_dtmCurrent = dtmTransactionDate FROM @cbLogSpecific
				SELECT @dblPreviousFutures = dblFutures FROM @cbLogPrev

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
					IF (ISNULL(@TotalBasis, 0) <> 0)
					BEGIN
						-- Negate AND add previous record
						UPDATE @cbLogPrev
						SET dblQty = CASE WHEN @strProcess = 'Price Fixation' --previous priced
											THEN CASE WHEN ISNULL(@TotalPriced, 0) = 0 THEN @dblPreviousQtyPriced * - 1 ELSE @TotalPriced - @dblPreviousQtyPriced END
										ELSE @TotalBasis * - 1 END
							, intPricingTypeId = 2
							, dblFutures = NULL
							, intActionId = 43

						-- Negate previous if the value is not 0
						IF NOT EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE dblQty = 0)
						BEGIN
							UPDATE @cbLogPrev
							SET strBatchId = @strBatchId
								, strProcess = @strProcess
								, dtmTransactionDate = @_dtmCurrent

							IF (@strProcess = 'Do Roll')
							BEGIN
								UPDATE @cbLogPrev
								SET intPriceUOMId = curr.intPriceUOMId
									, strTransactionReference = curr.strTransactionReference
									, strTransactionReferenceNo = curr.strTransactionReferenceNo
									, intTransactionReferenceId = curr.intTransactionReferenceId
									, intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
									, intUserId = curr.intUserId
									, dblOrigQty = curr.dblOrigQty
									, strNotes = ''
								FROM (SELECT * FROM @cbLogSpecific) curr
							END

							EXEC uspCTLogContractBalance @cbLogPrev, 0
						END

						UPDATE @cbLogSpecific
						SET dblQty = CASE WHEN @strProcess = 'Price Fixation' THEN (SELECT dblQty * - 1 FROM @cbLogPrev)
											ELSE @TotalBasis END
							, intPricingTypeId = (case when intPricingTypeId = 1 then 1 else 2 end)
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END		
					IF (ISNULL(@TotalPriced, 0) <> 0)
					BEGIN
						DECLARE @truePreviousPricingType INT
						SELECT @truePreviousPricingType = intPricingTypeId FROM @cbLogPrev

						-- Negate AND add previous record
						UPDATE @cbLogPrev
						SET dblQty = CASE WHEN @strProcess = 'Price Fixation' --previous priced
											THEN CASE WHEN ISNULL(@TotalPriced, 0) = 0 THEN @dblPreviousQtyPriced * - 1 ELSE @TotalPriced - @dblPreviousQtyPriced END
										ELSE @TotalPriced * - 1 END
							, intPricingTypeId = 1
							, dblFutures = @dblPreviousFutures
							, intActionId = 43

						-- Negate previous if the value is not 0
						IF NOT EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE dblQty = 0)
						BEGIN
							UPDATE @cbLogPrev
							SET strBatchId = @strBatchId
								, strProcess = @strProcess
								, dtmTransactionDate = @_dtmCurrent

							IF (@strProcess = 'Do Roll')
							BEGIN
								UPDATE @cbLogPrev
								SET intPriceUOMId = curr.intPriceUOMId
									, strTransactionReference = curr.strTransactionReference
									, strTransactionReferenceNo = curr.strTransactionReferenceNo
									, intTransactionReferenceId = curr.intTransactionReferenceId
									, intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
									, intUserId = curr.intUserId
									, dblOrigQty = curr.dblOrigQty
									, strNotes = ''
								FROM (SELECT * FROM @cbLogSpecific) curr
							END

							EXEC uspCTLogContractBalance @cbLogPrev, 0
						END

						UPDATE @cbLogSpecific
						SET dblQty = CASE WHEN @strProcess = 'Price Fixation' THEN (SELECT dblQty * - 1 FROM @cbLogPrev)
										ELSE @TotalPriced END
							, intPricingTypeId = CASE WHEN ISNULL(@truePreviousPricingType, 0) = 1 AND ISNULL(@truePricingTypeId, 0) <> 1 THEN @truePricingTypeId ELSE 1 END
							, dblFutures = @dblPreviousFutures
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
					IF (ISNULL(@TotalHTA, 0) <> 0)
					BEGIN
						-- Negate AND add previous record
						UPDATE @cbLogPrev
						SET dblQty = @TotalHTA * - 1
							, intPricingTypeId = 3
							, dblBasis = NULL
							, intActionId = 43

						-- Negate previous if the value is not 0
						IF NOT EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE dblQty = 0)
						BEGIN
							UPDATE @cbLogPrev
							SET strBatchId = @strBatchId
								, strProcess = @strProcess
								, dtmTransactionDate = @_dtmCurrent

							IF (@strProcess = 'Do Roll')
							BEGIN
								UPDATE @cbLogPrev
								SET intPriceUOMId = curr.intPriceUOMId
									, strTransactionReference = curr.strTransactionReference
									, strTransactionReferenceNo = curr.strTransactionReferenceNo
									, intTransactionReferenceId = curr.intTransactionReferenceId
									, intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
									, intUserId = curr.intUserId
									, dblOrigQty = curr.dblOrigQty
									, strNotes = ''
								FROM (SELECT * FROM @cbLogSpecific) curr
							END

							EXEC uspCTLogContractBalance @cbLogPrev, 0
						END

						UPDATE @cbLogSpecific
						SET dblQty = @TotalHTA
							, intPricingTypeId = CASE WHEN (@truePricingTypeId = 1 AND @prevPricingTypeId = 3) THEN 1 ELSE @truePricingTypeId END
						EXEC uspCTLogContractBalance @cbLogSpecific, 0						
					END
					IF (ISNULL(@TotalBasis, 0) = 0) AND (ISNULL(@TotalPriced, 0) = 0) AND ISNULL(@TotalHTA, 0) = 0
					BEGIN
						IF (@truePricingTypeId IN (4, 5, 6))
						BEGIN
							DECLARE @ptQty NUMERIC(18, 6)
							SELECT @ptQty = CASE WHEN @truePricingTypeId = 4 THEN @dblUnit
												WHEN @truePricingTypeId = 5 THEN @dblDP
												WHEN @truePricingTypeId = 6 THEN @dblCash END

							-- Negate AND add previous record
							UPDATE @cbLogPrev
							SET dblQty = @ptQty * - 1
								, intPricingTypeId = @truePricingTypeId
								, intActionId = 43

							-- Negate previous if the value is not 0
							IF NOT EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE dblQty = 0)
							BEGIN
								UPDATE @cbLogPrev
								SET strBatchId = @strBatchId
									, strProcess = @strProcess
									, dtmTransactionDate = @_dtmCurrent

								IF (@strProcess = 'Do Roll')
								BEGIN
									UPDATE @cbLogPrev
									SET intPriceUOMId = curr.intPriceUOMId
										, strTransactionReference = curr.strTransactionReference
										, strTransactionReferenceNo = curr.strTransactionReferenceNo
										, intTransactionReferenceId = curr.intTransactionReferenceId
										, intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
										, intUserId = curr.intUserId
										, dblOrigQty = curr.dblOrigQty
										, strNotes = ''
									FROM (SELECT * FROM @cbLogSpecific) curr
								END

								EXEC uspCTLogContractBalance @cbLogPrev, 0
							END

							UPDATE @cbLogSpecific
							SET dblQty = @ptQty
								, intPricingTypeId = @truePricingTypeId
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END
						ELSE IF (@prevPricingTypeId = 4 AND @currPricingTypeId = 1)
						BEGIN
							-- Negate AND add previous record
							UPDATE @cbLogPrev
							SET dblQty = @dblUnit * - 1
								, intPricingTypeId = 4
								, intActionId = 43

							-- Negate previous if the value is not 0
							IF NOT EXISTS(SELECT TOP 1 1 FROM @cbLogPrev WHERE dblQty = 0)
							BEGIN
								UPDATE @cbLogPrev
								SET strBatchId = @strBatchId
									, strProcess = @strProcess
									, dtmTransactionDate = @_dtmCurrent

								IF (@strProcess = 'Do Roll')
								BEGIN
									UPDATE @cbLogPrev
									SET intPriceUOMId = curr.intPriceUOMId
										, strTransactionReference = curr.strTransactionReference
										, strTransactionReferenceNo = curr.strTransactionReferenceNo
										, intTransactionReferenceId = curr.intTransactionReferenceId
										, intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
										, intUserId = curr.intUserId
										, dblOrigQty = curr.dblOrigQty
										, strNotes = ''
									FROM (SELECT * FROM @cbLogSpecific) curr
								END

								EXEC uspCTLogContractBalance @cbLogPrev, 0
							END

							UPDATE @cbLogSpecific
							SET dblQty = @dblUnit
								, intPricingTypeId = @truePricingTypeId
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END
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
				--Check if the sequence was HTA and then priced
				IF (@prevPricingTypeId = 3 AND @truePricingTypeId = 1 AND @TotalHTA > 0)
				BEGIN
					UPDATE @cbLogSpecific
					SET dblQty = @TotalConsumed * -1
						, dblOrigQty = @TotalConsumed
						, intPricingTypeId = 3
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					UPDATE @cbLogSpecific
					SET dblQty = @TotalConsumed
						, dblOrigQty = @TotalConsumed
						, intPricingTypeId = 1
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				ELSE IF (@strProcess = 'Do Roll')
				BEGIN
					IF (ISNULL(@TotalBasis, 0) <> 0)
					BEGIN
						-- Negate AND add previous record
						UPDATE @cbLogPrev
						SET dblQty = @TotalBasis * - 1
							, intPricingTypeId = 2
							, dblFutures = NULL
							, intActionId = 43
							, strBatchId = @strBatchId
							, strProcess = @strProcess
							, dtmTransactionDate = @_dtmCurrent
							, intPriceUOMId = curr.intPriceUOMId
							, strTransactionReference = curr.strTransactionReference
							, strTransactionReferenceNo = curr.strTransactionReferenceNo
							, intTransactionReferenceId = curr.intTransactionReferenceId
							, intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
							, intUserId = curr.intUserId
							, dblOrigQty = curr.dblOrigQty
							, strNotes = ''
						FROM (SELECT * FROM @cbLogSpecific) curr
						EXEC uspCTLogContractBalance @cbLogPrev, 0

						UPDATE @cbLogSpecific
						SET dblQty = @TotalBasis
							, intPricingTypeId = 2
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END		
					IF (ISNULL(@TotalPriced, 0) <> 0)
					BEGIN
						-- Negate AND add previous record
						UPDATE @cbLogPrev
						SET dblQty = @TotalPriced * - 1
							, intPricingTypeId = 1
							, dblFutures = @dblPreviousFutures
							, intActionId = 43
							, strBatchId = @strBatchId
							, strProcess = @strProcess
							, dtmTransactionDate = @_dtmCurrent
							, intPriceUOMId = curr.intPriceUOMId
							, strTransactionReference = curr.strTransactionReference
							, strTransactionReferenceNo = curr.strTransactionReferenceNo
							, intTransactionReferenceId = curr.intTransactionReferenceId
							, intTransactionReferenceDetailId = curr.intTransactionReferenceDetailId
							, intUserId = curr.intUserId
							, dblOrigQty = curr.dblOrigQty
							, strNotes = ''
						FROM (SELECT * FROM @cbLogSpecific) curr
						EXEC uspCTLogContractBalance @cbLogPrev, 0

						UPDATE @cbLogSpecific
						SET dblQty = 1
							, intPricingTypeId = 1
							, dblFutures = @dblPreviousFutures
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
				END
				ELSE
				BEGIN
					--Check if the sequence is being update
					IF EXISTS (SELECT TOP 1 1 FROM @cbLogSpecific WHERE intActionId = 43)  
					BEGIN
						--if the total priced qty is equal or less than contract qty, pricing type should be the pricing type of the header.
						IF (@TotalPriced <= @dblContractQty)
						BEGIN
							UPDATE @cbLogSpecific SET intPricingTypeId = @intHeaderPricingTypeId
						END
					END 

					-- Add current record
					UPDATE  @cbLogSpecific SET dblQty = @total * CASE WHEN @prevContractStatusId <> 3 AND @intContractStatusId = 3 THEN - 1 ELSE 1 END
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END	
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
                -- If there is remaining Priced and the Original Qty is more than the Priced, removed from Priced and add it to basis
				UPDATE @cbLogSpecific SET dblQty = (
					case
					when (case when dblOrigQty > @dblPriced then @FinalQty + @dblPriced else @FinalQty end) > @TotalPriced
					then @TotalPriced
					else (case when dblOrigQty > @dblPriced then @FinalQty + @dblPriced else @FinalQty end)
					end
				) * - 1, intPricingTypeId = 1, strTransactionReference = 'Price Fixation'
				EXEC uspCTLogContractBalance @cbLogSpecific, 0

				-- Add all the basis quantities
				-- Use current Basis Price when putting back basis qty
                -- If there is remaining Priced and the Original Qty is more than the Priced, removed from Priced and add it to basis
				UPDATE @cbLogSpecific SET dblQty = (
					case
					when @TotalBasis > 0 and (case when dblOrigQty > @dblPriced then @FinalQty + @dblPriced else @FinalQty end) > @TotalBasis and isnull(@ysnMultiPrice,0) = 0
					then @TotalBasis
					else (case when dblOrigQty > @dblPriced then @FinalQty + @dblPriced else @FinalQty end)
					end
				), intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END, dblBasis = @dblCurrentBasis
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @strProcess IN ('Priced DWG','Price Delete DWG', 'Price Update')
			BEGIN
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE IF @strNotes = 'Change Futures Price'
			BEGIN
				EXEC uspCTLogContractBalance @cbLogSpecific, 0
			END
			ELSE
			BEGIN
				DECLARE @prevOrigQty NUMERIC(18, 6)
					, @qtyDiff NUMERIC(18, 6)
					, @unloggedBasis NUMERIC(18, 6)
					, @dblRemainingQty NUMERIC(18, 6)
					, @dblQuantityAppliedAndPriced NUMERIC(18, 6)
					, @dblCurrentQty NUMERIC(18, 6)
					, @tmpTotal NUMERIC(18, 6)

				SELECT @dblRunningQty += @dblOrigQty
					, @dblRemainingQty = 0
				
				SELECT TOP 1 @prevOrigQty = ISNULL(dblPreviousQty,dblQuantity)    
					, @qtyDiff = dblQuantity - ISNULL(dblPreviousQty,dblQuantity)  
					, @dblRemainingQty = CASE WHEN ISNULL(@ysnLoadBased, 0) = 1 THEN (dblLoadPriced - dblLoadAppliedAndPriced) * @dblQuantityPerLoad ELSE dblQuantity - dblQuantityAppliedAndPriced END
					, @dblCurrentQty = dblQuantity
					, @dblQuantityAppliedAndPriced = dblQuantityAppliedAndPriced
				FROM vyuCTCombinePriceFixationDetail
				WHERE intPriceFixationDetailId = @intPriceFixationDetailId AND ysnMultiplePriceFixation = @ysnMultiPrice

				IF @strProcess = 'Price Delete' OR @strProcess = 'Fixation Detail Delete'
				BEGIN
					-- 	1.1. Decrease available priced quantities
					-- 	1.2. Increase available basis quantities
					--  1.3. Increase basis deliveries if DWG
					SET @FinalQty = CASE WHEN @intContractStatusId IN (1, 4) THEN @dblCurrentQty - @dblQuantityAppliedAndPriced ELSE 0 END

					-- Negate all the priced quantities
					UPDATE @cbLogSpecific SET dblQty = @FinalQty * - 1, intPricingTypeId = 1, strTransactionReference = 'Price Fixation'
					EXEC uspCTLogContractBalance @cbLogSpecific, 0

					-- Add all the basis quantities
					-- Use current Basis Price when putting back basis qty
					UPDATE @cbLogSpecific SET dblQty = @FinalQty, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE 2 END, dblBasis = @dblCurrentBasis
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				ELSE IF @strProcess IN ('Priced DWG','Price Delete DWG', 'Price Update')
				BEGIN
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				ELSE IF @strNotes = 'Change Futures Price'
				BEGIN
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
				END
				ELSE
				BEGIN
					IF (@qtyDiff <> 0)
					BEGIN
						-- Qty Changed
						SET @FinalQty =  CASE WHEN @dblAppliedQty > @prevOrigQty THEN @dblCurrentQty - @dblAppliedQty
											ELSE @dblCurrentQty - @prevOrigQty END
					END
					ELSE
					BEGIN
						-- New Price or No change
						SET @FinalQty = @dblQty
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
							UPDATE  @cbLogSpecific SET dblQty = @FinalQty * - 1, intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 3 ELSE @intHeaderPricingTypeId END
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						END

						-- Decrease Priced
						UPDATE  @cbLogSpecific SET dblQty = @FinalQty, intPricingTypeId = 1
						EXEC uspCTLogContractBalance @cbLogSpecific, 0
					END
				END
			END
		END
		ELSE IF @strSource = 'Inventory'
		BEGIN
			IF @strProcess IN ('Create Invoice', 'Delete Invoice', 'Create Credit Memo', 'Delete Credit Memo', 'Create Voucher', 'Delete Voucher')
			BEGIN

				
				--Unposting invoice should not log SBD
				set @ysnInvoicePosted = 0;

				if (@strProcess = 'Create Invoice' and exists (
					select top 1 1
					from @cbLogPrev lp
					join @cbLogCurrent i on i.intTransactionReferenceId = lp.intTransactionReferenceId
					join @cbLogSpecific ls
					on ls.strProcess = lp.strProcess
					and ls.strTransactionType = lp.strTransactionType
					and ls.strTransactionReference = lp.strTransactionReference
					and ls.intTransactionReferenceId = lp.intTransactionReferenceId
					and ls.intTransactionReferenceDetailId = lp.intTransactionReferenceDetailId
					and ls.intActionId = lp.intActionId
					and i.ysnInvoicePosted = 1				
				))
				begin
					set @ysnInvoicePosted = 1;
				end

				if (@ysnInvoicePosted = 0)
				begin
					UPDATE @cbLogSpecific SET intActionId = CASE WHEN @strProcess = 'Create Invoice' THEN 16
											WHEN @strProcess = 'Create Credit Memo' THEN 64
											WHEN @strProcess = 'Delete Invoice' THEN 63
											WHEN @strProcess = 'Delete Credit Memo' THEN 65
											WHEN @strProcess = 'Create Voucher' THEN 15
											WHEN @strProcess = 'Delete Voucher' THEN 62
											ELSE intActionId END
					EXEC uspCTLogContractBalance @cbLogSpecific, 0  
				end 

				SELECT @intId = MIN(intId) FROM @cbLogCurrent WHERE intId > @intId
				CONTINUE
			END

			IF @ysnInvoice = 1
			BEGIN				
				UPDATE @cbLogSpecific SET dblQty = dblQty * - 1
					, intActionId = CASE WHEN @strProcess = 'Create Invoice' THEN 16
										WHEN @strProcess = 'Create Credit Memo' or strInvoiceType = 'Credit Memo' THEN 64
										WHEN @strProcess = 'Delete Invoice' THEN 63
										WHEN @strProcess = 'Delete Credit Memo' THEN 65
										ELSE intActionId END
					, strTransactionReference = case when strInvoiceType = 'Credit Memo' then 'Credit Memo' else strTransactionReference end
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
					-- DP Update Balance
					UPDATE @cbLogSpecific
					SET strTransactionReference = 'Contract Sequence'
						, strTransactionType = 'Contract Balance'
						, intActionId = 43
						, strTransactionReferenceNo = strContractNumber
						, dblQty = dblQty * -1
					EXEC uspCTLogContractBalance @cbLogSpecific, 0
					
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
							--Dont log DWG Contract Balance if there's no change in quantity in posting DWG.
							IF ((@dblBasis >= @dblQty) and exists(select top 1 1 from @cbLogSpecific where dblQty <> 0 and dblOrigQty <> 0))
								EXEC uspCTLogContractBalance @cbLogSpecific, 0
							END
						END
					END
									
					IF (@currPricingTypeId = 2)
					BEGIN						
						IF  @dblQty <> 0
						BEGIN
							--During posting of DWG, don't log the Sales Basis Delivery when there's no changes in the quantity because it's already logged during distribution of the ticket.
							if not exists (
								select top 1 1
								from
									@cbLogPrev lp
									join @cbLogSpecific ls
									on
									lp.strTransactionType = 'Sales Basis Deliveries'
									and lp.strTransactionReference = ls.strTransactionReference
									and lp.intTransactionReferenceDetailId = ls.intTransactionReferenceDetailId
									and lp.intTransactionReferenceId = ls.intTransactionReferenceId
									and lp.dblQty = @dblQty
									and lp.strProcess = 'Update Sequence Balance'
								) and @strProcess = 'Update Sequence Balance - DWG'
							begin
								UPDATE @cbLogSpecific SET dblQty = @dblQty, strTransactionType = 'Sales Basis Deliveries', intPricingTypeId = 2, intActionId = 18
								EXEC uspCTLogContractBalance @cbLogSpecific, 0
							end
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
						AND a.intInventoryShipmentItemId = b.intTransactionReferenceDetailId
					END
					-- Inventory Receipt
					ELSE IF (@strTransactionReference = 'Inventory Receipt')
					BEGIN
						SELECT @dblActual = SUM(dblOpenReceive)
						FROM tblICInventoryReceiptItem a
						INNER JOIN @cbLogSpecific b ON a.intInventoryReceiptId = b.intTransactionReferenceId
						WHERE a.intInventoryReceiptItemId = b.intTransactionReferenceDetailId
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

						
						if exists (select top 1 1 from @cbLogSpecific where intPricingTypeId = 1 and dblQty < 0 and dblOrigQty - abs(dblQty) > 0)
						begin
							UPDATE @cbLogSpecific SET dblQty = (dblOrigQty - abs(dblQty)) * - 1, intPricingTypeId = 2, intActionId = case when intActionId = 46 then 18 else intActionId end
							EXEC uspCTLogContractBalance @cbLogSpecific, 0
						end
						
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
									UPDATE @cbLogSpecific SET dblQty = @_dblActual, intPricingTypeId = 1, strTransactionType = 'Sales Basis Deliveries', intActionId = case when intActionId = 18 then 46 else intActionId end
									EXEC uspCTLogContractBalance @cbLogSpecific, 0 
								end
							end
							else
							begin
								UPDATE @cbLogSpecific SET dblQty = @_dblActual, intPricingTypeId = 1, strTransactionType = 'Sales Basis Deliveries', intActionId = case when intActionId = 18 then 46 else intActionId end
								EXEC uspCTLogContractBalance @cbLogSpecific, 0 
							end
						END
						ELSE IF (@strTransactionReference = 'Inventory Receipt')  
						BEGIN  
							if (@currPricingTypeId = 1 and isnull(@ysnWithPriceFix,0) = 1)  
							begin  
								UPDATE @cbLogSpecific SET dblQty = @_dblActual, intPricingTypeId = 1, strTransactionType = 'Purchase Basis Deliveries'    
								EXEC uspCTLogContractBalance @cbLogSpecific, 0   
							end  
							ELSE
							BEGIN
								UPDATE @cbLogSpecific SET dblQty = @_dblActual, intPricingTypeId = 1, strTransactionType = 'Purchase Basis Deliveries'
								EXEC uspCTLogContractBalance @cbLogSpecific, 0 
							END
						END
						ELSE IF (@strTransactionReference = 'Settle Storage' AND @currPricingTypeId = 2 and exists (select top 1 1 from @cbLogSpecific where dblQty < 0))
                        BEGIN  
                            UPDATE @cbLogSpecific SET dblQty = abs(dblQty), intPricingTypeId = 1, strTransactionType = 'Purchase Basis Deliveries'    
                            EXEC uspCTLogContractBalance @cbLogSpecific, 0;
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
					IF ISNULL(@dblUnit, 0) > 0
					BEGIN
						UPDATE a SET dblQty = (CASE WHEN @dblQty > ISNULL(@dblUnit, 0) THEN ISNULL(@dblUnit, 0) ELSE @dblQty END) * - 1, intActionId = CASE WHEN a.intContractTypeId = 1 THEN 52 ELSE 51 END
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
							IF (@strTransactionType = 'Contract Balance' AND @strTransactionReference LIKE 'Inventory%') AND @TotalPriced = 0
							BEGIN
								UPDATE @cbLogSpecific SET dblQty = dblQty * - 1

								IF (ISNULL(@TotalOrigPriced, 0) = 0) OR (@TotalOrigPriced - (@TotalConsumed + @dblQty) <= 0)
								BEGIN
									UPDATE @cbLogSpecific SET intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 1
																						WHEN @intHeaderPricingTypeId = 1 THEN 1
																						ELSE 2 END, intActionId = (CASE WHEN intActionId = 46 AND @currPricingTypeId <> 3 THEN 18 ELSE intActionId END)
								END
							END
							ELSE
							BEGIN
								UPDATE @cbLogSpecific SET dblQty = dblQty * - 1, intPricingTypeId = 1, intActionId = (CASE WHEN intActionId = 18 THEN 46 ELSE intActionId END)
							END
						END
						ELSE
						BEGIN
							UPDATE @cbLogSpecific SET dblQty = dblQty * - 1

							IF (ISNULL(@TotalOrigPriced, 0) = 0) OR (@TotalOrigPriced - (@TotalConsumed + @dblQty) <= 0)
							BEGIN
								UPDATE @cbLogSpecific SET intPricingTypeId = CASE WHEN @currPricingTypeId = 3 THEN 1 
																					WHEN @intHeaderPricingTypeId = 1 THEN 1
																					ELSE 2 END, intActionId = (CASE WHEN intActionId = 46 AND @currPricingTypeId <> 3 THEN 18 ELSE intActionId END)
							END
						END
					END
					ELSE
					BEGIN
						UPDATE @cbLogSpecific SET dblQty = dblQty * - 1, intActionId = (case when intActionId = 18 then 46 when intActionId = 46 and @TotalOrigPriced = 0 and (dblQty * - 1) < 0 and strTransactionType = 'Sales Basis Deliveries' then 18 else intActionId end)
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
