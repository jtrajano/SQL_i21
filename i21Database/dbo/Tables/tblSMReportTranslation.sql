CREATE TABLE [dbo].[tblSMReportTranslation]
(
	[intReportTranslationId]	INT	 PRIMARY KEY IDENTITY (1, 1) NOT NULL,
    [strFieldName]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strTranslation]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[intTransactionId]			INT  NOT NULL,
	[intLanguageId]				INT  NOT NULL,
    [intConcurrencyId]			INT	 NOT NULL DEFAULT (1),
	CONSTRAINT [FK_tblSMReportTranslation_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]) ON DELETE CASCADE
)
