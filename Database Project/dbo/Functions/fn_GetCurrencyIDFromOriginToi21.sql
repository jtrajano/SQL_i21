
CREATE FUNCTION fn_GetCurrencyIDFromOriginToi21(@strOriginCurrencyID AS NVARCHAR(3))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intCurrencyID INT

	SELECT	@intCurrencyID = intCurrencyID
	FROM	dbo.tblSMCurrency 
	WHERE	strCurrency = @strOriginCurrencyID

	RETURN @intCurrencyID
END