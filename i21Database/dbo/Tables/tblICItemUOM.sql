CREATE TABLE [dbo].[tblICItemUOM]
(
	[intItemUOMId] INT NOT NULL IDENTITY , 
	[intItemId] INT NOT NULL,
    [intUnitMeasureId] INT NOT NULL, 
    [dblUnitQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblSellQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[strDescription] NVARCHAR(50) NULL, 
	[dblLength] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblVolume] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMaxQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemUOM] PRIMARY KEY ([intItemUOMId]), 
    CONSTRAINT [FK_tblICItemUOM_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemUOM_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
