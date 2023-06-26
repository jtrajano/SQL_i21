CREATE VIEW [dbo].[vyuMBILInvoice]    
 AS    
     
SELECT Invoice.intInvoiceId    
 , Invoice.strInvoiceNo    
 , Invoice.intOrderId    
 , (SELECT TOP 1 strOrderNumber FROM tblMBILOrder WHERE intOrderId = Invoice.intOrderId) AS strOrderNumber    
 , Invoice.intEntityCustomerId    
 , strCustomerNo = Customer.strEntityNo    
 , strCustomerName = Customer.strName    
 , Invoice.intLocationId    
 , Location.strLocationName    
 , Invoice.strType    
 , Invoice.dtmDeliveryDate    
 , Invoice.dtmInvoiceDate    
 , Invoice.intDriverId    
 , Driver.strDriverNo    
 , Driver.strDriverName    
 , Invoice.intShiftId    
 , InvoiceShift.intShiftNumber    
 , CASE WHEN InvoiceShift.intShiftNumber IS NULL THEN CONVERT(NVARCHAR(50),InvoiceShift.strShiftNo)  ELSE CONVERT(NVARCHAR(50),InvoiceShift.intShiftNumber) END as strShiftNo    
 , Invoice.strComments    
 , Invoice.strVoidComments    
 , ISNULL(dblTotal,0) as dblTotal    
 , Invoice.intTermId    
 , Term.strTerm    
 , ysnPosted = cast(case when i21Invoice.intInvoiceId is null then 0 else 1 end as bit)  
 , Invoice.ysnVoided    
 , Invoice.dtmPostedDate    
 , Invoice.dtmVoidedDate    
 , Invoice.intPaymentMethodId    
 , PaymentMethod.strPaymentMethod    
 , Invoice.strPaymentInfo    
 --, Invoice.inti21InvoiceId    
 , inti21InvoiceId = i21Invoice.intInvoiceId    
 , stri21InvoiceNo = i21Invoice.strInvoiceNumber    
 , Invoice.intLoadHeaderId
 , Invoice.intConcurrencyId    
 , strStatus = dbo.fnMBILGetInvoiceStatus(Invoice.intEntityCustomerId, NULL) COLLATE Latin1_General_CI_AS    
 , isnull(tax.dblTaxTotal,0) dblTotalTaxAmount      
 , isnull(tax.dblItemTotal,0) dblTotalBefTax    
 , strAccountStatus = REPLACE(REPLACE(CustomerAS.strCustomerAccountStatus,'<strCustomerAccountStatus>',''),'</strCustomerAccountStatus>','')  
 , ysnTransport = cast(case when isnull(transportDelivery.intOrderId,0) = 0 then 0 else 1 end as bit)
 , Invoice.strDiversionNumber
 , Invoice.intStateId
 , trstate.strStateName
 , ISNULL(items.dblGallonsDelivered, 0) as dblGallonsDelivered
FROM tblMBILInvoice Invoice    
LEFT JOIN (
  SELECT intInvoiceId, SUM(dblQuantity) as dblGallonsDelivered
  FROM tblMBILInvoiceItem
  GROUP BY intInvoiceId
) as items ON items.intInvoiceId = Invoice.intInvoiceId
--LEFT JOIN tblMBILInvoiceItem InvoiceItem ON InvoiceItem.intInvoiceId = Invoice.intInvoiceId    
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = Invoice.intEntityCustomerId    
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Invoice.intLocationId    
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Invoice.intDriverId    
LEFT JOIN tblMBILShift InvoiceShift ON InvoiceShift.intShiftId = Invoice.intShiftId    
LEFT JOIN tblMBILOrder InvoiceOrder ON InvoiceOrder.intOrderId = Invoice.intOrderId    
LEFT JOIN tblSMTerm Term ON Term.intTermID = Invoice.intTermId    
LEFT JOIN tblSMPaymentMethod PaymentMethod ON PaymentMethod.intPaymentMethodID = Invoice.intPaymentMethodId    
LEFT JOIN tblARInvoice i21Invoice ON i21Invoice.intInvoiceId = Invoice.inti21InvoiceId 
LEFT JOIN tblTRState trstate on trstate.intStateId = Invoice.intStateId
LEFT JOIN (    
 select    
 intEntityCustomerId,    
 intInvoiceId,    
 (    
 select SUBSTRING(strCustomerAccountStatus,0,LEN(strCustomerAccountStatus)+1) from (    
  select    
  (select strAccountStatusCode + ' - ' + strDescription + ', '    
   from tblARAccountStatus     
   where intAccountStatusId = tblARCustomerAccountStatus.intAccountStatusId FOR XML PATH('')) as strCustomerAccountStatus    
  from tblARCustomerAccountStatus     
  where tblARCustomerAccountStatus.intEntityCustomerId = tblMBILInvoice.intEntityCustomerId    
  group by intAccountStatusId    
  ) CAStatus    
 FOR XML PATH('')) as strCustomerAccountStatus    
 from    
 tblMBILInvoice    
) CustomerAS ON CustomerAS.intInvoiceId = Invoice.intInvoiceId    
LEFT JOIN (        
  SELECT item.intInvoiceId,SUM(isnull(dblItemTotal,0))dblItemTotal,SUM(isnull(dblTaxTotal,0))dblTaxTotal    
  FROM tblMBILInvoiceItem item          
  GROUP BY item.intInvoiceId) tax ON Invoice.intInvoiceId = tax.intInvoiceId  
LEFT JOIN (  
  SELECT TMOrder.intOrderId from tblMBILOrder TMOrder    
  INNER JOIN tblMBILDeliveryDetail MBILDT ON TMOrder.intDispatchId = MBILDT.intTMDispatchId    
  INNER JOIN tblMBILDeliveryHeader MBILDH ON MBILDH.intDeliveryHeaderId = MBILDT.intDeliveryHeaderId  
  INNER JOIN tblTRLoadHeader TRL ON TRL.intMobileLoadHeaderId = MBILDH.intLoadHeaderId   
  INNER JOIN tblTRLoadDistributionHeader TRDH on TRDH.intLoadHeaderId = TRL.intLoadHeaderId and TRDH.intShipToLocationId = MBILDH.intEntityLocationId and MBILDH.intCompanyLocationId = TRDH.intCompanyLocationId
  INNER JOIN tblTRLoadDistributionDetail TRDT on TRDH.intLoadDistributionHeaderId = TRDT.intLoadDistributionHeaderId and MBILDT.intTMSiteId = TRDT.intSiteId and MBILDT.intItemId = TRDT.intItemId
) transportDelivery on Invoice.intOrderId = transportDelivery.intOrderId
WHERE Invoice.intLoadHeaderId IS NULL