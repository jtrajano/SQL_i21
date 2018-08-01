CREATE VIEW [dbo].[vyuMBILOrder]
	AS
	
SELECT [Order].intOrderId
	, [Order].strOrderNumber
	, [Order].strOrderStatus
	, [Order].dtmRequestedDate
	, [Order].intEntityId
	, strCustomerNumber = Customer.strEntityNo
	, strCustomerName = Customer.strName
	, [Order].intSiteId
	, Site.intSiteNumber
	, strSiteDescription = Site.strDescription
	, Site.strSiteAddress
	, Site.strCity
	, Site.strState
	, Site.strZipCode
	, [Order].intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, [Order].dblQuantity
	, [Order].dblPrice
	, [Order].intContractDetailId
	, ContractHeader.strContractNumber
	, ContractDetail.intContractSeq
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
LEFT JOIN tblTMSite Site ON Site.intSiteID = [Order].intSiteId
LEFT JOIN tblICItem Item ON Item.intItemId = [Order].intItemId
LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = [Order].intContractDetailId
LEFT JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId
LEFT JOIN tblSMTerm Term ON Term.intTermID = [Order].intTermId
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = [Order].intDriverId
LEFT JOIN tblTMRoute Route ON Route.intRouteId = [Order].intRouteId