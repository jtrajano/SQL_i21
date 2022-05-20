GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuECCFCardTransaction')
	DROP VIEW vyuECCFCardTransaction
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'cftrxmst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuECCFCardTransaction]
		AS
		select
			strCustomerNo = convert(nvarchar(10),cftrx_ar_cus_no)
			,strCardNo = convert(nvarchar(16),cftrx_card_no)
			,dtmRevDate  = (case isdate(cftrx_rev_dt) when 1 then convert(date,convert(varchar,cftrx_rev_dt)) else null end)
			,intTime = convert(int,cftrx_time)
			,dblQuantity = cftrx_qty
			,dblTotal =  cftrx_calc_total
			,A4GLIdentity = ROW_NUMBER() over (order by cftrx_calc_total desc)
		from
			cftrxmst
		')
GO
