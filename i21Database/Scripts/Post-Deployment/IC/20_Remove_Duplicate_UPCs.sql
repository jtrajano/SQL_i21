PRINT N'START- IC Remove Duplicate UPCs'
GO

-- Add the CHECK CONSTRAINTS in tblICItemUOM
IF NOT EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_tblICItemUOM_intUpcCode' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
BEGIN
    ;WITH CTE
    AS
    (
        SELECT intItemUOMId, intUpcCode, strLongUPCCode, ROW_NUMBER() OVER (PARTITION BY intUpcCode ORDER BY intUpcCode) AS rc
        FROM tblICItemUOM
        WHERE intUpcCode IS NOT NULL
    )
    UPDATE CTE SET strLongUPCCode = NULL WHERE rc > 1;
    
	EXEC('ALTER TABLE tblICItemUOM ADD CONSTRAINT CK_tblICItemUOM_intUpcCode CHECK(dbo.fnICIsUpcExists(RTRIM(LTRIM(intUpcCode))) = 0)');
END

PRINT N'END - IC Add Remove Duplicate UPCs'
GO