CREATE FUNCTION [dbo].[fnSTGetLatestProcessId] 
(
	@intStoreId AS INT
)
RETURNS INT
AS BEGIN

    DECLARE @intCheckoutProcessId INT  = 0

    SELECT		TOP 1
                @intCheckoutProcessId = intCheckoutProcessId
    FROM		tblSTCheckoutProcess
    WHERE		intStoreId = @intStoreId
    ORDER BY    intCheckoutProcessId  DESC

    RETURN @intCheckoutProcessId
END