-- Create a stub view that can be used if the Origin Integration is not established. 

CREATE VIEW [dbo].vyuCMBankAccount
WITH SCHEMABINDING
AS 

SELECT	i21.intBankAccountId
		,i21.intBankId
		,i21.ysnActive
		,i21.intGLAccountId
		,i21.intCurrencyId
		,i21.intBankAccountType
		,i21.strContact
		,i21.strBankAccountNo
		,i21.strRTN
		,i21.strAddress
		,i21.strZipCode
		,i21.strCity
		,i21.strState
		,i21.strCountry
		,i21.strPhone
		,i21.strFax
		,i21.strWebsite
		,i21.strEmail
		,i21.intCheckStartingNo
		,i21.intCheckEndingNo
		,i21.intCheckNextNo
		,i21.ysnCheckEnableMICRPrint
		,i21.ysnCheckDefaultToBePrinted
		,i21.intBackupCheckStartingNo
		,i21.intBackupCheckEndingNo
		,i21.intEFTNextNo
		,i21.intBankStatementImportId
		,i21.intEFTBankFileFormatId
		,i21.intPositivePayBankFileFormatId
		,i21.strEFTCompanyId
		,i21.strEFTBankName
		,i21.strMICRDescription
		,i21.intMICRBankAccountSpacesCount
		,i21.intMICRBankAccountSpacesPosition
		,i21.intMICRCheckNoSpacesCount
		,i21.intMICRCheckNoSpacesPosition
		,i21.intMICRCheckNoLength
		,i21.intMICRCheckNoPosition
		,i21.strMICRLeftSymbol
		,i21.strMICRRightSymbol
		,i21.intCreatedUserId
		,i21.dtmCreated
		,i21.intLastModifiedUserId
		,i21.dtmLastModified
		,i21.strCbkNo
		,i21.intConcurrencyId
		-- The following fields are from the origin system		
		,apcbk_comment = CAST(NULL AS NVARCHAR(30))	-- CHAR (30)
		,apcbk_password = CAST(NULL AS NVARCHAR(16))	-- CHAR (16)
		,apcbk_show_bal_yn = CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_prompt_align_yn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_chk_clr_ord_dn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_import_export_yn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
		,apcbk_export_cbk_no	= CAST(NULL AS NVARCHAR(2))	-- CHAR (2)
		,apcbk_stmt_lock_rev_dt	= CAST(NULL AS INT)	-- INT yyyymmdd
		,apcbk_gl_close_rev_dt	= CAST(NULL AS INT)	-- INT yyyymmdd
		,apcbk_check_format_cs	= CAST(NULL AS NVARCHAR(2))	-- CHAR (2)
		,apcbk_laser_down_lines	= CAST(NULL AS INT)	-- INT
		,apcbk_prtr_checks	= CAST(NULL AS NVARCHAR(80))	-- CHAR (80)
		,apcbk_auto_assign_trx_yn	= CAST(NULL AS NVARCHAR(1))	-- Y/N
FROM	dbo.tblCMBankAccount i21