CREATE TABLE [dbo].[tblTRRackPriceHeader]
(
	[intRackPriceHeaderId] INT NOT NULL IDENTITY,
	[intSupplyPointId] INT NOT NULL,
	[dtmEffectiveDateTime]  DATETIME        NOT NULL,
	[strComments] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRRackPriceHeader] PRIMARY KEY ([intRackPriceHeaderId]),
	CONSTRAINT [FK_tblTRRackPriceHeader_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId])
)
