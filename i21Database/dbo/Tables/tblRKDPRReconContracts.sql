﻿CREATE TABLE [dbo].[tblRKDPRReconContracts]
(
	[intDPRReconContractId] INT IDENTITY NOT NULL, 
	[intDPRReconHeaderId] INT NOT NULL, 
	[intSort] INT NOT NULL,
	[strLocationName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCommodityCode] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strContractType] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[strContractStatus] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[strContractNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[intContractSeq] INT NULL,
	[strItemNo] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreatedDate] DATETIME NOT NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
	[dblQty] NUMERIC(24, 10) NOT NULL,
	[strUnitMeasure] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strUserName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strBucketName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strAction] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPricingType] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
	[strTicketNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
	[strLoadNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
	[dblLoadQty] NUMERIC(24, 10) NULL,
	[dblReceivedQty] NUMERIC(24, 10) NULL,
	[dblCash] NUMERIC(24, 10) NULL,
	[intContractHeaderId] INT NULL,
	[intTicketId] INT NULL,
	[intLoadId] INT NULL,
	[strDistribution] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
	[strStorageSchedule] NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
	[strSettlementTicket] NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
	[strStatus] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKDPRReconContracts] PRIMARY KEY ([intDPRReconContractId]), 
    CONSTRAINT [FK_tblRKDPRReconContracts_tblRKDPRHeader] FOREIGN KEY ([intDPRReconHeaderId]) REFERENCES [tblRKDPRReconHeader]([intDPRReconHeaderId]) ON DELETE CASCADE
)