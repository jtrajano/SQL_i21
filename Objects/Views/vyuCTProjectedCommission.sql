CREATE VIEW [dbo].[vyuCTProjectedCommission]

AS

	SELECT  CC.intContractCostId,
			SUBSTRING(CONVERT(NVARCHAR(20),dtmContractDate,106),4,10) COLLATE Latin1_General_CI_AS AS strContractDate,
			CH.strContractNumber + ' - ' + CP.strName strContractNumber,
			--ISNULL(BR.dblReqstdAmount,CC.dblRate) * CASE WHEN CC.ysnReceivable = 1 THEN 1 ELSE -1 END dblRate,
			EY.strName	AS  strEntity,
			SY.strName	AS  strSalesperson,
			CY.strCurrency,
			dtmContractDate,
			dblAmount = CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblQuantity)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount'	 OR CC.strCostMethod = 'Per Container'	THEN
							CC.dblRate
						WHEN	CC.strCostMethod = 'Percentage' THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100
				END

	FROM	tblCTContractCost	CC
	JOIN	tblCTContractDetail CD  ON	 CD.intContractDetailId	=   CC.intContractDetailId
	JOIN	tblCTContractHeader CH  ON	 CH.intContractHeaderId	=   CD.intContractHeaderId
	JOIN	tblEMEntity			EY  ON	 EY.intEntityId			=   CC.intVendorId
	JOIN	tblEMEntity			SY  ON	 SY.intEntityId			=   CH.intSalespersonId
	JOIN	tblEMEntity			CP  ON	 CP.intEntityId			=   CH.intCounterPartyId
	JOIN	tblSMCurrency		CY  ON	 CY.intCurrencyID		=   CC.intCurrencyId
	LEFT JOIN(
			SELECT	A.intContractCostId,B.dblReqstdAmount 
			FROM	tblCTContractCost A
			JOIN    tblCTBrkgCommnDetail	   B	  ON	 B.intContractCostId =	A.intContractCostId
			WHERE   A.strStatus = 'Requested'
	)							BR  ON	 BR.intContractCostId	=   CC.intContractCostId
	LEFT JOIN	tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
	LEFT JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId			=	CD.intItemUOMId	
	LEFT JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CC.intItemUOMId
	LEFT JOIN	tblICItemUOM		CM	ON	CM.intUnitMeasureId		=	IU.intUnitMeasureId
										AND CM.intItemId			=	CD.intItemId	
	WHERE   CC.dtmDueDate IS NOT NULL
	AND		ISNULL(CC.strStatus,'') <> 'Received/Paid'
	/*
	SELECT  CC.intContractCostId,
			SUBSTRING(CONVERT(NVARCHAR(20),dtmContractDate,106),4,10) COLLATE Latin1_General_CI_AS AS strContractDate,
			CH.strContractNumber + ' - ' + CP.strName strContractNumber,
			ISNULL(BR.dblReqstdAmount,CC.dblRate) * CASE WHEN CC.ysnReceivable = 1 THEN 1 ELSE -1 END dblRate,
			EY.strName	AS  strEntity,
			SY.strName	AS  strSalesperson,
			CY.strCurrency,
			dtmContractDate

	FROM	tblCTContractCost	CC
	JOIN	tblCTContractDetail CD  ON	 CD.intContractDetailId	=   CC.intContractDetailId
	JOIN	tblCTContractHeader CH  ON	 CH.intContractHeaderId	=   CD.intContractHeaderId
	JOIN	tblEMEntity			EY  ON	 EY.intEntityId			=   CC.intVendorId
	JOIN	tblEMEntity			SY  ON	 SY.intEntityId			=   CH.intSalespersonId
	JOIN	tblEMEntity			CP  ON	 CP.intEntityId			=   CH.intCounterPartyId
	JOIN	tblSMCurrency		CY  ON	 CY.intCurrencyID		=   CC.intCurrencyId
	LEFT JOIN(
			SELECT	A.intContractCostId,B.dblReqstdAmount 
			FROM	tblCTContractCost A
			JOIN    tblCTBrkgCommnDetail	   B	  ON	 B.intContractCostId =	A.intContractCostId
			WHERE   A.strStatus = 'Requested'
	)							BR  ON	 BR.intContractCostId	=   CC.intContractCostId
	WHERE   CC.dtmDueDate IS NOT NULL
	AND		ISNULL(CC.strStatus,'') <> 'Received/Paid'
	*/
