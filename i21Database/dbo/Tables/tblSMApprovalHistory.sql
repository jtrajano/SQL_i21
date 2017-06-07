CREATE TABLE [dbo].[tblSMApprovalHistory]
(
	[intApprovalHistoryId]			INT				NOT NULL PRIMARY KEY IDENTITY,
	[intApprovalId]					[int]			NOT NULL,
	[intEntityId]					[int]			NOT NULL,
	[ysnRejected]					[bit]			NULL DEFAULT(0),
	[ysnClosed]						[bit]			NULL DEFAULT(0),
	[ysnApproved]					[bit]			NULL DEFAULT(0),
	[ysnRead]						[bit]			NULL DEFAULT(0),
	[intConcurrencyId]				[int]			NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMApprovalHistory_tblSMApproval] FOREIGN KEY ([intApprovalId]) REFERENCES [tblSMApproval]([intApprovalId]) ON DELETE CASCADE, 
)
