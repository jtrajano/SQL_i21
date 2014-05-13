GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcntmst')
	DROP VIEW vwcntmst

GO


-- AG VIEW
	IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
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
			,vwcnt_due_rev_dt= CONVERT(DATETIME, SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),1,4) + ''/'' 
											+ SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),5,2) + ''/'' 
											+  SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
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
		
-- CONTRACTS DEPENDENT	
-- PT VIEW 
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'CN' and strDBName = db_name()	) = 1
BEGIN
	IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
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
			,vwcnt_due_rev_dt= CONVERT(DATETIME, SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),1,4) + ''/'' 
											+ SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),5,2) + ''/'' 
											+  SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
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
			
GO

