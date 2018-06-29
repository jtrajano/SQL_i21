PRINT N'BEGIN - Assign data for Stock UOM for the first time.'
GO

IF EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE ysnStockUOM IS NULL)
BEGIN
	UPDATE	tblICItemUOM
	SET		ysnStockUOM = 1 
	WHERE	ysnStockUnit = 1
			AND ysnStockUOM IS NULL 

	UPDATE	tblICItemUOM
	SET		ysnStockUOM = ISNULL(ysnStockUOM, 0) 
	WHERE	ysnStockUOM IS NULL 
END 

IF EXISTS (SELECT TOP 1 1 FROM tblICCommodityUnitMeasure WHERE ysnStockUOM IS NULL)
BEGIN
	UPDATE	tblICCommodityUnitMeasure
	SET		ysnStockUOM = 1 
	WHERE	ysnStockUnit = 1
			AND ysnStockUOM IS NULL 

	UPDATE	tblICCommodityUnitMeasure
	SET		ysnStockUOM = ISNULL(ysnStockUOM, 0) 
	WHERE	ysnStockUOM IS NULL 
END 

GO
PRINT N'END - Assign data for Stock UOM for the first time.'