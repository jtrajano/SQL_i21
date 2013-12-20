CREATE VIEW [dbo].[vwivcmst]
AS
SELECT
vwivc_bill_to_cus		=	agivc_bill_to_cus
,vwivc_ivc_no			=	agivc_ivc_no
,vwivc_loc_no			=	agivc_loc_no
,vwivc_type				=	CAST(agivc_type AS CHAR(4))
,vwivc_status			=	CAST(agivc_status AS CHAR(3))
,vwivc_rev_dt			=	agivc_rev_dt
,vwivc_comment			=	agivc_comment
,vwivc_po_no			=	agivc_po_no
,vwivc_sold_to_cus		=	agivc_sold_to_cus
,vwivc_slsmn_no			=	CAST(agivc_slsmn_no AS CHAR(4))
,vwivc_slsmn_tot		=	agivc_slsmn_tot
,vwivc_net_amt			=	agivc_net_amt
,vwivc_slstx_amt		=	CAST(agivc_slstx_amt AS DECIMAL(18,6))
,vwivc_srvchr_amt		=	agivc_srvchr_amt
,vwivc_disc_amt			=	CAST(agivc_disc_amt AS DECIMAL(18,6))
,vwivc_amt_paid			=	agivc_amt_paid
,vwivc_bal_due			=	agivc_bal_due
,vwivc_pend_disc		=	CAST(agivc_pend_disc AS DECIMAL(18,6))
,vwivc_no_payments		=	CAST(agivc_no_payments AS INT)
,vwivc_adj_inv_yn		=	agivc_adj_inv_yn
,vwivc_srvchr_cd		=	CAST(agivc_srvchr_cd AS INT)
,vwivc_disc_rev_dt		=	agivc_disc_rev_dt
,vwivc_net_rev_dt		=	agivc_net_rev_dt
,vwivc_src_sys			=	CAST(agivc_src_sys AS CHAR(4))
,vwivc_orig_rev_dt		=	agivc_orig_rev_dt
,vwivc_split_no			=	agivc_split_no
,vwivc_pd_days_old		=	CAST(agivc_pd_days_old AS INT)
,vwivc_currency			=	CAST(agivc_currency AS CHAR(4))
,vwivc_currency_rt		=	agivc_currency_rt
,vwivc_currency_cnt		=	agivc_currency_cnt
,vwivc_eft_ivc_paid_yn	=	agivc_eft_ivc_paid_yn
,vwivc_terms_code		=	CAST(agivc_terms_code AS CHAR(4))
,vwivc_pay_type			=	CAST(agivc_pay_type AS CHAR(4))
,vwivc_user_id			=	agivc_user_id
,vwivc_user_rev_dt		=	agivc_user_rev_dt
,A4GLIdentity			=	CAST(A4GLIdentity   AS INT)
FROM agivcmst
