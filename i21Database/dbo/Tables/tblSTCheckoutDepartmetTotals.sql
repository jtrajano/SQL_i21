﻿CREATE TABLE [dbo].[tblSTCheckoutDepartmetTotals]
(
	[intDepartmentTotalId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
	[intDepartmentId] INT,
    [intTotalSalesCount] INT NULL, 
    [dblTotalSalesAmount] DECIMAL(18, 6) NULL, 
    [dblRegisterSalesAmount] DECIMAL(18, 6) NULL, 
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
	CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]), 
    CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblICCategory] FOREIGN KEY ([intDepartmentId]) REFERENCES [tblICCategory]([intCategoryId]) 
)
