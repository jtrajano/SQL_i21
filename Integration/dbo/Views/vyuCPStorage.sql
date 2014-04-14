IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPStorage')
	DROP VIEW vwCPStorage
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPStorage')
	DROP VIEW vyuCPStorage
GO

-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gastrmst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPStorage]
		AS
		select
			gastr_stor_type
			,gastr_loc_no
			,gastr_dlvry_rev_dt = (case len(convert(varchar, gastr_dlvry_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastr_dlvry_rev_dt) AS CHAR(12)), 112) else null end)
			,gastr_tic_no
			,gastr_spl_no
			,gastr_dpa_or_rcpt_no
			,gastr_un_disc_due
			,gastr_un_disc_pd
			,gastr_un_stor_due
			,gastr_stor_schd_no
			,gastr_un_bal
			,gastr_cus_no
			,gastr_com_cd
			,gastr_tie_breaker
			,gastr_un_stor_pd
			,gastr_pur_sls_ind
			,A4GLIdentity
		from
			gastrmst
		where
			(gastr_un_bal > 0)
		')