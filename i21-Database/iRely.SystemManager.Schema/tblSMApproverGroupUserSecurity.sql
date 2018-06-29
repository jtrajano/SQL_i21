CREATE TABLE [dbo].[tblSMApproverGroupUserSecurity]
(
	[intApproverGroupUserSecurityId]		INT				NOT NULL PRIMARY KEY IDENTITY, 
    [intApproverGroupId]					INT				NOT NULL, 
    [intEntityUserSecurityId]				INT				NOT NULL, 
	[intApproverLevel]						INT				NOT NULL DEFAULT 1,
	[ysnEmailApprovalRequest]				BIT				NOT NULL DEFAULT 0,
	[intSort]								INT				NOT NULL DEFAULT 0,
    [intConcurrencyId]						INT				NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMApproverGroupUserSecurity_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES tblSMUserSecurity([intEntityId]),
	
)
