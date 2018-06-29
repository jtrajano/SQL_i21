CREATE TABLE [dbo].[tblSMApproverConfigurationForApprovalGroup]
(
	[intApproverConfigurationForApprovalGroupId]		INT												NOT NULL	PRIMARY KEY IDENTITY, 
    [intApprovalId]										INT												NOT NULL, 
	[intApproverId]										INT												NOT NULL, 
	[intConcurrencyId]									INT												NOT NULL	DEFAULT 1, 
	CONSTRAINT [FK_tblSMApproverConfigurationForApprovalGroup_tblSMApproval] FOREIGN KEY ([intApprovalId]) REFERENCES [tblSMApproval]([intApprovalId]) ON DELETE CASCADE
    
)
