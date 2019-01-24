CREATE VIEW vyuARTransactionSummary
AS
SELECT DISTINCT intYear 			= YEAR(I.dtmDate)
	  , intMonth 					= MONTH(I.dtmDate) 
	  , dtmTransactionDate 			= I.dtmDate
	  , dtmTransactionDateEnding 	= I.dtmDate
	  , intEntityCustomerId 		= I.intEntityCustomerId
	  , intCompanyLocationId		= I.intCompanyLocationId
	  , strName 					= E.strName
	  , strCustomerName 			= E.strName
	  , strCustomerNumber 			= C.strCustomerNumber
	  , intSourceId					= I.intSourceId
	  , strInvoiceOriginId			= I.strInvoiceOriginId
	  , intItemId 					= ID.intItemId
	  , strItemNo 					= ICI.strItemNo
	  , strDescription 				= ICI.strDescription
	  , intCategoryId 				= ICI.intCategoryId
	  , strCategoryCode 			= ICC.strCategoryCode
	  , strCategoryDescription 		= ICC.strDescription
	  , strSalesPersonEntityNo 		= SPerson.strEntityNo
	  , strSalesPersonName 			= SPerson.strName
	  , intSalesPersonId 			= I.intEntitySalespersonId
	  , dblSalesAmount 				= ID.dblPrice * (CASE WHEN dblQty < 0 THEN  dblQty * -1 ELSE dblQty END) 
	  , dblQuantity 				= (CASE WHEN dblQty < 0 THEN  dblQty * -1 ELSE dblQty END)
	  , dblBeginSalesAmount 		= 0
	  , dblBeginQuantity 			= 0
	  , dblEndSalesAmount 			= 0
	  , dblEndQuantity 				= 0
	  , dtmBeginDate				= '' COLLATE Latin1_General_CI_AS
	  , dtmEndingDate 				= '' COLLATE Latin1_General_CI_AS
	  , dblCost 					= dblCost * (CASE WHEN dblQty < 0 THEN  dblQty * -1 ELSE dblQty END) 
FROM tblARInvoice I
	INNER JOIN (tblARCustomer C INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId) 
		ON I.intEntityCustomerId = C.intEntityId
	INNER JOIN tblARInvoiceDetail ID
		ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN tblICItem ICI
		ON ICI.intItemId = ID.intItemId
	INNER JOIN tblICInventoryTransaction Cost
		ON Cost.intTransactionDetailId = ID.intInvoiceDetailId AND Cost.strTransactionId = I.strInvoiceNumber 
	LEFT JOIN tblICCategory ICC
		ON ICC.intCategoryId = ICI.intCategoryId
	LEFT JOIN tblEMEntity SPerson
		ON SPerson.intEntityId = I.intEntitySalespersonId
	LEFT JOIN tblICItemPricing IIP
		ON IIP.intItemId = ID.intItemId AND IIP.intItemLocationId = I.intCompanyLocationId
WHERE I.ysnPosted = 1 
  AND ID.intItemId IS NOT NULL 
  AND ICI.strType != 'Comment'
  AND Cost.intTransactionTypeId = 33 
  AND Cost.ysnIsUnposted = 0