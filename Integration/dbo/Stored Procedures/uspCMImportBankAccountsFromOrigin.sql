/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 19, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :  Cash Management - Bank and Bank Accounts Import Script. 
   
   Description		   :  The purpose of this script is to import bank account records from the origin system to the i21 system. 

   Sequence of scripts to run the import: 
	   1. uspCMImportBankAccountsFromOrigin (*This file)
	   2. uspCMImportBankTransactionsFromOrigin
	   3. uspCMImportBankReconciliationFromOrigin   
*/
GO
IF	EXISTS(select top 1 1 from sys.procedures where name = 'uspCMImportBankAccountsFromOrigin')
	AND (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN 
	DROP PROCEDURE uspCMImportBankAccountsFromOrigin

	EXEC('
		CREATE PROCEDURE [dbo].[uspCMImportBankAccountsFromOrigin]
		AS

		-- Bank Account Types:
		DECLARE @DEPOSIT_ACCOUNT INT = 1
		DECLARE @LOAN_ACCOUNT INT = 2

		-- MICR: ACCOUNT SPACE POSITION
		DECLARE @ACCOUNT_LEADING INT = 1
		DECLARE @ACCOUNT_TRAILING INT = 2

		-- MICR: CHECK NUMBER SPACE POSITION
		DECLARE @CHECKNO_LEADING INT = 1
		DECLARE @CHECKNO_TRAILING INT = 2

		-- MICR: CHECK NUMBER POSITION
		DECLARE @CHECKNO_LEFT INT = 1
		DECLARE @CHECKNO_MIdDLE INT = 2
		DECLARE @CHECKNO_RIGHT INT = 3

		-- DEFAULT CURRENCY
		DECLARE @intCurrencyId AS INT

		SELECT	TOP 1 
				@intCurrencyId = intCurrencyID 
		FROM	tblSMCurrency INNER JOIN tblSMPreferences
					ON tblSMCurrency.intCurrencyID = CAST(tblSMPreferences.strValue AS INT)
		WHERE	tblSMPreferences.strPreference = ''defaultCurrency''

		-- Auto-fix the GL Accounts used in Origin. Move it to under the "Cash Accounts" category. 
		--UPDATE	tblGLAccount
		--SET		intAccountGroupId = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = ''Cash Accounts''),
		--		intAccountCategoryId = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = ''Cash Account'')
		--from	tblGLAccount gl INNER JOIN (
		--			SELECT DISTINCT intGLAccountId = dbo.fnGetGLAccountIdFromOriginToi21(apcbk_gl_cash) FROM apcbkmst 
		--		) Q
		--			ON gl.intAccountId = Q.intGLAccountId

		-- Auto-fix the GL Account Segment used on GL Account. Move it under "Cash Account" category.
		UPDATE tblGLAccountSegment
		SET intAccountCategoryId = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = ''Cash Account'')
		WHERE intAccountSegmentId IN (Select DISTINCT intAccountSegmentId
										FROM tblGLAccount gl 
										INNER JOIN (SELECT DISTINCT intGLAccountId = dbo.fnGetGLAccountIdFromOriginToi21(apcbk_gl_cash) FROM apcbkmst ) Q
											ON gl.intAccountId = Q.intGLAccountId
										INNER JOIN tblGLAccountSegmentMapping ASM ON gl.intAccountId = ASM.intAccountId)

		-- INSERT new records for tblCMBank
		INSERT INTO tblCMBank (
				strBankName
				,strContact
				,strAddress
				,strZipCode
				,strCity
				,strState
				,strCountry
				,strPhone
				,strFax
				,strWebsite
				,strEmail
				,strRTN
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,intConcurrencyId
			)
		SELECT	strBankName				= LTRIM(RTRIM(ISNULL(QUERY.apcbk_desc, ''''))) 
				,strContact				= ''''
				,strAddress				= ''''
				,strZipCode				= ''''
				,strCity				= ''''
				,strState				= ''''
				,strCountry				= ''''
				,strPhone				= ''''
				,strFax					= ''''
				,strWebsite				= ''''	
				,strEmail				= ''''
				,strRTN					= (SELECT TOP 1 ISNULL(CAST(A.apcbk_transit_route AS NVARCHAR(12)), '''') FROM apcbkmst A WHERE A.apcbk_desc = QUERY.apcbk_desc) 
				,intCreatedUserId		= (SELECT TOP 1 dbo.fnConvertOriginUserIdtoi21(A.apcbk_user_id) FROM apcbkmst A WHERE A.apcbk_desc = QUERY.apcbk_desc) 
				,dtmCreated				= GETDATE()
				,intLastModifiedUserId	= (SELECT TOP 1 dbo.fnConvertOriginUserIdtoi21(A.apcbk_user_id) FROM apcbkmst A WHERE A.apcbk_desc = QUERY.apcbk_desc) 
				,dtmLastModified		= GETDATE()
				,intConcurrencyId		= 1
		FROM	(	SELECT	DISTINCT 
							apcbk_desc = i.apcbk_desc COLLATE Latin1_General_CI_AS
					FROM	apcbkmst i
					WHERE apcbk_bnk_no IS NULL 
				) QUERY
		WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBank WHERE strBankName = LTRIM(RTRIM(ISNULL(QUERY.apcbk_desc, ''''))) COLLATE Latin1_General_CI_AS)

		UNION SELECT 
				strBankName				= LTRIM(RTRIM(ISNULL(Q.ssbnk_name, '''')))
				,strContact				= (SELECT TOP 1 ISNULL(ssbnk_contact,'''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strAddress				= (SELECT TOP 1 ISNULL(ssbnk_addr1 + char(13) + ssbnk_addr2,'''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strZipCode				= (SELECT TOP 1 ISNULL(ssbnk_zip,'''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strCity				= (SELECT TOP 1 ISNULL(ssbnk_city,'''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strState				= (SELECT TOP 1 ISNULL(ssbnk_state,'''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strCountry				= ''''
				,strPhone				= (SELECT TOP 1 ISNULL(ssbnk_phone,'''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strFax					= ''''
				,strWebsite				= ''''	
				,strEmail				= (SELECT TOP 1 ISNULL(ssbnk_email_addr,'''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,strRTN					= (SELECT TOP 1 ISNULL(CAST(ssbnk_transit_route AS NVARCHAR(12)), '''') FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,intCreatedUserId		= (SELECT TOP 1  dbo.fnConvertOriginUserIdtoi21(ssbnk_user_id) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,dtmCreated				= GETDATE()
				,intLastModifiedUserId	= (SELECT TOP 1  dbo.fnConvertOriginUserIdtoi21(ssbnk_user_id) FROM ssbnkmst WHERE ssbnk_name = Q.ssbnk_name)
				,dtmLastModified		= GETDATE()
				,intConcurrencyId		= 1
		FROM(
				SELECT DISTINCT ssbnk_name FROM ssbnkmst
			) Q
		WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBank WHERE strBankName = LTRIM(RTRIM(ISNULL(Q.ssbnk_name, ''''))) COLLATE Latin1_General_CI_AS)

		-- Insert new record in tblCMBankAccount
		INSERT INTO tblCMBankAccount (
				intBankId
				,ysnActive
				,intGLAccountId
				,intCurrencyId
				,intBankAccountType
				,strContact
				,strBankAccountNo
				,strRTN
				,strAddress
				,strZipCode
				,strCity
				,strState
				,strCountry
				,strPhone
				,strFax
				,strWebsite
				,strEmail
				,intCheckStartingNo
				,intCheckEndingNo
				,intCheckNextNo
				,ysnCheckEnableMICRPrint
				,ysnCheckDefaultToBePrinted
				,intBackupCheckStartingNo
				,intBackupCheckEndingNo
				,intEFTNextNo
				,intEFTBankFileFormatId
				,strEFTCompanyId
				,strEFTBankName
				,strMICRDescription
				,intMICRBankAccountSpacesCount
				,intMICRBankAccountSpacesPosition
				,intMICRCheckNoSpacesCount
				,intMICRCheckNoSpacesPosition
				,intMICRCheckNoLength
				,intMICRCheckNoPosition
				,strMICRLeftSymbol
				,strMICRRightSymbol
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				,intConcurrencyId
				,strCbkNo	
		)
		SELECT			
				intBankId							= CASE WHEN i.apcbk_bnk_no IS NULL THEN
															(SELECT TOP 1 A.intBankId FROM tblCMBank A WHERE A.strBankName = LTRIM(RTRIM(ISNULL(i.apcbk_desc, ''''))) COLLATE Latin1_General_CI_AS)   
														ELSE
															(SELECT TOP 1 A.intBankId FROM tblCMBank A WHERE A.strBankName = (
																	SELECT  LTRIM(RTRIM(ISNULL(ssbnk_name, ''''))) COLLATE Latin1_General_CI_AS  FROM ssbnkmst WHERE  ssbnk_code = i.apcbk_bnk_no
																)
															)
														END	
				,ysnActive							= CASE WHEN i.apcbk_active_yn = ''Y'' THEN 1 ELSE 0 END 
				,intGLAccountId						= dbo.fnGetGLAccountIdFromOriginToi21(i.apcbk_gl_cash) 
				,intCurrencyId						= ISNULL(dbo.fnGetCurrencyIdFromOriginToi21(i.apcbk_currency), @intCurrencyId)
				,intBankAccountType					= @DEPOSIT_ACCOUNT
				,strContact							= ''''
				,strBankAccountNo					= ISNULL(i.apcbk_bank_acct_no, '''') COLLATE Latin1_General_CI_AS
				,strRTN								= ISNULL(i.apcbk_transit_route, '''') 
				,strAddress							= ''''
				,strZipCode							= ''''
				,strCity							= ''''
				,strState							= ''''
				,strCountry							= ''''
				,strPhone							= ''''
				,strFax								= ''''
				,strWebsite							= ''''
				,strEmail							= ''''
				,intCheckStartingNo					= 1
				,intCheckEndingNo					= ISNULL(i.apcbk_next_chk_no, 0)
				,intCheckNextNo						= ISNULL(i.apcbk_next_chk_no, 0)
				,ysnCheckEnableMICRPrint			= 1
				,ysnCheckDefaultToBePrinted			= 1
				,intBackupCheckStartingNo			= 0
				,intBackupCheckEndingNo				= 0
				,intEFTNextNo						= ISNULL(i.apcbk_next_eft_no, 0)
				,intEFTBankFileFormatId				= NULL 
				,strEFTCompanyId					= ''''
				,strEFTBankName						= ''''
				,strMICRDescription					= ''''
				,intMICRBankAccountSpacesCount		= 0
				,intMICRBankAccountSpacesPosition	= @ACCOUNT_LEADING
				,intMICRCheckNoSpacesCount			= 0
				,intMICRCheckNoSpacesPosition		= @CHECKNO_LEADING
				,intMICRCheckNoLength				= 6
				,intMICRCheckNoPosition				= @CHECKNO_LEFT
				,strMICRLeftSymbol					= ''C''
				,strMICRRightSymbol					= ''C''
				,intCreatedUserId					= dbo.fnConvertOriginUserIdtoi21(i.apcbk_user_id)
				,dtmCreated							= GETDATE()
				,intLastModifiedUserId				= dbo.fnConvertOriginUserIdtoi21(i.apcbk_user_id)
				,dtmLastModified					= GETDATE()
				,intConcurrencyId					= 1
				,strCbkNo							= i.apcbk_no	
		FROM	apcbkmst i
		WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBankAccount WHERE tblCMBankAccount.strCbkNo = i.apcbk_no COLLATE Latin1_General_CI_AS)
	')
END 
GO