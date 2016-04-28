CREATE TABLE [dbo].[tblSMApproval]
(
	[intApprovalId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intTransactionId] [int] NOT NULL,
	[intApproverId] [int] NULL,
	[strTransactionNumber] [nvarchar](50) NOT NULL,
	[intSubmittedById] [int] NOT NULL,
	[dblAmount] [numeric](18, 6) NOT NULL,
	[dtmDueDate] [datetime] NOT NULL,
	[strStatus] [nvarchar](15) NOT NULL,
	[strComment] [nvarchar](max) NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMApproval_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]), 
    CONSTRAINT [FK_tblSMApproval_tblEMEntity_Approver] FOREIGN KEY ([intApproverId]) REFERENCES [tblEMEntity]([intEntityId]), 
    CONSTRAINT [FK_tblSMApproval_tblEMEntity_SubmitterBy] FOREIGN KEY ([intSubmittedById]) REFERENCES [tblEMEntity]([intEntityId])
)
