CREATE TABLE [dbo].[tblSTCheckoutSalesTaxTotals]
(
	[intSalesTaxTotalsId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
	[intItemId] INT,
    [strTaxNo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [dblTotalTax] DECIMAL(18, 6) NULL, 
    [dblTaxableSales] DECIMAL(18, 6) NULL, 
    [dblTaxExemptSales] DECIMAL(18, 6) NULL, 
    [intSalesTaxAccount] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutSalesTaxTotals_intSalesTaxTotalsId] PRIMARY KEY ([intSalesTaxTotalsId]), 
    CONSTRAINT [FK_tblSTCheckoutSalesTaxTotals_tblGLAccount] FOREIGN KEY ([intSalesTaxAccount]) REFERENCES [tblGLAccount]([intAccountId]), 
	CONSTRAINT [FK_tblSTCheckoutSalesTaxTotals_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblSTCheckoutSalesTaxTotals_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE 
)
