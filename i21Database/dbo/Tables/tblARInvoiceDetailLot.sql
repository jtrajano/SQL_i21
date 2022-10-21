﻿CREATE TABLE [dbo].[tblARInvoiceDetailLot]
(
	[intInvoiceDetailLotId]     INT NOT NULL IDENTITY, 	
	[intInvoiceDetailId]		INT NOT NULL, 
	[intLotId]					INT NOT NULL, 
	[dblQuantityShipped]		NUMERIC(38, 20) NULL DEFAULT((0)), 
	[dblGrossWeight]			NUMERIC(38, 20) NULL DEFAULT((0)),
	[dblTareWeight]				NUMERIC(38, 20) NULL DEFAULT((0)),
	[dblWeightPerQty]			NUMERIC(38, 20) NULL DEFAULT((0)),
	[strWarehouseCargoNumber]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intSort]					INT NULL, 	
	[dtmDateCreated]			DATETIME NULL,
    [dtmDateModified]			DATETIME NULL,
    [intCreatedByUserId]		INT NULL,
    [intModifiedByUserId]		INT NULL,
	[intConcurrencyId]          INT CONSTRAINT [DF_tblARInvoiceDetailLot_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARInvoiceDetailLot] PRIMARY KEY CLUSTERED ([intInvoiceDetailLotId] ASC), 
	CONSTRAINT [FK_tblARInvoiceDetailLot_tblARInvoiceDetail_intInvoiceDetailId] FOREIGN KEY ([intInvoiceDetailId]) REFERENCES [tblARInvoiceDetail] ([intInvoiceDetailId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblARInvoiceDetailLot_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId])
);
CREATE INDEX [idx_tblARInvoiceDetailLot_tblARInvoiceDetail] ON [dbo].[tblARInvoiceDetailLot] (intInvoiceDetailId, intInvoiceDetailLotId) 
GO