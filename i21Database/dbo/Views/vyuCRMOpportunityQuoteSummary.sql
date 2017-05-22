CREATE VIEW [dbo].[vyuCRMOpportunityQuoteSummary]
	AS
		select
			a.intSalesOrderId
			,a.strSalesOrderNumber
			,a.dblSalesOrderTotal
			,dblSoftwareAmount = sum(isnull(b.dblLicenseAmount,0))
			,dblMaintenanceAmount = sum(isnull(b.dblMaintenanceAmount,0))
			,dblOtherAmount = sum(distinct isnull(c.dblTotal,0))
		from
			tblSOSalesOrder a
			left join tblSOSalesOrderDetail b
				on  b.intSalesOrderId = a.intSalesOrderId
			left join tblSOSalesOrderDetail c
				on c.intSalesOrderId = a.intSalesOrderId
				and c.dblLicenseAmount = 0
				and c.dblMaintenanceAmount = 0
		where
			a.strTransactionType = 'Quote'
			and a.strOrderStatus <> 'Expired'
		group by
			a.intSalesOrderId
			,a.strSalesOrderNumber
			,a.dblSalesOrderTotal
