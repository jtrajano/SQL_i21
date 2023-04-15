CREATE VIEW [dbo].[vyuCTContractAmendmentViewZug]  
  
AS
SELECT 
	dtmDate = dtmHistoryCreated,
	[strContractNumber], 
	[intContractSeq] ,
	[strEntityName], 
	[strContractType],	
	[strItemChanged],
	[strOldValue],
	[strNewValue],
	[strCommodityCode],
	[ysnPrinted],
	[ysnSigned],
	[dtmSigned] AS [dtmSignedDate],
	[strLocationName],
	[strAmendmentNumber],
	[strTrader] =  strSalesPerson
FROM [dbo].[vyuCTAmendmentHistory] 