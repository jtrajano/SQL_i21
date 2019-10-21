CREATE TABLE [dbo].[tblCFEncodeCardStagingTable] (
    [intEncodeCardStagingTableId]			INT            IDENTITY (1, 1) NOT NULL,
    [intEncodeCardId]						INT            NOT NULL,
    [intUserId]								INT			   NOT NULL,
	[intConcurrencyId]						INT            NULL,
    CONSTRAINT [PK_tblCFEncodeCardStagingTable] PRIMARY KEY CLUSTERED ([intEncodeCardStagingTableId] ASC)
);