CREATE TABLE [dbo].[tblSMLanguageTranslationStaging]
(
	[intLanguageTranslationStagingId]	INT IDENTITY (1, 1) NOT NULL,
	[strLabel]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTranslation]			NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblSMLanguageTranslationStaging] PRIMARY KEY CLUSTERED ([intLanguageTranslationStagingId] ASC)
)
