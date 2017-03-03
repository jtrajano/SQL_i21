CREATE TABLE [dbo].[tblSMApprovalListUserSecurity]
(
	[intApprovalListUserSecurityId]			INT				NOT NULL PRIMARY KEY IDENTITY, 
    [intApprovalListId]						INT				NOT NULL, 
    [intEntityUserSecurityId]				INT				NULL, 
	[intApproverLevel]						INT				NOT NULL DEFAULT 1,
	[intAlternateEntityUserSecurityId]		INT				NULL, 
	[intApproverGroupId]					INT				NULL, 
	[dblAmountOver]							NUMERIC(18, 6)	NOT NULL DEFAULT 0,
	[dblAmountLessThanEqual]				NUMERIC(18, 6)	NOT NULL DEFAULT 0,
	[ysnEmailApprovalRequest]				BIT				NOT NULL DEFAULT 0,
	[intSort]								INT				NOT NULL DEFAULT 0,
    [intConcurrencyId]						INT				NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMApprovalListUserSecurity_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES tblSMUserSecurity([intEntityUserSecurityId]),
	CONSTRAINT [FK_tblSMApprovalListUserSecurity_tblSMUserSecurity_Alternate] FOREIGN KEY ([intAlternateEntityUserSecurityId]) REFERENCES tblSMUserSecurity([intEntityUserSecurityId]), 
    CONSTRAINT [FK_tblSMApprovalListUserSecurity_tblSMApproverGroup] FOREIGN KEY ([intApproverGroupId]) REFERENCES [tblSMApproverGroup]([intApproverGroupId])
)
