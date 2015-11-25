CREATE TABLE [dbo].[tblSTMarkUpDownDetail]
(
	[intMarkUpDownDetailId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intMarkUpDownId] INT NOT NULL,
	[intItemUOMId] INT,
	[intCategoryId] INT,
	[strMarkUpOrDown] nvarchar(50),
	[strRetailShrinkRS] nvarchar(50),
	[intQty] int, 
    [dblRetailPerUnit] NUMERIC(18, 6) NULL, 
    [dblTotalRetailAmount] NUMERIC(18, 6) NULL, 
    [dblTotalCostAmount] NUMERIC(18, 6) NULL, 
    [strNote] NVARCHAR(250) NULL, 
    [dblActulaGrossProfit] NUMERIC(18, 6) NULL, 
    [ysnSentToHost] BIT NULL, 
    [strReason] NVARCHAR(250) NULL, 
    [intConcurrencyId] INT NULL,
	CONSTRAINT [FK_tblSTMarkUpDownDetail_tblSTMarkUpDown_intMarkUpDownId] FOREIGN KEY ([intMarkUpDownId]) REFERENCES [dbo].[tblSTMarkUpDown] ([intMarkUpDownId]) ON DELETE CASCADE,  
	
)
