CREATE TABLE [dbo].[tblSMAttachmentDetailLink] (
    [intAttachmentDetailLinkId]   INT    IDENTITY (1, 1) NOT NULL,
    [strKey]					  NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strRecordNo]				  NVARCHAR (50)    COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDateLink]				  DATETIME         NOT NULL,
	[intEntityId]				  INT              NULL,
    [intAttachmentId]			  INT              NULL,
    [intConcurrencyId]			  INT              NOT NULL,
    CONSTRAINT [PK_dbo.tblSMAttachmentDetailLink] PRIMARY KEY CLUSTERED ([intAttachmentDetailLinkId] ASC),
    CONSTRAINT [FK_tblSMAttachmentDetailLink_tblSMAttachment] FOREIGN KEY ([intAttachmentId]) REFERENCES [dbo].[tblSMAttachment] ([intAttachmentId]) ON DELETE CASCADE
);







