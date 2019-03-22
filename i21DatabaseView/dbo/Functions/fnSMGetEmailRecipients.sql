CREATE FUNCTION [dbo].[fnSMGetEmailRecipients]
(
	@intEMailId		int
)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @col NVARCHAR(MAX);	
	select @col = COALESCE(@col + ', ', '') + RTRIM(LTRIM(strEmailAddress)) 
		from tblSMEmailRecipient where intEmailId = @intEMailId
	RETURN @col
END

