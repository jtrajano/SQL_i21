CREATE VIEW [dbo].[vyuCTHeaderForPrepayment]

AS
	SELECT	 CH.intContractHeaderId
				,CH.dblQuantity
				,CH.strContractNumber
				,CH.intEntityId
				,ISNULL(CH.ysnUnlimitedQuantity, 0) ysnUnlimitedQuantity
				,CH.intCommodityId
				,ISNULL(CD.ysnComplete,0) AS ysnComplete
				,ISNULL(CD.dblCashPrice,0) dblCashPrice
				,CO.strCommodityCode
				,CO.strDescription AS	strCommodityDesc

		FROM			tblCTContractHeader	CH
				JOIN	tblICCommodity		CO	ON	CO.intCommodityId		=	CH.intCommodityId
		LEFT	JOIN	
		(
				SELECT	 intContractHeaderId
						,CAST(CASE WHEN SUM(intContractStatusId) = COUNT(1) * 5 THEN 1 ELSE 0 END AS BIT) AS ysnComplete
						,MIN(dblCashPrice) AS dblCashPrice
				FROM	tblCTContractDetail
				GROUP BY intContractHeaderId
		)									CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
		WHERE	ISNULL(CD.ysnComplete,0) = 0
