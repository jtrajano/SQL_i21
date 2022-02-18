CREATE TABLE [dbo].[tblSMTransaction]
(
	[intTransactionId]				INT													NOT NULL  IDENTITY,
	[intScreenId]					[int]												NOT NULL DEFAULT ((1)),
	[strTransactionNo]				[nvarchar](500)	COLLATE Latin1_General_CI_AS		NULL,
	[intEntityId]					[int]												NULL, 
	[dtmDate]						DATETIME											NULL, 
	[strApprovalStatus]				[nvarchar](150) COLLATE Latin1_General_CI_AS		NULL,
	[intRecordId]					[int]												NOT NULL,
	[dblAmount]						[numeric](18, 6)									NULL,
	[ysnLocked]						[bit]												NULL,
	[ysnOnceApproved]				[bit]												NULL,	
	[intApprovalForId]				[int]												NULL,
	[strApprovalFor]				[nvarchar](150) COLLATE Latin1_General_CI_AS		NULL,
	[ysnApprovalUseAlternateId]		[bit]											NULL,
	[dtmLockedDate]					DATETIME											NULL,
	[intLockedBy]					[int]												NULL,
	[intCurrencyId]					[int]												NULL,
	[strName]						[nvarchar](200) COLLATE Latin1_General_CI_AS		NULL,
	[strDescription]				[nvarchar](MAX) COLLATE Latin1_General_CI_AS		NULL,
	[intConcurrencyId]				[int]												NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMTransaction_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]),
    CONSTRAINT [PK_tblSMTransaction] PRIMARY KEY ([intTransactionId]), 
	CONSTRAINT [FK_tblSMTransaction_tblEMEntity] FOREIGN KEY ([intLockedBy]) REFERENCES [tblEMEntity]([intEntityId]),
    CONSTRAINT [UC_tblSMTransaction_intScreenId_intRecordId] UNIQUE ([intScreenId] ASC, [intRecordId] ASC)
)
GO

CREATE INDEX [IX_tblSMTransaction_intScreenId] ON [dbo].[tblSMTransaction] ([intScreenId])
GO

CREATE INDEX [IX_tblSMTransaction_intRecordId] ON [dbo].[tblSMTransaction] ([intRecordId])
GO