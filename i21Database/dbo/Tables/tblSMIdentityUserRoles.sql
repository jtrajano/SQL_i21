CREATE TABLE [dbo].[tblSMIdentityUserRoles] (
    [intUserId] INT NOT NULL,
    [intRoleId] NVARCHAR (128) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_dbo.tblSMIdentityUserRoles] PRIMARY KEY CLUSTERED ([intUserId] ASC, [intRoleId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_intUserId]
    ON [dbo].[tblSMIdentityUserRoles]([intUserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_intRoleId]
    ON [dbo].[tblSMIdentityUserRoles]([intRoleId] ASC);

