CREATE TABLE [dbo].[tblICCommodityProductLine]
(
	[intCommodityProductLineId] INT NOT NULL IDENTITY, 
    [intCommodityId] INT NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnDeltaHedge] BIT NULL DEFAULT ((0)), 
    [dblDeltaPercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCommodityProductLine] PRIMARY KEY ([intCommodityProductLineId]), 
    CONSTRAINT [FK_tblICCommodityProductLine_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
)
