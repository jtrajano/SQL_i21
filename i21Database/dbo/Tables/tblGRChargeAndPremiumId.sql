CREATE TABLE [dbo].[tblGRChargeAndPremiumId]
(
	[intChargeAndPremiumId] INT NOT NULL IDENTITY,
    [strChargeAndPremiumId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strChargeAndPremiumIdDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnActive] BIT NOT NULL,
	[dtmDateCreated] DATETIME NULL DEFAULT(GETDATE()),
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblGRChargeAndPremiumId_intChargeAndPremiumId] PRIMARY KEY ([intChargeAndPremiumId])
)
GO