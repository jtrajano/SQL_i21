CREATE TABLE [dbo].[tblARQuoteTemplate]
(
	[intQuoteTemplateId] INT NOT NULL IDENTITY , 
    [strTemplateName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strOrganization] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnDisplayTitle] BIT NULL,     
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblARQuoteTemplate_intQuoteTemplateId] PRIMARY KEY CLUSTERED ([intQuoteTemplateId] ASC)
)
