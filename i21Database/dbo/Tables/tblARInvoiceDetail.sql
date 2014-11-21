CREATE TABLE [dbo].[tblARInvoiceDetail] (
    [intInvoiceDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intInvoiceId]       INT             NOT NULL,
    [intItemId]          INT             NULL,
    [strItemDescription] NVARCHAR (250)  NULL,
	[intItemUOMId]       INT             NULL,
    [dblQtyOrdered]      NUMERIC (18, 6) NULL,
    [dblQtyShipped]      NUMERIC (18, 6) NULL,
    [dblPrice]           NUMERIC (18, 6) NULL,
    [dblTotal]           NUMERIC (18, 6) NULL,
    [intConcurrencyId]   INT             CONSTRAINT [DF_tblARInvoiceDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARInvoiceDetail] PRIMARY KEY CLUSTERED ([intInvoiceDetailId] ASC),
    CONSTRAINT [FK_tblARInvoiceDetail_tblARInvoice1] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId])
);








GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblARInvoiceDetail]([intInvoiceId] ASC, [intItemId] ASC, [strItemDescription] ASC, [dblQtyOrdered] ASC, [dblQtyShipped] ASC, [dblPrice] ASC, [dblTotal] ASC);

