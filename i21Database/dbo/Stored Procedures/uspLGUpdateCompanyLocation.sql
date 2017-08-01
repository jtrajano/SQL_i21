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
	END
END