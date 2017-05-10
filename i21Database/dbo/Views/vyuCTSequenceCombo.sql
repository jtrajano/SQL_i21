﻿CREATE VIEW [dbo].[vyuCTSequenceCombo]

AS

	SELECT	CD.intContractDetailId,
			CD.intContractSeq,
			IM.strItemNo,
			CH.strContractNumber + ' - ' +LTRIM(CD.intContractSeq)	AS	strSequenceNumber,	
			CH.strContractNumber,
			CD.intItemId,
			CD.intCompanyLocationId,
			CL.strLocationName

	FROM	tblCTContractDetail		CD	
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
	JOIN	tblICItem				IM	ON	IM.intItemId			=	CD.intItemId			LEFT
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId	=	CD.intCompanyLocationId
