﻿CREATE VIEW [dbo].[vyuCTSearchCleanCost]

AS

	SELECT	CC.intCleanCostId,
			CC.intEntityId,
			CC.intContractDetailId,
			CC.intShipmentId,
			CC.intInventoryReceiptId,
			CC.strReferenceNumber,
			CC.strCleanCostNumber,
			CC.ysnFinalCost,
			CC.dblUncleanWeights,
			CC.dblCleanWeights,
			CC.dblLossInWeights,
			CC.dblHumidity,
			CC.dblCostRate,
			CC.dblTotalAmount,
			CC.dblPriceInUnitUOM,
			CC.strRemark,
			CC.ysnExportProvPrice,
			CC.dtmExportProvPrice,
			CC.ysnExported,
			CC.dtmExported,

			EY.strName strEntityName,
			CH.strContractNumber + ' - ' +LTRIM(CD.intContractSeq)	AS	strSequenceNumber,
			SH.strLoadNumber,
			''  COLLATE Latin1_General_CI_AS AS strReceiptNumber,
			CY.strCurrency AS strCleanCostCurrency,
			UM.strUnitMeasure AS strCleanCostUOM

	FROM	tblCTCleanCost CC
	JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId		=	CC.intContractDetailId
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblLGLoadDetail			SD	ON	SD.intLoadDetailId			=	CC.intShipmentId
										AND	SD.intPContractDetailId		=	CC.intContractDetailId	
	JOIN	tblLGLoad				SH	ON	SH.intLoadId				=	SD.intLoadId										
	--JOIN	tblICInventoryReceipt	IR	ON	IR.intInventoryReceiptId	=	CC.intInventoryReceiptId
	JOIN	tblEMEntity				EY	ON	EY.intEntityId				=	CC.intEntityId
	CROSS	
	APPLY	tblCTCompanyPreference	CP
	JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID			=	CP.intCleanCostCurrencyId 	
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	CP.intCleanCostUOMId
