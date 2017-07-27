CREATE TABLE [dbo].[tblCFBatchRecalculateStagingTable] (
    [intBatchRecalculateId] INT             IDENTITY (1, 1) NOT NULL,
    [strBatchRecalculateId] NVARCHAR (MAX)  NULL,
    [intTransactionId]      INT             NULL,
    [strTransactionId]      NVARCHAR (MAX)  NULL,
    [intSiteId]             INT             NULL,
    [intNetworkId]          INT             NULL,
    [dtmTransactionDate]    DATETIME        NULL,
    [intCustomerId]         INT             NULL,
    [dblTotalAmount]        NUMERIC (18, 6) NULL,
    [strNetwork]            NVARCHAR (MAX)  NULL,
    [strPriceMethod]        NVARCHAR (MAX)  NULL,
    [strStatus]             NVARCHAR (MAX)  NULL,
    [strNewPriceMethod]     NVARCHAR (MAX)  NULL,
    [dblNewTotalAmount]     NUMERIC (18, 6) NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblCFBatchRecalculateStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFBatchRecalculateStagingTable] PRIMARY KEY CLUSTERED ([intBatchRecalculateId] ASC)
);

