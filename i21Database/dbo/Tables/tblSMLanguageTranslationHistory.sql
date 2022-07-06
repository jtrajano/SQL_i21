CREATE TABLE [dbo].[tblSMLanguageTranslationHistory]
(
	[intLanguageTranslationHistoryId]	INT IDENTITY (1, 1) NOT NULL,
	[intLanguageId]				INT NOT NULL,
	[strUnique]					NVARCHAR(MAX),
	[dtmUpdated]				DATETIME,
	[intConcurrencyId]			INT NOT NULL DEFAULT 0,
	CONSTRAINT [PK_tblSMLanguageTranslationHistory] PRIMARY KEY CLUSTERED ([intLanguageTranslationHistoryId] ASC)
)
