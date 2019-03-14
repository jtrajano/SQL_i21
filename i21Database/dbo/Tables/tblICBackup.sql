﻿CREATE TABLE [dbo].[tblICBackup]
(
	[intBackupId] INT NOT NULL IDENTITY(1,1),
    [dtmDate] DATETIME NOT NULL,
	[intUserId] INT NOT NULL,
	[strOperation] VARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strRemarks] VARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intCompanyId] INT NULL, 
	[ysnRebuilding] BIT NULL DEFAULT(0), 
	[dtmStart] DATETIME NULL,
	[dtmEnd] DATETIME NULL,
	CONSTRAINT [PK_tblICBackup] PRIMARY KEY NONCLUSTERED ([intBackupId])
)