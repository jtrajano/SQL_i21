CREATE TABLE [dbo].[tblCTPackingDescription](
	[intPackingDescriptionId] [INT] IDENTITY(1,1) NOT NULL,
	[strPackingDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strShortName] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnWeightDefinition] [bit] NULL,
	[dblWeightPerUnit] [numeric](18, 4) NULL,
	[intWeightPerUnitUOMId] [INT] NULL,
	[intPhysicalCountUOMId] [INT] NULL,
	[intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblCTPackingDescription_intPackingDescriptionId] PRIMARY KEY CLUSTERED ([intPackingDescriptionId] ASC),
	CONSTRAINT [UK_tblCTPackingDescription_strPackingDescription] UNIQUE ([strPackingDescription]),
	CONSTRAINT [FK_tblCTContractDetail_intWeightPerUnitUOMId_intPriceUOMId_intUnitMeasureId] FOREIGN KEY ([intWeightPerUnitUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICUnitMeasure_intPhysicalCountUOMId_intUnitMeasureId] FOREIGN KEY ([intPhysicalCountUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
 )