CREATE TABLE [dbo].[tblCFBatchUnpostStagingTable](
	[intBatchUnpostStagingTableId]		int IDENTITY(1,1) NOT NULL,
	[intTransactionId]					int NULL,
	[strTransactionId]					nvarchar (max) NULL,
	[strGuid]							nvarchar (max) NULL,
	[strResult]							nvarchar (max) NULL,
	[intConcurrencyId]					int CONSTRAINT [DF_tblCFBatchUnpostStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
 CONSTRAINT [PK_tblCFBatchUnpostStagingTable] PRIMARY KEY CLUSTERED ([intBatchUnpostStagingTableId] ASC
);