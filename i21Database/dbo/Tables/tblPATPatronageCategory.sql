﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblPATPatronageCategory]
	(
		[intPatronageCategoryId] INT NOT NULL IDENTITY , 
		[strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strPurchaseSale] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strUnitAmount] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[intUnitMeasureId] INT NULL DEFAULT ((0)) ,
		[intSort] INT NULL DEFAULT ((0)),
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblPATPatronageCategory] PRIMARY KEY ([intPatronageCategoryId]), 
		CONSTRAINT [AK_tblPATPatronageCategory_strCategoryCode] UNIQUE ([strCategoryCode])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblPATPatronageCategory',
		@level2type = N'COLUMN',
		@level2name = N'intPatronageCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Category Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblPATPatronageCategory',
		@level2type = N'COLUMN',
		@level2name = N'strCategoryCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblPATPatronageCategory',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Purchase or Sale',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblPATPatronageCategory',
		@level2type = N'COLUMN',
		@level2name = N'strPurchaseSale'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit or Amount',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblPATPatronageCategory',
		@level2type = N'COLUMN',
		@level2name = N'strUnitAmount'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblPATPatronageCategory',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblPATPatronageCategory',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
GO

CREATE TRIGGER [dbo].[trgPurchaseSale]
    ON [dbo].[tblPATPatronageCategory]
   FOR UPDATE
AS 

if (UPDATE (strPurchaseSale))   
BEGIN
    SET NOCOUNT ON;

   UPDATE tblPATRefundRateDetail
      SET strPurchaseSale = inserted.strPurchaseSale
     FROM   inserted
    WHERE tblPATRefundRateDetail.intPatronageCategoryId = inserted.intPatronageCategoryId
END