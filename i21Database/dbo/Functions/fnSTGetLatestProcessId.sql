CREATE FUNCTION [dbo].[fnSTGetLatestProcessId] 
(
	@intCheckoutId AS INT
)
RETURNS INT
AS BEGIN

    DECLARE @intCheckoutProcessId INT  = 0

    SELECT		TOP 1
                @intCheckoutProcessId = intCheckoutProcessId
    FROM		tblSTCheckoutProcess
    WHERE		intCheckoutId = @intCheckoutId
    ORDER BY    dtmCheckoutProcessDate  DESC

    RETURN @intCheckoutProcessId
END