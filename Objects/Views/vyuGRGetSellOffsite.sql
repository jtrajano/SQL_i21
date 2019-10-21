CREATE VIEW [dbo].[vyuGRGetSellOffsite]
AS     
 SELECT 
 intSellOffsiteId					= SO.intSellOffsiteId
,intItemId							= SO.intItemId
,strItemNo							= Item.strItemNo
,intCompanyLocationId				= SO.intCompanyLocationId
,strLocationName					= L.strLocationName
,intCompanyLocationSubLocationId	= SO.intCompanyLocationSubLocationId
,strSubLocationName					= SLOC.strSubLocationName
,intEntityId						= SO.intEntityId
,strEntityName						= E.strName
,dblSpotUnits						= SO.dblSpotUnits
,dblFuturesPrice					= SO.dblFuturesPrice
,dblFuturesBasis					= SO.dblFuturesBasis
,dblCashPrice						= SO.dblCashPrice
,strOffsiteTicket					= SO.strOffsiteTicket
,dblSelectedUnits					= SO.dblSelectedUnits
,dblContractUnits					= SO.dblContractUnits
,intCreatedUserId					= SO.intCreatedUserId
,strUserName						= Entity.strUserName
,dtmCreated							= SO.dtmCreated
,ysnPosted							= SO.ysnPosted
,intInvoiceId						= SO.intInvoiceId
,strInvoiceNumber					= Invoice.strInvoiceNumber
FROM tblGRSellOffsite SO
JOIN tblICItem Item ON Item.intItemId = SO.intItemId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId= SO.intCompanyLocationId
JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=SO.intCompanyLocationSubLocationId  
JOIN tblEMEntity E ON E.intEntityId = SO.intEntityId
JOIN tblSMUserSecurity Entity ON Entity.intEntityId=SO.intCreatedUserId
JOIN tblARInvoice Invoice ON Invoice.intInvoiceId=SO.intInvoiceId

