IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPInvoicesCredits')
	DROP VIEW vwCPInvoicesCredits
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPInvoicesCredits]
		AS
		select
			a.A4GLIdentity
			,a.agivc_bill_to_cus
			,a.agivc_ivc_no
			,a.agivc_loc_no
			,a.agivc_type
			,a.agivc_status
			,agivc_rev_dt = (case len(convert(varchar, a.agivc_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_rev_dt) AS CHAR(12)), 112) else null end)
			,a.agivc_comment
			,a.agivc_po_no
			,a.agivc_sold_to_cus
			,a.agivc_slsmn_no
			,a.agivc_slsmn_tot
			,a.agivc_net_amt
			,a.agivc_slstx_amt
			,a.agivc_srvchr_amt
			,a.agivc_disc_amt
			,a.agivc_amt_paid
			,a.agivc_bal_due
			,a.agivc_pend_disc
			,a.agivc_no_payments
			,a.agivc_adj_inv_yn
			,a.agivc_srvchr_cd
			,agivc_disc_rev_dt = (case len(convert(varchar, a.agivc_disc_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_disc_rev_dt) AS CHAR(12)), 112) else null end)
			,agivc_net_rev_dt = (case len(convert(varchar, a.agivc_net_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_net_rev_dt) AS CHAR(12)), 112) else null end)
			,a.agivc_src_sys
			,agivc_orig_rev_dt = (case len(convert(varchar, a.agivc_orig_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agivc_orig_rev_dt) AS CHAR(12)), 112) else null end)
			,a.agivc_split_no
			,a.agivc_pd_days_old
			,a.agivc_eft_ivc_paid_yn
			,a.agivc_terms_code
			,b.agloc_name
			,c.agcrd_amt
			,c.agcrd_amt_used
		from agivcmst a 
			left outer join aglocmst b 
				on a.agivc_loc_no = b.agloc_loc_no 
			left outer join agcrdmst c 
				on a.agivc_bill_to_cus = c.agcrd_cus_no 
				and a.agivc_orig_rev_dt = c.agcrd_rev_dt 
				and a.agivc_ivc_no = c.agcrd_ref_no
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPInvoicesCredits]
		AS
		select ''PETRO HERE'' XX
	')
GO
