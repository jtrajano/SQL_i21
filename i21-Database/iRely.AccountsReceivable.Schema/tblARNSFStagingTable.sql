CREATE TABLE [dbo].[tblARNSFStagingTable]
(
	[intNSFTransactionId]		INT				IDENTITY (1, 1) NOT NULL,
	[intEntityId]				INT				NULL,	
	[intConcurrencyId]			INT				NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARNSFStagingTable_intNSFTransactionId] PRIMARY KEY CLUSTERED ([intNSFTransactionId] ASC)
)
