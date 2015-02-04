CREATE TABLE [dbo].[tblSOSalesOrderDetail] (
    [intSalesOrderDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intSalesOrderId]       INT             NOT NULL,
    [intCompanyLocationId]  INT             CONSTRAINT [DF__tblSOSale__intCo__54065212] DEFAULT ((0)) NOT NULL,
    [intItemId]             INT             NULL,
    [strItemDescription]    NVARCHAR (250)  NULL,
    [intItemUOMId]          INT             NULL,
    [dblQtyOrdered]         NUMERIC (18, 6) NULL,
    [dblQtyAllocated]       NUMERIC (18, 6) NULL,
    [dblDiscount]           NUMERIC (18, 6) NULL,
    [intTaxId]              INT             NULL,
    [dblPrice]              NUMERIC (18, 6) NULL,
    [dblTotal]              NUMERIC (18, 6) NULL,
    [strComments]           NVARCHAR (250)  NULL,
    [intAccountId]          INT             NULL,
    [intCOGSAccountId]      INT             NULL,
    [intSalesAccountId]     INT             NULL,
    [intInventoryAccountId] INT             NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblSOSalesOrderDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSOSalesOrderDetail] PRIMARY KEY CLUSTERED ([intSalesOrderDetailId] ASC),
    CONSTRAINT [FK_tblSOSalesOrderDetail_tblSOSalesOrder] FOREIGN KEY ([intSalesOrderId]) REFERENCES [dbo].[tblSOSalesOrder] ([intSalesOrderId]) ON DELETE CASCADE
);

