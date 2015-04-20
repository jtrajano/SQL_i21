CREATE TABLE [dbo].[tblAREmailTemplate]
(
	[intEmailTemplateId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityCustomerId] INT NULL,
	[strSender] NVARCHAR(250) NULL, 
    [strTransactionType] NVARCHAR(50) NOT NULL, 
    [strEmailHeader] NVARCHAR(MAX) NULL, 
    [strEmailBody] NVARCHAR(MAX) NOT NULL, 
    [strEmailFooter] NVARCHAR(MAX) NULL, 
	[imgImage1] VARBINARY(MAX) NULL, 
    [imgImage2] VARBINARY(MAX) NULL, 
    [imgImage3] VARBINARY(MAX) NULL, 
    [imgImage4] VARBINARY(MAX) NULL,
    [ysnHtml] BIT NOT NULL DEFAULT 1, 
    [ysnDefault] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    [intEntityId] INT NULL,
    CONSTRAINT [FK_tblAREmailTemplate_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblAREmailTemplate_tblEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEntity(intEntityId)
)
