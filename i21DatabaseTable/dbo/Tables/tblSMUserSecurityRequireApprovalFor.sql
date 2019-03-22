CREATE TABLE [dbo].[tblSMUserSecurityRequireApprovalFor]
(
	[intUserSecurityReqApprovalForId]		INT IDENTITY (1, 1) NOT NULL,
    [intEntityUserSecurityId]				INT NOT NULL,
	[intScreenId]							INT NULL,
	[intApprovalListId]						INT NULL,
    [intConcurrencyId]						INT NOT NULL,
    CONSTRAINT [PK_dbo.tblSMUserSecurityRequireApprovalFor] PRIMARY KEY CLUSTERED ([intUserSecurityReqApprovalForId] ASC),
    CONSTRAINT [FK_dbo.tblSMUserSecurityRequireApprovalFor_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblSMUserSecurityRequireApprovalFor_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [dbo].[tblSMScreen] ([intScreenId]),
    CONSTRAINT [FK_tblSMUserSecurityRequireApprovalFor_tblSMApprovalList] FOREIGN KEY ([intApprovalListId]) REFERENCES [tblSMApprovalList] ([intApprovalListId]),
	CONSTRAINT [UK_tblSMUserSecurityRequireApprovalFor_Column] UNIQUE ([intEntityUserSecurityId], [intScreenId], [intApprovalListId])
)
