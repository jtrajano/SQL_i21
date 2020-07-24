CREATE TYPE [dbo].[RKSummaryLog] AS TABLE (
	intId INT IDENTITY PRIMARY KEY CLUSTERED
	, strBatchId NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strBucketType NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, intTransactionRecordId INT NULL
	, intTransactionRecordHeaderId INT NULL
	, strDistributionType NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strTransactionNumber NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, dtmTransactionDate DATETIME NOT NULL
	, intContractDetailId INT NULL
	, intContractHeaderId INT NULL
	, intFutOptTransactionId INT NULL
	, intTicketId INT NULL
	, intCommodityId INT NULL
	, intCommodityUOMId INT NULL
	, intItemId INT NULL
	, intBookId INT NULL
	, intSubBookId INT NULL
	, intLocationId INT NULL
	, intFutureMarketId INT
	, intFutureMonthId INT
	, dblNoOfLots DECIMAL(24, 10) NULL DEFAULT((0))
	, dblQty DECIMAL(24, 10) NULL DEFAULT((0))
	, dblPrice DECIMAL(24, 10) NULL DEFAULT((0))
	, dblContractSize DECIMAL(24, 10) NULL DEFAULT((0))
	, intEntityId INT NULL
	, ysnDelete BIT NULL DEFAULT((0))
	, intCurrencyId INT NULL
	, intUserId INT NULL
	, strNotes NVARCHAR(250) NULL
	, strMiscFields NVARCHAR(MAX) NULL
	, intActionId INT NULL
)