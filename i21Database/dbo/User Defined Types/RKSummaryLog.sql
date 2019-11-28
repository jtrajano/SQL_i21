CREATE TYPE [dbo].[RKSummaryLog] AS TABLE (
	intId INT IDENTITY PRIMARY KEY CLUSTERED
	, strTransactionType NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL
	, intTransactionRecordId INT NOT NULL
	, strTransactionNumber NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, dtmTransactionDate DATETIME
	, intContractDetailId INT NULL
	, intContractHeaderId INT NULL
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
	, intEntityId INT NULL
	, ysnDelete BIT NULL DEFAULT((0))
	, intUserId INT NULL
	, strNotes NVARCHAR(250) NULL
)