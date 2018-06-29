CREATE TABLE [dbo].[tblSMTransactionLockHistory]
(
	[intTransactionLockHistoryId]	INT											NOT NULL IDENTITY,
	[intTransactionId]				[int]										NOT NULL,
	[intEntityId]					[int]										NULL, 
	[dtmDate]						DATETIME									NULL, 
	[strAction]						[nvarchar](50) COLLATE Latin1_General_CI_AS	NULL,
	[intConcurrencyId]				[int]										NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMTransactionLockHistory_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblSMTransactionLockHistory_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
    CONSTRAINT [PK_tblSMTransactionLockHistory] PRIMARY KEY ([intTransactionLockHistoryId])
)