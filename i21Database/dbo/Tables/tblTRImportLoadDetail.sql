﻿CREATE TABLE [dbo].[tblTRImportLoadDetail]
(
    [intImportLoadDetailId] INT NOT NULL IDENTITY,
    [intImportLoadId] INT NOT NULL,
    [intTruckId] INT NULL,
    [strTruck] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [intTerminalId] INT NULL,
    [strTerminal] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [strBillOfLading] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [intCarrierId] INT NULL,
    [strCarrier] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [intDriverId] INT NULL,
    [strDriver] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [intTrailerId] INT NULL,
    [strTrailer] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [intSupplierId] INT NULL,
    [strSupplier] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [intDestinationId] INT NULL,
    [strDestination] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [dtmPullDate] DATETIME NULL,
    [intPullProductId] INT NULL,
    [strPullProduct] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [intDropProductId] INT NULL,
    [strDropProduct] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [dblDropGross] NUMERIC(18,6) NULL,
    [dblDropNet] NUMERIC(18,6) NULL,
    [dtmInvoiceDate] DATETIME NULL,
    [dtmDropDate] DATETIME NULL,
    [ysnValid] BIT,
    [strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblTRImportLoadDetail] PRIMARY KEY ([intImportLoadDetailId]),
	CONSTRAINT [FK_tblTRImportLoadDetail_tblTRImportLoad_intImportLoadId] FOREIGN KEY ([intImportLoadId]) REFERENCES [dbo].[tblTRImportLoad] ([intImportLoadId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblTRImportLoadDetail_intImportLoadId] ON [dbo].[tblTRImportLoadDetail] ([intImportLoadId])
GO
