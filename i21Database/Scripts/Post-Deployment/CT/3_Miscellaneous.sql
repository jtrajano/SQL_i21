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

GO
IF NOT EXISTS(SELECT * FROM tblCTAmendment)
BEGIN
	INSERT INTO tblCTAmendment (intConcurrencyId) SELECT 1
END
GO

GO

IF NOT EXISTS(SELECT * FROM tblCTPriceContract)
BEGIN
	IF EXISTS(SELECT * FROM tblCTPriceFixation)
	BEGIN
		PRINT('Filling data in Price Contract table')
		DECLARE @intNextId INT
		SET IDENTITY_INSERT tblCTPriceContract ON

		INSERT	INTO tblCTPriceContract(intPriceContractId,strPriceContractNo,intCommodityId,intFinalPriceUOMId,intConcurrencyId)
		SELECT	intPriceFixationId,LTRIM(intPriceFixationId),CH.intCommodityId,PF.intFinalPriceUOMId,1
		FROM	tblCTPriceFixation	PF
		JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	PF.intContractHeaderId
	
		UPDATE tblCTPriceFixation	SET intPriceContractId = intPriceFixationId WHERE intPriceContractId IS NULL

		SELECT @intNextId = MAX(intPriceContractId)+1 FROM tblCTPriceContract
		UPDATE tblSMStartingNumber SET intNumber = ISNULL(@intNextId,1) WHERE strTransactionType = 'Price Contract' AND strModule	= 'Contract Management'

		SET IDENTITY_INSERT tblCTPriceContract OFF
		PRINT('End filling data in Price Contract table')
	END
END	

GO