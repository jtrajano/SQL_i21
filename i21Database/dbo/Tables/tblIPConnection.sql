﻿CREATE TABLE [dbo].[tblIPConnection]
(
	[intConnectionId] INT NOT NULL IDENTITY, 
    [strConnectionName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intServerTypeId] INT NOT NULL, 
    [strServerName] NVARCHAR(512) COLLATE Latin1_General_CI_AS NULL, 
    [strDatabaseName] NVARCHAR(512) COLLATE Latin1_General_CI_AS NULL, 
    [intPortNo] INT NULL, 
    [strUserName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPassword] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intTimeout] INT NULL DEFAULT 60,
	[ysnUseCurrentDatabase] BIT DEFAULT 0,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL DEFAULT 0, 	 
	CONSTRAINT [PK_tblIPConnection_intConnectionId] PRIMARY KEY ([intConnectionId]),
	CONSTRAINT [UQ_tblIPConnection_strConnectionName] UNIQUE ([strConnectionName]),
	CONSTRAINT [FK_tblIPConnection_tblIPServerType_intServerTypeId] FOREIGN KEY ([intServerTypeId]) REFERENCES [tblIPServerType]([intServerTypeId]), 
)
