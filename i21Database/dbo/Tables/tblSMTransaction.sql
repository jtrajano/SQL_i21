CREATE TABLE [dbo].[tblSMTransaction]
(
	[intTransactionId]		INT													NOT NULL  IDENTITY,
	[intScreenId]			[int]												NOT NULL DEFAULT ((1)),
	[strTransactionNo]		[nvarchar](50)	COLLATE Latin1_General_CI_AS		NULL,
	[intEntityId]			[int]												NULL, 
	[dtmDate]				DATETIME											NULL, 
	[strApprovalStatus]		[nvarchar](150) COLLATE Latin1_General_CI_AS		NULL,
	[intConcurrencyId]		[int]												NOT NULL DEFAULT ((1)), 
	[intRecordId]			[int]												NOT NULL,
	[dblAmount]				[numeric](18, 6)									NULL,
	[strCurrency]			[nvarchar](50)	COLLATE Latin1_General_CI_AS		NULL,
    CONSTRAINT [FK_tblSMTransaction_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]),
    CONSTRAINT [PK_tblSMTransaction] PRIMARY KEY ([intTransactionId]), 
    CONSTRAINT [UC_tblSMTransaction_intScreenId_intRecordId] UNIQUE ([intScreenId] ASC, [intRecordId] ASC)
)