﻿CREATE VIEW [dbo].[vyuSCAgWorkOrder]
AS 
	SELECT 
		A.strOrderNumber
		,strLocation = C.strLocationName
		,strCustomerNumber = B.strEntityNo	
		,strCustomerName = B.strName
		,A.intWorkOrderId
		,intEntityId = A.intEntityCustomerId
	FROM tblAGWorkOrder A
	LEFT JOIN tblEMEntity B
		ON A.intEntityCustomerId = B.intEntityId
	LEFT JOIN tblEMEntityLocation C
		ON A.intEntityLocationId = C.intEntityLocationId
	
	
GO