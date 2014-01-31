
CREATE FUNCTION fn_GetCurrencyIdFromi21ToOrigin(@inti21CurrencyID AS INT)	
RETURNS CHAR(3) 
AS
BEGIN 

	DECLARE @sscur_key CHAR(3) 
	
	SELECT	@sscur_key = sscur_key
	FROM	dbo.sscurmst curL INNER JOIN dbo.tblSMCurrency curi21
				ON LTRIM(RTRIM(UPPER(curi21.strCurrency))) = LTRIM(RTRIM(UPPER(curL.sscur_key))) COLLATE Latin1_General_CI_AS 
	WHERE	curi21.intCurrencyID = @inti21CurrencyID
				
	RETURN @sscur_key COLLATE SQL_Latin1_General_CP1_CS_AS
END