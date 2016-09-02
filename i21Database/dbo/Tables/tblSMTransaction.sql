CREATE TABLE [dbo].[tblSMTransaction]
(
	[intTransactionId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intScreenId] [int] NOT NULL DEFAULT ((1)),
	[strRecordNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL, 
	[dtmDate] DATETIME NULL, 
	[strApprovalStatus] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMTransaction_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]),
	CONSTRAINT [UC_Screen_Transaction] UNIQUE (intScreenId, strRecordNo)
)
