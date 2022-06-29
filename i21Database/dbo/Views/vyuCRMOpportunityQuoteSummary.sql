CREATE VIEW [dbo].[vyuCRMOpportunityQuoteSummary]
	AS
SELECT 		 intSalesOrderId		= a.intSalesOrderId
		    ,strSalesOrderNumber	= a.strSalesOrderNumber
			,dblSalesOrderTotal	    = a.dblSalesOrderTotal
			,dblSoftwareAmount	    = Qoutes.dblSoftwareAmount
			,dblMaintenanceAmount	= Qoutes.dblMaintenanceAmount
			,dblOtherAmount			= Qoutes.dblOtherAmount
FROM  tblSOSalesOrder a	
OUTER APPLY
(
		SELECT    dblSoftwareAmount     = SUM(dblSoftwareAmount)
				, dblMaintenanceAmount  = SUM(dblMaintenanceAmount)
				, dblOtherAmount		= SUM(dblOtherAmount)
		FROM (
		
			SELECT
				 a.intSalesOrderId
				,dblSoftwareAmount	  = SUM(ISNULL(b.dblLicenseAmount,0) * ISNULL(b.dblQtyOrdered,0))
				,dblMaintenanceAmount = SUM(ISNULL(b.dblMaintenanceAmount,0) * ISNULL(b.dblQtyOrdered,0))
				,dblOtherAmount = 0
			FROM
				tblSOSalesOrder a
				LEFT JOIN tblSOSalesOrderDetail b
					ON  b.intSalesOrderId = a.intSalesOrderId
			WHERE
				a.strTransactionType = 'Quote'
				AND a.strOrderStatus <> 'Expired'
			GROUP BY a.intSalesOrderId

			UNION ALL

			SELECT
				 a.intSalesOrderId
				,dblSoftwareAmount	  = 0
				,dblMaintenanceAmount = 0
				,dblOtherAmount		  = SUM(ISNULL(b.dblTotal,0))
			FROM
				tblSOSalesOrder a
				LEFT JOIN tblSOSalesOrderDetail b
					ON  b.intSalesOrderId = a.intSalesOrderId
						AND b.dblLicenseAmount = 0
						AND b.dblMaintenanceAmount = 0
			WHERE
				a.strTransactionType = 'Quote'
				AND a.strOrderStatus <> 'Expired'
			GROUP BY a.intSalesOrderId
		
		) QuoteAmount

		WHERE QuoteAmount.intSalesOrderId = a.intSalesOrderId
) Qoutes

GO
