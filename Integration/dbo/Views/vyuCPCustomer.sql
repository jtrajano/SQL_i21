GO

-- DELETE OLD VIEW
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPCustomer')
	DROP VIEW vyuCPCustomer
GO
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPCustomer] AS
		select
			agcus_key
			,agcus_co_per_ind_cp
			,agcus_last_name
			,agcus_first_name
			,agcus_addr
			,agcus_addr2
			,agcus_city
			,agcus_state
			,agcus_zip
			,agcus_country
			,agcus_dlvry_point
			,agcus_county
			,agcus_phone
			,agcus_phone_ext
			,agcus_phone2
			,agcus_phone2_ext
			,agcus_bill_to
			,agcus_contact
			,agcus_comments
			,agcus_ar_future
			,agcus_ar_per1
			,agcus_ar_per2
			,agcus_ar_per3
			,agcus_ar_per4
			,agcus_ar_per5
			,agcus_cred_reg
			,agcus_cred_ppd
			,agcus_pend_ivc
			,agcus_pend_pymt
			,agcus_cred_ga
			,agcus_ytd_pur
			,agcus_ytd_pur_pt = null
			,agcus_ytd_sls
			,agcus_ytd_srvchr
			,agcus_last_ivc_rev_dt
			,agcus_last_pay_rev_dt
			,agcus_last_stmt_rev_dt
			,agcus_user_id
			,agcus_user_rev_dt
			,A4GLIdentity
		from
			agcusmst
		')
GO
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPCustomer] AS
		select
			agcus_key = ptcus_cus_no
			,agcus_co_per_ind_cp = ptcus_co_per_ind_cp
			,agcus_last_name = ptcus_last_name
			,agcus_first_name = ptcus_first_name
			,agcus_addr = ptcus_addr
			,agcus_addr2 = ptcus_addr2
			,agcus_city = ptcus_city
			,agcus_state = ptcus_state
			,agcus_zip = ptcus_zip
			,agcus_country = ptcus_country
			,agcus_dlvry_point = null
			,agcus_county = ptcus_country
			,agcus_phone = ptcus_phone
			,agcus_phone_ext = ptcus_phone_ext
			,agcus_phone2 = ptcus_phone2
			,agcus_phone2_ext = ptcus_phone_ext2
			,agcus_bill_to = ptcus_bill_to
			,agcus_contact = ptcus_contact
			,agcus_comments = ptcus_comment
			,agcus_ar_future = null
			,agcus_ar_per1 = ptcus_ar_curr
			,agcus_ar_per2 = ptcus_ar_3160
			,agcus_ar_per3 = ptcus_ar_6190
			,agcus_ar_per4 = ptcus_ar_91120
			,agcus_ar_per5 = ptcus_ar_ov120
			,agcus_cred_reg = ptcus_cred_reg
			,agcus_cred_ppd = ptcus_cred_ppd
			,agcus_pend_ivc = null
			,agcus_pend_pymt = null
			,agcus_cred_ga = null
			,agcus_ytd_pur = null
			,agcus_ytd_pur_pt = ptcus_purchs_ytd
			,agcus_ytd_sls = ptcus_ytd_sales
			,agcus_ytd_srvchr = ptcus_ytd_srvchr
			,agcus_last_ivc_rev_dt = ptcus_last_ivc_rev_dt
			,agcus_last_pay_rev_dt = ptcus_last_pay_rev_dt
			,agcus_last_stmt_rev_dt = ptcus_last_stmnt_rev_dt
			,agcus_user_id = ptcus_contact
			,agcus_user_rev_dt = ptcus_origin_rev_dt
			,A4GLIdentity = A4GLIdentity
		from
			ptcusmst
		')
GO
