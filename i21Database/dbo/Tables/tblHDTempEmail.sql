﻿CREATE TABLE [dbo].[tblHDTempEmail]
(
	[intTempEmailId] [int] IDENTITY(1,1) NOT NULL,
	[strSMTPServer] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSMTPPort] [int] NOT NULL,
	[strUserName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPassword] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnRequiresAuthentication] [bit] NULL,
	[strFromEmail] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFromDisplayName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strEmailTo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strEmailBcc] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strSubject] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strBodyMessage] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strBodyMessageType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnSend] BIT NOT NULL DEFAULT 0,	
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTempEmail] PRIMARY KEY CLUSTERED 
(
	[intTempEmailId] ASC
)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'intTempEmailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Server',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'strSMTPServer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'SMTP Port',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'intSMTPPort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Username',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'strUserName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Password',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'strPassword'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Requires Authentication?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'ysnRequiresAuthentication'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sender''s Email Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'strFromEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recipient''s Email Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = 'strEmailTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Subject',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'strSubject'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Message',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'strBodyMessage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Message Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'strBodyMessageType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Send',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = 'ysnSend'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTempEmail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'