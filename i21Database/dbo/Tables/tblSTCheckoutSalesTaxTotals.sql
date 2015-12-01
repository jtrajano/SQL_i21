CREATE TABLE [dbo].[tblSTCheckoutSalesTaxTotals]
(
	[intSalesTaxTotalsId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [intTaxNo] INT NULL, 
    [dblTotalTax] DECIMAL(18, 6) NULL, 
    [dblTaxableSales] DECIMAL(18, 6) NULL, 
    [dblTaxExemptSales] DECIMAL(18, 6) NULL, 
    [intSalesTaxAccount] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutSalesTaxTotals_intSalesTaxTotalsId] PRIMARY KEY ([intSalesTaxTotalsId]), 
    CONSTRAINT [FK_tblSTCheckoutSalesTaxTotals_tblGLAccount] FOREIGN KEY ([intSalesTaxAccount]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [FK_tblSTCheckoutSalesTaxTotals_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) 
)
