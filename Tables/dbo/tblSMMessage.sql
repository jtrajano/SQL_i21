CREATE TABLE [dbo].[tblSMMessage](
	[intMessageId]     INT              IDENTITY (1, 1) NOT NULL,
	[intEntityId]      INT              NULL,
	[strSubject]       NVARCHAR(MAX)    COLLATE Latin1_General_CI_AS NULL,
	[dtmAdded]         DATETIME DEFAULT (GETDATE()) NULL,
	[dtmModified]      DATETIME DEFAULT (GETDATE()) NULL,
	[intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblSMMessage] PRIMARY KEY ([intMessageId])
 )