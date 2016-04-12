CREATE TABLE [dbo].[tblMBFuelPointPriceChangeDetail]
(
	[intFuelPointPriceChangeDetailId] INT NOT NULL IDENTITY, 
    [intFuelPointPriceChangeId] INT NOT NULL, 
    [dtmDate] DATETIME NOT NULL DEFAULT (GETDATE()), 
    [strFuelingPoint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intItemId] INT NOT NULL, 
    [dblPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnBilled] BIT NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBFuelPointPriceChangeDetail] PRIMARY KEY ([intFuelPointPriceChangeDetailId]), 
    CONSTRAINT [FK_tblMBFuelPointPriceChangeDetail_tblMBFuelPointPriceChange] FOREIGN KEY ([intFuelPointPriceChangeId]) REFERENCES [tblMBFuelPointPriceChange]([intFuelPointPriceChangeId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMBFuelPointPriceChangeDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
