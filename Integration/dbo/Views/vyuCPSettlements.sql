GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPSettlements')
	DROP VIEW vwCPSettlements
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPSettlements')
	DROP VIEW vyuCPSettlements
GO
-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gastlmst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPSettlements]
		AS
		select
			gastl_rec_type
			,gastl_no_un
			,gastl_stl_amt
			,gastl_loc_no
			,gastl_stl_rev_dt = (case len(convert(varchar, gastl_stl_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastl_stl_rev_dt) AS CHAR(12)), 112) else null end)
			,gastl_tic_no
			,gastl_spl_no
			,gastl_ivc_no
			,gastl_defer_pmt_rev_dt = (case len(convert(varchar, gastl_defer_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastl_defer_pmt_rev_dt) AS CHAR(12)), 112) else null end)
			,gastl_cnt_no
			,gastl_pd_yn = (case gastl_pd_yn when ''Y'' then ''P'' else ''U'' end)
			,gastl_cus_no
			,gastl_com_cd
			,gastl_tie_breaker
			,gastl_chk_no
			,gastl_un_prc
			,gastl_pur_sls_ind
			,gastl_pmt_rev_dt = (case len(convert(varchar, gastl_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, gastl_pmt_rev_dt) AS CHAR(12)), 112) else null end)
			,A4GLIdentity
		from
			gastlmst
		where
			(gastl_rec_type <> ''F'')
		')
GO