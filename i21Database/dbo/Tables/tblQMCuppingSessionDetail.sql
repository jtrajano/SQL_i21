CREATE TABLE [dbo].[tblQMCuppingSessionDetail]
(
	[intCuppingSessionDetailId] 	INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] 				INT NULL DEFAULT ((1)),
	[intCuppingSessionId] 			INT NOT NULL,
	[intSampleId] 					INT NOT NULL,
	[intRank] 						INT NOT NULL,

	CONSTRAINT [PK_tblQMCuppingSessionDetail] PRIMARY KEY ([intCuppingSessionDetailId]),
    CONSTRAINT [FK_tblQMCuppingSessionDetail_tblQMCuppingSession_intCuppingSessionId] FOREIGN KEY ([intCuppingSessionId]) REFERENCES [tblQMCuppingSession]([intCuppingSessionId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblQMCuppingSessionDetail_tblQMSample_intSampleId] FOREIGN KEY ([intSampleId]) REFERENCES [tblQMSample]([intSampleId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMCuppingSessionDetail_intCuppingSessionId] ON [dbo].[tblQMCuppingSessionDetail](intCuppingSessionId)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMCuppingSessionDetail_intSampleId] ON [dbo].[tblQMCuppingSessionDetail](intSampleId)
GO