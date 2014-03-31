CREATE TABLE [dbo].[tblHDEmailSetup]
(
	[intEmailSetupId] [int] IDENTITY(1,1) NOT NULL,
	[strFromEmail] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFromName] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubjectPrefix] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strSMTPServer] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intSMTPPort] [int] NULL,
	[strEncryptedConnection] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnRequiresAuthen] [bit] NULL,
	[strUserName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDEmailSetup] PRIMARY KEY CLUSTERED 
(
	[intEmailSetupId] ASC
)
)
