CREATE VIEW [dbo].[vyuCTContractAmendmentViewZug]  
  
AS
SELECT 
	dtmDate = dtmHistoryCreated,
	[strContractNumber], 
	[intContractSeq] ,
	[strEntityName], 
	[strContractType],
	[strOldValue],
	[strNewValue],
	[strCommodityCode],
	[ysnPrinted],
	[ysnSigned],
	[dtmSigned] AS [dtmSignedDate],
	[strLocationName],
	[strAmendmentNumber]
FROM [dbo].[vyuCTAmendmentHistory] 