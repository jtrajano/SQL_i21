CREATE PROCEDURE [dbo].[uspLGAddContainerDetailLink]
	@strLoadNumber NVARCHAR(200),
	@intContractDetailId INT = NULL,
	@strContainerNumber NVARCHAR(200) = NULL
AS

DECLARE @intLoadId INT
		,@intPurchaseSale INT

SELECT TOP 1 
	@intLoadId = intLoadId
	,@intPurchaseSale = intPurchaseSale
FROM tblLGLoad WHERE strLoadNumber = @strLoadNumber

IF @intContractDetailId IS NOT NULL
	AND NOT EXISTS(SELECT 1 FROM tblLGLoadDetail 
					WHERE intLoadId = @intLoadId 
						AND ((@intPurchaseSale IN (1, 3) AND intPContractDetailId = @intContractDetailId) 
						 OR (@intPurchaseSale = 2 AND intSContractDetailId = @intContractDetailId)))
BEGIN
	RAISERROR ('Unable to Link Containers. Contract Detail is not selected for this Load/Shipment',16,1);
	RETURN;
END

IF @strContainerNumber IS NOT NULL
	AND NOT EXISTS(SELECT 1 FROM tblLGLoadContainer WHERE intLoadId = @intLoadId AND strContainerNumber = @strContainerNumber)
BEGIN
	RAISERROR ('Unable to Link Containers. Container Number is not present on this Load/Shipment',16,1);
	RETURN;
END

--Add Load Detail Container Link Data
INSERT INTO tblLGLoadDetailContainerLink
	(intLoadId
	,intLoadContainerId
	,intLoadDetailId
	,dblQuantity
	,intItemUOMId
	,dblLinkGrossWt
	,dblLinkTareWt
	,dblLinkNetWt
	,intConcurrencyId)
SELECT
	intLoadId = LD.intLoadId
	,intLoadContainerId = LC.intLoadContainerId
	,intLoadDetailId = LD.intLoadDetailId
	,dblQuantity = LC.dblQuantity
	,intItemUOMId = UOM.intItemUOMId
	,dblLinkGrossWt = LC.dblGrossWt
	,dblLinkTareWt = LC.dblTareWt
	,dblLinkNetWt = LC.dblNetWt
	,intConcurrencyId = 1
FROM
	tblLGLoad L
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	INNER JOIN tblLGLoadContainer LC ON LC.intLoadId = L.intLoadId
	LEFT JOIN tblICItemUOM UOM ON UOM.intItemId = LD.intItemId AND UOM.intUnitMeasureId = LC.intUnitMeasureId
WHERE 
	L.intLoadId = @intLoadId
	AND (@strContainerNumber IS NULL OR (@strContainerNumber IS NOT NULL AND LC.strContainerNumber = @strContainerNumber))
	AND ((@intPurchaseSale IN (1,3) AND LD.intPContractDetailId = @intContractDetailId)
		OR (@intPurchaseSale = 2 AND LD.intSContractDetailId = @intContractDetailId))
	AND NOT EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId AND intLoadContainerId = LC.intLoadContainerId)

GO