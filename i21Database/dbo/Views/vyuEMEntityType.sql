CREATE VIEW [dbo].[vyuEMEntityType]
	AS 



	SELECT	intEntityId,
								
								CASE WHEN [Vendor] IS NOT NULL THEN 1 ELSE 0 END Vendor, 		
								CASE WHEN [Customer] IS NOT NULL THEN 1 ELSE 0 END Customer, 
								CASE WHEN [Salesperson] IS NOT NULL THEN 1 ELSE 0 END Salesperson, 												
								CASE WHEN [Futures Broker] IS NOT NULL THEN 1 ELSE 0 END AS  FuturesBroker,
								CASE WHEN [Forwarding Agent] IS NOT NULL THEN 1 ELSE 0 END AS  ForwardingAgent,
								CASE WHEN [Terminal] IS NOT NULL THEN 1 ELSE 0 END AS  Terminal,
								CASE WHEN [Shipping Line] IS NOT NULL THEN 1 ELSE 0 END AS  ShippingLine,
								CASE WHEN [Trucker] IS NOT NULL THEN 1 ELSE 0 END AS  Trucker,
								CASE WHEN [Ship Via] IS NOT NULL THEN 1 ELSE 0 END AS  ShipVia,
								CASE WHEN [Insurer] IS NOT NULL THEN 1 ELSE 0 END AS  Insurer,
								CASE WHEN [Employee] IS NOT NULL THEN 1 ELSE 0 END Employee, 		
								CASE WHEN [Producer] IS NOT NULL THEN 1 ELSE 0 END [Producer], 	
								CASE WHEN [User] IS NOT NULL THEN 1 ELSE 0 END AS  [User],
								CASE WHEN [Prospect] IS NOT NULL THEN 1 ELSE 0 END AS  [Prospect],
								CASE WHEN [Competitor] IS NOT NULL THEN 1 ELSE 0 END AS  [Competitor],
								CASE WHEN [Buyer] IS NOT NULL THEN 1 ELSE 0 END AS  [Buyer],
								CASE WHEN [Partner] IS NOT NULL THEN 1 ELSE 0 END AS  [Partner]								

			FROM
			(
				select A.intEntityId, strType
					from tblEMEntity A
						JOIN [tblEMEntityType] B
							on A.intEntityId = B.intEntityId		
			) SourceTable
			PIVOT
			(
				max(strType)
				FOR strType  IN (
						[Vendor],
						[Customer],
						[Salesperson],
						[Futures Broker],
						[Forwarding Agent],
						[Terminal],
						[Shipping Line],
						[Trucker],
						[Ship Via],
						[Insurer],
						[Employee],
						[Producer],
						[User],
						[Prospect],
						[Competitor],
						[Buyer],
						[Partner]


					)
			) AS PivotTable


