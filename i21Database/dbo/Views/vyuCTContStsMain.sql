CREATE VIEW [dbo].[vyuCTContStsMain]
	
AS 

	SELECT	CD.intContractDetailId,
			CD.intCompanyLocationId,
			CH.intCommodityId 

	FROM	tblCTContractDetail CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
