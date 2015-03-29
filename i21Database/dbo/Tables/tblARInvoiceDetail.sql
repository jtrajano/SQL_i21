CREATE TABLE [dbo].[tblARInvoiceDetail] (
    [intInvoiceDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intInvoiceId]       INT             NOT NULL,
	[intCompanyLocationId]      INT      NOT NULL DEFAULT ((0)),
    [intItemId]          INT             NULL,
    [strItemDescription] NVARCHAR (250)  COLLATE Latin1_General_CI_AS  NULL,
	[intItemUOMId]       INT             NULL,
    [dblQtyOrdered]      NUMERIC (18, 6) NULL,
    [dblQtyShipped]      NUMERIC (18, 6) NULL,
    [dblPrice]           NUMERIC (18, 6) NULL,
    [dblTotal]           NUMERIC (18, 6) NULL,
	[intAccountId]		 INT             NULL,
	[intCOGSAccountId]		 INT             NULL,
	[intSalesAccountId]		 INT             NULL,
	[intInventoryAccountId]		 INT             NULL,
    [intConcurrencyId]   INT             CONSTRAINT [DF_tblARInvoiceDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARInvoiceDetail_intInvoiceDetailId] PRIMARY KEY CLUSTERED ([intInvoiceDetailId] ASC),
    CONSTRAINT [FK_tblARInvoiceDetail_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);








GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblARInvoiceDetail]([intInvoiceId] ASC, [intItemId] ASC, [strItemDescription] ASC, [dblQtyOrdered] ASC, [dblQtyShipped] ASC, [dblPrice] ASC, [dblTotal] ASC);

