CREATE FUNCTION [dbo].[fnApiSchemaTransformMapField] (@guiApiUniqueId UNIQUEIDENTIFIER, @strField NVARCHAR(200))
RETURNS NVARCHAR(400)
AS
BEGIN
    
DECLARE @strMap NVARCHAR(400)
SELECT @strMap = COALESCE(strSourceField, strTargetField)
FROM tblApiSchemaTransformMappedField 
WHERE strTargetField = @strField

RETURN ISNULL(@strMap, @strField)

END