﻿CREATE TABLE [dbo].[tblRKCollateralAdjustment]
(
	[intCollateralAdjustmentId] INT IDENTITY(1,1) NOT NULL, 
	[intCollateralId] INT NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)), 
	[dtmAdjustmentDate] DATETIME NOT NULL, 
	[dblAdjustmentAmount] numeric(18,6)  NOT NULL, 
	[strComments] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strAdjustmentNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	
	CONSTRAINT [PK_tblRKCollateralAdjustment_intCollateralAdjustmentId] PRIMARY KEY ([intCollateralAdjustmentId])
	CONSTRAINT [FK_tblRKCollateralAdjustment_tblRKCollateral_intCollateralId] FOREIGN KEY([intCollateralId])REFERENCES [dbo].[tblRKCollateral] ([intCollateralId]) ON DELETE CASCADE 
)
