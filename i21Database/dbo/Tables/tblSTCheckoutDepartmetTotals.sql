﻿CREATE TABLE [dbo].[tblSTCheckoutDepartmetTotals]
(
	[intDepartmentTotalId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
	[intCategoryId] INT,
    [intTotalSalesCount] INT NULL, 
    [dblTotalSalesAmount] DECIMAL(18, 6) NULL, 
    [dblRegisterSalesAmount] DECIMAL(18, 6) NULL, 
	[strDepartmentTotalsComment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intPromotionalDiscountsCount] INT NULL, 
    [dblPromotionalDiscountAmount] DECIMAL(18, 6) NULL, 
    [intManagerDiscountCount] INT NULL, 
    [dblManagerDiscountAmount] DECIMAL(18, 6) NULL, 
    [intRefundCount] INT NULL, 
    [dblRefundAmount] DECIMAL(18, 6) NULL, 
    [intItemsSold] INT NULL, 
    [dblTaxAmount1] DECIMAL(18, 6) NULL, 
    [dblTaxAmount2] DECIMAL(18, 6) NULL, 
    [dblTaxAmount3] DECIMAL(18, 6) NULL, 
    [dblTaxAmount4] DECIMAL(18, 6) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutDepartmetTotals_intDepartmentTotalId] PRIMARY KEY ([intDepartmentTotalId]) ,
	CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) 
)
