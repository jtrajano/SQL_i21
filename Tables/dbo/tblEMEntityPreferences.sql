﻿CREATE TABLE [dbo].[tblEMEntityPreferences]
(
	[intEntityPreferences]			INT IDENTITY (1, 1) NOT NULL,
	[strPreference]					NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,  
	[strValue]						NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,  
    [intConcurrencyId]              INT CONSTRAINT [DF_tblEMEntityPreferences_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityPreferences] PRIMARY KEY CLUSTERED ([intEntityPreferences] ASC)
)
