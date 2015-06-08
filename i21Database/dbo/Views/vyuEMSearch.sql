﻿CREATE VIEW [dbo].[vyuEMSearch]
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
		FuturesBroker
	FROM 		
			(SELECT	intEntityId, Name,		
								CASE WHEN [Customer] IS NOT NULL THEN 1 ELSE 0 END Customer, 		
								CASE WHEN [Vendor] IS NOT NULL THEN 1 ELSE 0 END Vendor, 		
								CASE WHEN [Employee] IS NOT NULL THEN 1 ELSE 0 END Employee, 		
								CASE WHEN [Salesperson] IS NOT NULL THEN 1 ELSE 0 END Salesperson, 		
								CASE WHEN [User] IS NOT NULL THEN 1 ELSE 0 END AS  [User],
								CASE WHEN [Futures Broker] IS NOT NULL THEN 1 ELSE 0 END AS  FuturesBroker
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
						[Futures Broker]
					)
			) AS PivotTable
		) a
		left join tblEntityLocation e  
			on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
		left join tblEntityToContact f  
			on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
		left join tblEntity g  
			on f.intEntityContactId = g.intEntityId  