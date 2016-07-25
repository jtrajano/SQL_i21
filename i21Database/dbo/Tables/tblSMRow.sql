CREATE TABLE [dbo].[tblSMRow]
(
	[intRowId]					INT	 PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [intCustomTabDetailId]		INT  NOT NULL,
	[intTransactionId]			INT  NOT NULL,
	[intSort]					INT	 NOT NULL DEFAULT (0),
    [intConcurrencyId]			INT	 NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMRow_tblSMCustomGridTab] FOREIGN KEY ([intCustomTabDetailId]) REFERENCES [tblSMCustomTabDetail]([intCustomTabDetailId]),
	CONSTRAINT [FK_tblSMRow_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId])
)
