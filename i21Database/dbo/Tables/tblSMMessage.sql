CREATE TABLE [dbo].[tblSMMessage](
	[intMessageId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[strSubject] [nvarchar](max) NULL,
	[dtmAdded] [datetime] NULL DEFAULT (GETDATE()),
	[dtmModified] [datetime] NULL DEFAULT (GETDATE()),
	[intConcurrencyId] [int] NOT NULL
	CONSTRAINT [PK_tblSMMessage] PRIMARY KEY ([intMessageId])
 )