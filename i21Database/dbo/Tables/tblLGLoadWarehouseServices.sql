﻿CREATE TABLE [dbo].[tblLGLoadWarehouseServices]
(
	[intLoadWarehouseServicesId] INT NOT NULL IDENTITY(1, 1),
    [intConcurrencyId] INT NOT NULL,
	[intLoadWarehouseId] INT NOT NULL,
	[strCategory] NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL,
	[strActivity] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NOT NULL,
	[intType] INT NOT NULL,
	[intItemId] [int] NULL,
	[dblUnitRate] NUMERIC(18, 6) NOT NULL,
	[intItemUOMId] INT NOT NULL,
	[dblQuantity] NUMERIC(18, 6) NULL,
	[dblCalculatedAmount] NUMERIC(18, 6) NULL,
	[dblActualAmount] NUMERIC(18, 6) NULL,
	[ysnChargeCustomer] [bit] NULL,
	[dblBillAmount] NUMERIC(18, 6) NULL,
	[ysnPrint] [bit] NOT NULL,
	[intSort] INT NOT NULL,
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
	
    CONSTRAINT [PK_tblLGLoadWarehouseServices] PRIMARY KEY ([intLoadWarehouseServicesId]),
    CONSTRAINT [FK_tblLGLoadWarehouseServices_tblLGLoadWarehouse_intLoadWarehouseId] FOREIGN KEY ([intLoadWarehouseId]) REFERENCES [tblLGLoadWarehouse]([intLoadWarehouseId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblLGLoadWarehouseServices_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGLoadWarehouseServices_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
