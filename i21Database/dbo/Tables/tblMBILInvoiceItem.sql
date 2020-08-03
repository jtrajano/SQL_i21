CREATE TABLE [dbo].[tblMBILInvoiceItem](
	[intInvoiceItemId] INT IDENTITY(1,1) NOT NULL,	
	[intInvoiceId] INT NOT NULL,
	[intSiteId] INT NOT NULL,
	[intItemId] INT NULL,
	[intItemUOMId] INT NULL,
	[intContractDetailId] INT NULL,
	[dblQuantity] NUMERIC (18, 6) NULL,
	[dblPrice] NUMERIC (18, 6) NULL,
	[dblPercentageFull] NUMERIC (18, 6) NULL,
	[inti21InvoiceDetailId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblMBILInvoiceItem] PRIMARY KEY CLUSTERED ([intInvoiceItemId] ASC),
    CONSTRAINT [FK_tblMBILInvoiceItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblMBILInvoiceItem_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblMBILInvoiceItem_tblCTContractDetail] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblMBILInvoiceItem_tblARInvoiceDetail] FOREIGN KEY ([inti21InvoiceDetailId]) REFERENCES [tblARInvoiceDetail]([intInvoiceDetailId]), 
    CONSTRAINT [FK_tblMBILInvoiceItem_tblMBILInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [tblMBILInvoice]([intInvoiceId]) ON DELETE CASCADE
)