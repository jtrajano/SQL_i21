﻿CREATE TABLE [dbo].[tblSMApprovalAmendmentLog]
(
	[intApprovalAmendmentLogId]		INT              IDENTITY (1, 1)				NOT NULL,
	[intTransactionId]				[int]											NOT NULL,
	[intApprovalId]					[int]											NULL,
	[strModifiedField]				[nvarchar](250) COLLATE Latin1_General_CI_AS	NOT NULL,
	[strOldValue]					[nvarchar](max) COLLATE Latin1_General_CI_AS	NOT NULL,
	[strNewValue]					[nvarchar](max) COLLATE Latin1_General_CI_AS	NOT NULL,
	[intEntityId]					[int]											NOT NULL,
	[dtmDate]						[datetime]										NOT NULL,
	[intContractSeq]					[int]											NULL,
	[intConcurrencyId]				[int]											NOT NULL DEFAULT (1), 
	CONSTRAINT [PK_tblSMApprovalAmendmentLog] PRIMARY KEY CLUSTERED ([intApprovalAmendmentLogId] ASC),
	CONSTRAINT [FK_tblSMApprovalAmendmentLog_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]) ON DELETE CASCADE
)
