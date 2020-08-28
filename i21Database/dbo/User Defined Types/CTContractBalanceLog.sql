CREATE TYPE [dbo].[CTContractBalanceLog] AS TABLE (
	intId INT IDENTITY PRIMARY KEY CLUSTERED
	, strBatchId NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, dtmTransactionDate DATETIME NOT NULL
	, strTransactionType NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strTransactionReference NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, intTransactionReferenceId INT NOT NULL
	, intTransactionReferenceDetailId INT NULL
	, strTransactionReferenceNo NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
	, intContractDetailId INT NOT NULL
	, intContractHeaderId INT NOT NULL
	, strContractNumber NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
	, intContractSeq INT NOT NULL
    , intContractTypeId INT NOT NULL
    , intEntityId INT NOT NULL
    , intCommodityId INT NOT NULL
	, intItemId INT NOT NULL
	, intLocationId INT NULL
	, intPricingTypeId INT NOT NULL
	, intFutureMarketId INT NULL
	, intFutureMonthId INT NULL
	, dblBasis NUMERIC(24, 10) NULL DEFAULT((0))
	, dblFutures NUMERIC(24, 10) NULL DEFAULT((0))
	, intQtyUOMId INT NULL
	, intQtyCurrencyId INT NULL
	, intBasisUOMId INT NULL
	, intBasisCurrencyId INT NULL
	, intPriceUOMId INT NULL
	, dtmStartDate DATETIME
	, dtmEndDate DATETIME
	, dblQty NUMERIC(24, 10) NULL DEFAULT((0))
	, intContractStatusId INT NOT NULL
	, intBookId INT NULL
	, intSubBookId INT NULL
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intUserId INT NULL
	, intActionId INT NULL
	, strProcess NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	-- Dynamic value
	, dblDynamic NUMERIC(24, 10) NULL DEFAULT((0))
)