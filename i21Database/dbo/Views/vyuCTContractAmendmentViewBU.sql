CREATE VIEW [dbo].[vyuCTContractAmendmentViewBU]  
  
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
	[strAmendmentNumber]
FROM [dbo].[vyuCTAmendmentHistory] 