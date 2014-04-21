IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPProductionHistory')
	DROP VIEW vwCPProductionHistory
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPProductionHistory')
	DROP VIEW vyuCPProductionHistory
GO
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacommst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gaphsmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'sssplmst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPProductionHistory]
		AS
		select
			a.A4GLIdentity
			,b.ssspl_desc
			,b.ssspl_rec_type
			,a.gaphs_spl_no
			,gaphs_dlvry_rev_dt = (case len(convert(varchar, a.gaphs_dlvry_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gaphs_dlvry_rev_dt) AS CHAR(12)), 112) else null end)
			,a.gaphs_loc_no
			,a.gaphs_tic_no
			,a.gaphs_gross_un
			,a.gaphs_wet_un
			,a.gaphs_net_un
			,a.gaphs_cus_no
			,a.gaphs_com_cd
			,c.gacom_desc
			,c.gacom_un_desc
			,a.gaphs_fees
			,a.gaphs_gross_wgt
			,a.gaphs_tare_wgt
			,a.gaphs_cus_ref_no
			,a.gaphs_pur_sls_ind
		from
			gacommst c
			,gaphsmst a
		left outer join
			sssplmst b 
			on a.gaphs_cus_no = b.ssspl_bill_to_cus
			and a.gaphs_spl_no = b.ssspl_split_no
			and b.ssspl_rec_type in (''G'', ''B'') 
		where
			(c.gacom_com_cd = a.gaphs_com_cd)
	')
GO