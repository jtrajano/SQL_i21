
-- Create a dummy view
-- The real view is in the integration script. The dummy view is used to avoid errors in the undeposited screen process when the 
-- origin AP module is not installed. 

CREATE VIEW [dbo].[vyuCMOriginUndepositedFund]
AS

SELECT	id = CAST(NULL AS INT) 
		,intUndepositedFundId = CAST(NULL AS INT)
		,intBankAccountId = CAST(NULL AS INT)
		,intGLAccountId = CAST(NULL AS INT)
		,strAccountDescription = CAST(NULL AS NVARCHAR(255))
		,dblAmount = CAST(NULL AS NUMERIC(18,6))
		,strName = CAST(NULL AS NVARCHAR(200)) 
		,dtmDate = CAST(NULL AS DATETIME)
WHERE 1 = 0

