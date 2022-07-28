CREATE TABLE [dbo].[tblGRAdjustmentType]
(
	[intAdjustmentTypeId] INT NOT NULL IDENTITY(1,1)
	,[strAdjustmentType] NVARCHAR(40)
	,[intConcurrencyId] INT NULL DEFAULT ((1)), 
	CONSTRAINT [PK_tblGRAdjustmentType_intAdjustmentTypeId] PRIMARY KEY ([intAdjustmentTypeId])
)
