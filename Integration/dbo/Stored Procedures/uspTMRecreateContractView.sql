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
						vwcnt_cus_no=agcnt_cus_no COLLATE Latin1_General_CI_AS
						,vwcnt_cnt_no= agcnt_cnt_no
						,vwcnt_line_no= CAST(agcnt_line_no AS INT)
						,vwcnt_alt_cus=agcnt_alt_cus COLLATE Latin1_General_CI_AS
						,vwcnt_itm_or_cls=agcnt_itm_or_cls COLLATE Latin1_General_CI_AS
						,vwcnt_loc_no=agcnt_loc_no COLLATE Latin1_General_CI_AS
						,vwcnt_alt_cnt_no=agcnt_alt_cnt_no COLLATE Latin1_General_CI_AS
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
						,vwcnt_ppd_yndm = CASE WHEN agcnt_ppd_yndm = ''M'' THEN ''Y'' ELSE ''N'' END
						,vwcnt_un_prc=agcnt_un_prc
						,vwcnt_prc_lvl = agcnt_prc_lvl
						,A4GLIdentity = CAST(A4GLIdentity   AS INT)
						,strItemDescription =  ''''
						,strCustomerName =  ''''
						,strItemUnitDescription = ''''
						,ysnMaxPrice = CASE WHEN agcnt_ppd_yndm = ''M'' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
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
						vwcnt_cus_no=ptcnt_cus_no COLLATE Latin1_General_CI_AS
						,vwcnt_cnt_no= CAST(ptcnt_cnt_no AS CHAR(8))  
						,vwcnt_line_no= CAST(ptcnt_line_no AS INT)
						,vwcnt_alt_cus=ptcnt_alt_cus_no COLLATE Latin1_General_CI_AS
						,vwcnt_itm_or_cls=CAST(ptcnt_itm_or_cls AS CHAR(13))  COLLATE Latin1_General_CI_AS
						,vwcnt_loc_no=ptcnt_loc_no COLLATE Latin1_General_CI_AS
						,vwcnt_alt_cnt_no=CAST(ptcnt_alt_cnt_no AS CHAR(8))  COLLATE Latin1_General_CI_AS
						,vwcnt_amt_orig=ptcnt_amt_orig
						,vwcnt_amt_bal= ptcnt_amt_bal
						
						,vwcnt_due_rev_dt= (CASE WHEN ptcnt_due_rev_dt = 0 THEN NULL 
											ELSE
												CONVERT(DATETIME, SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),1,4) + ''/'' 
														+ SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),5,2) + ''/'' 
														+  SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
											END)
						,vwcnt_hdr_comments=ptcnt_hdr_comments
						,vwcnt_un_orig=ptcnt_un_orig
						,vwcnt_un_bal= (CASE WHEN ptcnt_unlmd_qty_cnt = ''Y''
										 THEN 999999 
										 ELSE ptcnt_un_bal 
										 END)
						,vwcnt_lc1_yn=ptcnt_lc1_yn
						,vwcnt_lc2_yn=ptcnt_lc2_yn
						,vwcnt_lc3_yn=ptcnt_lc3_yn
						,vwcnt_lc4_yn =ptcnt_lc4_yn
						,vwcnt_lc5_yn =ptcnt_lc5_yn
						,vwcnt_lc6_yn =ptcnt_lc6_yn
						,vwcnt_ppd_yndm =ptcnt_prepaid_ynd COLLATE Latin1_General_CI_AS
						,vwcnt_un_prc=CAST(ptcnt_un_prc AS DECIMAL(18,6))  
						,vwcnt_prc_lvl = ptcnt_prc_lvl
						,A4GLIdentity = CAST(A4GLIdentity   AS INT)
						,strItemDescription =  ''''
						,strCustomerName =  ''''
						,strItemUnitDescription = ''''
						,ysnMaxPrice = CASE WHEN ptcnt_max_prc_yn = ''Y'' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
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
				vwcnt_cus_no=C.strEntityNo COLLATE Latin1_General_CI_AS
				,vwcnt_cnt_no= A.strContractNumber
				,vwcnt_line_no= B.intContractSeq
				,vwcnt_alt_cus= '''' COLLATE Latin1_General_CI_AS
				,vwcnt_itm_or_cls= E.strItemNo COLLATE Latin1_General_CI_AS
				,vwcnt_loc_no= F.strLocationName COLLATE Latin1_General_CI_AS
				,vwcnt_alt_cnt_no=''''
				,vwcnt_amt_orig= ISNULL(B.dblCashPrice,0.0) * ISNULL(B.dblOriginalQty,0.0)
				,vwcnt_amt_bal= ISNULL(B.dblBalance,0.0) * ISNULL(B.dblCashPrice,0.0)
				,vwcnt_due_rev_dt= B.dtmEndDate
				,vwcnt_hdr_comments=A.strInternalComment
				,vwcnt_un_orig=ISNULL(B.dblOriginalQty,0.0)
				,vwcnt_un_bal= B.dblBalance
				,vwcnt_lc1_yn=''''
				,vwcnt_lc2_yn=''''
				,vwcnt_lc3_yn=''''
				,vwcnt_lc4_yn =''''
				,vwcnt_lc5_yn =''''
				,vwcnt_lc6_yn =''''
				,vwcnt_ppd_yndm = (CASE 
										WHEN ISNULL(H.ysnPrepaid,0) = 1 THEN ''Y'' 
										ELSE ''N''
									END) COLLATE Latin1_General_CI_AS
						  	
				,vwcnt_un_prc= ISNULL(B.dblCashPrice,0.0)
				,vwcnt_prc_lvl = ''''
				,A4GLIdentity = CAST(B.intContractDetailId  AS INT)
				,strItemDescription =  E.strDescription
				,strCustomerName = C.strName
				,strItemUnitDescription = G.strUnitMeasure
				,ysnMaxPrice = CAST(0 AS BIT)
 			FROM tblCTContractHeader A
			INNER JOIN vyuCTContractHeaderNotMapped H
				ON A.intContractHeaderId = H.intContractHeaderId
			INNER JOIN tblCTContractDetail B
				ON A.intContractHeaderId = B.intContractHeaderId
			INNER JOIN tblEMEntity C
				ON A.intEntityId = C.intEntityId
			LEFT JOIN tblICItem E
				ON B.intItemId = E.intItemId	
			LEFT JOIN tblSMCompanyLocation F
				ON B.intCompanyLocationId = F.intCompanyLocationId
			LEFT JOIN tblICUnitMeasure G
				ON B.intUnitMeasureId = G.intUnitMeasureId	
	
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