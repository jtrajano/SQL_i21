﻿CREATE TABLE [dbo].[tblIPSAPIDOCTag]
(
	[intTagId] INT NOT NULL IDENTITY(1,1),
	[strMessageType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTagType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTag] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblIPSAPIDOCTag_intTagId] PRIMARY KEY ([intTagId])
)
