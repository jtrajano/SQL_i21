CREATE TABLE [dbo].[tblTRRackPriceHeader]
(
	[intRackPriceHeaderId] INT NOT NULL IDENTITY,
	[intSupplyPointId] INT NOT NULL,
	[dtmEffectiveDateTime]  DATETIME NOT NULL,
	[strComments] NVARCHAR(max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT((0)),
	CONSTRAINT [PK_tblTRRackPriceHeader] PRIMARY KEY ([intRackPriceHeaderId]),
	CONSTRAINT [FK_tblTRRackPriceHeader_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId])
)
