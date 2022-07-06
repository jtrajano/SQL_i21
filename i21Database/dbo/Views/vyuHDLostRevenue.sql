CREATE VIEW [dbo].[vyuHDLostRevenue]
	AS
		select
			tblSOSalesOrder.intEntityCustomerId
			,tblEMEntity.strName
			,intDate = convert(int,convert(nvarchar(8),tblSOSalesOrder.dtmDate,112))
			,tblEMEntityToContact.intEntityContactId
			,tblARCustomer.intSalespersonId
			,dblSalesOrderTotal = sum(tblSOSalesOrder.dblSalesOrderTotal)
		from
			tblSOSalesOrder
			inner join tblEMEntity on tblEMEntity.intEntityId = tblSOSalesOrder.intEntityCustomerId
			inner join tblEMEntityToContact on tblEMEntityToContact.intEntityId = tblEMEntity.intEntityId
			inner join tblARCustomer on tblARCustomer.[intEntityId] = tblEMEntity.intEntityId
		where
			tblSOSalesOrder.strTransactionType = 'Order'
			and tblEMEntityToContact.ysnDefaultContact = 1
		group by
			tblSOSalesOrder.intEntityCustomerId
			,tblEMEntity.strName
			,tblSOSalesOrder.dtmDate
			,tblEMEntityToContact.intEntityContactId
			,tblARCustomer.intSalespersonId
