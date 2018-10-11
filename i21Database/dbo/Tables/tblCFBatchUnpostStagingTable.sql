CREATE TABLE [dbo].[tblCFBatchUnpostStagingTable](
	[intBatchUnpostStagingTableId]		INT IDENTITY(1,1) NOT NULL,
	[intTransactionId]					INT NULL,
	[strTransactionId]					NVARCHAR (max) NULL,
	[strGuid]							NVARCHAR (max) NULL,
	[strResult]							NVARCHAR (max) NULL,
	[intConcurrencyId]					INT CONSTRAINT [DF_tblCFBatchUnpostStagingTable_intConcurrencyId] DEFAULT ((1)) NULL,
 CONSTRAINT [PK_tblCFBatchUnpostStagingTable] PRIMARY KEY CLUSTERED ([intBatchUnpostStagingTableId] ASC)
);
