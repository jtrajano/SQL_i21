CREATE TABLE [dbo].[tblSTCheckoutDealerCommission]
(
	[intDealerCommissionId] [int] IDENTITY(1,1) NOT NULL,
	[intCheckoutId] [int] NOT NULL,
	[dblCommissionAmount] [decimal](18,2) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
    CONSTRAINT [PK_tblSTCheckoutDealerCommission_intDealerCommissionId] PRIMARY KEY ([intDealerCommissionId]), 
    CONSTRAINT [FK_tblSTCheckoutDealerCommission_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE
)