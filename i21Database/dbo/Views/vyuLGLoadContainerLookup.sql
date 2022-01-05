CREATE VIEW [dbo].[vyuLGLoadContainerLookup]
AS 
SELECT	L.strLoadNumber 
		,LD.intLoadDetailId
		,intLoadContainerId = ISNULL(LC.intLoadContainerId, -1)
		,WeightUOM.strUnitMeasure
		,dblQuantity = CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN LD.dblQuantity ELSE LC.dblQuantity END 
		,dblDeliveredQuantity = CASE WHEN ISNULL(LC.dblReceivedQty, 0) = 0 THEN LD.dblDeliveredQuantity ELSE ISNULL(LC.dblReceivedQty, 0) END  
		,ItemUOM.dblUnitQty AS dblItemUOMCF
		,LC.strContainerNumber
		,LC.strContainerId
		,dblFranchise = CASE WHEN ISNULL(PWG.dblFranchise, 0) > 0 THEN PWG.dblFranchise / 100 ELSE 0 END 
		,dblContainerWeightPerQty = CASE WHEN ISNULL(LC.dblQuantity, 0) = 0 THEN LC.dblNetWt ELSE LC.dblNetWt / LC.dblQuantity END -- (LC.dblNetWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END)
		,intWeightUOMId = WeightItemUOM.intItemUOMId
		,dblWeightUOMConvFactor = WeightItemUOM.dblUnitQty 
		,LC.dblNetWt
		,strMarkings = LC.strMarks 
FROM	tblLGLoad L INNER JOIN tblLGLoadDetail LD
			ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM 
			ON WeightUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM WeightItemUOM 
			ON WeightItemUOM.intItemUOMId = LD.intWeightItemUOMId
		LEFT JOIN tblCTContractDetail CD 
			ON CD.intContractDetailId = LD.intPContractDetailId
		LEFT JOIN tblCTContractHeader CH 
			ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblCTWeightGrade PWG 
			ON PWG.intWeightGradeId = CH.intWeightId
		OUTER APPLY 
			(SELECT LC.intLoadContainerId, LC.strContainerNumber, LC.dblNetWt, LDCL.dblQuantity, LDCL.dblReceivedQty FROM tblLGLoadDetailContainerLink LDCL 
				INNER JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
			 WHERE LD.intLoadDetailId = LDCL.intLoadDetailId AND ISNULL(LC.ysnRejected, 0) = 0) LC
		WHERE L.intShipmentType = 1