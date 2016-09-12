CREATE TABLE [dbo].[tblSMTabRow]
(
	[intTabRowId]				INT	 PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intCustomTabId]			INT  NOT NULL,
	[intTransactionId]			INT  NOT NULL,
	[intSort]					INT	 NOT NULL DEFAULT (0),
    [intConcurrencyId]			INT	 NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMTabRow_tblSMCustomTab] FOREIGN KEY ([intCustomTabId]) REFERENCES [tblSMCustomTab]([intCustomTabId]),
	CONSTRAINT [FK_tblSMTabRow_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]) ON DELETE CASCADE
)


