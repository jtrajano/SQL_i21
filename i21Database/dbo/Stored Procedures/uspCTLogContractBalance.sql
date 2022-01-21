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
		, @intTransactionReferenceDetailId INT
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
		, @dblOrigQty NUMERIC(24, 10)
		, @intContractStatusId INT
		, @intBookId INT
		, @intSubBookId INT
		, @strNotes NVARCHAR(100)
		, @intUserId INT
		, @intActionId INT
		, @strProcess NVARCHAR(100)
		, @ysnDeleted BIT
		, @intTransCtr INT = 0
		, @intTotal INT
	
	SELECT @intTotal = COUNT(*) FROM @ContractSequences
	
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
		, [intTransactionReferenceDetailId] INT NULL
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
		, [dblOrigQty] NUMERIC(24, 10) NULL DEFAULT((0))
		, [intContractStatusId] INT NOT NULL
		, [intBookId] INT NULL
		, [intSubBookId] INT NULL
		, [strNotes] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, [ysnNegated] BIT DEFAULT((0)) NULL
		, [intRefContractBalanceId] INT NULL
		, [intUserId] INT NULL
		, [intActionId] INT NULL
		, [strProcess] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
		, [ysnDeleted] BIT DEFAULT((0)) NULL)

	IF @Rebuild = 1 
	BEGIN
		GOTO BulkRebuild
	END
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpLogItems)
	BEGIN
		SELECT TOP 1 @Id = intId
			, @strBatchId = strBatchId
			, @dtmTransactionDate = dtmTransactionDate
			, @strTransactionType = strTransactionType
			, @strTransactionReference = strTransactionReference
			, @intTransactionReferenceId = intTransactionReferenceId
			, @intTransactionReferenceDetailId = intTransactionReferenceDetailId
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
			, @dblOrigQty = dblOrigQty
			, @intContractStatusId = intContractStatusId
			, @intBookId = intBookId
			, @intSubBookId = intSubBookId
			, @strNotes = strNotes
			, @intUserId = intUserId
			, @intActionId = intActionId
			, @strProcess = strProcess
			, @ysnDeleted = ysnDeleted
		FROM #tmpLogItems

		DECLARE @intHeaderPricingTypeId INT = 0
		SELECT @intHeaderPricingTypeId = ISNULL(intPricingTypeId, 0) FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

		INSERT INTO @FinalTable(strBatchId
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
			, ysnDeleted)
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
			, ysnDeleted
		FROM #tmpLogItems WHERE intId = @Id
		AND NOT (@intHeaderPricingTypeId IN (1, 4, 5, 6, 7, 8) AND strTransactionType LIKE '%Basis Deliveries%')

		SET @intTransCtr += 1
		IF (@intTransCtr % 10000 = 0)
		BEGIN
			INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Processed ' + CAST(@intTransCtr AS NVARCHAR) + ' of ' + CAST(@intTotal AS NVARCHAR) + ' records.')
		END

		DELETE FROM #tmpLogItems WHERE intId = @Id
	END

	GOTO Logging

	BulkRebuild:

	SET @intTransCtr = @intTotal

	INSERT INTO @FinalTable(strBatchId
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
			, ysnDeleted)
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
			, ysnDeleted
		FROM #tmpLogItems

	Logging:
	
	INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Processed ' + CAST(@intTransCtr AS NVARCHAR) + ' of ' + CAST(@intTotal AS NVARCHAR) + ' records.')
	INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Starting Bulk Insert.')

	INSERT INTO tblCTContractBalanceLog(strBatchId
		, intActionId
		, strAction 
		, dtmTransactionDate
		, dtmCreatedDate
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
		, ysnNegated
		, intRefContractBalanceId
		, intUserId
		, strProcess
		, ysnDeleted)
	SELECT strBatchId
		, intActionId
		, strAction = A.strActionIn 
		, dtmTransactionDate
		, dtmCreatedDate = CASE WHEN @Rebuild = 1 THEN dtmTransactionDate ELSE GETUTCDATE() END
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
		, ysnNegated
		, intRefContractBalanceId
		, intUserId
		, strProcess
		, ysnDeleted
	FROM @FinalTable F
	LEFT JOIN tblRKLogAction A ON A.intLogActionId = F.intActionId

	INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Bulk Insert done.')

	DROP TABLE #tmpLogItems
END