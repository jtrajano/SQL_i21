CREATE FUNCTION [dbo].[fnEMGetEntityCompetitors]
(
	@intEntityId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(b.strName)) 
		from tblARCustomerCompetitor a 
			join vyuEMSearchEntityCompetitor b
				on a.intEntityId = b.intEntityId
	where a.intEntityCustomerId= @intEntityId
	RETURN @col
END




