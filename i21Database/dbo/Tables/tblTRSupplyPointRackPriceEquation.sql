CREATE TABLE [dbo].[tblTRSupplyPointRackPriceEquation]
(
	[intSupplyPointRackPriceEquationId] INT NOT NULL IDENTITY,
	[intItemId] INT NOT NULL,
	[intSupplyPointId] INT NOT NULL,
	[strOperand] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblFactor] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRSupplyPointRackPriceEquation] PRIMARY KEY ([intSupplyPointRackPriceEquationId]),
	CONSTRAINT [FK_tblTRSupplyPointRackPriceEquation_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblTRSupplyPointRackPriceEquation_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId]) ON DELETE CASCADE
	
)
