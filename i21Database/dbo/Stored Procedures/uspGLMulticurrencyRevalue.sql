CREATE PROCEDURE [dbo].[uspGLMulticurrencyRevalue]
@strModule NVARCHAR(5),
@dtmDate DATETIME 
AS

DECLARE @intDefaultCurrencyId INT 
SELECT @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

IF @strModule = 'AP'
BEGIN
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, 
	dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,
	dblForexRate dblHistoricForexRate ,dblHistoricAmount, dblAmountDifference = 0, strModule = 'AP'  COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuAPMultiCurrencyRevalue A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND ISNULL(dblForexRate, 1) <> 1
END

IF @strModule = 'CT'
BEGIN
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS ,strTransactionId  COLLATE Latin1_General_CI_AS ,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,
	strVendorName  COLLATE Latin1_General_CI_AS ,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS ,
	strLocation  COLLATE Latin1_General_CI_AS ,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS ,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0, strModule = 'CT', 
	strType = CASE WHEN strTransactionType = 'Purchase' THEN 'Payables' ELSE CASE WHEN  strTransactionType = 'Sales' THEN 'Receivables' END END  COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuCTMultiCurrencyRevalue A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND ISNULL(dblForexRate, 1) <> 1
 END
IF @strModule = 'AR' 
BEGIN
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,
	dblHistoricAmount, dblAmountDifference = 0, strModule = 'AR'  COLLATE Latin1_General_CI_AS , strType= 'Receivables'  COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
	,intOverrideLocationAccountId
	,intOverrideLOBAccountId
FROM vyuARMultiCurrencyRevalue A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND ISNULL(dblForexRate, 1) <> 1
END

IF @strModule = 'INV'
BEGIN
WITH cte AS(
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity, 
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,
	dblHistoricAmount, dblAmountDifference = 0, strModule = 'INV'  COLLATE Latin1_General_CI_AS , strType = 'Payables'  COLLATE Latin1_General_CI_AS 
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuICMultiCurrencyRevalueReceipt
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuICMultiCurrencyRevalueReceiptOtherCharges
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Receivables' COLLATE Latin1_General_CI_AS
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
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
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
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
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuICMultiCurrencyRevalueShipmentOtherCharges WHERE ysnReceivable = 1
)
SELECT A.*, strCurrency FROM cte A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE dtmDate <= @dtmDate
AND ISNULL(dblHistoricForexRate, 1) <> 1
END

IF @strModule = 'CM'
BEGIN

SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'CM'  COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuCMMultiCurrencyRevalue A
LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND ISNULL(dblForexRate, 1) <> 1
END

IF @strModule = 'FA'
BEGIN
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'FA'  COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuFAMultiCurrencyRevalue A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND ISNULL(dblForexRate, 1) <> 1
END

IF @strModule = 'CM Forwards'
BEGIN
WITH cte AS (
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Forwards' COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
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
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuCMForwardReceivablesMultiCurrencyRevalue
)
SELECT *, strCurrency FROM cte 
A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE dtmDate <= @dtmDate AND dtmDueDate > @dtmDate
AND ISNULL(dblHistoricForexRate, 1) <> 1
END

IF @strModule = 'CM In-Transit'
BEGIN
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM In-Transit' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuCMInTransitMultiCurrencyRevalue  A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND ISNULL(dblForexRate, 1) <> 1
END

IF @strModule = 'CM Swaps'
BEGIN
WITH cte AS(
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM Swaps' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
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
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
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
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
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
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuCMSwapInReceivablesInTransitMultiCurrencyRevalue
)
SELECT A.*, strCurrency FROM cte A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE dtmDate <= @dtmDate
AND ISNULL(dblHistoricForexRate, 1) <> 1
END

IF @strModule = 'GL'
BEGIN
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType ,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,
	strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0, strModule = 'GL'  COLLATE Latin1_General_CI_AS, 
	strType = 'Receivables'  COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
	,intOverrideLocationAccountId = NULL
	,intOverrideLOBAccountId = NULL
FROM vyuGLMulticurrencyRevalueGJ A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND ISNULL(dblForexRate, 1) <> 1
END