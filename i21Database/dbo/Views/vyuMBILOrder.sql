CREATE VIEW [dbo].[vyuMBILOrder]
	AS
	
SELECT [Order].intOrderId
	, [Order].intDispatchId
	, [Order].strOrderNumber
	, [Order].strOrderStatus
	, [Order].dtmRequestedDate
	, [Order].intEntityId
	, strCustomerNumber = Customer.strEntityNo
	, strCustomerName = Customer.strName
	, [Order].intTermId
	, Term.strTerm
	, [Order].strComments
	, [Order].intDriverId
	, Driver.strDriverNo
	, Driver.strDriverName
	, [Order].intRouteId
	, Route.strRouteId
	, [Order].intStopNumber
	, [Order].intConcurrencyId
FROM tblMBILOrder [Order]
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = [Order].intEntityId
LEFT JOIN tblSMTerm Term ON Term.intTermID = [Order].intTermId
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = [Order].intDriverId
LEFT JOIN tblTMRoute Route ON Route.intRouteId = [Order].intRouteId