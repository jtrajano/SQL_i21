CREATE TABLE [dbo].[tblSMApprovalListUserSecurity]
(
	[intApprovalListUserSecurityId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intApprovalListId] INT NOT NULL, 
    [intEntityUserSecurityId] INT NOT NULL, 
	[intSort] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMApprovalListUserSecurity_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES tblSMUserSecurity([intEntityUserSecurityId])
)
