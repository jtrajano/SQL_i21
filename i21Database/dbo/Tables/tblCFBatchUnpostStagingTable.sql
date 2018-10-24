CREATE TABLE [dbo].[tblCFBatchUnpostStagingTable] (
    [intBatchUnpostStagingTableId] INT            IDENTITY (1, 1) NOT NULL,
    [intTransactionId]             INT            NULL,
    [strTransactionId]             NVARCHAR (MAX) NULL,
    [strGuid]                      NVARCHAR (MAX) NULL,
    [dtmTransactionDate]           DATETIME       NULL,
    [dtmPostedDate]                DATETIME       NULL,
    [intNetworkId]                 INT            NULL,
    [strNetworkId]                 NVARCHAR (MAX) NULL,
    [intSiteId]                    INT            NULL,
    [strSiteId]                    NVARCHAR (MAX) NULL,
    [intCustomerId]                INT            NULL,
    [strCustomerNumber]            NVARCHAR (MAX) NULL,
    [strCustomerName]              NVARCHAR (MAX) NULL,
    [intItemId]                    INT            NULL,
    [strItemId]                    NVARCHAR (MAX) NULL,
    [strResult]                    NVARCHAR (MAX) NULL,
    [intConcurrencyId]             INT            CONSTRAINT [DF_tblCFBatchUnpostStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFBatchUnpostStagingTable] PRIMARY KEY CLUSTERED ([intBatchUnpostStagingTableId] ASC) WITH (FILLFACTOR = 70)
);


