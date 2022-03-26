CREATE TABLE [dbo].[tblCTTermCostDetail]
(
	[intTermCostDetailId] INT IDENTITY NOT NULL, 
    [intTermCostId] INT NOT NULL, 
    [intCostId] INT NOT NULL, 
    [strCostMethod] NVARCHAR(50) NOT NULL, 
    [intCurrencyId] INT NULL, 
    [dblValue] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intUnitMeasureId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblCTTermCostDetail] PRIMARY KEY ([intTermCostDetailId]), 
    CONSTRAINT [FK_tblCTTermCostDetail_tblCTTermCost] FOREIGN KEY ([intTermCostId]) REFERENCES [tblCTTermCost]([intTermCostId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblCTTermCostDetail_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [FK_tblCTTermCostDetail_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
    CONSTRAINT [FK_tblCTTermCostDetail_tblICItem] FOREIGN KEY ([intCostId]) REFERENCES [tblICItem]([intItemId])
)
