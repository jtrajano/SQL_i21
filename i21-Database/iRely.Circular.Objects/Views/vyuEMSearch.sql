﻿CREATE VIEW [dbo].[vyuEMSearch]
as 
SELECT 
		a.intEntityId,   
		b.strEntityNo, 
		b.strName,
		g.strPhone,  
		e.strAddress,  
		e.strCity,  
		e.strState,  
		e.strZipCode,
		intWarehouseId = isnull(e.intWarehouseId, -99),
		Customer,
		Vendor,
		Employee,
		Salesperson,
		[User],
		FuturesBroker,
		ForwardingAgent,
		Terminal,
		ShippingLine,
		Trucker,
		Insurer,
		ShipVia,
		VendorOrCustomer =  Vendor + Customer,
		b.strFederalTaxId,
		strDefaultEntityType = ET.strType
	FROM 		
			(SELECT	intEntityId,
								CASE WHEN [Customer] IS NOT NULL THEN 1 ELSE 0 END Customer, 		
								CASE WHEN [Vendor] IS NOT NULL THEN 1 ELSE 0 END Vendor, 		
								CASE WHEN [Employee] IS NOT NULL THEN 1 ELSE 0 END Employee, 		
								CASE WHEN [Salesperson] IS NOT NULL THEN 1 ELSE 0 END Salesperson, 		
								CASE WHEN [User] IS NOT NULL THEN 1 ELSE 0 END AS  [User],
								CASE WHEN [Futures Broker] IS NOT NULL THEN 1 ELSE 0 END AS  FuturesBroker,
								CASE WHEN [Forwarding Agent] IS NOT NULL THEN 1 ELSE 0 END AS  ForwardingAgent,
								CASE WHEN [Terminal] IS NOT NULL THEN 1 ELSE 0 END AS  Terminal,
								CASE WHEN [Shipping Line] IS NOT NULL THEN 1 ELSE 0 END AS  ShippingLine,
								CASE WHEN [Trucker] IS NOT NULL THEN 1 ELSE 0 END AS  Trucker,
								CASE WHEN [Insurer] IS NOT NULL THEN 1 ELSE 0 END AS  Insurer,
								CASE WHEN [Ship Via] IS NOT NULL THEN 1 ELSE 0 END AS  ShipVia
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
						[Customer], 
						[Vendor], 
						[Employee], 
						[Salesperson],
						[User],
						[Futures Broker],
						[Forwarding Agent],
						[Terminal],
						[Shipping Line],
						[Trucker],
						[Insurer],
						[Ship Via]
					)
			) AS PivotTable
		) a
		join tblEMEntity b
			on a.intEntityId = b.intEntityId
		left join [tblEMEntityLocation] e  
			on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
		left join [tblEMEntityToContact] f  
			on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
		left join tblEMEntity g  
			on f.intEntityContactId = g.intEntityId
		CROSS APPLY (
			SELECT  TOP 1 intEntityId, strType
				FROM    [tblEMEntityType]
				WHERE   intEntityId = a.intEntityId
		) ET
