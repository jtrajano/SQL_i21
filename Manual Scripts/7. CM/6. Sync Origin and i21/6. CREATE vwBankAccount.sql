IF EXISTS (SELECT TOP 1 1 FROM sys.views WHERE name = 'vwCMBankAccount')
	DROP VIEW [dbo].vwCMBankAccount
GO

CREATE VIEW [dbo].vwCMBankAccount
WITH SCHEMABINDING
AS 

SELECT	i21.intBankAccountID
		,i21.strBankName
		,i21.ysnActive
		,i21.intGLAccountID
		,i21.intCurrencyID
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
		,i21.intEFTBankFileFormatID
		,i21.strEFTCompanyID
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
		,i21.intCreatedUserID
		,i21.dtmCreated
		,i21.intLastModifiedUserID
		,i21.dtmLastModified
		,i21.strCbkNo
		,i21.intConcurrencyID
		-- The following fields are from the origin system		
		,origin.apcbk_comment				-- CHAR (30)
		,origin.apcbk_password				-- CHAR (16)
		,origin.apcbk_show_bal_yn			-- Y/N
		,origin.apcbk_prompt_align_yn		-- Y/N
		,origin.apcbk_chk_clr_ord_dn		-- Y/N
		,origin.apcbk_import_export_yn		-- Y/N
		,origin.apcbk_export_cbk_no			-- CHAR (2)
		,origin.apcbk_stmt_lock_rev_dt		-- INT yyyymmdd
		,origin.apcbk_gl_close_rev_dt		-- INT yyyymmdd
		,origin.apcbk_check_format_cs		-- CHAR (2)
		,origin.apcbk_laser_down_lines		-- INT
		,origin.apcbk_prtr_checks			-- CHAR (80)
		,origin.apcbk_auto_assign_trx_yn	-- Y/N
FROM	dbo.tblCMBankAccount i21 LEFT JOIN dbo.apcbkmst_legacy origin
			ON i21.strCbkNo = origin.apcbk_no COLLATE Latin1_General_CI_AS
GO 

-- Comment this for now. I am unable to add indexes on views that is using LEFT, RIGHT, or OUTER joins. Index only works on INNER joins. 
-- Creating unique key on [intBankAccountID] in view 'vwCMBankAccount'
-- CREATE UNIQUE CLUSTERED INDEX PK_vwCMBankAccount ON vwCMBankAccount ([intBankAccountID])
GO