CREATE TABLE [dbo].[tblCRMJiraIssue]
(
	[intJiraIssueId] [int] IDENTITY(1,1) NOT NULL,
	[strJiraKey] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMJiraIssue_intJiraIssueId] PRIMARY KEY CLUSTERED ([intJiraIssueId] ASC),
	CONSTRAINT [FK_tblCRMJiraIssue_tblSMTransaction_intTransactionId] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblSMTransaction] ([intTransactionId]),
	CONSTRAINT [UQ_tblCRMJiraIssue_intTransactionId_strJiraKey] UNIQUE ([intTransactionId],[strJiraKey])
)
