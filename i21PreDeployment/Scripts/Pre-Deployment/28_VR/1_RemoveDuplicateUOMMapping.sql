EXEC(N'IF (OBJECT_ID(''UQ_tblVRUOMXref_strVendorUOM_intEntityId'', ''UQ'') IS NOT NULL)
BEGIN
    ALTER TABLE tblVRUOMXref
    DROP CONSTRAINT UQ_tblVRUOMXref_strVendorUOM_intEntityId
END')

GO

-- Remove duplicate UOM mapping
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblVRUOMXref]') AND type in (N'U'))
BEGIN
    ;WITH cte AS
    (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY intVendorSetupId, intUnitMeasureId ORDER BY intVendorSetupId, intUnitMeasureId) AS Count
    FROM tblVRUOMXref
    )
    DELETE FROM cte
    WHERE Count > 1;
END;

GO