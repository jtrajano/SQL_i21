CREATE FUNCTION [dbo].[fnEMEntityMessage]
(
	@intEntityId	INT,
	@strMessageType	NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(a.strMessage)) 
		from tblEMEntityMessage a
	where a.intEntityId = @intEntityId
		and (@strMessageType = '' OR a.strMessageType = @strMessageType )
	RETURN @col


END