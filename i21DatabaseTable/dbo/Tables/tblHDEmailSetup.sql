CREATE TABLE [dbo].[tblHDEmailSetup]
(
	[intEmailSetupId] [int] IDENTITY(1,1) NOT NULL,
	[strFromEmail] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFromName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubjectPrefix] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strSMTPServer] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intSMTPPort] [int] NULL,
	[strEncryptedConnection] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnRequiresAuthentication] [bit] NULL,
	[strUserName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDEmailSetup] PRIMARY KEY CLUSTERED 
(
	[intEmailSetupId] ASC
)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'intEmailSetupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sender''s Email Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'strFromEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sender''s Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'strFromName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email''s Subject Prefix',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'strSubjectPrefix'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Server',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'strSMTPServer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Port',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'intSMTPPort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Encrypted Connection',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'strEncryptedConnection'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Requires Authentication?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'ysnRequiresAuthentication'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Username',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'strUserName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Password',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'strPassword'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDEmailSetup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'