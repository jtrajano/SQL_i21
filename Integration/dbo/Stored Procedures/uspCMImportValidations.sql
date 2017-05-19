/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: June 12, 2014
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  Cash Management - Import Validation 
   
   Description		   :  The purpose of this script to validate data before import takes place. It will allow the user to perform the 
						  corrections to avoid bad data imports. 

*/
GO
IF	EXISTS(select top 1 1 from sys.procedures where name = 'uspCMImportValidations')
	AND (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN 
	DROP PROCEDURE uspCMImportValidations

	EXEC('
		CREATE PROCEDURE [dbo].[uspCMImportValidations]
			@Invalid_UserId_Found AS BIT OUTPUT
			,@Invalid_GL_Account_Id_Found AS BIT OUTPUT
			,@Missing_GL_Account_Id AS BIT OUTPUT
			,@Invalid_Currency_Id_Found AS BIT OUTPUT
			,@Invalid_Bank_Account_Found AS BIT OUTPUT
			,@Missing_Default_Currency AS BIT OUTPUT
			,@Missing_Cash_Account_Group AS BIT OUTPUT
			,@Future_Clear_Date_Found AS BIT OUTPUT
			,@Unbalance_Found AS BIT OUTPUT
			,@Duplicate_Bank_Name_Found AS BIT OUTPUT
		AS

		DECLARE @CASH_ACCOUNT AS NVARCHAR(20) = ''Cash Account''
		DECLARE @ASSET AS NVARCHAR(20) = ''Asset''
	
		-- Check for invalid user id''s (WARN)
		SELECT	TOP 1 
				@Invalid_UserId_Found = 1  
		FROM	apcbkmst 
		WHERE	dbo.fnConvertOriginUserIdtoi21(apcbk_user_id) IS NULL

		-- Auto-fix the GL Accounts used in Origin. Move it to under the "Cash Accounts" group. 
		--UPDATE	tblGLAccount
		--SET		intAccountGroupId = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = ''Cash Accounts'')
		--from	tblGLAccount gl INNER JOIN (
		--			SELECT DISTINCT intGLAccountId = dbo.fnGetGLAccountIdFromOriginToi21(apcbk_gl_cash) FROM apcbkmst 
		--		) Q
		--			ON gl.intAccountId = Q.intGLAccountId

		-- Auto-fix the GL Accounts used in Origin. Move it to under the "Cash Accounts" category. 
		UPDATE	tblGLAccountSegment
		SET		intAccountCategoryId  = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = ''Cash Account'')
		from	tblGLAccount gl INNER JOIN (
					SELECT DISTINCT intGLAccountId = dbo.fnGetGLAccountIdFromOriginToi21(apcbk_gl_cash) FROM apcbkmst 
				) Q
					ON gl.intAccountId = Q.intGLAccountId INNER JOIN
                         dbo.tblGLAccountSegmentMapping ON gl.intAccountId = dbo.tblGLAccountSegmentMapping.intAccountId INNER JOIN
                         dbo.tblGLAccountSegment ON dbo.tblGLAccountSegmentMapping.intAccountSegmentId = dbo.tblGLAccountSegment.intAccountSegmentId

		-- Check for missing "Cash Account" group. (ERR)
		--SELECT @Missing_Cash_Account_Group = 1
		--WHERE NOT EXISTS (SELECT TOP 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = ''Cash Accounts'')
		SELECT @Missing_Cash_Account_Group = 1
		WHERE NOT EXISTS (SELECT TOP 1 intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = ''Cash Account'')

		-- Check for invalid GL accounts. It must be moved under the Cash Account Group before import can be done. (ERR)
		--SELECT	TOP 1 
		--		@Invalid_GL_Account_Id_Found = 1  
		--FROM	apcbkmst o INNER JOIN tblGLAccount accnt
		--			ON dbo.fnGetGLAccountIdFromOriginToi21(o.apcbk_gl_cash) = accnt.intAccountId
		--		INNER JOIN tblGLAccountGroup grp
		--			ON accnt.intAccountGroupId = grp.intAccountGroupId
		--WHERE	grp.strAccountGroup <> @CASH_ACCOUNT
		--		OR grp.strAccountType <> @ASSET
		SELECT	@Invalid_GL_Account_Id_Found = 1  
		FROM	apcbkmst o INNER JOIN vyuGLAccountDetail accnt
					ON dbo.fnGetGLAccountIdFromOriginToi21(o.apcbk_gl_cash) = accnt.intAccountId
		WHERE	accnt.strAccountCategory <> @CASH_ACCOUNT
				OR accnt.strAccountType <> @ASSET

		-- Check for missing GL Account from tblGLCOACrossReference. (ERR)
		SELECT @Missing_GL_Account_Id = 1
		FROM apcbkmst
		WHERE dbo.fnGetGLAccountIdFromOriginToi21(apcbk_gl_cash) IS NULL


		-- Check for bank accounts assigned to multiple GL accounts. 
		-- They must be moved to different Cash Accounts before import can be done. (ERR)
		SELECT @Invalid_Bank_Account_Found = 1
		WHERE EXISTS (SELECT TOP 1 apcbk_gl_cash, count(*) FROM apcbkmst GROUP BY apcbk_gl_cash HAVING count(*) > 1)

		-- Check for missing default currency. 
		SELECT	TOP 1
				@Missing_Default_Currency = 0
		FROM	tblSMCurrency 
		WHERE	intCurrencyID = (SELECT CAST(strValue AS INT) FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'')

		-- Check for invalid currency id''s. It must be defined first before import can be done (ERR). 
		SELECT	TOP 1 
				@Invalid_Currency_Id_Found = 1  
		FROM	apcbkmst
		WHERE	dbo.fnGetCurrencyIdFromOriginToi21(apcbk_currency) IS NULL
				AND apcbk_currency IS NOT NULL
				
		-- Check if there is a future clearing date (ERR)
		SELECT	TOP 1 @Future_Clear_Date_Found = 1
		FROM	apchkmst
		WHERE	apchk_clear_rev_dt > CONVERT(VARCHAR(10),GETDATE(),112)

		-- Check if balance against the running balance on GL(ERR)
		SELECT TOP 1 @Unbalance_Found = 1 FROM(
			SELECT 
			strExternalId,
			CASE WHEN  SUM(dblDebit-dblCredit) <> apcbk_bal THEN 1 ELSE 0 END AS NotBalance
			FROM 
			tblGLDetail INNER JOIN tblGLCOACrossReference ON tblGLDetail.intAccountId = tblGLCOACrossReference.inti21Id
			INNER JOIN apcbkmst ON tblGLCOACrossReference.strExternalId = apcbk_gl_cash
			AND ysnIsUnposted = 0
			GROUP BY strExternalId, apcbk_bal
		) AS T
		WHERE NotBalance = 1

		--Check for duplicate Bank Name
		SELECT TOP 1 @Duplicate_Bank_Name_Found = 1 
		FROM(
				SELECT  ssbnk_name = i.ssbnk_name COLLATE Latin1_General_CI_AS
				FROM ssbnkmst i
				GROUP BY i.ssbnk_name COLLATE Latin1_General_CI_AS
				HAVING (COUNT(i.ssbnk_name) > 1)
			) Q


		SELECT	@Invalid_UserId_Found = ISNULL(@Invalid_UserId_Found, 0)
				,@Invalid_GL_Account_Id_Found = ISNULL(@Invalid_GL_Account_Id_Found, 0)
				,@Missing_GL_Account_Id = ISNULL(@Missing_GL_Account_Id,0)
				,@Invalid_Currency_Id_Found = ISNULL(@Invalid_Currency_Id_Found,0)
				,@Invalid_Bank_Account_Found = ISNULL(@Invalid_Bank_Account_Found, 0)
				,@Missing_Default_Currency = ISNULL(@Missing_Default_Currency, 1)
				,@Missing_Cash_Account_Group = ISNULL(@Missing_Cash_Account_Group, 0)
				,@Future_Clear_Date_Found = ISNULL(@Future_Clear_Date_Found, 0)	
				,@Unbalance_Found = ISNULL(@Unbalance_Found, 0)	
				,@Duplicate_Bank_Name_Found = ISNULL(@Duplicate_Bank_Name_Found, 0)	
	')

END

