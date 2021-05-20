﻿CREATE TABLE [dbo].[tblSMAttachment] (
    [intAttachmentId]   INT              IDENTITY (1, 1) NOT NULL,
    [strName]           NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strFileType]       NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [strFileIdentifier] UNIQUEIDENTIFIER NOT NULL,
    [strScreen]         NVARCHAR (50)    COLLATE Latin1_General_CI_AS NOT NULL,
    [strComment]        NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [strRecordNo]       NVARCHAR (50)    COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]           NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL DEFAULT('attachment'), -- attachment, ocr
    [ysnOcrProcessed]   BIT NULL DEFAULT(0),
    [dtmDateModified]   DATETIME         NOT NULL,
    [intSize]           INT              NOT NULL,
    [intOptimizedSize]  INT              NULL,
    [intEntityId]       INT              NULL,
	[ysnDisableDelete]	BIT				 NULL,
    [intConcurrencyId]  INT              NOT NULL,
    CONSTRAINT [PK_dbo.tblAttachment] PRIMARY KEY CLUSTERED ([intAttachmentId] ASC)
)
GO

CREATE INDEX [IX_tblSMAttachment_strScreen] ON [dbo].[tblSMAttachment] ([strScreen])
GO

CREATE INDEX [IX_tblSMAttachment_strRecordNo] ON [dbo].[tblSMAttachment] ([strRecordNo])
GO








