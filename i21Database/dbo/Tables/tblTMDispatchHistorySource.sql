CREATE TABLE [dbo].[tblTMDispatchHistorySource] (
    [intDispatchHistorySourceId]	INT				IDENTITY (1, 1) NOT NULL,
    [intDispatchSyncId]				INT				NOT NULL,
    [intSourceType]					INT				NOT NULL,		--	Valid Values
																	--	1-"Invoice"
																	--	2-"Transport Load"
	[intConcurrencyId]				INT				DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMDispatchHistorySource] PRIMARY KEY CLUSTERED ([intDispatchHistorySourceId] ASC),
    CONSTRAINT [FK_tblTMDispatchHistorySource_tblTMDispatchHistory_intDispatchSyncId] FOREIGN KEY ([intDispatchSyncId]) REFERENCES [tblTMDispatchHistory]([intDispatchSyncId]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_tblTMDispatchHistorySource_intDispatchSyncId] ON [dbo].[tblTMDispatchHistorySource] ([intDispatchSyncId]) 

GO