CREATE PROCEDURE uspLGUpdateCompanyLocation 
	@intContractDetailId INT
AS
BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX)

	DECLARE @ysnUpdateCompanyLocation BIT = 0

	SELECT @ysnUpdateCompanyLocation = ISNULL(ysnUpdateCompanyLocation, 0)
	FROM tblLGCompanyPreference

	

	IF (@ysnUpdateCompanyLocation = 1)
	BEGIN

		IF EXISTS(	SELECT	1 
					FROM	tblICInventoryReceiptItem	RI														
					JOIN	tblICInventoryReceipt		IR	ON	IR.intInventoryReceiptId	=	RI.intInventoryReceiptId 
															AND IR.strReceiptType	IN	('Purchase Contract','Inventory Return')
					JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId = RI.intLineNo
					WHERE	CD.intCompanyLocationId  <> IR.intLocationId AND	RI.intLineNo	=	@intContractDetailId)
		BEGIN
			RAISERROR('Cannot change location of sequence as it is used in inventory receipt.',16,1)
		END

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

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO