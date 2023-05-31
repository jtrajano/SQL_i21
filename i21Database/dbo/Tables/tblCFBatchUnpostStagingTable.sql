CREATE TABLE [dbo].[tblCFBatchUnpostStagingTable] (
    [intBatchUnpostStagingTableId] INT            IDENTITY (1, 1) NOT NULL,
    [intTransactionId]             INT            NULL,
    [strTransactionId]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strGuid]                      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmTransactionDate]           DATETIME       NULL,
    [dtmPostedDate]                DATETIME       NULL,
    [intNetworkId]                 INT            NULL,
    [strNetworkId]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS  NULL,
    [intSiteId]                    INT            NULL,
    [strSiteId]                    NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId]                INT            NULL,
    [strCustomerNumber]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCustomerName]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intItemId]                    INT            NULL,
    [strItemId]                    NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strResult]                    NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]             INT            CONSTRAINT [DF_tblCFBatchUnpostStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFBatchUnpostStagingTable] PRIMARY KEY CLUSTERED ([intBatchUnpostStagingTableId] ASC) WITH (FILLFACTOR = 70)
);


