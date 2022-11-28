CREATE FUNCTION [dbo].[fnApiSchemaTransformHasField] (@guiApiUniqueId UNIQUEIDENTIFIER, @strField NVARCHAR(200))
RETURNS BIT
AS
BEGIN
    
DECLARE @Value BIT

IF EXISTS(SELECT * FROM tblApiSchemaTransformSourceField WHERE strTargetField = @strField)
    SET @Value = 1
ELSE
    SET @Value = 0

RETURN @Value

END