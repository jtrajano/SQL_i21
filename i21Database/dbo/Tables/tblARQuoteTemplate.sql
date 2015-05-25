CREATE TABLE [dbo].[tblARQuoteTemplate]
(
	[intQuoteTemplateId] INT NOT NULL IDENTITY , 
    [strTemplateName] NVARCHAR(100) NULL, 
	[strOrganization] NVARCHAR(50) NULL, 
    [ysnDisplayTitle] BIT NULL,     
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblARQuoteTemplate_intQuoteTemplateId] PRIMARY KEY CLUSTERED ([intQuoteTemplateId] ASC)
)
