CREATE TABLE [dbo].[tblAREmailTemplate]
(
	[intEmailTemplateId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityCustomerId] INT NULL,
	[strSender] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strEmailHeader] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strEmailBody] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strEmailFooter] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[imgImage1] VARBINARY(MAX) NULL, 
    [imgImage2] VARBINARY(MAX) NULL, 
    [imgImage3] VARBINARY(MAX) NULL, 
    [imgImage4] VARBINARY(MAX) NULL,
    [ysnHtml] BIT NOT NULL DEFAULT 1, 
    [ysnDefault] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    [intEntityId] INT NULL,
    CONSTRAINT [FK_tblAREmailTemplate_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblAREmailTemplate_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId)
)
