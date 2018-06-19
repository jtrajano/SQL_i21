﻿CREATE TABLE [dbo].[tblSTMarkUpDownDetail]
(
	[intMarkUpDownDetailId] INT NOT NULL IDENTITY,
	[intMarkUpDownId] INT NOT NULL,
	[intItemId] INT NULL,
	[intCategoryId] INT NULL,
	[strMarkUpOrDown] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strRetailShrinkRS] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intQty] NUMERIC(18, 6) NULL, 
    [dblRetailPerUnit] NUMERIC(18, 6) NULL, 
    [dblTotalRetailAmount] NUMERIC(18, 6) NULL, 
    [dblTotalCostAmount] NUMERIC(18, 6) NULL, 
    [strNote] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [dblActulaGrossProfit] NUMERIC(18, 6) NULL, 
    [ysnSentToHost] BIT NULL, 
    [strReason] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTMarkUpDownDetail] PRIMARY KEY CLUSTERED ([intMarkUpDownDetailId] ASC), 
	CONSTRAINT [FK_tblSTMarkUpDownDetail_tblSTMarkUpDown_intMarkUpDownId] FOREIGN KEY ([intMarkUpDownId]) REFERENCES [dbo].[tblSTMarkUpDown] ([intMarkUpDownId]) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblSTMarkUpDownDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSTMarkUpDownDetail_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
)
