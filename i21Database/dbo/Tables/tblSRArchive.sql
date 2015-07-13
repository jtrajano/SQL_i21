CREATE TABLE [dbo].[tblSRArchive]
(
	[intArchiveId] [int] NOT NULL IDENTITY(1, 1),
	[dtmDateTime] [datetime] NOT NULL,
	[intUserId] [int] NOT NULL,
	[strUserName] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
	[strDocumentKey] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
	[strName] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
	[strDisplayName] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
	[blbReport] [varbinary] (max) NULL,
	[ysnIsActive] [bit] NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblSRArchive] PRIMARY KEY CLUSTERED ([intArchiveId] ASC)
)
