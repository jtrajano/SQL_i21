CREATE VIEW [dbo].[vyuSCAgWorkOrder]
AS 
	SELECT 
		A.strOrderNumber
		,strLocation = C.strLocationName
		,strCustomerNumber = B.strEntityNo	
		,strCustomerName = B.strName
		,A.intWorkOrderId
		,intEntityId = A.intEntityCustomerId
		,A.ysnShipped
		,A.ysnFinalized
	FROM tblAGWorkOrder A
	LEFT JOIN tblEMEntity B
		ON A.intEntityCustomerId = B.intEntityId
	LEFT JOIN tblSMCompanyLocation C
		ON A.intCompanyLocationId = C.intCompanyLocationId
	
	
GO