CREATE TABLE [dbo].[tblMBILInvoiceItem](
	[intInvoiceItemId] INT IDENTITY(1,1) NOT NULL,	
	[intInvoiceSiteId] INT NOT NULL,
	[intItemId] INT NULL,
	[intItemUOMId] INT NULL,
	[intContractDetailId] INT NULL,
	[dblQuantity] NUMERIC (18, 6) NULL,
	[dblPrice] NUMERIC (18, 6) NULL,
	[inti21InvoiceDetailId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblMBILInvoiceItem] PRIMARY KEY CLUSTERED ([intInvoiceItemId] ASC),
	CONSTRAINT [FK_tblMBILInvoiceItem_tblMBILInvoiceSite] FOREIGN KEY([intInvoiceSiteId]) REFERENCES [dbo].[tblMBILInvoiceSite] ([intInvoiceSiteId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMBILInvoiceItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblMBILInvoiceItem_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblMBILInvoiceItem_tblCTContractDetail] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblMBILInvoiceItem_tblARInvoiceDetail] FOREIGN KEY ([inti21InvoiceDetailId]) REFERENCES [tblARInvoiceDetail]([intInvoiceDetailId])
)