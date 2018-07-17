CREATE VIEW [dbo].[vyuCTAOP]
AS	
	SELECT	AD.*,
			AP.strYear,
			CO.strCommodityCode,
			IM.strItemNo,
			BI.strItemNo AS strBasisItemNo,
			VM.strUnitMeasure	AS strVolumeUOM,
			WM.strUnitMeasure	AS strWeightUOM,
			--PM.strUnitMeasure	AS strPriceUOM
			Currency.strCurrency,
			LO.strLocationName

	FROM	tblCTAOPDetail			AD
	JOIN	tblCTAOP				AP	ON	AD.intAOPId				=	AP.intAOPId			LEFT
	JOIN	tblICCommodity			CO	On	CO.intCommodityId		=	AD.intCommodityId	LEFT
	JOIN	tblICItem				IM	ON	IM.intItemId			=	AD.intItemId		LEFT
	JOIN	tblICItem				BI	ON	BI.intItemId			=	AD.intBasisItemId	LEFT
	JOIN	tblICItemUOM			VU	ON	VU.intItemUOMId			=	AD.intVolumeUOMId	LEFT
	JOIN	tblICUnitMeasure		VM	ON	VM.intUnitMeasureId		=	VU.intUnitMeasureId	LEFT
	JOIN	tblICItemUOM			WU	ON	WU.intItemUOMId			=	AD.intWeightUOMId	LEFT
	JOIN	tblICUnitMeasure		WM	ON	WM.intUnitMeasureId		=	WU.intUnitMeasureId	LEFT
	JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId			=	AD.intPriceUOMId	LEFT
	JOIN	tblSMCompanyLocation	LO	ON	LO.intCompanyLocationId	=	AD.intCompanyLocationId
	--LEFT	JOIN	tblICUnitMeasure	PM	ON	PM.intUnitMeasureId	=	PU.intUnitMeasureId
	LEFT	JOIN	tblSMCurrency Currency	ON	Currency.intCurrencyID	=	AD.intCurrencyId		
