IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPGAContracts')
	DROP VIEW vwCPGAContracts

-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1
	EXEC ('
	CREATE VIEW [dbo].[vwCPGAContracts]
	AS
	select
		a.gacnt_loc_no
		,a.gacnt_cnt_no
		,a.gacnt_seq_no
		,gacnt_due_rev_dt = (case len(convert(varchar, a.gacnt_due_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gacnt_due_rev_dt) AS CHAR(12)), 112) else null end)
		,a.gacnt_comments
		,a.gacnt_trk_rail_ind
		,gacnt_pbhcu_ind = (case a.gacnt_pbhcu_ind when ''B'' then ''Basis'' when ''P'' then ''Priced'' when ''H'' then ''HTA'' when ''C'' then ''CB'' when ''U'' then rtrim(ltrim(b.gacom_desc))+'' Only'' else '''' end)
		,a.gacnt_un_bot_basis
		,a.gacnt_un_cash_prc
		,a.gacnt_un_bot_prc
		,a.gacnt_com_cd
		,a.gacnt_cus_no
		,b.gacom_desc
		,a.gacnt_un_bal
		,a.gacnt_un_bal_unprc
		,status = (case when a.gacnt_un_bal > 0 then ''Open'' else ''Closed'' end)
		,a.gacnt_pur_sls_ind
		,a.gacnt_un_frt_basis
		,'''' as Remarks
		,a.gacnt_remarks_1
		,a.gacnt_remarks_2
		,a.gacnt_remarks_3
		,a.gacnt_remarks_4
		,a.gacnt_remarks_5
		,a.gacnt_remarks_6
		,a.gacnt_remarks_7
		,a.gacnt_remarks_8
		,a.gacnt_remarks_9
		,a.A4GLIdentity
	from
		gacntmst a
	left outer join
		gacommst b
		on a.gacnt_com_cd = b.gacom_com_cd
	')
GO
