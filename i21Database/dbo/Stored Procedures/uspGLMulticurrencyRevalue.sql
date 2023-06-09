CREATE PROCEDURE [dbo].[uspGLMulticurrencyRevalue]
@strModule NVARCHAR(20),
@dtmDate DATETIME 
AS

DECLARE @intDefaultCurrencyId INT 
SELECT @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference


DECLARE  @tblMulti TABLE(
	[strTransactionType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[dtmDueDate] [datetime] NULL,
	[strVendorName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strCommodity] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLineOfBusiness] [nvarchar](500 )COLLATE Latin1_General_CI_AS NULL,
	[strLocation] [nvarchar](200) NULL,
	[strTicket] [nvarchar](max) NULL,
	[strContractId] [nvarchar](100) NULL,
	[strItemId] [nvarchar](100) NULL,
	[dblQuantity] [decimal](38, 15) NULL,
	[dblUnitPrice] [numeric](38, 20) NULL,
	[dblTransactionAmount] [decimal](38, 6) NULL,
	[intCurrencyId] [int] NULL,
	[intCurrencyExchangeRateTypeId] [int] NULL,
	[strForexRateType] [nvarchar](20) NULL,
	[dblHistoricForexRate] [decimal](38, 15) NULL,
	[dblHistoricAmount] [decimal](38, 6) NULL,
	[dblAmountDifference] [decimal](18, 6) NOT NULL,
	[strModule] [varchar](13) NOT NULL,
	[strType] [varchar](11) NULL,
	[intAccountId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[intLOBSegmentCodeId] [int] NULL,
	[intNewCurrencyExchangeRateTypeId] [int] NULL,
	[strNewForexRateType] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL
)


IF @strModule = 'AP'
BEGIN
INSERT INTO  @tblMulti
SELECT
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, 
	dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,
	dblForexRate dblHistoricForexRate ,dblHistoricAmount, dblAmountDifference = 0, strModule = 'AP'  COLLATE Latin1_General_CI_AS, 
	strType = CASE WHEN A.strTransactionType = 'Debit Memo' THEN
	 'Payables' ELSE 'Receivables' END   
	 COLLATE Latin1_General_CI_AS 
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
	,strCurrency COLLATE Latin1_General_CI_AS strCurrency
FROM vyuAPMultiCurrencyRevalue A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND intCurrencyId <> @intDefaultCurrencyId
END

IF @strModule = 'CT'
BEGIN
	INSERT INTO  @tblMulti
	SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS ,strTransactionId  COLLATE Latin1_General_CI_AS ,strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,
	strVendorName  COLLATE Latin1_General_CI_AS ,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS ,
	strLocation  COLLATE Latin1_General_CI_AS ,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS ,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0, strModule = 'CT', 
	strType = CASE WHEN strTransactionType = 'Purchase' THEN 'Payables' ELSE CASE WHEN  strTransactionType = 'Sale' THEN 'Receivables' END END  COLLATE Latin1_General_CI_AS
	,intAccountId = NULL
	,intCompanyLocationId
	,intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
	,strCurrency COLLATE Latin1_General_CI_AS strCurrency
FROM vyuCTMultiCurrencyRevalue A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND intCurrencyId <> @intDefaultCurrencyId
 END
IF @strModule = 'AR' 
BEGIN
	INSERT INTO  @tblMulti
	SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,
	dblHistoricAmount, dblAmountDifference = 0, strModule = 'AR'  COLLATE Latin1_General_CI_AS , strType= 'Receivables'  COLLATE Latin1_General_CI_AS,
	intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
	,strCurrency COLLATE Latin1_General_CI_AS strCurrency
FROM vyuARMultiCurrencyRevalue A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND intCurrencyId <> @intDefaultCurrencyId
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
	,intAccountId = NULL
	,intCompanyLocationId
	,intLOBSegmentCodeId = intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
FROM vyuICMultiCurrencyRevalueReceipt
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Payables'  COLLATE Latin1_General_CI_AS
	,intAccountId = NULL
	,intCompanyLocationId
	,intLOBSegmentCodeId = intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
FROM vyuICMultiCurrencyRevalueReceiptOtherCharges
UNION ALL
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,strTransactionDate dtmDate,
	strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,
	strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,
	strContractNumber  COLLATE Latin1_General_CI_AS strContractId,strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,
	intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, strForexRateType  COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'INV'  COLLATE Latin1_General_CI_AS, strType = 'Receivables' COLLATE Latin1_General_CI_AS
	,intAccountId = NULL
	,intCompanyLocationId
	,intLOBSegmentCodeId = intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
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
	,intAccountId = NULL
	,intCompanyLocationId
	,intLOBSegmentCodeId = intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
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
	,intAccountId = NULL
	,intCompanyLocationId
	,intLOBSegmentCodeId = intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
FROM vyuICMultiCurrencyRevalueShipmentOtherCharges WHERE ysnReceivable = 1
)
INSERT INTO  @tblMulti
SELECT A.*, strCurrency
FROM cte A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE dtmDate <= @dtmDate
AND intCurrencyId <> @intDefaultCurrencyId
END

IF @strModule = 'CM'
BEGIN
	INSERT INTO  @tblMulti
	SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'CM'  COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS,
	intAccountId = intAccountId,
	intCompanyLocationId,
	intLOBSegmentCodeId = NULL,
	intNewCurrencyExchangeRateTypeId = NULL,
	strNewForexRateType = '' COLLATE Latin1_General_CI_AS,
	strCurrency COLLATE Latin1_General_CI_AS strCurrency
FROM vyuCMMultiCurrencyRevalue A
LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE dtmDate = @dtmDate
AND @intDefaultCurrencyId <> intCurrencyId
END

IF @strModule = 'FA'
BEGIN
	INSERT INTO  @tblMulti
	SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,strVendorName  COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0,
	strModule = 'FA'  COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS,
	intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
	,strCurrency COLLATE Latin1_General_CI_AS strCurrency
FROM dbo.fnFAMultiCurrencyRevalue(@dtmDate) A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND intCurrencyId <> @intDefaultCurrencyId
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
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
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
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = intLOBSegmentCodeId
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
FROM vyuCMForwardReceivablesMultiCurrencyRevalue
)
INSERT INTO  @tblMulti
SELECT A.*, strCurrency
FROM cte 
A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE dtmDate <= @dtmDate AND dtmDueDate > @dtmDate
AND A.intCurrencyId <> @intDefaultCurrencyId
END

IF @strModule = 'CM In-Transit'
BEGIN
	INSERT INTO  @tblMulti
	SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType, strTransactionId COLLATE Latin1_General_CI_AS strTransactionId, 
	strTransactionDate dtmDate, strTransactionDueDate dtmDueDate, strVendorName COLLATE Latin1_General_CI_AS strVendorName,
	strCommodity COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation COLLATE Latin1_General_CI_AS strLocation, strTicket COLLATE Latin1_General_CI_AS strTicket,strContractNumber COLLATE Latin1_General_CI_AS strContractId,
	strItemId COLLATE Latin1_General_CI_AS strItemId, dblQuantity, dblUnitPrice, dblAmount dblTransactionAmount, intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType COLLATE Latin1_General_CI_AS strForexRateType, dblForexRate dblHistoricForexRate, dblHistoricAmount, dblAmountDifference,
	strModule = 'CM In-Transit' COLLATE Latin1_General_CI_AS, strType = 'Receivables'  COLLATE Latin1_General_CI_AS
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
	,strCurrency COLLATE Latin1_General_CI_AS strCurrency
FROM vyuCMInTransitMultiCurrencyRevalue  A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE strTransactionDate <= @dtmDate
AND A.intCurrencyId <> @intDefaultCurrencyId
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
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
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
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
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
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
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
	,intAccountId
	,intCompanyLocationId
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
FROM vyuCMSwapInReceivablesInTransitMultiCurrencyRevalue
)
INSERT INTO  @tblMulti
SELECT A.*, strCurrency
FROM cte A LEFT JOIN tblSMCurrency B on A.intCurrencyId = B.intCurrencyID
WHERE dtmDate <= @dtmDate
AND A.intCurrencyId <> @intDefaultCurrencyId
END

IF @strModule = 'GL'
BEGIN
INSERT INTO  @tblMulti
SELECT 
	strTransactionType COLLATE Latin1_General_CI_AS strTransactionType ,strTransactionId  COLLATE Latin1_General_CI_AS strTransactionId,
	strTransactionDate dtmDate,strTransactionDueDate dtmDueDate,
	strVendorName  COLLATE Latin1_General_CI_AS strVendorName,strCommodity  COLLATE Latin1_General_CI_AS strCommodity,strLineOfBusiness  COLLATE Latin1_General_CI_AS strLineOfBusiness,
	strLocation  COLLATE Latin1_General_CI_AS strLocation,strTicket  COLLATE Latin1_General_CI_AS strTicket,strContractNumber  COLLATE Latin1_General_CI_AS strContractId,
	strItemId  COLLATE Latin1_General_CI_AS strItemId,dblQuantity,dblUnitPrice, dblAmount dblTransactionAmount,intCurrencyId, intForexRateType intCurrencyExchangeRateTypeId, 
	strForexRateType,dblForexRate dblHistoricForexRate,dblHistoricAmount, dblAmountDifference = 0, strModule = 'GL'  COLLATE Latin1_General_CI_AS, 
	strType = 'Receivables'  COLLATE Latin1_General_CI_AS
	,intAccountId = intAccountId
	,intCompanyLocationId = NULL
	,intLOBSegmentCodeId = NULL
	,intNewCurrencyExchangeRateTypeId = NULL
	,strNewForexRateType = '' COLLATE Latin1_General_CI_AS
	,A.strCurrency COLLATE Latin1_General_CI_AS strCurrency
FROM vyuGLMulticurrencyRevalueGJ A
WHERE dtmDate <= @dtmDate
AND A.intCurrencyId <> @intDefaultCurrencyId
END

IF @strModule = 'GL' -- GL will average
WITH CTE AS(
	SELECT  
	strTransactionType = '',
	SUM(A.dblTransactionAmount)dblTransactionAmount,
	A.intCurrencyId,
	SUM(A.dblHistoricAmount)dblHistoricAmount, 
	SUM(A.dblAmountDifference)dblAmountDifference,
	strForexRateType = 'Avg',
	A.strType,
	A.strCurrency,
	intAccountIdOverride = A.intAccountId,
	strAccountId
	FROM @tblMulti A JOIN tblGLAccount B ON B.intAccountId = A.intAccountId
	GROUP BY
	intCurrencyId,
	strCurrency,
	strAccountId,
	A.intAccountId,
	A.strType
	HAVING SUM(dblTransactionAmount)<> 0
)
SELECT *,
dblHistoricForexRate = dblHistoricAmount/dblTransactionAmount
FROM CTE
ELSE
	SELECT 
	A.strTransactionType,
	A.strTransactionId , 
	C.strAccountId,
	A.dtmDate, 
	A.dtmDueDate,
	A.strVendorName  ,
	A.strCommodity,
	A.strLineOfBusiness ,
	A.strLocation ,
	A.strTicket, 
	A.strContractId,
	A.strItemId,
	A.dblQuantity,
	A.dblUnitPrice,  
	A.dblTransactionAmount,
	A.intCurrencyId,  
	A.intCurrencyExchangeRateTypeId, 
	A.strForexRateType, 
	A.dblHistoricForexRate,
	A.dblHistoricAmount, 
	A.dblAmountDifference , 
	A.strModule, 
	A.strType,
	B.strCurrency,
	intAccountIdOverride = A.intAccountId,
	intLOBSegmentOverrideId = intLOBSegmentCodeId,
	A.intNewCurrencyExchangeRateTypeId,
	A.strNewForexRateType,
	CL.* 
	FROM @tblMulti A 
	LEFT JOIN tblGLAccount C ON C.intAccountId = A.intAccountId
	LEFT JOIN tblSMCurrency B ON A.intCurrencyId = B.intCurrencyID
	OUTER APPLY(
		SELECT	
		intLocationSegmentCodeId = intProfitCenter  , 
		intCompanySegmentCodeId = intCompanySegment 
		FROM dbo.tblSMCompanyLocation 
		WHERE intCompanyLocationId = A.intCompanyLocationId
	)CL