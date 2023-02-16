CREATE VIEW [dbo].[vyuEMEntityContact]
AS
SELECT intEntityId						= B.intEntityId
	 , strEntityName					= B.strName
	 , intEntityContactId				= D.intEntityId
	 , strName							= D.strName
	 , strEmail							= D.strEmail
	 , strWebsite						= j.strValue
	 , strLocationName					= E.strLocationName
	 , strPhone							= phone.strPhone
	 , strMobile						= mob.strPhone
	 , strTimezone						= E.strTimezone
	 , strTitle							= D.strTitle
	 , ysnPortalAccess					= C.ysnPortalAccess
	 , ysnActive						= CASE WHEN (X.[User] = 1 AND C.ysnDefaultContact = 1) THEN CASE WHEN (userSec.ysnDisabled = 1) THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END ELSE D.ysnActive END
	 , ysnDefaultContact				= C.ysnDefaultContact
	 , strContactType					= D.strContactType
	 , strEmailDistributionOption		= D.strEmailDistributionOption
	 , strUserEmailDistributionOption	= Case when (X.[User] = 1) THEN B.strEmailDistributionOption ELSE '' END
	 , imgPhoto							= B.imgPhoto
	 , papit							= g.strPassword
	 , strPhoneCountry					= ISNULL(h.strCountryCode, i.strCountryCode)
	 , strFormatCountry					= ISNULL(h.strCountryFormat, i.strCountryFormat)
	 , strFormatArea					= ISNULL(h.strAreaCityFormat, i.strAreaCityFormat)
	 , strFormatLocal					= ISNULL(h.strLocalNumberFormat, i.strLocalNumberFormat)
	 , intAreaCityLength				= ISNULL(h.intAreaCityLength, i.intAreaCityLength)
	 , intCountryId						= ISNULL(h.intCountryID, i.intCountryID)
	 , strMobileLookUp					= mob.strPhoneLookUp
	 , Vendor							= X.Vendor
	 , Customer							= X.Customer
	 , Salesperson						= X.Salesperson
	 , FuturesBroker					= X.FuturesBroker
	 , ForwardingAgent					= X.ForwardingAgent
	 , Terminal							= X.Terminal
	 , ShippingLine						= X.ShippingLine
	 , Trucker							= X.Trucker
	 , ShipVia							= X.ShipVia
	 , Insurer							= X.Insurer
	 , Employee							= X.Employee
	 , Producer							= X.Producer
	 , [User]							= X.[User]
	 , Prospect							= X.Prospect
	 , Competitor						= X.Competitor
	 , Buyer							= X.Buyer
	 , [Partner]						= X.[Partner]
	 , [Lead]							= X.[Lead]
	 , Veterinary						= X.Veterinary
	 , Lien								= X.Lien
	 , [Broker]							= X.[Broker]
FROM dbo.tblEMEntity AS B 
INNER JOIN dbo.tblEMEntityToContact AS C ON B.intEntityId = C.intEntityId
INNER JOIN dbo.tblEMEntity AS D ON C.intEntityContactId = D.intEntityId
join vyuEMEntityType X ON X.intEntityId = B.intEntityId
LEFT JOIN tblEMEntityPhoneNumber phone ON phone.intEntityId = D.intEntityId
LEFT JOIN tblEMEntityMobileNumber mob ON mob.intEntityId = D.intEntityId
LEFT OUTER JOIN dbo.tblEMEntityLocation E ON C.intEntityLocationId = E.intEntityLocationId
--JOIN vyuEMSearch F ON F.intEntityId = B.intEntityId
LEFT JOIN tblEMEntityCredential g on g.intEntityId = D.intEntityId
LEFT JOIN tblSMCountry h on h.strCountry = E.strCountry
CROSS APPLY (
	SELECT * 
	FROM tblSMCountry 
	WHERE intCountryID IN (SELECT TOP 1 intDefaultCountryId FROM tblSMCompanyPreference)
) i
OUTER APPLY (
	SELECT TOP 1 * 
	FROM tblEMContactDetail 
	WHERE intEntityId = C.intEntityContactId 
	  AND intContactDetailTypeId = 5
) j
LEFT OUTER JOIN tblSMUserSecurity userSec ON B.intEntityId = userSec.intEntityId