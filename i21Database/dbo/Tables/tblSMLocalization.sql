CREATE TABLE [dbo].[tblSMLocalization]
(
	[intLocalizationId]	INT IDENTITY (1, 1) NOT NULL,
	[intLanguageId]		INT NOT NULL,
	[strLabel]			NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTranslation]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]  INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblSMLocalization_tblSMLanguage] FOREIGN KEY ([intLanguageId]) REFERENCES [dbo].[tblSMLanguage] ([intLanguageId]),
	CONSTRAINT [PK_tblSMLocalization] PRIMARY KEY CLUSTERED ([intLocalizationId] ASC)
)
