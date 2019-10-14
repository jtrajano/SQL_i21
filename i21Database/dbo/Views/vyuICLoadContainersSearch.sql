CREATE VIEW [dbo].[vyuICLoadContainersSearch]
AS 
SELECT
	  [LoadDetail].intLoadDetailId
	, intLoadContainerId = ISNULL(LoadContainer.intLoadContainerId, -1)
	, [Load].strLoadNumber
	, dblDeliveredQuantity = NULL
	, WeightUOM.strUnitMeasure
	, dblItemUOMCF = ItemUOM.dblUnitQty
	, dblQuantity =
		CASE
			WHEN ISNULL(ContainerLink.dblQuantity,0) = 0 THEN LoadDetail.dblQuantity 
			ELSE ContainerLink.dblQuantity 
		END
	, intWeightUOMId = LoadDetail.intWeightItemUOMId
	, dblContainerWeightPerQty = NULL
	, dblFranchise = NULL
	, strContainerNumber = LoadContainer.strContainerNumber
FROM tblLGLoad [Load]
	INNER JOIN tblLGLoadDetail LoadDetail ON [Load].intLoadId = LoadDetail.intLoadId
	LEFT OUTER JOIN tblLGLoadDetailContainerLink ContainerLink ON ContainerLink.intLoadDetailId = LoadDetail.intLoadDetailId
	LEFT OUTER JOIN tblLGLoadContainer LoadContainer ON LoadContainer.intLoadContainerId = ContainerLink.intLoadContainerId
	LEFT OUTER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
WHERE [Load].intShipmentType = 1