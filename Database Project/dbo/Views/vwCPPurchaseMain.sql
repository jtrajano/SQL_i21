














CREATE VIEW [dbo].[vwCPPurchaseMain]
AS

select distinct
	 id = row_number() over (order by agstm_bill_to_cus)
	,strCustomerNo = agstm_bill_to_cus
	,strItemNo = agstm_itm_no
	,strLocationNo = agstm_loc_no
	,strDescription = agitm_desc
	,intUnit = agstm_un
	,strUnitDescription = agstm_un_desc
	,dblAmount = sum(agstm_amount)
from
	vwCPPurchaseDetail
--where
--	agstm_ship_rev_dt between @datefrom and @dateto
--	and agstm_bill_to_cus = ''
--	and agstm_itm_no = ''
group by
	agstm_bill_to_cus
	,agstm_itm_no
	,agstm_loc_no
	,agitm_desc
	,agstm_un
	,agstm_un_desc

