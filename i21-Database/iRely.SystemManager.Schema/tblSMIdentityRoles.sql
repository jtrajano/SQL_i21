CREATE TABLE [dbo].[tblSMIdentityRoles] (
    [intRoleId]   NVARCHAR (128) NOT NULL,
    [strName]     NVARCHAR (256) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_dbo.tblSMIdentityRoles] PRIMARY KEY CLUSTERED ([intRoleId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex]
    ON [dbo].[tblSMIdentityRoles]([strName] ASC);