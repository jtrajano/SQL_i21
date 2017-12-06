


CREATE VIEW [dbo].[vyuCFTopCardLockCustomer]
AS
SELECT 
 intEntityCustomerId
,strCustomerNumber
,emEnt.strName
,dblQtyShipped
,dblQtyOrdered
,dblInvoiceTotal
,dtmDate
FROM tblCFAccount as cfAccnt
INNER JOIN tblARCustomer as arCust
ON cfAccnt.intCustomerId = arCust.intEntityId
INNER JOIN tblEMEntity as emEnt
ON arCust.intEntityId = emEnt.intEntityId
INNER JOIN tblARInvoice as arInv
ON arCust.intEntityId = arInv.intEntityCustomerId 
INNER JOIN tblARInvoiceDetail as arInvDetail
ON arInv.intInvoiceId = arInvDetail.intInvoiceId
WHERE arInv.strInvoiceNumber like '%CFDT%'