IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICEffectiveItemPrice]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'intItemUOMId' AND OBJECT_ID = OBJECT_ID(N'tblICEffectiveItemPrice')) 
    BEGIN
		EXEC('ALTER TABLE tblICEffectiveItemPrice ADD intItemUOMId INT NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'intItemUOMId' AND OBJECT_ID = OBJECT_ID(N'tblICEffectiveItemPrice')) 
    BEGIN
		EXEC('
			UPDATE EffectiveItemPrice
			SET 
				EffectiveItemPrice.intItemUOMId = ItemUOM.intItemUOMId 
			FROM	
				tblICEffectiveItemPrice EffectiveItemPrice
			LEFT JOIN 
				tblICItemUOM ItemUOM
				ON 
					EffectiveItemPrice.intItemId = ItemUOM.intItemId
					AND
					ItemUOM.ysnStockUnit = 1
			WHERE
				EffectiveItemPrice.intItemUOMId IS NULL				
		')

		EXEC('
			ALTER TABLE tblICEffectiveItemPrice
			ALTER COLUMN intItemUOMId INT NOT NULL;
		')
    END
END