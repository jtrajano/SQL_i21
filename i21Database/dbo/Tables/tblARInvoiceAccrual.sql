CREATE TABLE [dbo].[tblARInvoiceAccrual](
	[intInvoiceAccrualId] [int] IDENTITY(1,1) NOT NULL,
	[intInvoiceId] [int] NOT NULL,
	[dtmAccrualDate] [datetime] NULL,
	[dblAmount] [numeric](18, 6) NULL,
	[intConcurrencyId] INT CONSTRAINT [DF_tblARInvoiceAccrual_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceAccrual_intInvoiceAccrualId] PRIMARY KEY CLUSTERED ([intInvoiceAccrualId] ASC),
	CONSTRAINT [FK_tblARInvoiceAccrual_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId])  ON DELETE CASCADE
)