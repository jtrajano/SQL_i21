CREATE VIEW [dbo].[vyuCTProjectedCommission]

AS

	SELECT  CC.intContractCostId,
			SUBSTRING(CONVERT(NVARCHAR(20),dtmContractDate,106),4,10)  AS strContractDate,
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
