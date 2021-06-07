CREATE TABLE [dbo].[tblSMIDPProcessResult] (
    [intIDPProcessResultId]				INT IDENTITY (1, 1) NOT NULL,
    [intAttachmentId]					INT NOT NULL,
	[strBatchNo]						NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strResult]							NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strMessage]						NVARCHAR (500) COLLATE Latin1_General_CI_AS NOT NULL,
    [intRecordNo]						INT NULL,
    [intEntityId]						INT NULL,
	[dblTotal]							DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[intUserId]							INT NULL,
	[dtmDateTime]						DATETIME NULL,
    [intConcurrencyId]					INT DEFAULT (1) NOT NULL,

    CONSTRAINT [PK_tblSMIDPProcessResult] PRIMARY KEY CLUSTERED ([intIDPProcessResultId] ASC),
    CONSTRAINT [FK_tblSMIDPProcessResult_tblSMAttachment] FOREIGN KEY ([intAttachmentId]) REFERENCES [dbo].[tblSMAttachment] ([intAttachmentId])
);

