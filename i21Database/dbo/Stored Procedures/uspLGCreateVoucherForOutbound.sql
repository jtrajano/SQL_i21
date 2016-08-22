CREATE PROCEDURE uspLGCreateVoucherForOutbound
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intBillId INT OUTPUT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(4000);
	DECLARE @intErrorSeverity INT;
	DECLARE @intErrorState INT;
	DECLARE @voucherDetailNonInvContract AS VoucherDetailNonInvContract
	DECLARE @total AS INT
	DECLARE @intVendorEntityId AS INT;


	SELECT TOP 1 @intVendorEntityId = intVendorEntityId
	FROM tblLGWarehouseRateMatrixHeader WRMH
	JOIN tblLGLoadWarehouse LW ON LW.intWarehouseRateMatrixHeaderId = WRMH.intWarehouseRateMatrixHeaderId
	WHERE LW.intLoadId = @intLoadId

	INSERT INTO @voucherDetailNonInvContract (
		intContractHeaderId
		,intContractDetailId
		,intItemId
		,intAccountId
		,dblQtyReceived
		,dblCost
		)
	SELECT CH.intContractHeaderId
		,CD.intContractDetailId
		,Item.intItemId
		,intAccountId = [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,dblQtyReceived = 1
		,dblCost = (
			Sum(LWS.dblActualAmount) / (
				SELECT SUM(dblNet)
				FROM tblLGLoadDetail D
				WHERE L.intLoadId = D.intLoadId
				) * SUM(LD.dblNet)
			)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
	JOIN tblICItem Item ON Item.intItemId = LWS.intItemId
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = Item.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = LW.intSubLocationId
		AND ItemLoc.intLocationId = SLCL.intCompanyLocationId
	WHERE L.intLoadId = @intLoadId
		AND LWS.dblActualAmount > 0
	GROUP BY LWS.intLoadWarehouseServicesId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,Item.intItemId
		,ItemLoc.intItemLocationId
		,LD.dblNet
		,L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId

	INSERT INTO @voucherDetailNonInvContract (
		intContractHeaderId
		,intContractDetailId
		,intItemId
		,intAccountId
		,dblQtyReceived
		,dblCost
		)
	SELECT CH.intContractHeaderId
		,CD.intContractDetailId
		,V.intItemId
		,intAccountId = [dbo].[fnGetItemGLAccount](V.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,dblQtyReceived = 1
		,dblCost = (
			Sum(V.dblPrice) / (
				SELECT SUM(dblNet)
				FROM vyuLGLoadCostForVendor VN
				WHERE VN.intLoadId = V.intLoadId
				)
			) * V.dblNet
	FROM vyuLGLoadCostForVendor V
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = V.intLoadDetailId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN ISNULL(LD.intPContractDetailId, 0) = 0
				THEN LD.intSContractDetailId
			ELSE LD.intPContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = V.intItemId
	WHERE V.intLoadId = @intLoadId
	GROUP BY CH.intContractHeaderId
		,CD.intContractDetailId
		,V.intItemId
		,ItemLoc.intItemLocationId
		,V.intLoadId
		,V.strLoadNumber
		,V.dblNet

	SELECT @total = COUNT(*)
	FROM @voucherDetailNonInvContract;

	IF (@total = 0)
	BEGIN
		RAISERROR ('Bill process failure #1',11,1);
		RETURN;
	END

	--SELECT * FROM @voucherDetailNonInvContract
	EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
		,@vendorId = @intVendorEntityId
		,@voucherDetailNonInvContract = @voucherDetailNonInvContract
		,@billId = @intBillId OUTPUT

	SELECT @intBillId
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH