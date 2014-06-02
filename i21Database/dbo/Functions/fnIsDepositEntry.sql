
-- Create a default function. 
-- 
-- It always return zero (false). It means all bank records are assumed to be created in i21 and not in the Deposit Entry (origin). 

-- This default function solves the following: 
-- 1. If Integration is not established, it is assumed all bank records are not from the Deposit Entry. 
-- 2. It avoids failure on all stored procedures in i21Database that is using this function. 
-- 3. When integration is established, the function is overwritten by the integration script deployment. 
CREATE FUNCTION [dbo].[fnIsDepositEntry](
	@strLink NVARCHAR(50)
)
	RETURNS BIT 
AS
BEGIN
	RETURN 0
END