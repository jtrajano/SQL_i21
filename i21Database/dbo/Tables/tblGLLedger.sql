CREATE TABLE [dbo].[tblGLLedger]
(
	[intLedgerId]		INT IDENTITY (1, 1) NOT NULL,
	[strLedgerName]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]	INT DEFAULT 1 NOT NULL,

    CONSTRAINT [PK_tblGLLedger] PRIMARY KEY CLUSTERED ([intLedgerId] ASC)
)
