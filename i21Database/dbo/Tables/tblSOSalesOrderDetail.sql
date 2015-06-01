﻿CREATE TABLE [dbo].[tblSOSalesOrderDetail] (
    [intSalesOrderDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intSalesOrderId]       INT             NOT NULL,
    [intItemId]             INT             NULL,
    [strItemDescription]    NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intItemUOMId]          INT             NULL,
    [dblQtyOrdered]         NUMERIC (18, 6) NULL,
    [dblQtyAllocated]       NUMERIC (18, 6) NULL,
	[dblQtyShipped]			NUMERIC (18, 6) NULL DEFAULT ((0)),
    [dblDiscount]           NUMERIC (18, 6) NULL,
    [intTaxId]              INT             NULL,
    [dblPrice]              NUMERIC (18, 6) NULL,
	[dblTotalTax]           NUMERIC (18, 6) NULL,
    [dblTotal]              NUMERIC (18, 6) NULL,
    [strComments]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]          INT             NULL,
    [intCOGSAccountId]      INT             NULL,
    [intSalesAccountId]     INT             NULL,
    [intInventoryAccountId] INT             NULL,
	[intStorageLocationId]  INT             NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblSOSalesOrderDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSOSalesOrderDetail] PRIMARY KEY CLUSTERED ([intSalesOrderDetailId] ASC),
    CONSTRAINT [FK_tblSOSalesOrderDetail_tblSOSalesOrder] FOREIGN KEY ([intSalesOrderId]) REFERENCES [dbo].[tblSOSalesOrder] ([intSalesOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [dbo].[tblICStorageLocation] ([intStorageLocationId])
);