GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPOptions')
	DROP VIEW vwCPOptions
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPOptions')
	DROP VIEW vyuCPOptions
GO
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gaoptmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacommst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPOptions]
		AS
		select
			a.A4GLIdentity
			,a.gaopt_status_ind
			,a.gaopt_bot_opt
			,a.gaopt_ref_no
			,gaopt_exp_rev_dt = (case len(convert(varchar, a.gaopt_exp_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gaopt_exp_rev_dt) AS CHAR(12)), 112) else null end)
			,a.gaopt_buy_sell
			,a.gaopt_put_call
			,a.gaopt_un_prem
			,a.gaopt_un_srvc_fee
			,a.gaopt_no_un
			,a.gaopt_un_strk_prc
			,a.gaopt_com_cd
			,a.gaopt_cus_no
			,b.gacom_desc
			,b.gacom_un_desc
			,a.gaopt_prcd_no_un
			,a.gaopt_prcd_un_prc
			,a.gaopt_un_target_prc
			,a.gaopt_pur_sls_ind
		from
			gaoptmst a
		left outer join
			gacommst b
			on a.gaopt_com_cd = b.gacom_com_cd 
		')
GO
