﻿CREATE TABLE [dbo].[tblAPImportValidationLog]
(
	[intId] INT NOT NULL IDENTITY, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NOT NULL, 
    [dtmDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblAPImportValidationLog] PRIMARY KEY ([intId])
)
