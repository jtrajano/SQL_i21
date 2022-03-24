﻿CREATE TABLE [dbo].[tblRKSummaryLog]
(
	intSummaryLogId INT IDENTITY NOT NULL,
	strBatchId NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	dtmCreatedDate DATETIME NULL DEFAULT (GETUTCDATE()),
	strBucketType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intActionId INT NULL,
	strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intTransactionRecordId INT NULL,
	intTransactionRecordHeaderId INT NULL,
	strDistributionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	dtmTransactionDate DATETIME NULL,
	intContractDetailId INT NULL,
	intContractHeaderId INT NULL,
	intFutureMarketId INT NULL,
	intFutureMonthId INT NULL,
	intFutOptTransactionId INT NULL,
	intCommodityId INT NULL,
	intItemId INT NULL,
	intProductTypeId INT NULL,
	intOrigUOMId INT NULL,
	intBookId INT NULL,
	intSubBookId INT NULL,
	intLocationId INT NULL,
	strInOut NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	dblOrigNoOfLots DECIMAL(24, 10) NULL DEFAULT((0)),
	dblContractSize DECIMAL(24, 10) NULL DEFAULT((0)),
	dblOrigQty DECIMAL(24, 10) NULL DEFAULT((0)),
	dblPrice DECIMAL(24, 10) NULL DEFAULT((0)),
	intEntityId INT NULL,
	intTicketId INT NULL,
	intCurrencyId INT NULL,
	intUserId INT NULL, 
	strNotes NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	strMiscField NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnNegate] BIT NULL DEFAULT ((0)), 
    [intRefSummaryLogId] INT NULL,
	[intOptionMonthId] INT NULL,
	[strOptionMonth] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[dblStrike] DECIMAL(24, 10) NULL,
	[strOptionType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strInstrumentType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[intBrokerageAccountId] INT NULL,
	[strBrokerAccount] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strBroker] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strBuySell] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[ysnPreCrush] BIT NULL,
	[strBrokerTradeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intMatchNo] INT NULL,
	[intMatchDerivativesHeaderId] INT NULL,
	[intMatchDerivativesDetailId] INT NULL,
	[strStorageTypeCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[ysnReceiptedStorage] BIT NULL,
	[intTypeId] INT NULL,
	[strStorageType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intDeliverySheetId] INT NULL,
	[strTicketStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOwnedPhysicalStock] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strStorageTypeDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] BIT NULL,
	[ysnExternal] BIT NULL,
	[intStorageHistoryId] INT NULL,
	[intInventoryReceiptItemId] INT NULL,
	[intLoadDetailId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKSummaryLog] PRIMARY KEY ([intSummaryLogId])
)

GO

CREATE NONCLUSTERED INDEX [IX_tblRKSummaryLog_intTransactionRecordId] ON [dbo].[tblRKSummaryLog]
(
	[intTransactionRecordId]
)
INCLUDE (
	intTransactionRecordHeaderId
)
GO