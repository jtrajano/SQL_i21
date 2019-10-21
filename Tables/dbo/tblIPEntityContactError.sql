﻿CREATE TABLE [dbo].[tblIPEntityContactError]
(
	[intStageEntityContactId] INT IDENTITY(1,1),
	[intStageEntityId] INT,
	[strEntityName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strFirstName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strLastName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblIPEntityContactError_intStageEntityContactId] PRIMARY KEY ([intStageEntityContactId])
)
