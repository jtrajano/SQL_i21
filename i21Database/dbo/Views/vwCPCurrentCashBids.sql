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
	--and (a.gaprc_com_cd = @gaprc_com_cd)