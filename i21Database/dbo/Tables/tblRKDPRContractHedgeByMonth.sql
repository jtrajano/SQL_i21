﻿CREATE TABLE [dbo].[tblRKDPRContractHedgeByMonth]
(
	[intDPRContractHedgeByMonthId] INT IDENTITY NOT NULL , 
    [intDPRHeaderId] INT NOT NULL, 
	[intRowNumber] INT NULL,
    [strCommodityCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intContractHeaderId] INT NULL,
    [strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strInternalTradeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intFutOptTransactionHeaderId] INT NULL,
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strLocationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strContractEndMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strContractEndMonthNearBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblTotal] NUMERIC(24, 10) NULL,
    [strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strAccountNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strTranType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblNoOfLot] NUMERIC(24, 10) NULL,
    [dblDelta] NUMERIC(24, 10) NULL,
    [intBrokerageAccountId] INT NULL,
    [strInstrumentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strEntityName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intSeqNo] INT NULL,
    [intItemId] INT NULL,
    [strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intCategoryId] INT NULL,
    [strCategory] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intFutureMarketId] INT NULL,
    [strFutureMarket] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intFutureMonthId] INT NULL,
    [strFutureMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strDeliveryDate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strBrokerTradeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strNotes] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [ysnCrush] BIT NULL DEFAULT((0)),
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKDPRContractHedgeByMonth] PRIMARY KEY ([intDPRContractHedgeByMonthId]), 
    CONSTRAINT [FK_tblRKDPRContractHedgeByMonth_tblRKDPRHeader] FOREIGN KEY ([intDPRHeaderId]) REFERENCES [tblRKDPRHeader]([intDPRHeaderId]) ON DELETE CASCADE
)
GO

CREATE NONCLUSTERED INDEX [IX_tblRKDPRContractHedgeByMonth_intDPRHeaderId]
	ON [dbo].[tblRKDPRContractHedgeByMonth] ([intDPRHeaderId]);   
GO  
