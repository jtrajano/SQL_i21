CREATE TABLE [dbo].[tblSMUserRole] (
    [intUserRoleID]     INT            IDENTITY (1, 1) NOT NULL,
    [strName]           NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL ,
    [strDescription]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strMenu]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strMenuPermission] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strForm]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnAdmin]          BIT            DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]  INT            DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([intUserRoleID] ASC), 
    CONSTRAINT [UQ_tblSMUserRole_strName] UNIQUE ([strName]) 
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'strName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JSON string for Menu. Obsolete on 14.3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'strMenu'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JSON string for Menu Permissions. Obsolete on 14.3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'strMenuPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JSON string for Form. Obsolete on 14.3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'strForm'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Enable Administrator Rights',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'ysnAdmin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRole',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'