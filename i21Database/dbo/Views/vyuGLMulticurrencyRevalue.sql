﻿CREATE VIEW [dbo].[vyuGLMulticurrencyRevalue]
AS
--SELECT 
--strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount,intCurrencyId, intForexRateType, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate ,dblHistoricAmount, strModule = 'AP', strType = 'Payables'
--FROM vyuAPVoucherForPayment -- 'AP'
--UNION ALL
--SELECT 
--strTransactionType COLLATE Latin1_General_CI_AS ,strTransactionId  COLLATE Latin1_General_CI_AS ,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS ,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS ,strLocation  COLLATE Latin1_General_CI_AS ,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS ,dblQuantity,dblUnitPrice, dblAmount,intCurrencyId, intForexRateType, strForexRateType  ='',dblForexRate dblHistoricForexRate,dblHistoricAmount,strModule = 'CT', strType = CASE WHEN strTransactionType = 'Purchase' THEN 'Payables' ELSE CASE WHEN  strTransactionType = 'Sales' THEN 'Receivables' END END
--FROM vyuCTMultiCurrencyRevalue
--UNION ALL
SELECT 
strTransactionType COLLATE Latin1_General_CI_AS,strTransactionId  COLLATE Latin1_General_CI_AS,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS,strCommodity  COLLATE Latin1_General_CI_AS,strLineOfBusiness  COLLATE Latin1_General_CI_AS,strLocation  COLLATE Latin1_General_CI_AS,strTicket  COLLATE Latin1_General_CI_AS,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS,dblQuantity,dblUnitPrice, dblAmount,intCurrencyId, intForexRateType, strForexRateType  COLLATE Latin1_General_CI_AS,dblForexRate dblHistoricForexRate,dblHistoricAmount,strModule = 'AR' , strType= 'Receivables'
FROM vyuARMultiCurrencyRevalue
UNION ALL
SELECT 
strTransactionType COLLATE Latin1_General_CI_AS,strTransactionId  COLLATE Latin1_General_CI_AS,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS,strCommodity  COLLATE Latin1_General_CI_AS,strLineOfBusiness  COLLATE Latin1_General_CI_AS,strLocation  COLLATE Latin1_General_CI_AS,strTicket  COLLATE Latin1_General_CI_AS,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS,dblQuantity,dblUnitPrice, dblAmount,intCurrencyId, intForexRateType, strForexRateType  COLLATE Latin1_General_CI_AS,dblForexRate dblHistoricForexRate,dblHistoricAmount,strModule = 'IC', strType = 'Payables'
FROM vyuICMultiCurrencyRevalueReceipt
UNION ALL
SELECT 
strTransactionType COLLATE Latin1_General_CI_AS,strTransactionId  COLLATE Latin1_General_CI_AS,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS,strCommodity  COLLATE Latin1_General_CI_AS,strLineOfBusiness  COLLATE Latin1_General_CI_AS,strLocation  COLLATE Latin1_General_CI_AS,strTicket  COLLATE Latin1_General_CI_AS,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS,dblQuantity,dblUnitPrice, dblAmount,intCurrencyId, intForexRateType, strForexRateType  COLLATE Latin1_General_CI_AS,dblForexRate dblHistoricForexRate,dblHistoricAmount,strModule = 'IC', strType = 'Payables'
FROM vyuICMultiCurrencyRevalueReceiptOtherCharges
UNION ALL
SELECT 
strTransactionType COLLATE Latin1_General_CI_AS,strTransactionId  COLLATE Latin1_General_CI_AS,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS,strCommodity  COLLATE Latin1_General_CI_AS,strLineOfBusiness  COLLATE Latin1_General_CI_AS,strLocation  COLLATE Latin1_General_CI_AS,strTicket  COLLATE Latin1_General_CI_AS,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS,dblQuantity,dblUnitPrice, dblAmount,intCurrencyId, intForexRateType, strForexRateType  COLLATE Latin1_General_CI_AS,dblForexRate dblHistoricForexRate,dblHistoricAmount,strModule = 'IC', strType = 'Receivables'
 FROM vyuICMultiCurrencyRevalueShipment
UNION ALL
SELECT 
strTransactionType COLLATE Latin1_General_CI_AS,strTransactionId  COLLATE Latin1_General_CI_AS,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS,strCommodity  COLLATE Latin1_General_CI_AS,strLineOfBusiness  COLLATE Latin1_General_CI_AS,strLocation  COLLATE Latin1_General_CI_AS,strTicket  COLLATE Latin1_General_CI_AS,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS,dblQuantity,dblUnitPrice, dblAmount,intCurrencyId, intForexRateType, strForexRateType  COLLATE Latin1_General_CI_AS,dblForexRate dblHistoricForexRate,dblHistoricAmount,strModule = 'IC', strType = 'Payables'
FROM vyuICMultiCurrencyRevalueShipmentOtherCharges