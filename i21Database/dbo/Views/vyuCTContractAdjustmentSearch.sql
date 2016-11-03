CREATE VIEW [dbo].[vyuCTContractAdjustmentSearch]

AS

	SELECT	CD.intContractDetailId,
			CD.strContractNumber,
			CD.intContractSeq,
			CD.strContractType,
			CE.strName AS strEntityName,
			CE.strEntityNo,
			CD.strPricingType,
			CD.strFutureMonth,
			CD.dblFutures,
			CD.dblBasis,
			CD.dblCashPrice,
			CD.strPriceUOM,
			CD.dblDetailQuantity dblQuantity,
			CD.dblBalance,
			CD.strItemUOM,

			AD.intAdjustmentId,
			AD.strAdjustmentNo,
			AD.dtmAdjustmentDate,
			AD.strComment,
			AD.dblAdjustedQty,
			AD.dblCancellationPrice,
			AD.dblGainLossPerUnit,
			AD.dblCancelFeePerUnit,
			AD.dblCancelFeeFlatAmount,
			AD.dblTotalGainLoss,
			AD.dblTotalFee,
			AD.intAccountId,
			AD.intCreatedById,
			AD.dtmCreated,
			AD.intLastModifiedById,
			AD.dtmLastModified,

			EC.strName	AS strCreatedBy,
			EU.strName	AS strUpdatedBy		
	FROM	[vyuCTSearchContractDetail]	CD	LEFT
	JOIN	tblCTContractAdjustment	AD	ON	AD.intContractDetailId	=	CD.intContractDetailId	LEFT 
	JOIN	tblEMEntity				EC	ON	EC.intEntityId			=	AD.intCreatedById		LEFT
	JOIN	tblEMEntity				EU	ON	EU.intEntityId			=	AD.intLastModifiedById  LEFT
	JOIN    tblEMEntity				CE  ON  CE.intEntityId			=   CD.intEntityId
