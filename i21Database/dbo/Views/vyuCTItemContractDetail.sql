CREATE VIEW [dbo].[vyuCTItemContractDetail]
	
AS 

	SELECT	*
	FROM	(
				SELECT	
						CH.strContractNumber,
						IC.strItemNo,
						IC.strDescription,
						UM.strUnitMeasure,
						TG.strTaxGroup,
						CS.strContractStatus,
						CD.*						

					FROM	tblCTItemContractDetail				CD	
				
					JOIN	tblCTItemContractHeader				CH	ON	CH.intItemContractHeaderId			=		CD.intItemContractHeaderId	
			LEFT	JOIN	tblICItem							IC	ON	IC.intItemId						=		CD.intItemId
			LEFT	JOIN	tblICUnitMeasure					UM	ON	UM.intUnitMeasureId					=		CD.intItemUOMId
			LEFT	JOIN	tblSMTaxGroup						TG	ON	TG.intTaxGroupId					=		CD.intTaxGroupId
			LEFT	JOIN	tblCTContractStatus					CS	ON	CS.intContractStatusId				=		CD.intContractStatusId
			

			) tblX
