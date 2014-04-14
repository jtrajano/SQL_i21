IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPCurrentCashBids')
	DROP VIEW vwCPCurrentCashBids
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPCurrentCashBids')
	DROP VIEW vyuCPCurrentCashBids
GO

-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1 and 
	(SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'gacommst') = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPCurrentCashBids]
		AS
		select
			a.A4GLIdentity
			,a.gaprc_com_cd
			,a.gaprc_un_cash_prc
			,b.gacom_desc
			,a.gaprc_loc_no
			,c.galoc_desc
			
		from
			gacommst b
		right outer join
			gaprcmst a
			on b.gacom_com_cd = a.gaprc_com_cd
		left join
			galocmst c
			on c.galoc_loc_no = a.gaprc_loc_no
		where
			(a.gaprc_un_cash_prc > 0)
		')
GO