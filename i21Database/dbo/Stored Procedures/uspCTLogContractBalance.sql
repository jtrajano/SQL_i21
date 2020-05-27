CREATE PROCEDURE [dbo].[uspCTLogContractBalance]
	@ContractSequences CTContractBalanceLog READONLY
	, @Rebuild BIT

AS

BEGIN
	SELECT * INTO #tmpLogItems FROM @ContractSequences

	DECLARE @Id INT
		, @strBatchId NVARCHAR(100) 
		, @dtmTransactionDate DATETIME
		, @strTransactionType NVARCHAR(100)
		, @strTransactionReference NVARCHAR(100)
		, @intTransactionReferenceId INT
		, @strTransactionReferenceNo NVARCHAR(100)
		, @intContractDetailId INT
		, @intContractHeaderId INT
		, @intContractTypeId INT
		, @intEntityId INT
		, @intCommodityId INT
		, @intItemId INT
		, @intLocationId INT
		, @intPricingTypeId INT
		, @intFutureMarketId INT
		, @intFutureMonthId INT
		, @dblBasis NUMERIC(24, 10)
		, @dblFutures NUMERIC(24, 10)
		, @intQtyUOMId INT
		, @intQtyCurrencyId INT
		, @intBasisUOMId INT
		, @intBasisCurrencyId INT
		, @intPriceUOMId INT
		, @dtmStartDate DATETIME
		, @dtmEndDate DATETIME
		, @dblQty NUMERIC(24, 10)
		, @intContractStatusId INT
		, @intBookId INT
		, @intSubBookId INT
		, @strNotes NVARCHAR(100)
		, @intUserId INT
		, @intActionId INT
		, @strProcess NVARCHAR(100)

	-- Validate Batch Id
	IF EXISTS(SELECT TOP 1 1 FROM #tmpLogItems WHERE ISNULL(strBatchId, '') = '')
	BEGIN
		EXEC uspSMGetStartingNumber 148, @strBatchId OUTPUT

		UPDATE tmp
		SET strBatchId = @strBatchId
		FROM #tmpLogItems tmp
		WHERE ISNULL(strBatchId, '') = ''
	END

	DECLARE @FinalTable AS TABLE (strBatchId NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
		, [dtmTransactionDate] DATETIME
		, [strTransactionType] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
		, [strTransactionReference] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
		, [intTransactionReferenceId] INT NOT NULL
		, [strTransactionReferenceNo] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
		, [intContractDetailId] INT NOT NULL
		, [intContractHeaderId] INT NOT NULL
		, [strContractNumber] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
		, [intContractSeq] INT NOT NULL
		, [intContractTypeId] INT NOT NULL
		, [intEntityId] INT NOT NULL
		, [intCommodityId] INT NOT NULL
		, [intItemId] INT NOT NULL
		, [intLocationId] INT NULL
		, [intPricingTypeId] INT NOT NULL
		, [intFutureMarketId] INT NULL
		, [intFutureMonthId] INT NULL
		, [dblBasis] NUMERIC(24, 10) NULL DEFAULT((0))
		, [dblFutures] NUMERIC(24, 10) NULL DEFAULT((0))
		, [intQtyUOMId] INT NULL
		, [intQtyCurrencyId] INT NULL
		, [intBasisUOMId] INT NULL
		, [intBasisCurrencyId] INT NULL
		, [intPriceUOMId] INT NULL
		, [dtmStartDate] DATETIME
		, [dtmEndDate] DATETIME
		, [dblQty] NUMERIC(24, 10) NULL DEFAULT((0))
		, [intContractStatusId] INT NOT NULL
		, [intBookId] INT NULL
		, [intSubBookId] INT NULL
		, [strNotes] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, [ysnNegated] BIT DEFAULT((0)) NULL
		, [intRefContractBalanceId] INT NULL
		, [intUserId] INT NULL
		, [intActionId] INT NULL
		, [strProcess] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL)

	--DECLARE @PrevLog AS TABLE ([intContractBalanceLogId] INT
	--	, [strBatchId] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	--	, [dtmTransactionDate] DATETIME
	--	, [dtmCreatedDate] DATETIME
	--	, [strTransactionType] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	--	, [strTransactionReference] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	--	, [intTransactionReferenceId] INT NOT NULL
	--	, [strTransactionReferenceNo] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	--	, [intContractDetailId] INT NOT NULL
	--	, [intContractHeaderId] INT NOT NULL
	--	, [intContractTypeId] INT NOT NULL
	--	, [intEntityId] INT NOT NULL
	--	, [intCommodityId] INT NOT NULL
	--	, [intItemId] INT NOT NULL
	--	, [intLocationId] INT NULL
	--	, [intPricingTypeId] INT NOT NULL
	--	, [intFutureMarketId] INT NULL
	--	, [intFutureMonthId] INT NULL
	--	, [dblBasis] NUMERIC(24, 10) NULL DEFAULT((0))
	--	, [dblFutures] NUMERIC(24, 10) NULL DEFAULT((0))
	--	, [intQtyUOMId] INT NULL
	--	, [intQtyCurrencyId] INT NULL
	--	, [intBasisUOMId] INT NULL
	--	, [intBasisCurrencyId] INT NULL
	--	, [intPriceUOMId] INT NULL
	--	, [dtmStartDate] DATETIME
	--	, [dtmEndDate] DATETIME
	--	, [dblQty] NUMERIC(24, 10) NULL DEFAULT((0))
	--	, [intContractStatusId] INT NOT NULL
	--	, [intBookId] INT NULL
	--	, [intSubBookId] INT NULL
	--	, [strNotes] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	--	, [ysnNegated] BIT DEFAULT((0)) NULL
	--	, [intRefContractBalanceId] INT NULL)

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpLogItems)
	BEGIN
		SELECT TOP 1 @Id = intId
			, @strBatchId = strBatchId
			, @dtmTransactionDate = dtmTransactionDate
			, @strTransactionType = strTransactionType
			, @strTransactionReference = strTransactionReference
			, @intTransactionReferenceId = intTransactionReferenceId
			, @strTransactionReferenceNo = strTransactionReferenceNo
			, @intContractDetailId = intContractDetailId
			, @intContractHeaderId = intContractHeaderId
			, @intContractTypeId = intContractTypeId
			, @intEntityId = intEntityId
			, @intCommodityId = intCommodityId
			, @intItemId = intItemId
			, @intLocationId = intLocationId
			, @intPricingTypeId = intPricingTypeId
			, @intFutureMarketId = intFutureMarketId
			, @intFutureMonthId = intFutureMonthId
			, @dblBasis = dblBasis
			, @dblFutures = dblFutures
			, @intQtyUOMId = intQtyUOMId
			, @intQtyCurrencyId = intQtyCurrencyId
			, @intBasisUOMId = intBasisUOMId
			, @intBasisCurrencyId = intBasisCurrencyId
			, @intPriceUOMId = intPriceUOMId
			, @dtmStartDate = dtmStartDate
			, @dtmEndDate = dtmEndDate
			, @dblQty = dblQty
			, @intContractStatusId = intContractStatusId
			, @intBookId = intBookId
			, @intSubBookId = intSubBookId
			, @strNotes = strNotes
			, @intUserId = intUserId
			, @intActionId = intActionId
			, @strProcess = strProcess
		FROM #tmpLogItems

		--SELECT * INTO #tmpPrevLogList
		--FROM tblCTContractBalanceLog
		--WHERE intContractDetailId = @intContractDetailId
		--	AND strTransactionType = @strTransactionType
		--	AND ISNULL(ysnNegated, 0) = 0 
		--	AND intRefContractBalanceId NOT IN (SELECT intContractBalanceLogId FROM tblCTContractBalanceLog WHERE ysnNegated = 1)
		--ORDER BY intContractBalanceLogId ASC

		--IF (SELECT COUNT(*) FROM #tmpPrevLogList ) > 1
		--BEGIN
		--	IF EXISTS(SELECT TOP 1 1 FROM #tmpPrevLogList WHERE intPricingTypeId = 1)
		--	BEGIN
		--		INSERT INTO @PrevLog
		--		SELECT TOP 1 * FROM #tmpPrevLogList WHERE intPricingTypeId = 1
		--		ORDER BY intContractBalanceLogId ASC
		--	END
		--	ELSE
		--	BEGIN
		--		INSERT INTO @PrevLog
		--		SELECT TOP 1 * FROM #tmpPrevLogList ORDER BY intContractBalanceLogId ASC
		--	END
		--END
		--ELSE
		--BEGIN
		--	INSERT INTO @PrevLog
		--	SELECT TOP 1 * FROM #tmpPrevLogList
		--END		

		---- Validate if no changes was detected on fields with bearing
		--IF EXISTS(SELECT TOP 1 1
		--	FROM @PrevLog
		--	WHERE @intContractDetailId = intContractDetailId
		--		AND @intContractHeaderId = intContractHeaderId
		--		AND @intContractTypeId = intContractTypeId
		--		AND @intEntityId = intEntityId
		--		AND @intCommodityId = intCommodityId
		--		AND @intItemId = intItemId
		--		AND @intLocationId = intLocationId
		--		AND @intPricingTypeId = intPricingTypeId
		--		AND @intFutureMarketId = intFutureMarketId
		--		AND @intFutureMonthId = intFutureMonthId
		--		AND @dblBasis = dblBasis
		--		AND @dblFutures = dblFutures
		--		AND @intQtyUOMId = intQtyUOMId
		--		AND @intQtyCurrencyId = intQtyCurrencyId
		--		AND @intBasisUOMId = intBasisUOMId
		--		AND @intBasisCurrencyId = intBasisCurrencyId
		--		AND @intPriceUOMId = intPriceUOMId
		--		AND @dtmStartDate = dtmStartDate
		--		AND @dtmEndDate = dtmEndDate
		--		AND @dblQty = dblQty
		--		AND @intContractStatusId = intContractStatusId
		--		AND @intBookId = intBookId
		--		AND @intSubBookId = intSubBookId)
		--BEGIN
		--	CONTINUE
		--END

		--IF EXISTS(SELECT TOP 1 1 FROM @PrevLog)
		--BEGIN
		--	INSERT INTO @FinalTable(strBatchId
		--		, dtmTransactionDate
		--		, strTransactionType
		--		, strTransactionReference
		--		, intTransactionReferenceId
		--		, strTransactionReferenceNo
		--		, intContractDetailId
		--		, intContractHeaderId
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
		--		, ysnNegated
		--		, intRefContractBalanceId)
		--	SELECT @strBatchId
		--		, dtmTransactionDate
		--		, strTransactionType
		--		, strTransactionReference
		--		, intTransactionReferenceId
		--		, strTransactionReferenceNo
		--		, intContractDetailId
		--		, intContractHeaderId
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
		--		, strNotes = ISNULL(strNotes, '')
		--		, ysnNegated = 1
		--		, intRefContractBalanceId = intContractBalanceLogId
		--	FROM @PrevLog
		--END


		INSERT INTO @FinalTable(strBatchId
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
			, strProcess)
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
			, strProcess
		FROM #tmpLogItems WHERE intId = @Id

		--DROP TABLE #tmpPrevLogList

		DELETE FROM #tmpLogItems WHERE intId = @Id
	END

	INSERT INTO tblCTContractBalanceLog(strBatchId
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
		, ysnNegated
		, intRefContractBalanceId
		, intUserId
		, strProcess)
	SELECT strBatchId
		, intActionId
		, strAction = A.strActionIn 
		, dtmTransactionDate
		, dtmCreatedDate = CASE WHEN @Rebuild = 1 THEN dtmTransactionDate ELSE GETUTCDATE() END
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
		, ysnNegated
		, intRefContractBalanceId
		, intUserId
		, strProcess
	FROM @FinalTable F
	LEFT JOIN tblRKLogAction A ON A.intLogActionId = F.intActionId

	DROP TABLE #tmpLogItems
END