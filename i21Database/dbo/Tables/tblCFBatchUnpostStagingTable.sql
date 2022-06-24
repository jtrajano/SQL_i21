CREATE TABLE [dbo].[tblCFBatchUnpostStagingTable] (
    [intBatchUnpostStagingTableId] INT            IDENTITY (1, 1) NOT NULL,
    [intTransactionId]             INT            NULL,
    [strTransactionId]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strGuid]                      NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [dtmTransactionDate]           DATETIME       NULL,
    [dtmPostedDate]                DATETIME       NULL,
    [intNetworkId]                 INT            NULL,
    [strNetworkId]                 NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
    [intSiteId]                    INT            NULL,
    [strSiteId]                    NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId]                INT            NULL,
    [strCustomerNumber]            NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strCustomerName]              NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intItemId]                    INT            NULL,
    [strItemId]                    NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strResult]                    NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]             INT            CONSTRAINT [DF_tblCFBatchUnpostStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFBatchUnpostStagingTable] PRIMARY KEY CLUSTERED ([intBatchUnpostStagingTableId] ASC) WITH (FILLFACTOR = 70)
);


