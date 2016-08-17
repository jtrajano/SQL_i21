CREATE TABLE [dbo].[tblARInvoiceDetailComponent]
(
	[intInvoiceDetailComponentId]	INT	NOT NULL IDENTITY, 
    [intInvoiceDetailId]			INT	NOT NULL,     
    [intComponentItemId]			INT	NULL,
	[strComponentType]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intItemUOMId]					INT	NULL,
    [dblQuantity]					NUMERIC (18, 6) NULL,
	[dblUnitQuantity]				NUMERIC (18, 6) NULL,
    [intConcurrencyId]				INT CONSTRAINT [DF_tblARInvoiceDetailComponent_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceDetailComponent_intInvoiceDetailComponentId] PRIMARY KEY CLUSTERED ([intInvoiceDetailComponentId] ASC)
)
