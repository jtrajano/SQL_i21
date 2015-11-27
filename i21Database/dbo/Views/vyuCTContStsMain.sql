CREATE VIEW [dbo].[vyuCTContStsMain]
	
AS 

	SELECT	CD.intContractDetailId,
			CD.intCompanyLocationId,
			CH.intCommodityId, 
			CONVERT(NVARCHAR(20),CH.dtmContractDate,106) + ' - ' +
			ISNULL(IM.strItemNo + ' - ','')  +
			ISNULL(MA.strFutMarketName  + ' - ','') +
			ISNULL(MO.strFutureMonth  + ' - ','') +
			ISNULL(CB.strContractBasis  + ' - ','') +
			ISNULL(EY.strName,'') +
			'('+SS.strContractStatus+')'
			strInfo

	FROM	tblCTContractDetail CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblCTContractStatus	SS	ON	SS.intContractStatusId	=	CD.intContractStatusId	LEFT
	JOIN	tblICItem			IM	ON	IM.intItemId			=	CD.intItemId			LEFT
	JOIN	tblRKFutureMarket	MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId		LEFT
	JOIN	tblCTContractBasis	CB	ON	CB.intContractBasisId	=	CH.intContractBasisId	LEFT
	JOIN	tblEntity			EY	ON	EY.intEntityId			=	CH.intEntityId

	
