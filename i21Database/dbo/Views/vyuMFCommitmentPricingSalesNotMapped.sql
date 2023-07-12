CREATE VIEW vyuMFCommitmentPricingSalesNotMapped
AS
SELECT CPS.intCommitmentPricingSalesId
	,CH.strContractNumber
	,CD.intContractSeq
	,CASE WHEN CPS.dblFXPrice <> NULL 
		THEN ROUND(CPS.dblFXPrice, 4)
			ELSE ROUND(ISNULL(CD.dblFXPrice, 0), 4)
		END AS dblFXPriceCD
	,FM.strFutMarketName
	,B.strBook
	,SB.strSubBook
FROM tblMFCommitmentPricingSales CPS
JOIN tblCTContractDetail CD ON CD.intContractDetailId = CPS.intContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CPS.intFutureMarketId
LEFT JOIN tblCTBook B ON B.intBookId = CPS.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CPS.intSubBookId
