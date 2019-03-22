CREATE FUNCTION [dbo].[fnEMGetEntityLineOfBusiness]
(
	@intEntityId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(c.strLineOfBusiness)) 
		from tblEMEntityLineOfBusiness a			
			join tblEMEntity b
				on a.intEntityId = b.intEntityId
			join [tblSMLineOfBusiness] c
				on c.intLineOfBusinessId = a.intLineOfBusinessId
	where a.intEntityId = @intEntityId
	RETURN @col
END

