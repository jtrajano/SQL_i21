CREATE TABLE [dbo].[tblSMComment] (
    [intCommentId]		INT IDENTITY(1,1) NOT NULL,
	[strComment]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strScreen]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmAdded]			DATETIME DEFAULT (GETDATE()) NULL,
	[dtmModified]		DATETIME DEFAULT (GETDATE()) NULL,
	[intEntityId]		INT NULL,
	[intConcurrencyId]	INT NOT NULL,
    CONSTRAINT [PK_tblSMComment] PRIMARY KEY CLUSTERED ([intCommentId] ASC)
);