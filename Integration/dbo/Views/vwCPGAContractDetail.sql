IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPGAContractDetail')
	DROP VIEW vwCPGAContractDetail

-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacntmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacommst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPGAContractDetail]
		AS
		select
			A4GLIdentity = row_number() over (order by a.gacnt_cnt_no)
			,strCustomerNo = a.gacnt_cus_no
			,strContractNo = a.gacnt_cnt_no
			--,strSequenceNo = ''-''+convert(varchar,a.gacnt_seq_no)
			,strSequenceNo = REPLACE(STR(a.gacnt_seq_no, 2), SPACE(1), ''0'')
			,strContractType = (case a.gacnt_pur_sls_ind when ''P'' then ''Purchase Contract'' when ''S'' then ''Sales Contract'' else '''' end)
			,strLocation = a.gacnt_loc_no
			,strCommodity = b.gacom_desc
			,dtmContractDate = (case len(convert(varchar, a.gacnt_cnt_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gacnt_cnt_rev_dt) AS CHAR(12)), 112) else null end)
			,strOriginalTitle = ''Original ''+convert(varchar,b.gacom_un_desc)+'' :''
			,dblOriginalValue = a.gacnt_no_un
			,strType = (case a.gacnt_pbhcu_ind when ''B'' then ''Basis'' when ''P'' then ''Priced'' when ''H'' then ''HTA'' when ''C'' then ''CB'' when ''U'' then convert(varchar,b.gacom_desc)+'' Only'' else a.gacnt_pbhcu_ind end)
			,dtmBeginShipDate = (case len(convert(varchar, a.gacnt_beg_ship_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gacnt_beg_ship_rev_dt) AS CHAR(12)), 112) else null end)
			,strBalanceTitle = ''Balance ''+convert(varchar,b.gacom_un_desc)+'' :''
			,dblBalanceValue = a.gacnt_un_bal
			,dblCashPriced = a.gacnt_un_cash_prc
			,dtmDueDate = (case len(convert(varchar, a.gacnt_due_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gacnt_due_rev_dt) AS CHAR(12)), 112) else null end)
			,strUnpricedTitle = ''UnPriced ''+convert(varchar,b.gacom_un_desc)+'' :''
			,dblUnpricedValue = a.gacnt_un_bal_unprc
			,dblBOTPriced = a.gacnt_un_bot_prc
			,strHowShip = (case a.gacnt_trk_rail_ind when ''T'' then ''Truck'' when ''R'' then ''Rail'' when ''B'' then ''Both'' when ''D'' then ''Delivery'' when ''P'' then ''Pickup'' else '''' end)
			,strInTransitTitle = ''In-Transit ''+convert(varchar,b.gacom_un_desc)+'' :''
			,dblInTransitValue = a.gacnt_un_bal_transit
			,dblBotBasis = a.gacnt_un_bot_basis
			,strCustomerContract = a.gacnt_cus_cnt_no
			,strScheduleTitle = ''Schedule ''+convert(varchar,b.gacom_un_desc)+'' :''
			,dblScheduleValue = a.gacnt_sched_un
			,strBotOption = convert(varchar,a.gacnt_bot) +'' / ''+ convert(varchar,a.gacnt_bot_option)
			,dtmDefferPaymentDate = (case len(convert(varchar, a.gacnt_defer_pmt_rev_dt)) when 8 then convert(date, cast(convert(varchar, a.gacnt_defer_pmt_rev_dt) AS CHAR(12)), 112) else null end)
			,strBuyerName = a.gacnt_buyer
			,strDiscounts = (case a.gacnt_disc_dca_ind when ''D'' then ''Delivery'' when ''A'' then ''As-Is'' else ''Contract'' end)
			,dblDefferPaymentRate = a.gacnt_int_rt
			,strSigned = (case a.gacnt_signed_yn when ''Y'' then ''Yes'' else ''No'' end)
			,strDiscountSchedTitle = (case a.gacnt_disc_dca_ind when ''A'' then ''Discount Sched:'' else '''' end)
			,dblDiscountSchedValue = (case a.gacnt_disc_dca_ind when ''A'' then convert(varchar,a.gacnt_as_is_disc) else '''' end)
			,dblFreightRate = a.gacnt_frt_trk_rt
			,strPrinted = (case a.gacnt_printed_yn when ''Y'' then ''Yes'' else ''No'' end)
			,strMarketZone = a.gacnt_printed_yn
			,strLastContractSeq = a.gacnt_last_cnt_seq_no
			,strLastHistorySeq = a.gacnt_last_hst_seq_no
			,strRemarks = convert(varchar,a.gacnt_remarks_1)+'' ''+convert(varchar,a.gacnt_remarks_2)+'' ''+convert(varchar,a.gacnt_remarks_3)
			,a.gacnt_seq_no
			,a.gacnt_loc_no
			,a.gacnt_cnt_no
			,a.gacnt_cus_no
			,a.gacnt_com_cd
			,a.gacnt_pur_sls_ind
			,b.gacom_un_desc
			,a.gacnt_mkt_zone	
		from
			gacntmst a
			,gacommst b
		where
			a.gacnt_com_cd = b.gacom_com_cd 
		')
GO
