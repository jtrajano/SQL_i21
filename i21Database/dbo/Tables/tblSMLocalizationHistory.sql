CREATE TABLE [dbo].[tblSMLocalizationHistory]
(
	[intLocalizationHistoryId]	INT IDENTITY (1, 1) NOT NULL,
	[intLanguageId]				INT NOT NULL,
	[strUnique]					NVARCHAR(MAX),
	[dtmUpdated]				DATETIME,
	[intConcurrencyId]			INT NOT NULL DEFAULT 0,
	CONSTRAINT [PK_tblSMLocalizationHistory] PRIMARY KEY CLUSTERED ([intLocalizationHistoryId] ASC)
)
