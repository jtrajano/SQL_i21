CREATE TABLE [dbo].[tblPOPurchaseDetail]
(
	[intPurchaseDetailId] INT NOT NULL PRIMARY KEY, 
    [intPurchaseId] INT NOT NULL, 
    [intProductId] INT NULL, 
    [intUnitOfMeasureId] INT NOT NULL, 
    [intAccountId] INT NOT NULL, 
    [dblQtyOrdered] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblVolume] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblWeight] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[dtmExpectedDate] DATETIME,
    [intLineNo] INT NOT NULL DEFAULT 1
)
