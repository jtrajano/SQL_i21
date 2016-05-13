﻿CREATE TABLE [dbo].[tblSMApproval]
(
	[intApprovalId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intTransactionId] [int] NOT NULL,
	[intApproverId] [int] NULL,
	[strTransactionNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSubmittedById] [int] NOT NULL,
	[dblAmount] [numeric](18, 6) NOT NULL,
	[dtmDueDate] [datetime] NULL,
	[strStatus] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[ysnCurrent] [bit] NULL,
	[ysnEmailNotification] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMApproval_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]), 
    CONSTRAINT [FK_tblSMApproval_tblEMEntity_Approver] FOREIGN KEY ([intApproverId]) REFERENCES [tblEMEntity]([intEntityId]), 
    CONSTRAINT [FK_tblSMApproval_tblEMEntity_SubmitterBy] FOREIGN KEY ([intSubmittedById]) REFERENCES [tblEMEntity]([intEntityId])
)
