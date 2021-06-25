CREATE TABLE [dbo].[tblSMLocalization]
(
	[intLocalizationId]	INT IDENTITY (1, 1) NOT NULL,
	[intScreenLabelId]	INT NOT NULL,
	[intLanguageId]		INT NOT NULL,
    [strTranslation]	NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]  INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblSMLocalization_tblSMLanguage] FOREIGN KEY ([intLanguageId]) REFERENCES [dbo].[tblSMLanguage] ([intLanguageId]),
	CONSTRAINT [FK_tblSMLocalization_tblSMScreenLabel] FOREIGN KEY ([intScreenLabelId]) REFERENCES [dbo].[tblSMScreenLabel] ([intScreenLabelId]),
	CONSTRAINT [PK_tblSMLocalization] PRIMARY KEY CLUSTERED ([intLocalizationId] ASC)
)
