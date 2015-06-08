CREATE VIEW [dbo].[vyuEMSearch]
as 
SELECT 
		a.intEntityId,    
		a.Name as strName,  
		g.strPhone,  
		e.strAddress,  
		e.strCity,  
		e.strState,  
		e.strZipCode,
		Customer,
		Vendor,
		Employee,
		Salesperson,
		[User],
		FuturesBroker,
		ForwardingAgent,
		Terminal,
		ShippingLine
	FROM 		
			(SELECT	intEntityId, Name,		
								CASE WHEN [Customer] IS NOT NULL THEN 1 ELSE 0 END Customer, 		
								CASE WHEN [Vendor] IS NOT NULL THEN 1 ELSE 0 END Vendor, 		
								CASE WHEN [Employee] IS NOT NULL THEN 1 ELSE 0 END Employee, 		
								CASE WHEN [Salesperson] IS NOT NULL THEN 1 ELSE 0 END Salesperson, 		
								CASE WHEN [User] IS NOT NULL THEN 1 ELSE 0 END AS  [User],
								CASE WHEN [Futures Broker] IS NOT NULL THEN 1 ELSE 0 END AS  FuturesBroker,
								CASE WHEN [Forwarding Agent] IS NOT NULL THEN 1 ELSE 0 END AS  ForwardingAgent,
								CASE WHEN [Terminal] IS NOT NULL THEN 1 ELSE 0 END AS  Terminal,
								CASE WHEN [Shipping Line] IS NOT NULL THEN 1 ELSE 0 END AS  ShippingLine
			FROM
			(
				select A.intEntityId,  A.strName Name, strType 
					from tblEntity A
						JOIN tblEntityType B
							on A.intEntityId = B.intEntityId		
			) SourceTable
			PIVOT
			(
				max(strType)
				FOR strType  IN (
						[Customer], 
						[Vendor], 
						[Employee], 
						[Salesperson],
						[User],
						[Futures Broker],
						[Forwarding Agent],
						Terminal,
						[Shipping Line]
					)
			) AS PivotTable
		) a
		left join tblEntityLocation e  
			on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
		left join tblEntityToContact f  
			on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
		left join tblEntity g  
			on f.intEntityContactId = g.intEntityId  