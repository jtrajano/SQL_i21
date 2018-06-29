CREATE TABLE [dbo].[tblSTCheckoutDeposits]
(
	[intDepositId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [intDepNo] INT NULL, 
    [dblCash] DECIMAL(18, 6) NULL, 
    [dblCoin] DECIMAL(18, 6) NULL, 
    [dblTotalCash] DECIMAL(18, 6) NULL, 
    [strChecks] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblTotalDeposit] DECIMAL(18, 6) NULL, 
    [dblNSFChcks] DECIMAL(18, 6) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutDeposits_intDepositId] PRIMARY KEY ([intDepositId]), 
    CONSTRAINT [FK_tblSTCheckoutDeposits_tblICCategory] FOREIGN KEY ([intDepNo]) REFERENCES [tblICCategory]([intCategoryId]), 
    CONSTRAINT [FK_tblSTCheckoutDeposits_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE 
)
