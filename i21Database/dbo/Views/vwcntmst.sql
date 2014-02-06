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
,vwcnt_due_rev_dt= CONVERT(DATETIME, SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),1,4) + '/' 
								+ SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),5,2) + '/' 
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