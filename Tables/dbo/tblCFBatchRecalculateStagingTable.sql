CREATE TABLE [dbo].[tblCFBatchRecalculateStagingTable] (
    [intBatchRecalculateId] INT             IDENTITY (1, 1) NOT NULL,
    [strBatchRecalculateId] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTransactionId]      INT             NULL,
    [strTransactionId]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intSiteId]             INT             NULL,
    [intNetworkId]          INT             NULL,
    [dtmTransactionDate]    DATETIME        NULL,
    [intCustomerId]         INT             NULL,
    [dblTotalAmount]        NUMERIC (18, 6) NULL,
    [strNetwork]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPriceMethod]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strStatus]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNewPriceMethod]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblNewTotalAmount]     NUMERIC (18, 6) NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblCFBatchRecalculateStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFBatchRecalculateStagingTable] PRIMARY KEY CLUSTERED ([intBatchRecalculateId] ASC)
);

