CREATE TABLE [dbo].[tblIPFTPServer]
(
	[intFTPServerId] INT NOT NULL IDENTITY, 
	[strServerName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strServerType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strServerUrl] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intPortNo] INT NULL, 
	[strUserName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPassword] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strDomainName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intTimeout] INT NULL DEFAULT 60,
	[ysnUsePassive] BIT DEFAULT 0,
	[ysnUseSsl] BIT DEFAULT 0,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL DEFAULT 0, 	 
	CONSTRAINT [PK_tblIPFTPServer_intFTPServerId] PRIMARY KEY ([intFTPServerId])
)
