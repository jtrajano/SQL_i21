CREATE VIEW [dbo].[vyuGRGetUnPriced]
AS
SELECT 
	 intUnPricedId		  = UnPriced.intUnPricedId
	,strTicketType		  = UnPriced.strTicketType
	,intItemId			  = UnPriced.intItemId
	,strItemNo			  = Item.strItemNo
	,intCompanyLocationId = UnPriced.intCompanyLocationId
	,strLocationName	  = L.strLocationName
	,strPriceTicket		  = UnPriced.strPriceTicket
	,dblFuturesPrice	  = dblFuturesPrice
	,dblFuturesBasis	  = dblFuturesBasis
	,dblCashPrice		  = dblCashPrice
	,intCreatedUserId     = UnPriced.intCreatedUserId
	,strUserName          = Entity.strUserName
	,dtmCreated           = UnPriced.dtmCreated
	,ysnPosted            = UnPriced.ysnPosted
FROM tblGRUnPriced UnPriced
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = UnPriced.intCompanyLocationId
JOIN tblICItem Item ON Item.intItemId = UnPriced.intItemId
JOIN tblSMUserSecurity Entity ON Entity.intEntityId = UnPriced.intCreatedUserId
