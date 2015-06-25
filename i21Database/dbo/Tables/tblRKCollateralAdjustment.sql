CREATE TABLE [dbo].[tblRKCollateralAdjustment]
(
	[intCollateralAdjustmentId] INT IDENTITY(1,1) NOT NULL, 
	[intCollateralId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[dtmAdjustmentDate] INT NOT NULL, 
	[dblRemainingQuantity] numeric(18,6)  NOT NULL, 
	[dblAdjustmentAmount] numeric(18,6)  NOT NULL, 
	[strComments] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intAdjustmentNo] INT NOT NULL
	
	CONSTRAINT [PK_tblRKCollateralAdjustment_intCollateralAdjustmentId] PRIMARY KEY ([intCollateralAdjustmentId])
	CONSTRAINT [FK_tblRKCollateralAdjustment_tblRKCollateral_intCollateralId] FOREIGN KEY([intCollateralId])REFERENCES [dbo].[tblRKCollateral] ([intCollateralId])
)
