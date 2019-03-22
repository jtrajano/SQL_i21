CREATE TABLE [dbo].[tblSMGridRow]
(
	[intGridRowId]					INT	 PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intCustomTabDetailId]		INT  NOT NULL,
	[intTransactionId]			INT  NOT NULL,
	[intSort]					INT	 NOT NULL DEFAULT (0),
    [intConcurrencyId]			INT	 NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMGridRow_tblSMCustomGridTab] FOREIGN KEY ([intCustomTabDetailId]) REFERENCES [tblSMCustomTabDetail]([intCustomTabDetailId]),
	CONSTRAINT [FK_tblSMGridRow_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]) ON DELETE CASCADE
)
