CREATE VIEW [dbo].[vyuICLoadContainers]
AS 
SELECT
	  [LoadDetail].intLoadDetailId
	, intLoadContainerId = ISNULL(LoadContainer.intLoadContainerId, -1)
	, [Load].strLoadNumber
	, dblQuantity =
		CASE
			WHEN ISNULL(ContainerLink.dblQuantity,0) = 0 THEN LoadDetail.dblQuantity 
			ELSE ContainerLink.dblQuantity 
		END
	, dblDeliveredQuantity =
		CASE
			WHEN ISNULL(ContainerLink.dblReceivedQty, 0) = 0 THEN LoadDetail.dblDeliveredQuantity 
			ELSE ISNULL(ContainerLink.dblReceivedQty, 0)
		END
	, WeightUOM.strUnitMeasure
	, dblItemUOMCF = ItemUOM.dblUnitQty
	, intWeightUOMId = LoadDetail.intWeightItemUOMId
	, dblContainerWeightPerQty =
		CASE
			WHEN ISNULL(LoadContainer.dblQuantity, 0) = 0 THEN LoadContainer.dblNetWt
			ELSE LoadContainer.dblNetWt / LoadContainer.dblQuantity
		END
	, dblFranchise =
		CASE
			WHEN ISNULL(WeightGrade.dblFranchise, 0) > 0 THEN WeightGrade.dblFranchise / 100
			ELSE 0
		END
	, strContainerNumber = LoadContainer.strContainerNumber
	, strMarks = LoadContainer.strMarks 
FROM tblLGLoad [Load]
	INNER JOIN tblLGLoadDetail LoadDetail ON [Load].intLoadId = LoadDetail.intLoadId
	LEFT OUTER JOIN tblLGLoadDetailContainerLink ContainerLink ON ContainerLink.intLoadDetailId = LoadDetail.intLoadDetailId
	LEFT OUTER JOIN tblLGLoadContainer LoadContainer ON LoadContainer.intLoadContainerId = ContainerLink.intLoadContainerId
	LEFT OUTER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT OUTER JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = LoadDetail.intPContractDetailId
	LEFT OUTER JOIN tblCTContractHeader [Contract] ON [Contract].intContractHeaderId = ContractDetail.intContractHeaderId
	LEFT OUTER JOIN tblCTWeightGrade WeightGrade ON WeightGrade.intWeightGradeId = [Contract].intWeightId
WHERE [Load].intShipmentType = 1