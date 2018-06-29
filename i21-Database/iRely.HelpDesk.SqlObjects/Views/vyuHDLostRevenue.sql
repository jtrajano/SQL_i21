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
			,tblEMEntity
			,tblEMEntityToContact
			,tblARCustomer
		where
			tblSOSalesOrder.strTransactionType = 'Order'
			and tblEMEntity.intEntityId = tblSOSalesOrder.intEntityCustomerId
			and tblEMEntityToContact.intEntityId = tblEMEntity.intEntityId
			and tblEMEntityToContact.ysnDefaultContact = 1
			and tblARCustomer.[intEntityId] = tblEMEntity.intEntityId
		group by
			tblSOSalesOrder.intEntityCustomerId
			,tblEMEntity.strName
			,tblSOSalesOrder.dtmDate
			,tblEMEntityToContact.intEntityContactId
			,tblARCustomer.intSalespersonId
