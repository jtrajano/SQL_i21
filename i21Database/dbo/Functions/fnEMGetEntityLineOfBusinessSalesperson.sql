CREATE FUNCTION [dbo].[fnEMGetEntityLineOfBusinessSalesperson]
(
	@intEntityId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(c.strName)) 
		from tblEMEntityLineOfBusiness a			
			join tblEMEntity b
				on a.intEntityId = b.intEntityId
			JOIN [tblEMEntity] c
				on c.intEntityId = a.intEntitySalespersonId
	where a.intEntityId = @intEntityId
	RETURN @col
END