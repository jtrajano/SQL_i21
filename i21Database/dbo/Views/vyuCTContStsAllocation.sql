CREATE VIEW [dbo].[vyuCTContStsAllocation]

AS 

		SELECT	AD.intAllocationDetailId,
				CH.strContractNumber + '-' + LTRIM(CD.intContractSeq) strSequenceNumber,
				EY.strName strEntityName,
				dblSAllocatedQty dblAllocatedQty,
				AD.intPContractDetailId intContractDetailId,
				'Sale' strContractType
		FROM	tblLGAllocationDetail	AD
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId		=	AD.intSContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
		JOIN	tblEntity				EY	ON	EY.intEntityId				=	CH.intEntityId

		UNION ALL 

		SELECT	AD.intAllocationDetailId,
				CH.strContractNumber + '-' + LTRIM(CD.intContractSeq) strSequenceNumber,
				EY.strName strEntityName,
				dblPAllocatedQty,
				AD.intSContractDetailId,
				'Purchase' strContractType
		FROM	tblLGAllocationDetail	AD
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId		=	AD.intPContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
		JOIN	tblEntity				EY	ON	EY.intEntityId				=	CH.intEntityId
