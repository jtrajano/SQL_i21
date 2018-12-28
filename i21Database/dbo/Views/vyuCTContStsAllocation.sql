CREATE VIEW [dbo].[vyuCTContStsAllocation]

AS 

		SELECT	AD.intAllocationDetailId,
				CH.strContractNumber + '-' + LTRIM(CD.intContractSeq) strSequenceNumber,
				EY.strName strEntityName,
				dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intSUnitMeasureId,LP.intWeightUOMId,dblSAllocatedQty) dblAllocatedQty,
				AD.intPContractDetailId intContractDetailId,
				'Sale' COLLATE Latin1_General_CI_AS AS strContractType

		FROM	tblLGAllocationDetail	AD
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId		=	AD.intSContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
		JOIN	tblEMEntity				EY	ON	EY.intEntityId				=	CH.intEntityId		CROSS	
		APPLY	tblLGCompanyPreference	LP

		UNION ALL 

		SELECT	AD.intAllocationDetailId,
				CH.strContractNumber + '-' + LTRIM(CD.intContractSeq) strSequenceNumber,
				EY.strName strEntityName,
				dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,AD.intPUnitMeasureId,LP.intWeightUOMId,dblSAllocatedQty) dblAllocatedQty,
				AD.intSContractDetailId,
				'Purchase' COLLATE Latin1_General_CI_AS AS strContractType

		FROM	tblLGAllocationDetail	AD
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId		=	AD.intPContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
		JOIN	tblEMEntity				EY	ON	EY.intEntityId				=	CH.intEntityId			CROSS	
		APPLY	tblLGCompanyPreference	LP
