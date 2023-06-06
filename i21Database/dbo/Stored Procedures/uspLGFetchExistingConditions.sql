CREATE PROCEDURE [dbo].[uspLGFetchExistingConditions]
	@intOriginId INT,
	@strOriginPort NVARCHAR(50) = NULL,
	@strDestinationPort NVARCHAR(50) = NULL,
	@intCertificationId INT,
	@intShippingLineEntityId INT,
	@intPSubLocationId INT,
	@intVendorEntityId INT
AS
BEGIN
	SELECT DISTINCT
		LC.intLoadConditionId,
		LC.intConditionId,
		CTC.strConditionName,
		CTC.strConditionDesc AS strConditionDescription,
		L.strLoadNumber
	FROM tblLGLoad L
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	INNER JOIN tblICItem ICI ON ICI.intItemId = LD.intItemId
	INNER JOIN (
		SELECT 
			intConditionId, 
			MAX(intLoadConditionId) AS intLoadConditionId,
			MAX(intLoadId) AS intLoadId 
		FROM tblLGLoadCondition
		GROUP BY 
			intConditionId
	) LC ON LC.intLoadId = L.intLoadId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = 
		CASE 
			WHEN L.intPurchaseSale = 1 THEN LD.intPContractDetailId
			WHEN L.intPurchaseSale = 2 THEN LD.intSContractDetailId
		END
	INNER JOIN tblCTContractCertification CC ON CC.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblCTCondition CTC ON CTC.intConditionId = LC.intConditionId
	WHERE
		ICI.intOriginId = @intOriginId AND
		L.strOriginPort = @strOriginPort AND
		L.strDestinationPort = @strDestinationPort AND
		LD.intVendorEntityId = @intVendorEntityId AND
		COALESCE(CC.intCertificationId, 1) = CASE WHEN @intCertificationId = 0 THEN COALESCE(CC.intCertificationId, 1) ELSE @intCertificationId END AND
		COALESCE(L.intShippingLineEntityId, 1) = CASE WHEN @intShippingLineEntityId = 0 THEN COALESCE(L.intShippingLineEntityId, 1) ELSE @intShippingLineEntityId END AND
		COALESCE(LD.intPSubLocationId, 1) = CASE WHEN @intPSubLocationId = 0 THEN COALESCE(LD.intPSubLocationId, 1) ELSE @intPSubLocationId END AND
		LC.intConditionId IS NOT NULL
END
