CREATE TABLE [dbo].[tblMFNutrient]
(
	[intNutrientId] INT NOT NULL IDENTITY(1,1),
	[intCommodityId] INT,
	[intPropertyId] INT,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFNutrient_intConcurrencyId] DEFAULT 0, 
	CONSTRAINT [PK_tblMFNutrient_intNutrientId] PRIMARY KEY ([intNutrientId]),
	CONSTRAINT [FK_tblMFNutrient_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblMFNutrient_tblQMProperty_intPropertyId] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]),
	CONSTRAINT [UQ_tblMFNutrient_intCommodityId_intPropertyId] UNIQUE ([intCommodityId],[intPropertyId])
)
