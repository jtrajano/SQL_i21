CREATE TABLE [dbo].[tblCTInvoiceType](
	[intInvoiceTypeId] [int] NOT NULL,
	[strInvoiceType] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](60) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] BIT NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTInvoiceType_intInvoiceTypeId] PRIMARY KEY CLUSTERED ([intInvoiceTypeId] ASC)
)