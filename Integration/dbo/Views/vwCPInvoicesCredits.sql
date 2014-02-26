IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPInvoicesCredits')
	DROP VIEW vwCPInvoicesCredits
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
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
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPInvoicesCredits]
			as
			select
			a.A4GLIdentity
			,agivc_bill_to_cus = a.ptivc_cus_no
			,agivc_ivc_no = a.ptivc_invc_no
			,agivc_loc_no = a.ptivc_loc_no
			,agivc_type = a.ptivc_type
			,agivc_status = a.ptivc_status
			,agivc_rev_dt = (case len(convert(varchar, a.ptivc_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.ptivc_rev_dt) AS CHAR(12)), 112) else null end)
			,agivc_comment = a.ptivc_comment
			,agivc_po_no = a.ptivc_po_no
			,agivc_sold_to_cus = a.ptivc_sold_to --a.agivc_sold_to_cus
			,agivc_slsmn_no = a.ptivc_sold_by --a.agivc_slsmn_no
			,agivc_slsmn_tot = a.ptivc_sold_by_tot --a.agivc_slsmn_tot
			,agivc_net_amt = a.ptivc_net
			,agivc_slstx_amt = a.ptivc_sales_tax
			,agivc_srvchr_amt = a.ptivc_serv_chg
			,agivc_disc_amt = a.ptivc_disc_amt
			,agivc_amt_paid = a.ptivc_amt_applied --a.agivc_amt_paid
			,agivc_bal_due = a.ptivc_bal_due
			,agivc_pend_disc = a.ptivc_pend_disc
			,agivc_no_payments = a.ptivc_no_payments
			,agivc_adj_inv_yn = a.ptivc_adj_inv_yn
			,agivc_srvchr_cd = null --a.agivc_srvchr_cd
			,agivc_disc_rev_dt = (case len(convert(varchar, a.ptivc_gl_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.ptivc_gl_rev_dt) AS CHAR(12)), 112) else null end)
			,agivc_net_rev_dt = (case len(convert(varchar, a.ptivc_last_pay_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.ptivc_last_pay_rev_dt) AS CHAR(12)), 112) else null end)
			,agivc_src_sys = a.ptivc_src_sys
			,agivc_orig_rev_dt = (case len(convert(varchar, a.ptivc_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.ptivc_rev_dt) AS CHAR(12)), 112) else null end)
			,agivc_split_no = null --a.agivc_split_no
			,agivc_pd_days_old = null --a.agivc_pd_days_old
			,agivc_eft_ivc_paid_yn = a.ptivc_eft_ivc_paid_yn
			,agivc_terms_code = a.ptivc_terms_code
			,agloc_name = b.ptloc_name
			,agcrd_amt = c.ptcrd_amt
			,agcrd_amt_used = c.ptcrd_amt_used
		from ptivcmst a  --agivcmst a 
			left outer join ptlocmst b --aglocmst b 
				on a.ptivc_loc_no = b.ptloc_loc_no 
			left outer join ptcrdmst c --agcrdmst c 
				on a.ptivc_cus_no = c.ptcrd_cus_no 
				and a.ptivc_rev_dt = c.ptcrd_rev_dt 
				and a.ptivc_invc_no = c.ptcrd_invc_no
	')
GO
