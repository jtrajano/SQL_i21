IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPContracts')
	DROP VIEW vwCPContracts
GO

--CONTRACTS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'CN' and strDBName = db_name()	) = 1
BEGIN
	-- AG VIEW
	IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		EXEC ('
			CREATE VIEW [dbo].[vwCPContracts]
			AS
			select distinct
				a.A4GLIdentity
				,a.agcnt_cnt_no
				,a.agcnt_loc_no
				,a.agcnt_amt_bal
				,agcnt_due_rev_dt = (case len(convert(varchar, a.agcnt_due_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.agcnt_due_rev_dt) AS CHAR(12)), 112) else null end)
				,a.agcnt_hdr_comments
				,a.agcnt_ppd_yndm
				,a.agcnt_itm_or_cls
				,b.agitm_no
				,b.agitm_un_desc
				,a.agcnt_line_no
				,a.agcnt_un_bal
				,a.agcnt_cus_no
				, strStatus = (case when a.agcnt_un_bal > 0 then ''Open'' else ''Closed'' end)
			from
				agcntmst a
			left outer join
				agitmmst b 
				on 
					a.agcnt_itm_or_cls = b.agitm_no
					and a.agcnt_loc_no = b.agitm_loc_no
			where
				(a.agcnt_itm_or_cls <> ''*'')
				and (a.agcnt_line_no <> 0)
			')
	-- PT VIEW
	IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
		EXEC ('
			CREATE VIEW [dbo].[vwCPContracts]
			AS
			select 1 XX
			')	
END
GO
