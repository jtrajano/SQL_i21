﻿CREATE TABLE [dbo].[tblSMLanguage]
(
	[intLanguageId]				INT	 PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [strLanguage]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[ysnDefault]				BIT  NULL,
    [intConcurrencyId]			INT	 NOT NULL DEFAULT (1), 
    CONSTRAINT [AK_tblSMLanguage_strLanguage] UNIQUE ([strLanguage])
)
