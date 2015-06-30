CREATE TABLE [dbo].[tblARQuoteTemplateDetail]
(
	[intQuoteTemplateDetailId] INT NOT NULL IDENTITY , 
    [intQuoteTemplateId] INT NOT NULL,     
    [strSectionName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnDisplayTitle] BIT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[intAttachmentId] INT NOT NULL, 
    CONSTRAINT [PK_tblARQuoteTemplateDetail_intQuoteTemplateDetailId] PRIMARY KEY CLUSTERED ([intQuoteTemplateDetailId] ASC),
    CONSTRAINT [FK_tblARQuoteTemplateDetail_tblARQuoteTemplate] FOREIGN KEY ([intQuoteTemplateId]) REFERENCES [dbo].[tblARQuoteTemplate]([intQuoteTemplateId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARQuoteTemplateDetail_tblSMAttachment] FOREIGN KEY ([intAttachmentId]) REFERENCES [dbo].[tblSMAttachment]([intAttachmentId]) ON DELETE CASCADE
)
