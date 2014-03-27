
CREATE FUNCTION fnGetCurrencyIdFromOriginToi21(@strOriginCurrencyId AS NVARCHAR(3))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intCurrencyId INT

	SELECT	@intCurrencyId = intCurrencyId
	FROM	dbo.tblSMCurrency 
	WHERE	strCurrency = @strOriginCurrencyId

	RETURN @intCurrencyId
END