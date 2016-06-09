CREATE TABLE [dbo].[tblEMEntityRequireApprovalFor]
(
	[intEntityRequireApprovalForId]				INT NOT NULL PRIMARY KEY IDENTITY,
    [intEntityId]								INT NOT NULL,
    [intScreenId]								INT NOT NULL,
	[intApprovalListId]							INT NULL,
    [intConcurrencyId]							INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblEMEntityRequireApprovalFor_tblSMCompanyLocation] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblEMEntityRequireApprovalFor_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen] ([intScreenId]),
    CONSTRAINT [FK_tblEMEntityRequireApprovalFor_tblSMApprovalList] FOREIGN KEY ([intApprovalListId]) REFERENCES [tblSMApprovalList] ([intApprovalListId]),
	CONSTRAINT [UK_tblEMEntityRequireApprovalFor_Column] UNIQUE ([intEntityId], [intScreenId], [intApprovalListId])
)
