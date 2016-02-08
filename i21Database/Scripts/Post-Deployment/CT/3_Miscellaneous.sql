GO
UPDATE tblCTSequenceUsageHistory SET strFieldName = REPLACE(strFieldName,'Quantiy','Quantity')
GO

GO
UPDATE tblCTContractHeader SET dtmCreated = dtmContractDate WHERE dtmCreated IS NULL
GO

GO--Updating New Column Values
UPDATE	HI
SET		HI.intExternalHeaderId	=	AP.intExternalHeaderId,
		HI.intContractHeaderId	=	AP.intContractHeaderId,
		HI.intContractSeq		=	AP.intContractSeq,
		HI.strNumber			=	AP.strNumber,
		HI.strUserName			=	AP.strUserName
FROM	tblCTSequenceUsageHistory HI
CROSS	APPLY dbo.fnCTGetSequenceUsageHistoryAdditionalParam(HI.intContractDetailId,HI.strScreenName,HI.intExternalId,HI.intUserId) AP
WHERE	HI.intContractHeaderId IS NULL
GO