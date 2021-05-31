﻿CREATE VIEW [dbo].[vyuCRMLostRevenue]
	AS
	select
		overall.intEntityCustomerId
		,overall.strName
		,overall.intDate
		,overall.intEntityContactId
		,overall.intTempEntityContactId
		,overall.intSalespersonId
		,overall.dblSalesOrderTotal
		,overall.dblSalesOrderTotalShip
		,overall.dblSalesOrderTotalUnShip
		,dblTotalContractAmount
		,dblTotalContractOrdered
		,dblRemainingContractAmount
		,dblTotalOrderAndContract = (overall.dblSalesOrderTotalShip + overall.dblSalesOrderTotalUnShip + overall.dblRemainingContractAmount)

		,dblSalesOrderTotalUnits
		,dblSalesOrderTotalShipUnits
		,dblSalesOrderTotalUnShipUnits
		,dblTotalContractAmountUnits
		,dblTotalContractOrderedUnits
		,dblRemainingContractAmountUnits
		,dblTotalOrderAndContractUnits = (overall.dblSalesOrderTotalShipUnits + overall.dblSalesOrderTotalUnShipUnits + overall.dblRemainingContractAmountUnits)

		,strCategory
		,strItem
		,strContact
	from
	(
		select
			salesorders.intEntityCustomerId
			,salesorders.strName
			,salesorders.intDate
			,salesorders.intEntityContactId
			,salesorders.intTempEntityContactId
			,salesorders.intSalespersonId
			,salesorders.dblSalesOrderTotal
			,salesorders.dblSalesOrderTotalShip
			,salesorders.dblSalesOrderTotalUnShip
			,dblTotalContractAmount = 0
			,dblTotalContractOrdered = 0
			,dblRemainingContractAmount = 0

			,dblSalesOrderTotalUnits
			,dblSalesOrderTotalShipUnits
			,dblSalesOrderTotalUnShipUnits
			,dblTotalContractAmountUnits
			,dblTotalContractOrderedUnits
			,dblRemainingContractAmountUnits

			,strCategory
			,strItem
			,strContact
		from
		(
		select
			tblSOSalesOrder.intEntityCustomerId
			,strName = '('+ltrim(rtrim(tblEMEntity.strEntityNo))+') ' + tblEMEntity.strName
			,intDate = convert(int,convert(nvarchar(8),tblSOSalesOrder.dtmDate,112))
			,intEntityContactId = tblSOSalesOrder.intEntityContactId
			,intTempEntityContactId = isnull(tblSOSalesOrder.intEntityContactId,0)
			,tblARCustomer.intSalespersonId
			,dblSalesOrderTotal = sum(case when tblSOSalesOrderDetail.dblTotal < 1 then 0 else tblSOSalesOrderDetail.dblTotal end)
			,dblSalesOrderTotalShip = sum(
						case
							when tblSOSalesOrderDetail.dblQtyShipped < 1
							then 0
							else round((tblSOSalesOrderDetail.dblQtyShipped * tblSOSalesOrderDetail.dblPrice) * (1 - (tblSOSalesOrderDetail.dblDiscount/100)), 2)
						end
					 )
			,dblSalesOrderTotalUnShip = sum(
						   case
							   when ((case when tblSOSalesOrderDetail.dblQtyOrdered < 1 then 0 else tblSOSalesOrderDetail.dblQtyOrdered end) - tblSOSalesOrderDetail.dblQtyShipped) < 1
							   then 0
							   else round((((case when tblSOSalesOrderDetail.dblQtyOrdered < 1 then 0 else tblSOSalesOrderDetail.dblQtyOrdered end) - tblSOSalesOrderDetail.dblQtyShipped) * tblSOSalesOrderDetail.dblPrice) * (1 - (tblSOSalesOrderDetail.dblDiscount/100)), 2)
						   end
					   )
			,dblSalesOrderTotalUnits = sum(case when tblSOSalesOrderDetail.dblQtyOrdered < 1 then 0 else tblSOSalesOrderDetail.dblQtyOrdered end)
			,dblSalesOrderTotalShipUnits  = sum(tblSOSalesOrderDetail.dblQtyShipped)
			,dblSalesOrderTotalUnShipUnits  = (case when tblSOSalesOrderDetail.dblQtyShipped > tblSOSalesOrderDetail.dblQtyOrdered then 0 else (sum(tblSOSalesOrderDetail.dblQtyOrdered) - sum(tblSOSalesOrderDetail.dblQtyShipped)) end)
			,dblTotalContractAmountUnits = 0
			,dblTotalContractOrderedUnits = 0
			,dblRemainingContractAmountUnits = 0
			,strCategory = tblSOSalesOrder.strType
			,strItem = tblICItem.strItemNo
			,strContact = (select top 1 strName from tblEMEntity where intEntityId = tblSOSalesOrder.intEntityContactId)
		from
			tblSOSalesOrder
			inner join tblSOSalesOrderDetail on tblSOSalesOrderDetail.intSalesOrderId = tblSOSalesOrder.intSalesOrderId
			inner join tblICItem on tblICItem.intItemId = tblSOSalesOrderDetail.intItemId
			inner join tblEMEntity on tblEMEntity.intEntityId = tblSOSalesOrder.intEntityCustomerId
			inner join tblARCustomer on tblARCustomer.intEntityId = tblEMEntity.intEntityId
		where
			tblSOSalesOrder.strTransactionType = 'Order'
		group by
			tblSOSalesOrder.intEntityCustomerId
			,tblEMEntity.strName
			,tblEMEntity.strEntityNo
			,tblSOSalesOrder.dtmDate
			,tblARCustomer.intSalespersonId
			,tblSOSalesOrderDetail.dblQtyShipped
			,tblSOSalesOrderDetail.dblQtyOrdered
			,tblSOSalesOrder.strType
			,tblICItem.strItemNo
			,tblSOSalesOrder.intEntityContactId
		) as salesorders

		union all

		select
			contracts.intEntityCustomerId
			,contracts.strName
			,contracts.intDate
			,contracts.intEntityContactId
			,contracts.intTempEntityContactId
			,contracts.intSalespersonId
			,contracts.dblSalesOrderTotal
			,contracts.dblSalesOrderTotalShip
			,contracts.dblSalesOrderTotalUnShip
			,dblTotalContractAmount
			,dblTotalContractOrdered = (case when contracts.dblTotalContractOrdered is null then 0 else contracts.dblTotalContractOrdered end)
			,dblRemainingContractAmount = (contracts.dblTotalContractAmount - (case when contracts.dblTotalContractOrdered is null then 0 else contracts.dblTotalContractOrdered end))

			,dblSalesOrderTotalUnits
			,dblSalesOrderTotalShipUnits
			,dblSalesOrderTotalUnShipUnits
			,dblTotalContractAmountUnits
			,dblTotalContractOrderedUnits = (case when contracts.dblTotalContractOrderedUnits is null then 0 else contracts.dblTotalContractOrderedUnits end)
			,dblRemainingContractAmountUnits = (contracts.dblTotalContractAmountUnits - (case when contracts.dblTotalContractOrderedUnits is null then 0 else contracts.dblTotalContractOrderedUnits end))

			,strCategory
			,strItem
			,strContact
		from
		(
			select
				intEntityCustomerId = c.intEntityId
				,strName = '('+ltrim(rtrim(c.strEntityNo))+') ' + c.strName
				,intDate = convert(int,convert(nvarchar(8),b.dtmContractDate,112))
				,intEntityContactId = b.intEntityContactId
				,intTempEntityContactId = isnull(b.intEntityContactId,0)
				,f.intSalespersonId
				,dblSalesOrderTotal = 0
				,dblSalesOrderTotalShip = 0
				,dblSalesOrderTotalUnShip = 0
				,dblTotalContractAmount = sum(a.dblTotalCost)
				,dblTotalContractOrdered = (select sum(case when e.dblTotal < 1 then 0 else e.dblTotal end) from tblSOSalesOrderDetail e where e.intContractHeaderId = b.intContractHeaderId)
				,dblSalesOrderTotalUnits = 0
				,dblSalesOrderTotalShipUnits = 0
				,dblSalesOrderTotalUnShipUnits = 0
				,dblTotalContractAmountUnits = sum(a.dblQuantity)
				,dblTotalContractOrderedUnits = (select sum(case when e.dblQtyOrdered < 1 then 0 else e.dblQtyOrdered end) from tblSOSalesOrderDetail e where e.intContractHeaderId = b.intContractHeaderId)
				,strCategory = g.strCommodityCode
				,strItem = h.strItemNo
				,strContact = (select top 1 strName from tblEMEntity where intEntityId = b.intEntityContactId)
			from
				tblCTContractDetail a
				inner join tblCTContractHeader b on  b.intContractHeaderId = a.intContractHeaderId
				inner join tblICCommodity g on g.intCommodityId = b.intCommodityId
				inner join tblICItem h on h.intItemId = a.intItemId
				inner join tblEMEntity c on c.intEntityId = b.intEntityId
				inner join tblARCustomer f on f.intEntityId = c.intEntityId
			group by
				c.intEntityId
				,c.strName
				,c.strEntityNo
				,f.intSalespersonId
				,b.dtmContractDate
				,b.intContractHeaderId
				,g.strCommodityCode
				,h.strItemNo
				,b.intEntityContactId
		) as contracts
	) as overall
