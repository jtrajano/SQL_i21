CREATE VIEW [dbo].[vyuICLGContainerLookup]
AS
SELECT LD.intLoadId, LD.intLoadDetailId,
	L.strLoadNumber,
	LC.strContainerNumber,
	UOM.strUnitMeasure,
	ISNULL(LC.intLoadContainerId,-1) AS intLoadContainerId,
	CASE WHEN ISNULL(LDCL.dblQuantity,0) = 0 THEN LD.dblQuantity ELSE LDCL.dblQuantity END AS dblQuantity,
	CASE WHEN ISNULL(LDCL.dblReceivedQty, 0) = 0 THEN LD.dblDeliveredQuantity ELSE ISNULL(LDCL.dblReceivedQty, 0) END AS dblDeliveredQuantity,
	ItemUOM.dblUnitQty AS dblItemUOMCF,
	dblContainerWeightPerQty = (LC.dblNetWt / LC.dblQuantity),
	CD.dblCashPrice / CASE 
		WHEN ISNULL(CU.intCent, 0) = 0
			THEN 1.00
		ELSE CU.intCent
		END AS dblMainCashPrice
	,CASE 
		WHEN PWG.dblFranchise > 0
			THEN PWG.dblFranchise / 100
		ELSE 0.00
		END AS dblFranchise
FROM tblLGLoadDetail LD
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblICItem IM ON IM.intItemId = LD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
	LEFT JOIN tblCTWeightGrade PWG ON PWG.intWeightGradeId = CH.intWeightId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId