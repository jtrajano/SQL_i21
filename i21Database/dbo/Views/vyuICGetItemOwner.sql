CREATE VIEW [dbo].[vyuICGetItemOwner]
	AS

SELECT	o.intItemOwnerId
		,o.intItemId		
		,o.intOwnerId
		,e.strName
		,c.strCustomerNumber
		,i.strItemNo
FROM	tblICItem i 
		INNER JOIN tblICItemOwner o
			ON i.intItemId = o.intItemId
		INNER JOIN tblARCustomer c
			ON c.[intEntityId] = o.intOwnerId		
		INNER JOIN tblEMEntity e
			ON e.intEntityId = c.[intEntityId]