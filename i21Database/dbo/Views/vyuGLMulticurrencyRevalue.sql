CREATE VIEW [dbo].[vyuGLMulticurrencyRevalue]
AS
WITH CTE AS(
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, 
	dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,
	dblForexRate dblHistoricForexRate ,dblHistoricAmount, dblAmountDifference = 0, strModule = 'AP'  COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
FROM vyuAPMultiCurrencyRevalue -- 'AP'
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS ,strTransactionId  COLLATE Latin1_General_CI_AS ,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,
	strVendorName  COLLATE Latin1_General_CI_AS ,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS ,
	strLocation  COLLATE Latin1_General_CI_AS ,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS ,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0, strModule = 'CT', 
	strType = CASE WHEN strTransactionType = 'Purchase' THEN 'Payables' ELSE CASE WHEN  strTransactionType = 'Sales' THEN 'Receivables' END END  COLLATE Latin1_General_CI_AS
FROM vyuCTMultiCurrencyRevalue
 UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,
	dblHistoricAmount, dblAmountDifference = 0, strModule = 'AR'  COLLATE Latin1_General_CI_AS , strType= 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuARMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity, 
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,
	dblHistoricAmount, dblAmountDifference = 0, strModule = 'INV'  COLLATE Latin1_General_CI_AS , strType = 'Payables'  COLLATE Latin1_General_CI_AS 
FROM vyuICMultiCurrencyRevalueReceipt
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
FROM vyuICMultiCurrencyRevalueReceiptOtherCharges
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Receivables' COLLATE Latin1_General_CI_AS
 FROM vyuICMultiCurrencyRevalueShipment
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
FROM vyuICMultiCurrencyRevalueShipmentOtherCharges WHERE ysnPayable = 1
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuICMultiCurrencyRevalueShipmentOtherCharges WHERE ysnReceivable = 1
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'CM'  COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuCMMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'FA'  COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuFAMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Forwards' COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
FROM vyuCMForwardPayablesMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Forwards' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuCMForwardReceivablesMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM In-Transit' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuCMInTransitMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Swaps' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuCMSwapOutReceivablesMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Swaps' COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
FROM vyuCMSwapInPayablesMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Swaps' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuCMSwapInReceivablesMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Swaps' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
FROM vyuCMSwapInReceivablesInTransitMultiCurrencyRevalue
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS ,strTransactionId  COLLATE Latin1_General_CI_AS ,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,
	strVendorName  COLLATE Latin1_General_CI_AS ,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS ,
	strLocation  COLLATE Latin1_General_CI_AS ,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS ,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0, strModule = 'GL'  COLLATE Latin1_General_CI_AS, 
	strType = 'General Ledger'  COLLATE Latin1_General_CI_AS
FROM vyuGLMulticurrencyRevalueGJ
)
SELECT A.*, strCurrency FROM CTE A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID