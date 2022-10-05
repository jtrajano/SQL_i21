CREATE TABLE [dbo].[tblGLLedgerDetail]
(
	[intLedgerDetailId]	INT IDENTITY(1, 1) NOT NULL,
	[intLedgerId]		INT NOT NULL,
	[strLedgerName]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnActive]			BIT DEFAULT(1) NOT NULL,
    [intConcurrencyId]	INT DEFAULT(1) NOT NULL,

    CONSTRAINT [PK_tblGLLedgerDetail] PRIMARY KEY CLUSTERED ([intLedgerDetailId] ASC),
	CONSTRAINT [FK_tblGLLedgerDetail_tblGLLedger] FOREIGN KEY ([intLedgerId]) REFERENCES [dbo].[tblGLLedger]([intLedgerId]) ON DELETE CASCADE
)
