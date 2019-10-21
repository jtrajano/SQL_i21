CREATE VIEW [dbo].[vyuEMEntityCredentialContact]
	AS 

SELECT
	EntityCredential.intEntityId,
	vEntityContact.intEntityContactId,
	vEntityContact.strEntityName,
	vEntityContact.strName,
	vEntityContact.strEmail,
	vEntityContact.strLocationName,
	vEntityContact.strPhone,
	vEntityContact.strMobile,
	vEntityContact.strMobileLookUp,
	vEntityContact.strTimezone,
	vEntityContact.strTitle,
	vEntityContact.ysnPortalAccess,
	vEntityContact.ysnActive,
	vEntityContact.ysnDefaultContact,
	vEntityContact.Customer,
	vEntityContact.Vendor,
	vEntityContact.Employee,
	vEntityContact.Salesperson,
	CASE WHEN ISNULL(UserSecurity.[intEntityId], 0) = 0 THEN 0 ELSE vEntityContact.[User] END [User],
	vEntityContact.FuturesBroker,
	vEntityContact.ForwardingAgent,
	vEntityContact.Terminal,
	vEntityContact.ShippingLine,
	vEntityContact.Trucker,
	vEntityContact.strContactType,
	vEntityContact.strEmailDistributionOption,
	vEntityContact.imgPhoto,
	vEntityContact.papit,
	ysnReqTwoFactorAuth = Cast(isnull(SecurityPolicy.ysnReqTwoFactorAuth, 0) as bit),
	UserSecurity.ysnDisabled
FROM tblEMEntityCredential AS EntityCredential 
	INNER JOIN vyuEMEntityContact AS vEntityContact
		ON EntityCredential.intEntityId = (
			CASE WHEN vEntityContact.ysnPortalAccess = 1
				THEN vEntityContact.intEntityContactId
				ELSE vEntityContact.intEntityId
			END
		)
	LEFT JOIN tblSMUserSecurity UserSecurity 
		ON EntityCredential.intEntityId = UserSecurity.[intEntityId]
	LEFT JOIN tblSMSecurityPolicy SecurityPolicy
		ON UserSecurity.intSecurityPolicyId = SecurityPolicy.intSecurityPolicyId 


