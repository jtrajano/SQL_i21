CREATE TABLE [dbo].[tblSOSalesOrderDetailComponent]
(
	[intSalesOrderDetailComponentId]	INT	NOT NULL IDENTITY, 
    [intSalesOrderDetailId]				INT	NOT NULL,     
    [intComponentItemId]				INT	NULL,
	[strComponentType]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intItemUOMId]						INT	NULL,
    [dblQuantity]						NUMERIC (18, 6) NULL,
	[dblUnitQuantity]					NUMERIC (18, 6) NULL,
    [intConcurrencyId]					INT CONSTRAINT [DF_tblSOSalesOrderDetailComponent_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblSOSalesOrderDetailComponent_intSalesOrderDetailComponentId] PRIMARY KEY CLUSTERED ([intSalesOrderDetailComponentId] ASC)	
)