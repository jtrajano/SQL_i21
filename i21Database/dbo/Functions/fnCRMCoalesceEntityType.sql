CREATE FUNCTION [dbo].[fnCRMCoalesceEntityType](@intEntityId int)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strEntityType nvarchar(max);
	SELECT
		@strEntityType = COALESCE(@strEntityType + ', ', '') + tblEMEntityType.strType
	FROM
		tblEMEntityType
	WHERE
		tblEMEntityType.intEntityId = @intEntityId

	return @strEntityType

END