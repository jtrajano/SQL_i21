CREATE TABLE [dbo].[tblSMUserSecurity] (
    [intUserSecurityID] INT            IDENTITY (1, 1) NOT NULL,
	[intEntityId]		INT            NULL,
    [intUserRoleID]     INT            NOT NULL,
	[intCompanyLocationId]     INT     NULL,
    [strUserName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
	[strJIRAUserName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strFullName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strPassword]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
	[strOverridePassword] NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
	[strDashboardRole]  NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strFirstName]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strMiddleName]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strLastName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strPhone]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strDepartment]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strLocation]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strEmail]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strMenuPermission] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strMenu]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strForm]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strFavorite]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [ysnDisabled]       BIT            DEFAULT ((0)) NOT NULL,
    [ysnAdmin]          BIT            DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]  INT            DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([intUserSecurityID] ASC),
    CONSTRAINT [FK_UserSecurity_UserRole] FOREIGN KEY ([intUserRoleID]) REFERENCES [dbo].[tblSMUserRole] ([intUserRoleID]),
	CONSTRAINT [FK_UserSecurity_Entity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
	CONSTRAINT [FK_UserSecurity_CompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'intCompanyLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strUserName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JIRA User Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strJIRAUserName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Full Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strFullName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Password',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strPassword'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Override Password',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strOverridePassword'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dashboard Role',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strDashboardRole'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'First Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strFirstName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Middle Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strMiddleName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strLastName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Department',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strDepartment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JSON String for Menu Permission. Obsolete on Version 14.3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strMenuPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JSON string for Menu. Obsolete on Version 14.3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strMenu'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JSON string for form. Obsolete on Version 14.3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strForm'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JSON string for Favorites. Obsolete on Version 14.3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'strFavorite'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User is Disabled',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'ysnDisabled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Enable Administrator Rights',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'ysnAdmin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'