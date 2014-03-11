IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPGABusinessSummary')
	DROP VIEW vwCPGABusinessSummary
GO
-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gastlmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacommst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPGABusinessSummary]
		AS
		WITH GAS
		AS 
		(
			SELECT 
			 CASE WHEN (ISNULL(a.gastl_shrk_what_1, '''') <> '''' and a.gastl_shrk_what_1 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_1)
				  WHEN (ISNULL(a.gastl_shrk_what_1, '''') <> '''' and a.gastl_shrk_what_1 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_1 + a.gastl_shrk_pct_1 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_2, '''') <> '''' and a.gastl_shrk_what_2 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_2)
				  WHEN (ISNULL(a.gastl_shrk_what_2, '''') <> '''' and a.gastl_shrk_what_2 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_2 + a.gastl_shrk_pct_2 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_3, '''') <> '''' and a.gastl_shrk_what_3 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_3)
				  WHEN (ISNULL(a.gastl_shrk_what_3, '''') <> '''' and a.gastl_shrk_what_3 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_3 + a.gastl_shrk_pct_3 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_4, '''') <> '''' and a.gastl_shrk_what_4 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_4)
				  WHEN (ISNULL(a.gastl_shrk_what_4, '''') <> '''' and a.gastl_shrk_what_4 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_4 + a.gastl_shrk_pct_4 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_5, '''') <> '''' and a.gastl_shrk_what_5 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_5)
				  WHEN (ISNULL(a.gastl_shrk_what_5, '''') <> '''' and a.gastl_shrk_what_5 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_5 + a.gastl_shrk_pct_5 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_6, '''') <> '''' and a.gastl_shrk_what_6 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_6)
				  WHEN (ISNULL(a.gastl_shrk_what_6, '''') <> '''' and a.gastl_shrk_what_6 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_6 + a.gastl_shrk_pct_6 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_7, '''') <> '''' and a.gastl_shrk_what_7 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_7)
				  WHEN (ISNULL(a.gastl_shrk_what_7, '''') <> '''' and a.gastl_shrk_what_7 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_7 + a.gastl_shrk_pct_7 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_8, '''') <> '''' and a.gastl_shrk_what_8 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_8)
				  WHEN (ISNULL(a.gastl_shrk_what_8, '''') <> '''' and a.gastl_shrk_what_8 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_8 + a.gastl_shrk_pct_8 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_9, '''') <> '''' and a.gastl_shrk_what_9 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_9)
				  WHEN (ISNULL(a.gastl_shrk_what_9, '''') <> '''' and a.gastl_shrk_what_9 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_9 + a.gastl_shrk_pct_9 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_10, '''') <> '''' and a.gastl_shrk_what_10 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_10)
				  WHEN (ISNULL(a.gastl_shrk_what_10, '''') <> '''' and a.gastl_shrk_what_10 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_10 + a.gastl_shrk_pct_10 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_11, '''') <> '''' and a.gastl_shrk_what_11 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_11)
				  WHEN (ISNULL(a.gastl_shrk_what_11, '''') <> '''' and a.gastl_shrk_what_11 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_11 + a.gastl_shrk_pct_11 / 100 * a.gastl_un_prc)
				  WHEN (ISNULL(a.gastl_shrk_what_12, '''') <> '''' and a.gastl_shrk_what_12 <> ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_12)
				  WHEN (ISNULL(a.gastl_shrk_what_12, '''') <> '''' and a.gastl_shrk_what_12 = ''P'') THEN (a.gastl_no_un * a.gastl_un_disc_amt_12 + a.gastl_shrk_pct_12 / 100 * a.gastl_un_prc)
			END AS drying, a.A4GLIdentity
			FROM gastlmst a
		),
		GAS2
		as
		(
			SELECT 
			 CASE WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_ckoff_amt) + isnumeric(a.gastl_ins_amt) + isnumeric(a.gastl_fees_pd))
				  WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) = 0) THEN (isnumeric(a.gastl_ckoff_amt) + isnumeric(a.gastl_ins_amt))
				  WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_ckoff_amt) + isnumeric(a.gastl_fees_pd))
				  WHEN (ISNULL(a.gastl_ckoff_amt, 0) <> 0 and ISNULL(a.gastl_ins_amt, 0) = 0 and ISNULL(a.gastl_fees_pd, 0) = 0) THEN (isnumeric(a.gastl_ckoff_amt))
				  
				  WHEN (ISNULL(a.gastl_ckoff_amt, 0) = 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_ins_amt) + isnumeric(a.gastl_fees_pd))
				  WHEN (ISNULL(a.gastl_ckoff_amt, 0) = 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) = 0) THEN (isnumeric(a.gastl_ins_amt))
				  WHEN (ISNULL(a.gastl_ckoff_amt, 0) = 0 and ISNULL(a.gastl_ins_amt, 0) <> 0 and ISNULL(a.gastl_fees_pd, 0) <> 0) THEN (isnumeric(a.gastl_fees_pd))
			END AS chkIns, a.A4GLIdentity
			FROM gastlmst a
		),
		GAS3
		as
		(
			SELECT 
			 CASE WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ckoff_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') <> '''') THEN b.gacom_ckoff_desc+''=''+convert(varchar,a.gastl_adj_ckoff_amt)
				  WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ckoff_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') = '''') THEN ''CKOFF=''+convert(varchar,a.gastl_adj_ckoff_amt)
			else ''''
			END AS recType, a.A4GLIdentity
			FROM gastlmst a, gacommst b where b.gacom_com_cd = a.gastl_com_cd and a.gastl_pur_sls_ind = ''P''
		),
		GAS4
		as
		(
			SELECT 
			 CASE WHEN ISNULL(a.gastl_rec_type, '''') = '''' THEN ''''
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''M'' THEN ''SPOT SALE''
				  WHEN (ISNULL(a.gastl_rec_type, '''') = ''C'' and isnull(a.gastl_cnt_no,'''') = '''') THEN ''CONT''
				  WHEN (ISNULL(a.gastl_rec_type, '''') = ''C'' and isnull(a.gastl_cnt_no,'''') <> '''') THEN ''CONT ''+Convert(varchar,a.gastl_cnt_no)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''F'' THEN ''FREIGHT @''+Convert(varchar,a.gastl_frt_rt)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''I'' THEN ''INTEREST''
				  WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ins_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') <> '''') THEN b.gacom_ckoff_desc+''=''+convert(varchar,a.gastl_adj_ins_amt)
				  WHEN (ISNULL(a.gastl_rec_type, '''') = ''J'' and isnumeric(a.gastl_adj_ins_amt) <> 0 and ISNULL(b.gacom_ckoff_desc, '''') = '''') THEN ''INS=''+convert(varchar,a.gastl_adj_ins_amt)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''D'' THEN ''BILLED ADV''
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''1'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_1, '''') from ecctlmst e)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''2'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_2, '''') from ecctlmst e)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''3'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_3, '''') from ecctlmst e)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''4'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_4, '''') from ecctlmst e)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''5'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_5, '''') from ecctlmst e)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''6'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_6, '''') from ecctlmst e)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''7'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_7, '''') from ecctlmst e)
				  WHEN ISNULL(a.gastl_rec_type, '''') = ''8'' THEN (select top 1 isnull(e.ecctl_ga_stor_desc_8, '''') from ecctlmst e)
			END AS recType, a.A4GLIdentity
			FROM gastlmst a, gacommst b where b.gacom_com_cd = a.gastl_com_cd and a.gastl_pur_sls_ind = ''P''
		)
		select
			a.A4GLIdentity
			,a.gastl_com_cd
			,gastl_pd_yn = (case a.gastl_pd_yn when ''Y'' then ''P'' else ''U'' end)
			,a.gastl_rec_type
			,a.gastl_un_prc
			,a.gastl_cus_no
			,a.gastl_pur_sls_ind
			,a.gastl_no_un
			,a.gastl_stl_amt
			,a.gastl_un_disc_pd
			,a.gastl_un_disc_adj
			,a.gastl_un_stor_pd
			,a.gastl_ckoff_amt
			,a.gastl_ins_amt
			,a.gastl_fees_pd
			,a.gastl_un_frt_rt
			,a.gastl_loc_no
			,a.gastl_tic_no
			,a.gastl_spl_no
			,a.gastl_cnt_no
			,a.gastl_shrk_what_1
			,a.gastl_shrk_what_2
			,a.gastl_shrk_what_3
			,a.gastl_shrk_what_4
			,a.gastl_shrk_what_5
			,a.gastl_shrk_what_6
			,a.gastl_shrk_what_7
			,a.gastl_shrk_what_8
			,a.gastl_shrk_what_9
			,a.gastl_shrk_what_10
			,a.gastl_shrk_what_11
			,a.gastl_shrk_what_12
			,a.gastl_chk_no
			,a.gastl_un_disc_amt_1
			,a.gastl_un_disc_amt_2
			,a.gastl_un_disc_amt_3
			,a.gastl_un_disc_amt_4
			,a.gastl_un_disc_amt_5
			,a.gastl_un_disc_amt_6
			,a.gastl_un_disc_amt_7
			,a.gastl_un_disc_amt_8
			,a.gastl_un_disc_amt_9
			,a.gastl_un_disc_amt_10
			,a.gastl_un_disc_amt_11
			,a.gastl_un_disc_amt_12
			,a.gastl_shrk_pct_1
			,a.gastl_shrk_pct_2
			,a.gastl_shrk_pct_3
			,a.gastl_shrk_pct_4
			,a.gastl_shrk_pct_5
			,a.gastl_shrk_pct_6
			,a.gastl_shrk_pct_7
			,a.gastl_shrk_pct_8
			,a.gastl_shrk_pct_9
			,a.gastl_shrk_pct_10
			,a.gastl_shrk_pct_11
			,a.gastl_shrk_pct_12
			,gastl_stl_rev_dt = (case len(convert(varchar, a.gastl_stl_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_stl_rev_dt) AS CHAR(12)), 112) else null end)
			,gastl_pmt_rev_dt = (case len(convert(varchar, a.gastl_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gastl_pmt_rev_dt) AS CHAR(12)), 112) else null end)
			,Storage = (a.gastl_no_un * a.gastl_un_stor_pd)
			,Drying = (SELECT TOP 1 drying FROM GAS where A4GLIdentity = a.A4GLIdentity)
			,Discount = (SELECT TOP 1 (case when drying <= ((a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj)) then ((a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj) + (a.gastl_no_un * a.gastl_frt_rt)) - drying else (a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj) + (a.gastl_no_un * a.gastl_frt_rt) end) FROM GAS where A4GLIdentity = a.A4GLIdentity)
			,Gross = a.gastl_stl_amt + (a.gastl_no_un * a.gastl_un_disc_pd) + (a.gastl_no_un * a.gastl_un_disc_adj) + (a.gastl_no_un * a.gastl_un_stor_pd) + a.gastl_ckoff_amt + a.gastl_ins_amt + a.gastl_fees_pd + (a.gastl_no_un * a.gastl_un_frt_rt)
			,Type = (SELECT TOP 1 recType FROM GAS3 where A4GLIdentity = a.A4GLIdentity)+'' ''+(SELECT TOP 1 recType FROM GAS4 where A4GLIdentity = a.A4GLIdentity)
			,Units = a.gastl_no_un
			,a.gastl_adj_ckoff_amt
			,a.gastl_frt_rt
			,a.gastl_adj_ins_amt
			,a.gastl_frt_un
			,b.gacom_ckoff_desc
			,b.gacom_ins_desc
			,'''' as TypeDetails
			,Chk_Ins = (SELECT TOP 1 chkIns FROM GAS2 where A4GLIdentity = a.A4GLIdentity)
		from
			gastlmst a
			,gacommst b
		where
			(a.gastl_pur_sls_ind = ''P'')
			and (a.gastl_com_cd = b.gacom_com_cd)

			')

GO
