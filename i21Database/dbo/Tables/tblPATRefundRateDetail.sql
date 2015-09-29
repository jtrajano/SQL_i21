CREATE TABLE [dbo].[tblPATRefundRateDetail]
(
	[intRefundTypeDetailId] INT NOT NULL IDENTITY, 
    [intRefundTypeId] INT NULL, 
    [intPatronageCategoryId] INT NOT NULL, 
    [strPurchaseSale] NVARCHAR(50) NOT NULL, 
    [dblRate] NUMERIC(18, 6) NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefundRateDetail] PRIMARY KEY ([intRefundTypeDetailId]), 
    CONSTRAINT [FK_tblPATRefundRateDetail_tblPATRefundRate] FOREIGN KEY ([intRefundTypeId]) REFERENCES [tblPATRefundRate]([intRefundTypeId]), 
    CONSTRAINT [FK_tblPATRefundRateDetail_tblPATPatronageCategory] FOREIGN KEY ([intPatronageCategoryId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId]) 
)
