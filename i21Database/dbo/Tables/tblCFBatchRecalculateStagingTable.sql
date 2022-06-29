CREATE TABLE [dbo].[tblCFBatchRecalculateStagingTable] (
    [intBatchRecalculateId] INT             IDENTITY (1, 1) NOT NULL,
    [strBatchRecalculateId] NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intTransactionId]      INT             NULL,
    [strTransactionId]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intSiteId]             INT             NULL,
    [intNetworkId]          INT             NULL,
    [dtmTransactionDate]    DATETIME        NULL,
    [intCustomerId]         INT             NULL,
    [dblTotalAmount]        NUMERIC (18, 6) NULL,
    [strNetwork]            NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceMethod]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strStatus]             NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strNewPriceMethod]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [dblNewTotalAmount]     NUMERIC (18, 6) NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblCFBatchRecalculateStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFBatchRecalculateStagingTable] PRIMARY KEY CLUSTERED ([intBatchRecalculateId] ASC)
);

