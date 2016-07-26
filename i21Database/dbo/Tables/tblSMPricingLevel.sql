CREATE TABLE [dbo].[tblSMPricingLevel]
(
	[intPricingLevelId] INT NOT NULL IDENTITY,
    [strPricingLevelName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblSMPricingLevel] PRIMARY KEY ([intPricingLevelId])
)
