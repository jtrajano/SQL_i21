CREATE TABLE [dbo].[tblCTIndex]
(
	[intIndexId] INT IDENTITY NOT NULL,
	[strIndex] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[dblAdjustment] NUMERIC(4,2) NOT NULL, 
    [intUnitMeasureId] INT NOT NULL, 
    [ysnActive] BIT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblCTIndex_intIndexId] PRIMARY KEY CLUSTERED ([intIndexId] ASC),
	CONSTRAINT [FK_tblCTIndex_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
