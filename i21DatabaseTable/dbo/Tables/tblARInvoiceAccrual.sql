CREATE TABLE [dbo].[tblARInvoiceAccrual](
	[intInvoiceAccrualId]	INT IDENTITY(1,1) NOT NULL,
	[intInvoiceId]			INT				NOT NULL,
	[intInvoiceDetailId]	INT				NOT NULL,
	[dtmAccrualDate]		DATETIME		NULL,
	[dblAmount]				NUMERIC(18, 6)	NULL,
	[intCompanyId]			INT				NULL,
	[intConcurrencyId]		INT				CONSTRAINT [DF_tblARInvoiceAccrual_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceAccrual_intInvoiceAccrualId] PRIMARY KEY CLUSTERED ([intInvoiceAccrualId] ASC),
	CONSTRAINT [FK_tblARInvoiceAccrual_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblARInvoiceACcrual_tblARInvoiceDetail] FOREIGN KEY ([intInvoiceDetailId]) REFERENCES [dbo].[tblARInvoiceDetail] ([intInvoiceDetailId]) ON DELETE CASCADE

)