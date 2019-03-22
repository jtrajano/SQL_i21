CREATE TABLE [dbo].[tblTRSupplyPointProductSearchHeader]
(
	[intSupplyPointProductSearchHeaderId] INT NOT NULL IDENTITY,
	[intItemId] INT NOT NULL,
	[intSupplyPointId] INT NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRSupplyPointProductSearchHeader] PRIMARY KEY ([intSupplyPointProductSearchHeaderId]),
	CONSTRAINT [FK_tblTRSupplyPointProductSearchHeader_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblTRSupplyPointProductSearchHeader_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId]) ON DELETE CASCADE
	
)
