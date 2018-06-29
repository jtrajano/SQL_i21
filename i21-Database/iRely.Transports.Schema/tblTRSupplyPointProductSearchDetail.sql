CREATE TABLE [dbo].[tblTRSupplyPointProductSearchDetail]
(
    [intSupplyPointProductSearchDetailId] INT NOT NULL IDENTITY,
	[intSupplyPointProductSearchHeaderId] INT NOT NULL,
	[strSearchValue] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRSupplyPointProductSearchDetail] PRIMARY KEY ([intSupplyPointProductSearchDetailId]),
	CONSTRAINT [FK_tblTRSupplyPointProductSearchDetail_tblTRSupplyPointProductSearchHeader_intSupplyPointProductSearchHeaderId] FOREIGN KEY ([intSupplyPointProductSearchHeaderId]) REFERENCES [dbo].[tblTRSupplyPointProductSearchHeader] ([intSupplyPointProductSearchHeaderId]) ON DELETE CASCADE
)
