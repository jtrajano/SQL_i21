CREATE TABLE [dbo].[tblARInvoiceDetailComponent]
(
	[intInvoiceDetailComponentId]	INT	NOT NULL IDENTITY, 
    [intInvoiceDetailId]			INT	NOT NULL,     
    [intComponentItemId]			INT	NULL,
	[strComponentType]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intItemUOMId]					INT	NULL,
    [dblQuantity]					NUMERIC (38, 20) NULL,
	[dblUnitQuantity]				NUMERIC (38, 20) NULL,
	[intCompanyId]					INT NULL,
    [intConcurrencyId]				INT CONSTRAINT [DF_tblARInvoiceDetailComponent_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceDetailComponent_intInvoiceDetailComponentId] PRIMARY KEY CLUSTERED ([intInvoiceDetailComponentId] ASC)
)
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetailComponent_intInvoiceDetailId]
	ON [dbo].[tblARInvoiceDetailComponent] ([intInvoiceDetailId])
INCLUDE ([intComponentItemId],[intItemUOMId],[dblQuantity],[dblUnitQuantity])
GO