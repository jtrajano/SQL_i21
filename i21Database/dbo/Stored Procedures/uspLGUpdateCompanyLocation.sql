CREATE PROCEDURE uspLGUpdateCompanyLocation 
	@intContractDetailId INT
AS
BEGIN
	DECLARE @ysnUpdateCompanyLocation BIT = 0

	SELECT @ysnUpdateCompanyLocation = ISNULL(ysnUpdateCompanyLocation, 0)
	FROM tblLGCompanyPreference

	IF (@ysnUpdateCompanyLocation = 1)
	BEGIN
		UPDATE LD
		SET intPCompanyLocationId = CD.intCompanyLocationId,
			intPSubLocationId = CD.intSubLocationId
		FROM tblLGLoadDetail  LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		WHERE CD.intContractDetailId = @intContractDetailId

		UPDATE LW
		SET intSubLocationId = CD.intSubLocationId,
			intStorageLocationId = CD.intStorageLocationId		
		FROM tblLGLoadDetail LD
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		WHERE CD.intContractDetailId = @intContractDetailId
	END
END