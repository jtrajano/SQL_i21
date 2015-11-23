CREATE TABLE [dbo].[tblSMUserSecurityRequireApprovalFor]
(
	[intUserSecurityReqApprovalForId]		INT IDENTITY (1, 1) NOT NULL,
    [intEntityUserSecurityId]				INT NOT NULL,
    [strRequireApprovalFor]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]						INT            NOT NULL,
    CONSTRAINT [PK_dbo.tblSMUserSecurityRequireApprovalFor] PRIMARY KEY CLUSTERED ([intUserSecurityReqApprovalForId] ASC),
    CONSTRAINT [FK_dbo.tblSMUserSecurityRequireApprovalFor_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [dbo].[tblSMUserSecurity] ([intEntityUserSecurityId]) ON DELETE CASCADE
)
