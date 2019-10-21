﻿CREATE TABLE [dbo].[tblIPStep]
(
	[intStepId] INT NOT NULL IDENTITY,
	[intProcessId] INT NOT NULL, 
    [strStepName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [intStepTypeId] INT NOT NULL,
    [intSequenceNo] INT NOT NULL DEFAULT 0, 
    [intSuccessStepId] INT NULL , 
    [intFailureStepId] INT NULL ,
    [intConnectionId] INT NULL, 
    [strSQL] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intSQLTypeId] INT,
	[intFileTypeId] INT NULL,
	[intDelimiterId] INT NULL,
	[strRecordMarker] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intRowsToSkip] INT NULL DEFAULT 0,
	[ysnDeleteFileAfterTransfer] bit DEFAULT 0,
	[strFileName] NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL,
	[strSheetName] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnGenerateHeader] BIT DEFAULT 0,
	[ysnGenerateMultipleFile] BIT DEFAULT 0,
	[ysnSuccessFailureStep] BIT NULL DEFAULT 0,
	[strDestinationFolder] NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL,
	[ysnDeleteFile] BIT DEFAULT 0,
	[ysnCopyFile] BIT DEFAULT 0,
	[ysnPrefixTimeStamp] BIT DEFAULT 0,
    [intSourceConnectionId] INT NULL, 
    [strSourceSQL] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intSourceSQLTypeId] INT,
	[strXSLFileName] NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL,
	[strErrorFileName] NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL,
	[strJoinColumnName] NVARCHAR(128) COLLATE Latin1_General_CI_AS NULL,
	[strDetailRecordMarker] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intDetailRowsToSkip] INT NULL DEFAULT 0,
	[strRecordDelimeter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFirstLine] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnPrefixZero] BIT DEFAULT 0,
	[intNoOfDecimalPlaces] INT NULL DEFAULT 0,
	[strFrom] NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL,
	[strTo] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCC] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strBCC] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strAttachment] NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL,
	[strSubject] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strWebApi] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intFTPServerId] INT,
	[strFTPOperationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFTPServerFile] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFTPLocalFile] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strWsdl] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strProtocol] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strInterfaceName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strIdocName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnUseBulkCopy] BIT NULL DEFAULT 0,
	[strReprocessSQL] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intDelayTime] INT NULL DEFAULT 0,
	[ysnSkip] BIT NULL DEFAULT 0,
	[intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblIPStep_intStepId] PRIMARY KEY ([intStepId]),
	CONSTRAINT [UQ_tblIPStep_strStepName] UNIQUE ([intProcessId],[strStepName]),
	CONSTRAINT [FK_tblIPStep_tblIPProcess_intProcessId] FOREIGN KEY ([intProcessId]) REFERENCES [tblIPProcess]([intProcessId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblIPStep_tblIPStepType_intStepTypeId] FOREIGN KEY ([intStepTypeId]) REFERENCES [tblIPStepType]([intStepTypeId]), 
	CONSTRAINT [FK_tblIPStep_tblIPFileType_intFileTypeId] FOREIGN KEY ([intFileTypeId]) REFERENCES [tblIPFileType]([intFileTypeId]), 
	CONSTRAINT [FK_tblIPStep_tblIPDelimiter_intDelimiterId] FOREIGN KEY ([intDelimiterId]) REFERENCES [tblIPDelimiter]([intDelimiterId]), 
	CONSTRAINT [FK_tblIPStep_tblIPConnection_intConnectionId] FOREIGN KEY ([intConnectionId]) REFERENCES [tblIPConnection]([intConnectionId]),
	CONSTRAINT [FK_tblIPStep_tblIPSQLType_intSQLTypeId] FOREIGN KEY ([intSQLTypeId]) REFERENCES [tblIPSQLType]([intSQLTypeId]), 
	CONSTRAINT [FK_tblIPStep_tblIPConnection_intSourceConnectionId] FOREIGN KEY ([intSourceConnectionId]) REFERENCES [tblIPConnection]([intConnectionId]),
	CONSTRAINT [FK_tblIPStep_tblIPSQLType_intSourceSQLTypeId] FOREIGN KEY ([intSourceSQLTypeId]) REFERENCES [tblIPSQLType]([intSQLTypeId]), 
	CONSTRAINT [FK_tblIPStep_tblIPFTPServer_intFTPServerId] FOREIGN KEY ([intFTPServerId]) REFERENCES [tblIPFTPServer]([intFTPServerId]),
)
