CREATE FUNCTION [dbo].[fnGLGetActivityBalance] 
(	
	@strAccountId NVARCHAR(100),
	@dtmDate DATETIME,
	@strBalanceType NVARCHAR(30),
	@strBalanceOrUnit NVARCHAR(10)
)
RETURNS @tbl TABLE (
balance NUMERIC (18,6)
)

AS
BEGIN
		DECLARE @isRetainedAccount BIT = 0
		INSERT INTO @tbl
		SELECT ISNULL(Bal.balance,0.00)
			FROM tblGLAccount Account 
			JOIN tblGLAccountGroup Grop ON Account.intAccountGroupId = Grop.intAccountGroupId
			OUTER APPLY (SELECT TOP 1 ISNULL(intRetainAccount,0)account from tblGLFiscalYear WHERE intRetainAccount = Account.intAccountId) re
			CROSS APPLY dbo.fnGLGetBalancesDateCriteria(@dtmDate,Grop.strAccountType, @strBalanceType,re.account) Dates
			CROSS APPLY dbo.fnGLComputeBalance(Account.intAccountId, Dates.dtmDateFrom,Dates.dtmDateTo,Grop.strAccountType,@strBalanceOrUnit,NULL,re.account)Bal
			WHERE Account.strAccountId = @strAccountId
		RETURN
END