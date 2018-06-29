-- Create a stub view that can be used if the Origin Integration is not established. 

CREATE VIEW [dbo].vyuCMBankAccount
WITH SCHEMABINDING
AS 

SELECT	i21.intBankAccountId
		,i21.intBankId
		,strBankName = (SELECT strBankName FROM dbo.tblCMBank WHERE intBankId = i21.intBankId)
		,i21.ysnActive
		,i21.intGLAccountId
		,strGLAccountId = (SELECT strAccountId FROM dbo.tblGLAccount WHERE intAccountId = i21.intGLAccountId)
		,i21.intCurrencyId
		,strCurrency = (SELECT strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = i21.intCurrencyId)
		,i21.intBankAccountType
		,i21.strContact
		,i21.strBankAccountHolder
		,ISNULL(dbo.fnAESDecryptASym(i21.strBankAccountNo),strBankAccountNo) COLLATE Latin1_General_CI_AS AS strBankAccountNo
		,ISNULL(dbo.fnAESDecryptASym(i21.strRTN),strRTN) COLLATE Latin1_General_CI_AS AS strRTN
		,i21.strAddress
		,i21.strZipCode
		,i21.strCity
		,i21.strState
		,i21.strCountry
		,i21.strPhone
		,i21.strFax
		,i21.strWebsite
		,i21.strEmail
		,i21.strIBAN
		,i21.strSWIFT
		,i21.intCheckStartingNo
		,i21.intCheckEndingNo
		,i21.intCheckNextNo
		,i21.intCheckNoLength
		,i21.ysnCheckEnableMICRPrint
		,i21.ysnCheckDefaultToBePrinted
		,i21.intBackupCheckStartingNo
		,i21.intBackupCheckEndingNo
		,i21.intEFTNextNo
		,i21.intBankStatementImportId
		,strBankStatementFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intBankStatementImportId)
		,i21.intEFTBankFileFormatId
		,strACHFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intEFTBankFileFormatId)
		,i21.intPositivePayBankFileFormatId
		,strPositivePayFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intPositivePayBankFileFormatId)
		,i21.intEFTARFileFormatId
		,strEFTARFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intEFTARFileFormatId)
		,i21.intEFTPRFileFormatId
		,strEFTPRFormat = (SELECT strName FROM dbo.tblCMBankFileFormat WHERE intBankFileFormatId = i21.intEFTPRFileFormatId)
		,i21.strEFTCompanyId
		,i21.strEFTBankName
		,i21.strMICRDescription
		,ISNULL(dbo.fnAESDecryptASym(i21.strMICRRoutingNo),strMICRRoutingNo) COLLATE Latin1_General_CI_AS AS strMICRRoutingNo
		,ISNULL(dbo.fnAESDecryptASym(i21.strMICRBankAccountNo),strMICRBankAccountNo) COLLATE Latin1_General_CI_AS AS strMICRBankAccountNo
		,i21.strMICRRoutingPrefix
		,i21.strMICRRoutingSuffix
		,i21.strMICRBankAccountPrefix
		,i21.strMICRBankAccountSuffix
		,i21.intMICRBankAccountSpacesCount
		,i21.intMICRBankAccountSpacesPosition
		,i21.intMICRCheckNoSpacesCount
		,i21.intMICRCheckNoSpacesPosition
		,i21.intMICRCheckNoLength
		,i21.intMICRCheckNoPosition
		,i21.strMICRLeftSymbol
		,i21.strMICRRightSymbol
		,i21.strMICRFinancialInstitutionPrefix
		,i21.strMICRFinancialInstitution
		,i21.strMICRFinancialInstitutionSuffix
		,i21.intMICRFinancialInstitutionSpacesCount
		,i21.intMICRFinancialInstitutionSpacesPosition
		,i21.strMICRDesignationPrefix
		,i21.strMICRDesignation
		,i21.strMICRDesignationSuffix
		,i21.intMICRDesignationSpacesCount
		,i21.intMICRDesignationSpacesPosition
		,i21.strFractionalRoutingNumber
		,i21.strUserDefineMessage
		,i21.strSignatureLineCaption
		,i21.ysnShowTwoSignatureLine
		,i21.dblGreaterThanAmount
		,i21.ysnShowFirstSignature
		,i21.dblFirstAmountIsOver
		,i21.intFirstUserId
		,strFirstUserName = (SELECT strUserName FROM dbo.tblSMUserSecurity WHERE intEntityId = i21.intFirstUserId)
		,i21.intFirstSignatureId
		,strFirstSignatureName = (SELECT strName FROM dbo.tblSMSignature WHERE intSignatureId = i21.intFirstSignatureId)
		,blbFirstSignatureDetail = (SELECT blbDetail FROM dbo.tblSMSignature WHERE intSignatureId = i21.intFirstSignatureId)
		,i21.ysnShowSecondSignature
		,i21.dblSecondAmountIsOver
		,i21.intSecondUserId
		,strSecondUserName = (SELECT strUserName FROM dbo.tblSMUserSecurity WHERE intEntityId = i21.intSecondUserId)
		,i21.intSecondSignatureId
		,strSecondSignatureName = (SELECT strName FROM dbo.tblSMSignature WHERE intSignatureId = i21.intSecondSignatureId)
		,blbSecondSignatureDetail = (SELECT blbDetail FROM dbo.tblSMSignature WHERE intSignatureId = i21.intSecondSignatureId)
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

		-- convert value suitable for checkbox for apcbk_show_bal_yn,apcbk_import_export_yn,apcbk_prompt_align_yn,apcbk_auto_assign_trx_yn
		,NULL ysnShowRunningBalance
		,NULL ysnPrintAlignPattern
		,NULL ysnImportExportTrans
		,NULL ysnAutoAssignOtherTrans
		-- This is used to check if the bank account have a transaction
		,ysnHasTransaction = CAST(ISNULL((select TOP 1 1 from  dbo.tblCMBankTransaction where intBankAccountId = i21.intBankAccountId),0) AS bit)
		-- This is used to check if EFT No has been used
		,ysnEFTNoUsed = CAST(ISNULL(
						(SELECT TOP 1 1 FROM (
						SELECT strTransactionId FROM  dbo.tblCMBankTransaction WHERE intBankAccountId = i21.intBankAccountId AND intBankTransactionTypeId IN (22,23,122,123) AND strReferenceNo <> '' AND intBankFileAuditId IS NOT NULL
						UNION ALL SELECT strSourceTransactionId FROM dbo.tblCMUndepositedFund WHERE intBankAccountId = i21.intBankAccountId AND (strReferenceNo <> '' OR strReferenceNo IS NOT NULL) AND intBankFileAuditId IS NOT NULL
						) tbl),0) AS bit)
FROM	dbo.tblCMBankAccount i21

GO
--Create trigger that will insert on the main table

 