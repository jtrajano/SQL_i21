CREATE FUNCTION [dbo].[fnCMGetBankAccountHistoricRate]
	(
	@intBankAccountId INT,
	@dtmDate DATETIME
	)
RETURNS  DECIMAL(18,6)

AS

BEGIN
DECLARE @result DECIMAL(18,6)


SELECT  @result= AVG(dblExchangeRate) FROM tblCMBankTransaction 
WHERE intBankAccountId = @intBankAccountId
AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
AND ysnPosted =1


RETURN @result
END

