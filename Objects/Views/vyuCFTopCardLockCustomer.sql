
CREATE VIEW [dbo].[vyuCFTopCardLockCustomer]
AS


SELECT 
 cfTran.intCustomerId as intEntityCustomerId
,strCustomerNumber
,emEnt.strName
,dblQuantity as dblQtyShipped
,dblQuantity as dblQtyOrdered
,dblCalculatedTotalPrice as dblInvoiceTotal
,dtmTransactionDate as dtmDate
,emCont.strName AS strContactName
,emCont.strPhone AS strPhoneNumber
FROM tblCFAccount as cfAccnt
INNER JOIN tblARCustomer as arCust
ON cfAccnt.intCustomerId = arCust.intEntityId
INNER JOIN tblEMEntity as emEnt
ON arCust.intEntityId = emEnt.intEntityId
INNER JOIN tblCFTransaction as cfTran
ON cfTran.intCustomerId = cfAccnt.intCustomerId
INNER JOIN vyuEMEntityContact as emCont
ON emEnt.intEntityId = emCont.intEntityId 
AND emCont.ysnDefaultContact = 1
WHERE ISNULL(cfTran.ysnPosted,0) = 1
GO
