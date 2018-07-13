PRINT N'BEGIN - IC Data Fix for 18.3. #4'
GO

IF EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.3)
BEGIN 
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
END 
GO

PRINT N'END - IC Data Fix for 18.3. #4'