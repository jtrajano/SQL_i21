CREATE TABLE [dbo].[tblLGContainerType]
(
	[intContainerTypeId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strContainerType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblLength] NUMERIC(18, 6) NULL , 
    [dblWidth] NUMERIC(18, 6) NULL , 
    [dblHeight] NUMERIC(18, 6) NULL, 
    [intDimensionUnitMeasureId] INT NULL, 
    [dblNetWeight] NUMERIC(18, 6) NULL, 
    [dblEmptyWeight] NUMERIC(18, 6) NULL, 
    [dblGrossWeight] NUMERIC(18, 6) NULL, 
    [intWeightUnitMeasureId] INT NULL, 
    CONSTRAINT [PK_tblLGContainerType_intContainerTypeId] PRIMARY KEY ([intContainerTypeId]), 
    CONSTRAINT [FK_tblLGContainerType_tblICUnitMeasure_intDimensionUnitMeasureId] FOREIGN KEY ([intDimensionUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGContainerType_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
