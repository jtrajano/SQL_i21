CREATE TABLE [dbo].[tblSMUserSecurity] (
    --[intEntityUserSecurityId] INT            IDENTITY (1, 1) NOT NULL,
	[intEntityUserSecurityId]		INT NOT NULL,
    [intUserRoleID]					INT NULL,
	[intCompanyLocationId]			INT NULL,
	[intSecurityPolicyId]			INT NULL,
    [strUserName]					NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
	[strJIRAUserName]				NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strFullName]					NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strPassword]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
	[strOverridePassword]			NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
	[strDashboardRole]				NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strFirstName]					NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strMiddleName]					NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strLastName]					NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strPhone]						NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strDepartment]					NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strLocation]					NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strEmail]						NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strMenuPermission]				NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strMenu]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strForm]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT (''),
    [strFavorite]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [ysnDisabled]					BIT DEFAULT ((0)) NOT NULL,
    [ysnAdmin]						BIT	DEFAULT ((0)) NOT NULL,
	[ysnRequirePurchasingApproval]	BIT	DEFAULT ((0)) NOT NULL,
    [strDateFormat]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strNumberFormat]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intInvalidAttempt]				INT NOT NULL DEFAULT 0,
	[ysnLockedOut]					BIT NOT NULL DEFAULT 0,
	[dtmLockOutTime]				DATETIME NULL,
	[strEmployeeOriginId]			NVARCHAR(10) NULL,
	[ysnStoreManager]				BIT NOT NULL DEFAULT(0), 

	[intScaleSetupId]				INT NULL,
	[dtmScaleDate]				DATETIME NULL,
	[intScaleTruckDriverReferenceId]				INT  NULL,

    [intConcurrencyId]				INT	DEFAULT (1) NOT NULL,
	[intEntityIdOld]				INT NULL,
	[intUserSecurityIdOld]			INT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([intEntityUserSecurityId] ASC),
    CONSTRAINT [FK_UserSecurity_tblSMSecurityPolicy] FOREIGN KEY ([intSecurityPolicyId]) REFERENCES [dbo].[tblSMSecurityPolicy] ([intSecurityPolicyId]),
    CONSTRAINT [FK_UserSecurity_UserRole] FOREIGN KEY ([intUserRoleID]) REFERENCES [dbo].[tblSMUserRole] ([intUserRoleID]),
	CONSTRAINT [FK_UserSecurity_Entity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_UserSecurity_CompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]), 
	CONSTRAINT [FK_UserSecurity_tblSCScaleSetup] FOREIGN KEY ([intScaleSetupId]) REFERENCES [dbo].tblSCScaleSetup ([intScaleSetupId]), 	

    CONSTRAINT [AK_tblSMUserSecurity_strUserName] UNIQUE ([strUserName]) --this use in an sp named uspEMMergeEntity, any change in name should also be applied there MCG 
);


GO
--EXEC sp_addextendedproperty @name = N'MS_Description',
--    @value = N'Identity field',
--    @level0type = N'SCHEMA',
--    @level0name = N'dbo',
--    @level1type = N'TABLE',
--    @level1name = N'tblSMUserSecurity',
--    @level2type = N'COLUMN',
--    @level2name = N'intEntityUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurity',
    @level2type = N'COLUMN',
    @level2name = N'intEntityUserSecurityId'
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
GO

--CREATE TRIGGER [dbo].[Trigger_tblSMUserSecurity]
--    ON [dbo].[tblSMUserSecurity]
--    AFTER INSERT
--    AS
--    BEGIN
--        SET NoCount ON
--		DECLARE @intEntityUserSecurityId INT

--		SELECT @intEntityUserSecurityId = [intEntityUserSecurityId] FROM INSERTED;

--		EXEC uspSMUpdateUserPreferenceEntry @intEntityUserSecurityId
--    END