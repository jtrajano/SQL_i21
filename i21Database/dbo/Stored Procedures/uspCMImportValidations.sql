/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: June 12, 2014
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  Cash Management - Import Validation 
   
   Description		   :  The purpose of this script to validate data before import takes place. It will allow the user to perform the 
						  corrections to avoid bad data imports. 

*/
CREATE PROCEDURE [dbo].[uspCMImportValidations]
	@Invalid_UserId_Found AS BIT OUTPUT
	,@Invalid_GL_Account_Id_Found AS BIT OUTPUT
	,@Invalid_Currency_Id_Found AS BIT OUTPUT
	,@Missing_Default_Currency AS BIT OUTPUT
AS

DECLARE @CASH_ACCOUNT AS NVARCHAR(20) = 'Cash Accounts'
DECLARE @ASSET AS NVARCHAR(20) = 'Asset'
	
-- Check for invalid user id's (WARN)
SELECT	TOP 1 
		@Invalid_UserId_Found = 1  
FROM	apcbkmst 
WHERE	dbo.fnConvertOriginUserIdtoi21(apcbk_user_id) IS NULL

-- Auto-fix the GL Accounts used in Origin. Move it to under the "Cash Accounts" group. 
UPDATE	tblGLAccount
SET		intAccountGroupId = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Cash Accounts')
from	tblGLAccount gl INNER JOIN (
			SELECT DISTINCT intGLAccountId = dbo.fnGetGLAccountIdFromOriginToi21(apcbk_gl_cash) FROM apcbkmst 
		) Q
			ON gl.intAccountId = Q.intGLAccountId

-- Check for invalid GL accounts. It must be moved under the Cash Account Group before import can be done. (ERR)
SELECT	TOP 1 
		@Invalid_GL_Account_Id_Found = 1  
FROM	apcbkmst o INNER JOIN tblGLAccount accnt
			ON dbo.fnGetGLAccountIdFromOriginToi21(o.apcbk_gl_cash) = accnt.intAccountId
		INNER JOIN tblGLAccountGroup grp
			ON accnt.intAccountGroupId = grp.intAccountGroupId
WHERE	grp.strAccountGroup <> @CASH_ACCOUNT
		OR grp.strAccountType <> @ASSET

-- Check for missing default currency. 
SELECT	TOP 1
		@Missing_Default_Currency = 0
FROM	tblSMCurrency 
WHERE	intCurrencyID = (SELECT CAST(strValue AS INT) FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')

-- Check for invalid currency id's. It must be defined first before import can be done (ERR). 
SELECT	TOP 1 
		@Invalid_Currency_Id_Found = 1  
FROM	apcbkmst
WHERE	dbo.fnGetCurrencyIdFromOriginToi21(apcbk_currency) IS NULL
		AND apcbk_currency IS NOT NULL 

SELECT	@Invalid_UserId_Found = ISNULL(@Invalid_UserId_Found, 0)
		,@Invalid_GL_Account_Id_Found = ISNULL(@Invalid_GL_Account_Id_Found, 0)
		,@Invalid_Currency_Id_Found = ISNULL(@Invalid_Currency_Id_Found,0)
		,@Missing_Default_Currency = ISNULL(@Missing_Default_Currency, 1)

GO