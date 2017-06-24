CREATE VIEW [dbo].[vyuCTQualityApprovedRejected]

AS

	with cte as
	(
		SELECT	SA.intContractDetailId,
				CD.dblQuantity, 
				SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SA.intItemId,intRepresentingUOMId,CD.intUnitMeasureId, dblRepresentingQty)) dblTotalApprovedQty
		FROM	tblQMSample			SA
		JOIN	tblCTContractDetail	CD	ON CD.intContractDetailId	=	SA.intContractDetailId
		WHERE	intSampleStatusId	=	3
		GROUP BY SA.intContractDetailId,CD.dblQuantity
	)

	SELECT	intContractDetailId,
			dblTotalApprovedQty AS dblApprovedQty,
			CASE WHEN dblTotalApprovedQty>= dblQuantity THEN 'Approved' ELSE 'Partially Approved' END strSampleStatus
	FROM	cte

	UNION ALL

	SELECT	intContractDetailId,
			dblTotalRejectedQty AS dblApprovedQty,
			CASE WHEN dblTotalRejectedQty>= dblQuantity THEN 'Rejected' ELSE 'Partially Rejected' END strSampleStatus 
	FROM	
	(
			SELECT	SA.intContractDetailId,
					CD.dblQuantity, 
					SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SA.intItemId,intRepresentingUOMId,CD.intUnitMeasureId, dblRepresentingQty)) dblTotalRejectedQty
			FROM	tblQMSample			SA
			JOIN	tblCTContractDetail	CD	ON CD.intContractDetailId	=	SA.intContractDetailId
			WHERE	intSampleStatusId	=	4
			AND		SA.intContractDetailId	NOT IN	(SELECT intContractDetailId FROM cte)
			GROUP BY SA.intContractDetailId,CD.dblQuantity
	)t
