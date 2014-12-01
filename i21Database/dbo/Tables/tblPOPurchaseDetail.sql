﻿CREATE TABLE [dbo].[tblPOPurchaseDetail]
(
	[intPurchaseDetailId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intPurchaseId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intUnitOfMeasureId] INT NOT NULL, 
    [intAccountId] INT NOT NULL, 
	[intBinLocationId] INT NULL,
	[intLocationId] INT NOT NULL,
    [dblQtyOrdered] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblVolume] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblWeight] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblTotal] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[dtmExpectedDate] DATETIME,
    [intLineNo] INT NOT NULL DEFAULT 1,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [FK_tblPOPurchaseDetail_tblPOPurchase] FOREIGN KEY ([intPurchaseId]) REFERENCES [dbo].[tblPOPurchase] ([intPurchaseId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblPOPurchaseDetail_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
