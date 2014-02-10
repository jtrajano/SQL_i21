﻿IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPCurrentCashBids')
	DROP VIEW vwCPCurrentCashBids

-- GRAINS DEPENDENT
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPCurrentCashBids]
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