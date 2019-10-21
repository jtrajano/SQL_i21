CREATE FUNCTION [dbo].[fnEMGetEntityAreaOfInterest]
(
	@intEntityId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(c.strType)) 
		from tblEMEntityAreaOfInterest a			
			join tblEMEntity b
				on a.intEntityId = b.intEntityId
			join tblHDTicketType c
				on c.intTicketTypeId = a.intTicketTypeId
	where a.intEntityId = @intEntityId
	RETURN @col
END