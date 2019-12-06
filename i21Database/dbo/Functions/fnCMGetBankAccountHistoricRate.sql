CREATE FUNCTION [dbo].[fnCMGetBankAccountHistoricRate]
	(
	@intBankAccountId INT,
	@dtmDate DATETIME
	)
RETURNS  DECIMAL(18,6)

AS

BEGIN
DECLARE @result DECIMAL(18,6)
DECLARE @bankBalance decimal(18,6)
DECLARE @glBalance decimal(18,6)
DECLARE @intGLAccountId INT
DECLARE @intCurrencyId INT

SELECT TOP 1 @intGLAccountId =intGLAccountId, @intCurrencyId = intCurrencyId
FROM tblCMBankAccount where intBankAccountId = @intBankAccountId

SELECT  @result= AVG(dblExchangeRate) FROM tblCMBankTransaction 
WHERE intBankAccountId = @intBankAccountId
AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
AND ysnPosted =1


RETURN @result
END

