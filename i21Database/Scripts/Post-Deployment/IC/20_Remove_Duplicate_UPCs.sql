PRINT N'START- IC Remove Duplicate UPCs'
GO
-- Remove the old check constraint. 
IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_tblICItemUOM_intUpcCode' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
BEGIN 
	EXEC ('ALTER TABLE [tblICItemUOM] DROP CONSTRAINT CK_tblICItemUOM_intUpcCode')
END 
GO 
IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_tblICItemUOM_intUpcCode2' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
BEGIN 
	EXEC ('ALTER TABLE [tblICItemUOM] DROP CONSTRAINT CK_tblICItemUOM_intUpcCode2')
END 
GO 
-- Add the CHECK CONSTRAINTS in tblICItemUOM
IF NOT EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_tblICItemUOM_intUpcCode3' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
BEGIN
    ;WITH CTE
    AS
    (
        SELECT intItemUOMId, intUpcCode, strLongUPCCode, ROW_NUMBER() OVER (PARTITION BY intUpcCode ORDER BY intUpcCode) AS rc
        FROM tblICItemUOM
        WHERE intUpcCode IS NOT NULL
    )
    UPDATE CTE SET strLongUPCCode = NULL WHERE rc > 1;
    
	EXEC('ALTER TABLE tblICItemUOM ADD CONSTRAINT CK_tblICItemUOM_intUpcCode3 CHECK(dbo.fnICIsUpcExists2(strLongUPCCode, intItemUOMId, intModifier) = 0)');
END

PRINT N'END - IC Add Remove Duplicate UPCs'
GO