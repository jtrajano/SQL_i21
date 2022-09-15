CREATE TABLE [dbo].[tblGLLedgerAccount]
(
	[intLedgerAccountId]	INT IDENTITY(1, 1) NOT NULL,
	[intLedgerId]			INT NOT NULL,
	[intAccountId]			INT NOT NULL,
	[ysnRequireSubledger]	BIT DEFAULT(0) NOT NULL,
    [intConcurrencyId]		INT DEFAULT(1) NOT NULL,

    CONSTRAINT [PK_tblGLLedgerAccount] PRIMARY KEY CLUSTERED ([intLedgerAccountId] ASC),
	CONSTRAINT [FK_tblGLLedgerAccount_tblGLLedger] FOREIGN KEY ([intLedgerId]) REFERENCES [dbo].[tblGLLedger]([intLedgerId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGLLedgerAccount_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount]([intAccountId])
)
