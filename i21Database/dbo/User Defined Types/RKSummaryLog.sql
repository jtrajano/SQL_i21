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
	, strInOut NVARCHAR(50)
	, intOptionMonthId INT NULL
	, strOptionMonth NVARCHAR(20) NULL
	, dblStrike DECIMAL(24, 10) NULL
	, strOptionType NVARCHAR(10) NULL
	, strInstrumentType NVARCHAR(30) NULL
	, intBrokerageAccountId INT NULL
	, strBrokerAccount NVARCHAR(50) NULL
	, strBroker NVARCHAR(50) NULL
	, strBuySell NVARCHAR(10) NULL
	, ysnPreCrush BIT NULL
	, strBrokerTradeNo NVARCHAR(50) NULL
	, intMatchNo INT NULL
	, intMatchDerivativesHeaderId INT NULL
	, intMatchDerivativesDetailId INT NULL
	, strStorageTypeCode NVARCHAR(3) NULL
	, ysnReceiptedStorage BIT NULL
	, intTypeId INT NULL
	, strStorageType NVARCHAR(50) NULL
	, intDeliverySheetId INT NULL
	, strTicketStatus NVARCHAR(50) NULL
	, strOwnedPhysicalStock NVARCHAR(50) NULL
	, strStorageTypeDescription NVARCHAR(50) NULL
	, ysnActive BIT NULL
	, ysnExternal BIT NULL
	, intStorageHistoryId INT NULL
	, intInventoryReceiptItemId INT NULL
	, intLoadDetailId INT NULL
)