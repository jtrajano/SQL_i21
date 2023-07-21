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
						ysnIsUsed = CONVERT(BIT, CASE WHEN (SELECT TOP 1 1 FROM tblARInvoiceDetail WHERE intItemContractDetailId = CD.intItemContractDetailId) = 1 THEN 1
						ELSE 0 END),
						CH.intEntityId,
						CH.intSalespersonId,
						CH.dtmExpirationDate,
						EY.strName     AS strEntityName,
						SP.strName     AS strSalesperson, 
						CD.dblBalance * CD.dblPrice AS dblBalanceTotal,
						CD.*						

					FROM	tblCTItemContractDetail				CD	
				
					JOIN	tblCTItemContractHeader				CH	ON	CH.intItemContractHeaderId			=		CD.intItemContractHeaderId	
			LEFT	JOIN	tblICItem							IC	ON	IC.intItemId						=		CD.intItemId
			LEFT	JOIN	tblICItemUOM						IU	ON	IU.intItemId						=		CD.intItemId AND CD.intItemUOMId = IU.intItemUOMId  
			LEFT	JOIN	tblICUnitMeasure					UM	ON	UM.intUnitMeasureId					=		IU.intUnitMeasureId
			LEFT	JOIN	tblSMTaxGroup						TG	ON	TG.intTaxGroupId					=		CD.intTaxGroupId
			LEFT	JOIN	tblCTContractStatus					CS	ON	CS.intContractStatusId				=		CD.intContractStatusId
			LEFT	JOIN	tblEMEntity							EY  ON	EY.intEntityId						=		CH.intEntityId
			LEFT    JOIN	tblEMEntity							SP	ON	SP.intEntityId						=       CH.intSalespersonId 
			

			) tblX
