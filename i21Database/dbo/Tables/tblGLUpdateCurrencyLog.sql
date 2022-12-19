CREATE TABLE [dbo].[tblGLUpdateCurrencyLog]
(
	[intUpdateCurrencyLogId] INT IDENTITY(1, 1) NOT NULL,
	[intEntityId] INT NULL,
	[intAccountId] INT NULL,
	[intOldCurrencyId] INT NULL,
	[intNewCurrencyId] INT NULL,
	[strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] DATETIME,
	[intConcurrencyId] INT DEFAULT 1 NOT NULL

	CONSTRAINT [PK_tblGLUpdateCurrencyLog] PRIMARY KEY CLUSTERED ([intUpdateCurrencyLogId] ASC)
)
