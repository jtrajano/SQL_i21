﻿CREATE TABLE [dbo].[tblSMAuditLog] (
    [intAuditLogId]   INT              IDENTITY (1, 1) NOT NULL,
    [strActionType]		 NVARCHAR(100)    COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] NVARCHAR(100)	  COLLATE Latin1_General_CI_AS NULL, 
	[strRecordNo]		 NVARCHAR(50)	  COLLATE Latin1_General_CI_AS NULL, 
	[strDescription]	 NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
	[strRoute]      	 NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
	[strJsonData]		 NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]			 DATETIME         NOT NULL,
    [intEntityId]        INT              NULL,
    [intConcurrencyId]   INT              NOT NULL,
    CONSTRAINT [FK_dbo.tblSMAuditLog_dbo.tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [PK_dbo.tblSMAuditLog] PRIMARY KEY CLUSTERED ([intAuditLogId] ASC)
);







