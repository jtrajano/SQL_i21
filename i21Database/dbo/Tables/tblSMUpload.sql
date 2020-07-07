CREATE TABLE [dbo].[tblSMUpload] (
    [intUploadId]       INT              IDENTITY (1, 1) NOT NULL,
    [intAttachmentId]   INT              NULL,
    [strFileIdentifier] UNIQUEIDENTIFIER NOT NULL,
    [blbFile]           VARBINARY (MAX)  NULL,
    [dtmDateUploaded]   DATETIME         NOT NULL,
    [intConcurrencyId]  INT              NOT NULL,
    CONSTRAINT [PK_tblUpload] PRIMARY KEY CLUSTERED ([intUploadId] ASC),
    CONSTRAINT [FK_tblSMUpload_tblSMAttachment] FOREIGN KEY ([intAttachmentId]) REFERENCES [dbo].[tblSMAttachment] ([intAttachmentId]) ON DELETE CASCADE
);

GO

CREATE INDEX [IX_tblSMUpload_intAttachmentId] ON [dbo].[tblSMUpload] ([intAttachmentId]) INCLUDE([blbFile])
