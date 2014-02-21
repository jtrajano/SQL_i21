/*
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPurchaseMain')
	DROP VIEW vwCPPurchaseMain
GO
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
group by
	agstm_bill_to_cus
	,agstm_itm_no
	,agstm_loc_no
	,agitm_desc
	,agstm_un
	,agstm_un_desc

GO
*/

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPurchaseMain')
	DROP VIEW vwCPPurchaseMain
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPPurchaseDetail')
	EXEC('
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
	group by
		agstm_bill_to_cus
		,agstm_itm_no
		,agstm_loc_no
		,agitm_desc
		,agstm_un
		,agstm_un_desc
	')
GO