
-- Create a default function. 
-- 
-- It always return none. It means all bank records are assumed to be created in i21 and not in the Deposit Entry (origin). 

-- This default function solves the following: 
-- 1. If Integration is not established, it is assumed all bank records are not from the Deposit Entry. 
-- 2. It avoids failure on all stored procedures in i21Database that is using this function. 
-- 3. When integration is established, the function is overwritten by the integration script deployment. 
CREATE FUNCTION [dbo].[fnGetDepositEntry]()
	RETURNS @OriginDepositEntrty TABLE 
	(
		strLink NVARCHAR(100) COLLATE Latin1_General_CI_AS
	)
AS
BEGIN
	RETURN
END