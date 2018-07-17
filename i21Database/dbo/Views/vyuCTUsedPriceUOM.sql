CREATE VIEW [dbo].[vyuCTUsedPriceUOM]

AS

	SELECT  DISTINCT 
			UM.intUnitMeasureId,
			UM.strUnitMeasure  

	FROM	tblCTContractDetail CD
	JOIN	tblICItemUOM		IU ON	 IU.intItemUOMId	 =	CD.intPriceItemUOMId
	JOIN	tblICUnitMeasure	UM ON	 UM.intUnitMeasureId =	IU.intUnitMeasureId
	WHERE   CD.intPriceItemUOMId IS NOT NULL
