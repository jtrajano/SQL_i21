GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPGAContractHistory')
	DROP VIEW vwCPGAContractHistory
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPGAContractHistory')
	DROP VIEW vyuCPGAContractHistory
GO
-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacntmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacommst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gahstmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'agcusmst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPGAContractHistory]
		AS
		select
			A4GLIdentity = row_number() over (order by a.gacnt_cnt_no)
			,strCustomerNo = a.gacnt_cus_no
			,strContractNo = a.gacnt_cnt_no
			,strSequenceNo = REPLACE(STR(a.gacnt_seq_no, 2), SPACE(1), ''0'')
			,strContractType = (case a.gacnt_pur_sls_ind when ''P'' then ''Purchase Contract'' when ''S'' then ''Sales Contract'' else '''' end)
			,strLocation = a.gacnt_loc_no
			,strCommodity = b.gacom_desc	
			,strCustomerName = ltrim(rtrim(d.agcus_first_name)) + '' '' + ltrim(rtrim(d.agcus_last_name))
			,strLocationDetail = a.gacnt_loc_no
			,strFarm = c.gahst_farm_no
			,strTicketNo = c.gahst_tic_no
			,dtmDeliveryDate = (case len(convert(varchar, c.gahst_dlvry_rev_dt)) when 8 then convert(date, cast(convert(varchar, c.gahst_dlvry_rev_dt) AS CHAR(12)), 112) else null end)
			,dblDelivered = c.gahst_no_un
			,strComment = c.gahst_adj_comment
			,a.gacnt_seq_no
			,a.gacnt_loc_no
			,a.gacnt_cnt_no
			,a.gacnt_cus_no
			,a.gacnt_com_cd
			,a.gacnt_pur_sls_ind
		from
			gacntmst a
			,gacommst b
			,gahstmst c
			,agcusmst d
		where
			a.gacnt_com_cd = b.gacom_com_cd
			and d.agcus_key = a.gacnt_cus_no
			and c.gahst_cnt_no = a.gacnt_cnt_no
			--and (a.gacnt_seq_no = ''1'') 
			--and (a.gacnt_loc_no = ''001'') 
			--and (a.gacnt_cnt_no = ''00001195'') 
			--and (a.gacnt_cus_no = ''0000000505'') 
			--and (a.gacnt_com_cd = ''C'') 
			--and (a.gacnt_pur_sls_ind = ''S'') 
		')
GO
