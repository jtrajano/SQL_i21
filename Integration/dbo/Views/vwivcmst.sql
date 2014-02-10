IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwivcmst')
	DROP VIEW vwivcmst

GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
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
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwivcmst]
		AS
		SELECT
		vwivc_bill_to_cus		=	ptivc_cus_no
		,vwivc_ivc_no			=	CAST(ptivc_invc_no AS CHAR(8))  
		,vwivc_loc_no			=	ptivc_loc_no
		,vwivc_type				=	CAST(NULL AS CHAR(4))  
		,vwivc_status			=	CAST(ptivc_sold_by AS CHAR(3))  
		,vwivc_rev_dt			=	NULL
		,vwivc_comment			=	ptivc_comment  
		,vwivc_po_no			=	ptivc_po_no
		,vwivc_sold_to_cus		=	ptivc_sold_to
		,vwivc_slsmn_no			=	CAST(NULL AS CHAR(4))  
		,vwivc_slsmn_tot		=	ptivc_sold_by_tot
		,vwivc_net_amt			=	ptivc_net
		,vwivc_slstx_amt		=	CAST(ptivc_sales_tax AS DECIMAL(18,6)) 
		,vwivc_srvchr_amt		=	CAST(0.00 AS DECIMAL(18,6))  
		,vwivc_disc_amt			=	CAST(ptivc_disc_amt AS DECIMAL(18,6))  
		,vwivc_amt_paid			=	ptivc_amt_applied
		,vwivc_bal_due			=	ptivc_bal_due
		,vwivc_pend_disc		=	CAST(ptivc_pend_disc AS DECIMAL(18,6)) 
		,vwivc_no_payments		=	CAST(ptivc_no_payments AS INT)
		,vwivc_adj_inv_yn		=	ptivc_adj_inv_yn
		,vwivc_srvchr_cd		=	CAST(0 AS INT)  
		,vwivc_disc_rev_dt		=	NULL
		,vwivc_net_rev_dt		=	NULL
		,vwivc_src_sys			=	CAST(NULL AS CHAR(4))  
		,vwivc_orig_rev_dt		=	NULL
		,vwivc_split_no			=	CAST(NULL AS CHAR(4))  
		,vwivc_pd_days_old		=	CAST(0 AS INT) 
		,vwivc_currency			=	CAST(NULL AS CHAR(4)) 
		,vwivc_currency_rt		=	CAST(0.00 AS DECIMAL(18,6))
		,vwivc_currency_cnt		=	CAST(NULL AS CHAR(8))  
		,vwivc_eft_ivc_paid_yn	=	ptivc_eft_ivc_paid_yn 
		,vwivc_terms_code		=	CAST(NULL AS CHAR(4)) 
		,vwivc_pay_type			=	CAST(NULL AS CHAR(4)) 
		,vwivc_user_id			=	CAST(NULL AS CHAR(16))  
		,vwivc_user_rev_dt		=	NULL
		,A4GLIdentity			=	CAST(A4GLIdentity   AS INT)
		FROM ptivcmst
		')

GO

