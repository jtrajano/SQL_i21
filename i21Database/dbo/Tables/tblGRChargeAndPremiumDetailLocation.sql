CREATE TABLE [dbo].[tblGRChargeAndPremiumDetailLocation]
(
	[intChargeAndPremiumDetailLocationId] INT NOT NULL IDENTITY,
	[intChargeAndPremiumDetailId] INT NOT NULL,
	[intCompanyLocationId] INT NULL,
	[dblRate] DECIMAL(38,20) NULL DEFAULT ((0)),	
	[intConcurrencyId] INT NULL DEFAULT((1)),
	CONSTRAINT [PK_tblGRChargeAndPremiumDetailLocation_intChargeAndPremiumDetailLocationId] PRIMARY KEY ([intChargeAndPremiumDetailLocationId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetailLocation_intChargeAndPremiumDetailId] FOREIGN KEY ([intChargeAndPremiumDetailId]) REFERENCES [tblGRChargeAndPremiumDetail]([intChargeAndPremiumDetailId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetailLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
)
GO

CREATE NONCLUSTERED INDEX [IX_tblGRChargeAndPremiumDetailLocation_intChargeAndPremiumDetailId]
ON [dbo].[tblGRChargeAndPremiumDetailLocation] ([intChargeAndPremiumDetailId])
GO