﻿CREATE VIEW [dbo].[vyuCTContractCostEnquiryCost]
	
AS

	SELECT	CC.intContractCostId,
			CC.intContractDetailId,
			CC.strItemNo,
			CC.strVendorName,
			CC.strCostMethod,
			CC.dblRate,
			CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblQuantity)*CC.dblRate
					WHEN	CC.strCostMethod = 'Amount'		THEN
						CC.dblRate
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100
			END  * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1) dblAmount,
			CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,PU.intUnitMeasureId,CC.intUnitMeasureId,CC.dblRate)
					WHEN	CC.strCostMethod = 'Amount'		THEN
						CC.dblRate/dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)
					WHEN	CC.strCostMethod = 'Percentage' THEN 
						(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100)/
						dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)
			END  dblAmountPer,
			BD.dblTotal * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1) dblActual,
			BD.dblTotal/ 
			dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity) * dbo.fnCTGetCurrencyExchangeRate(CC.intContractCostId,1)dblActualPer,
			BD.strBillTranactionType COLLATE Latin1_General_CI_AS AS strBillTranactionType

	FROM	
	(
			SELECT		CC.intContractCostId,
						CC.intContractDetailId,
						CC.intItemUOMId,
						CC.strCostMethod,
						CC.dblRate,
						CC.intItemId,
						IU.intUnitMeasureId,
						EY.strName strVendorName, 
						IM.strItemNo
			FROM		tblCTContractCost	CC
			JOIN		tblICItem			IM ON IM.intItemId				=	CC.intItemId
			LEFT JOIN	tblICItemUOM		IU ON IU.intItemUOMId			=	CC.intItemUOMId
			LEFT JOIN	tblICUnitMeasure	UM ON UM.intUnitMeasureId		=	IU.intUnitMeasureId
			LEFT JOIN	tblSMCurrency		CY ON CY.intCurrencyID			=	CC.intCurrencyId
			LEFT JOIN	tblEMEntity			EY ON EY.intEntityId			=	CC.intVendorId
			WHERE	ISNULL(ysnBasis,0) <> 1
	)		CC 
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId	=	CC.intContractDetailId	
	JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICItemUOM				CU	ON	CU.intItemUOMId			=	CC.intItemUOMId			LEFT	
	JOIN	tblICItemUOM				CM	ON	CM.intUnitMeasureId		=	CC.intUnitMeasureId
											AND	CM.intItemId			=	CD.intItemId			LEFT
	JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	(
					SELECT	BD.intItemId,
							BD.dblTotal,	
							BD.intContractHeaderId,
							CASE	WHEN BL.intTransactionType = 1 THEN 'Voucher'
									WHEN BL.intTransactionType = 2 THEN 'Vendor Prepayment'
									WHEN BL.intTransactionType = 3 THEN 'Debit Memo'
									WHEN BL.intTransactionType = 4 THEN 'Payable'
									WHEN BL.intTransactionType = 5 THEN 'Purchase Order'
									WHEN BL.intTransactionType = 6 THEN 'Bill Template'
									WHEN BL.intTransactionType = 7 THEN 'Bill Approval'
									WHEN BL.intTransactionType = 8 THEN 'Overpayment'
									WHEN BL.intTransactionType = 9 THEN '1099 Adjustment'
									WHEN BL.intTransactionType = 10 THEN 'Patronage'
									WHEN BL.intTransactionType = 11 THEN 'Claim'
							END	strBillTranactionType
					FROM	tblAPBillDetail		BD
					JOIN	tblAPBill			BL	ON	BL.intBillId	=	BD.intBillId


			)BD	ON	BD.intContractHeaderId	=	CD.intContractHeaderId AND CC.intItemId = BD.intItemId