CREATE TABLE [dbo].[tblARQuotePage]
(
	[intQuotePageId]			INT NOT NULL IDENTITY, 
    [strPageTitle]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPageDescription]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPageBody]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT NOT NULL,	
	CONSTRAINT [PK_tblARQuotePage_intQuotePageId] PRIMARY KEY CLUSTERED ([intQuotePageId] ASC),
	CONSTRAINT [UK_tblARQuotePage_strPageTitle] UNIQUE (strPageTitle)
)
