CREATE VIEW [dbo].[vyuEMSearchEntityCustomer]
AS
SELECT B.intEntityId
	 , B.strEntityNo
	 , B.strName
	 , PHONE.strPhone 
	 , E.strAddress
	 , E.strCity  
	 , E.strState
	 , E.strZipCode
	 , intWarehouseId = ISNULL(E.intWarehouseId, -99)
	 , B.strFederalTaxId
	 , CURRENCY.strCurrency
	 , C.ysnActive
FROM dbo.tblEMEntity B WITH (NOLOCK)
JOIN (
	SELECT intEntityId
		 , intCurrencyId
		 , ysnActive
    FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON C.intEntityId = B.intEntityId
JOIN (
	SELECT intEntityId
	FROM dbo.vyuEMEntityType WITH (NOLOCK)
	WHERE Customer = 1
) D ON D.intEntityId = B.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strAddress
		 , strCity
		 , strState
		 , strZipCode
		 , intWarehouseId
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
	WHERE ysnDefaultLocation = 1
) E ON B.intEntityId = E.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , intEntityContactId
	FROM dbo.tblEMEntityToContact WITH (NOLOCK)
	WHERE ysnDefaultContact = 1
) F ON F.intEntityId = B.intEntityId
LEFT JOIN (
	SELECT intEntityId
	FROM dbo.tblEMEntity WITH (NOLOCK) 
) G ON F.intEntityContactId = G.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , strPhone
	FROM dbo.tblEMEntityPhoneNumber WITH (NOLOCK)
) PHONE ON PHONE.intEntityId = G.intEntityId
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CURRENCY ON CURRENCY.intCurrencyID = C.intCurrencyId