CREATE TABLE [dbo].[tblSMCustomGridRow]
(
	[intCustomGridRowId]        INT             PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intCustomGridTabId]		INT             NOT NULL,
	[intTransactionId]			INT             NOT NULL,
	[intSort]					INT             NOT NULL DEFAULT (0),
    [intConcurrencyId]			INT				NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMCustomGridRow_tblSMCustomGridTab] FOREIGN KEY ([intCustomGridTabId]) REFERENCES [tblSMCustomGridTab]([intCustomGridTabId]),
	CONSTRAINT [FK_tblSMCustomGridRow_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId])
)
