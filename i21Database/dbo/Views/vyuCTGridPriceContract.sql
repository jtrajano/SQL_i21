CREATE VIEW [dbo].[vyuCTGridPriceContract]

AS

	SELECT
			PC.intPriceContractId
			,PC.strPriceContractNo
			,PC.intCommodityId
			,PC.intFinalPriceUOMId
			,PC.intFinalCurrencyId
			,PC.intCreatedById
			,PC.dtmCreated
			,PC.intLastModifiedById
			,PC.dtmLastModified
			,PC.intConcurrencyId
			,PC.intCompanyId
			,PC.intPriceContractRefId
			,PC.ysnReadOnlyInterCoPrice
			,UM.strUnitMeasure	AS	strFinalPriceUOM
			,CY.strCurrency		AS	strFinalCurrency
			,CY.ysnSubCurrency
			,MY.strCurrency		AS	strMainCurrency
			,ysnLoad = (select isnull(CH.ysnLoad,convert(bit,0)) from tblCTContractHeader CH where CH.intContractHeaderId = (select top 1 PF.intContractHeaderId from tblCTPriceFixation PF where PF.intPriceContractId = PC.intPriceContractId))
			,ysnPaid = dbo.[fnCTCheckIfPaid](PC.intPriceContractId)

	FROM			tblCTPriceContract			PC
			JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PC.intFinalPriceUOMId
			JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
	LEFT	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	PC.intFinalCurrencyId
	LEFT	JOIN	tblSMCurrency				MY	ON	MY.intCurrencyID				=	CY.intMainCurrencyId