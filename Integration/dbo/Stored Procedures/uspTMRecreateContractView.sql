GO
	PRINT 'START OF CREATING [uspTMRecreateContractView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateContractView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateContractView
GO

CREATE PROCEDURE uspTMRecreateContractView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblTMOriginMod') IS NOT NULL DROP TABLE #tblTMOriginMod

	CREATE TABLE #tblTMOriginMod
	(
		 intModId INT IDENTITY(1,1)
		, strDBName nvarchar(50) NOT NULL 
		, strPrefix NVARCHAR(5) NOT NULL UNIQUE
		, strName NVARCHAR(30) NOT NULL UNIQUE
		, ysnUsed BIT NOT NULL 
	)

	-- AG ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcntmst')
	BEGIN
		DROP VIEW vwcntmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwcntmst]
					AS
					SELECT
						vwcnt_cus_no=agcnt_cus_no
						,vwcnt_cnt_no= agcnt_cnt_no
						,vwcnt_line_no= agcnt_line_no
						,vwcnt_alt_cus=agcnt_alt_cus
						,vwcnt_itm_or_cls=agcnt_itm_or_cls
						,vwcnt_loc_no=agcnt_loc_no
						,vwcnt_alt_cnt_no=agcnt_alt_cnt_no
						,vwcnt_amt_orig=agcnt_amt_orig
						,vwcnt_amt_bal=agcnt_amt_bal
						,vwcnt_due_rev_dt= (CASE WHEN agcnt_due_rev_dt = 0 THEN NULL 
											ELSE
												CONVERT(DATETIME, SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),1,4) + ''/'' 
														+ SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),5,2) + ''/'' 
														+  SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
											END)
						,vwcnt_hdr_comments=agcnt_hdr_comments
						,vwcnt_un_orig=agcnt_un_orig
						,vwcnt_un_bal=agcnt_un_bal
						,vwcnt_lc1_yn=agcnt_lc1_yn
						,vwcnt_lc2_yn=agcnt_lc2_yn
						,vwcnt_lc3_yn=agcnt_lc3_yn
						,vwcnt_lc4_yn =agcnt_lc4_yn
						,vwcnt_lc5_yn =agcnt_lc5_yn
						,vwcnt_lc6_yn =agcnt_lc6_yn
						,vwcnt_ppd_yndm =agcnt_ppd_yndm
						,vwcnt_un_prc=agcnt_un_prc
						,vwcnt_prc_lvl = agcnt_prc_lvl
						,A4GLIdentity = CAST(A4GLIdentity   AS INT)

					FROM agcntmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwcntmst]
					AS
					SELECT
						vwcnt_cus_no=ptcnt_cus_no
						,vwcnt_cnt_no= CAST(ptcnt_cnt_no AS CHAR(8))  
						,vwcnt_line_no= ptcnt_line_no
						,vwcnt_alt_cus=ptcnt_alt_cus_no
						,vwcnt_itm_or_cls=CAST(ptcnt_itm_or_cls AS CHAR(13))  
						,vwcnt_loc_no=ptcnt_loc_no
						,vwcnt_alt_cnt_no=CAST(ptcnt_alt_cnt_no AS CHAR(8)) 
						,vwcnt_amt_orig=ptcnt_amt_orig
						,vwcnt_amt_bal=ptcnt_amt_bal
						,vwcnt_due_rev_dt= (CASE WHEN ptcnt_due_rev_dt = 0 THEN NULL 
											ELSE
												CONVERT(DATETIME, SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),1,4) + ''/'' 
														+ SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),5,2) + ''/'' 
														+  SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
											END)
						,vwcnt_hdr_comments=ptcnt_hdr_comments
						,vwcnt_un_orig=ptcnt_un_orig
						,vwcnt_un_bal=ptcnt_un_bal
						,vwcnt_lc1_yn=ptcnt_lc1_yn
						,vwcnt_lc2_yn=ptcnt_lc2_yn
						,vwcnt_lc3_yn=ptcnt_lc3_yn
						,vwcnt_lc4_yn =ptcnt_lc4_yn
						,vwcnt_lc5_yn =ptcnt_lc5_yn
						,vwcnt_lc6_yn =ptcnt_lc6_yn
						,vwcnt_ppd_yndm =ptcnt_prepaid_ynd
						,vwcnt_un_prc=CAST(ptcnt_un_prc AS DECIMAL(18,6))  
						,vwcnt_prc_lvl = ptcnt_prc_lvl
						,A4GLIdentity = CAST(A4GLIdentity   AS INT)
					FROM ptcntmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwcntmst]
			AS
			SELECT
				vwcnt_cus_no=C.strEntityNo
				,vwcnt_cnt_no= A.strContractNumber
				,vwcnt_line_no= 0
				,vwcnt_alt_cus= ''''
				,vwcnt_itm_or_cls= E.strItemNo 
				,vwcnt_loc_no= F.strLocationNumber
				,vwcnt_alt_cnt_no=''''
				,vwcnt_amt_orig= 0.0
				,vwcnt_amt_bal= 0.0
				,vwcnt_due_rev_dt= A.dtmDateDue
				,vwcnt_hdr_comments=A.strComments
				,vwcnt_un_orig=0.0
				,vwcnt_un_bal=0.0
				,vwcnt_lc1_yn=''''
				,vwcnt_lc2_yn=''''
				,vwcnt_lc3_yn=''''
				,vwcnt_lc4_yn =''''
				,vwcnt_lc5_yn =''''
				,vwcnt_lc6_yn =''''
				,vwcnt_ppd_yndm = (CASE 
										WHEN A.strPrepaid = ''Yes'' THEN ''Y'' 
										WHEN A.strPrepaid = ''No'' THEN ''N''
										ELSE ''D''
									END)
						  	
				,vwcnt_un_prc= D.dblUnitPrice
				,vwcnt_prc_lvl = A.strPriceLevel
				,A4GLIdentity = CAST(D.intContractDetailId   AS INT)
				,intContractId = A.intContractId
			FROM tblARCustomerContract A
			INNER JOIN tblARCustomer B
				ON A.intCustomerId = B.intEntityCustomerId
			INNER JOIN tblEntity C
				ON B.intEntityCustomerId = C.intEntityId
			INNER JOIN tblARCustomerContractDetail D
				ON A.intContractId = D.intContractId
			INNER JOIN tblICItem E
				ON D.intItemId = E.intItemId	
			INNER JOIN tblSMCompanyLocation F
				ON A.intLocationId = F.intCompanyLocationId
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateContractView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateContractView'
GO 
	EXEC ('uspTMRecreateContractView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateContractView'
GO