GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPGAContractOption')
	DROP VIEW vwCPGAContractOption
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPGAContractOption')
	DROP VIEW vyuCPGAContractOption
GO
-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacntmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacommst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gaoptmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'agcusmst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPGAContractOption]
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
	
			,strOption = c.gaopt_bot_opt
			,strLocationDetail = a.gacnt_loc_no
			,dtmExpireDate = (case len(convert(varchar, c.gaopt_exp_rev_dt)) when 8 then convert(date, cast(convert(varchar, c.gaopt_exp_rev_dt) AS CHAR(12)), 112) else null end)
			,strBuySell = c.gaopt_buy_sell
			,strPutCall = c.gaopt_put_call
			,strComment = c.gaopt_comments
			,dblPremiumServiceFee = c.gaopt_un_prem
			,dblNumberBU = c.gaopt_no_un
			,dblStrikePrice = c.gaopt_un_strk_prc
			,strStatus = c.gaopt_status_ind
	
			,a.gacnt_seq_no
			,a.gacnt_loc_no
			,a.gacnt_cnt_no
			,a.gacnt_cus_no
			,a.gacnt_com_cd
			,a.gacnt_pur_sls_ind
		from
			gacntmst a
			,gacommst b
			,gaoptmst c
			,agcusmst d
		where
			a.gacnt_com_cd = b.gacom_com_cd
			and d.agcus_key = a.gacnt_cus_no
			and c.gaopt_cus_no = a.gacnt_cus_no
			and c.gaopt_pur_sls_ind = a.gacnt_pur_sls_ind
			and c.gaopt_com_cd = a.gacnt_com_cd
			--and (a.gacnt_seq_no = ''1'') 
			--and (a.gacnt_loc_no = ''001'') 
	--and (a.gacnt_cnt_no = ''00001195'') 
	--and (a.gacnt_cus_no = ''0000000505'') 
	--and (a.gacnt_com_cd = ''C'') 
	--and (a.gacnt_pur_sls_ind = ''S'')
		')
GO
