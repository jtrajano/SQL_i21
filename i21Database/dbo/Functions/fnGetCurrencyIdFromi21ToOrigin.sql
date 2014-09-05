
-- Create a default function. 
-- 
-- It always return NULL because the origin table sscurmst is not found in the database. 
CREATE FUNCTION fnGetCurrencyIdFromi21ToOrigin(@inti21CurrencyID AS INT)	
RETURNS CHAR(3) 
AS
BEGIN 
	RETURN NULL
END