CREATE TABLE [dbo].[tblSMCompanyLocationRequireApprovalFor]
(
	[intCompanyLocationRequireApprovalForId]	INT NOT NULL PRIMARY KEY IDENTITY,
    [intCompanyLocationId]						INT NOT NULL,
    [intScreenId]								INT NOT NULL,
	[intApprovalListId]							INT NULL,
    [intConcurrencyId]							INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCompanyLocationRequireApprovalFor_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSMCompanyLocationRequireApprovalFor_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen] ([intScreenId]),
    CONSTRAINT [FK_tblSMCompanyLocationRequireApprovalFor_tblSMApprovalList] FOREIGN KEY ([intApprovalListId]) REFERENCES [tblSMApprovalList] ([intApprovalListId]),
	CONSTRAINT [UK_tblSMCompanyLocationRequireApprovalFor_Column] UNIQUE ([intCompanyLocationId], [intScreenId], [intApprovalListId])
)
