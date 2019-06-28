CREATE VIEW [dbo].[vyuCTItemContractDetail]
	
AS 

	SELECT	*
	FROM	(
				SELECT	
						IC.strItemNo,
						IC.strDescription,
						UM.strUnitMeasure,
						TG.strTaxGroup,
						CS.strContractStatus,
						CH.*						

					FROM	tblCTItemContractDetail				CH	
				
					JOIN	tblICItem							IC	ON	IC.intItemId						=		CH.intItemId							
			LEFT	JOIN	tblICUnitMeasure					UM	ON	UM.intUnitMeasureId					=		CH.intItemUOMId
			LEFT	JOIN	tblSMTaxGroup						TG	ON	TG.intTaxGroupId					=		CH.intTaxGroupId
			LEFT	JOIN	tblCTContractStatus					CS	ON	CS.intContractStatusId				=		CH.intContractStatusId
			

			) tblX
