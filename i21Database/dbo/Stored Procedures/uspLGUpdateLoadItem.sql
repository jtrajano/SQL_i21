﻿CREATE PROCEDURE [dbo].[uspLGUpdateLoadItem]
	@intContractDetailId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(MAX);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @ErrMsg      NVARCHAR(MAX);
DECLARE @strItemType NVARCHAR(MAX);
DECLARE @intContractTypeId INT; 
DECLARE @intCount INT, @intItemId INT, @intItemUOMId INT;

BEGIN TRY
	IF (IsNull(@intContractDetailId, 0) = 0)
	BEGIN
		RAISERROR('Invalid Contract Sequence Identifier', 11, 1);
		RETURN;
	END

	SELECT @intContractTypeId = CT.intContractTypeId, @intItemId=CT.intItemId, @intItemUOMId=CT.intItemUOMId FROM vyuCTContractDetailView CT WHERE CT.intContractDetailId=@intContractDetailId
	SELECT @strItemType = Item.strType FROM tblICItem Item WHERE Item.intItemId = @intItemId
	SELECT @intCount = COUNT(LD.intLoadDetailId) FROM tblLGLoadDetail LD  
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE LD.intPContractDetailId = @intContractDetailId
	IF (@strItemType = 'Bundle' AND @intContractTypeId = 1 AND @intCount > 0)
	BEGIN
		RAISERROR('Bundle item cannot be changed for this purchase contract sequence, load/shipment already exists.', 11, 1);
		RETURN;
	END

	SELECT @intCount = COUNT(LD.intLoadDetailId) FROM tblLGLoadDetail LD  
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE L.ysnPosted = 1 AND (LD.intPContractDetailId = @intContractDetailId OR LD.intSContractDetailId = @intContractDetailId)
	IF (@intCount > 0)
	BEGIN
		RAISERROR('Item cannot be changed for this contract sequence. Already load / shipment using this contract sequence has been posted.', 11, 1);
		RETURN;
	END
	
	SELECT @intCount = COUNT(LD.intLoadDetailId) FROM tblLGLoadDetail LD  
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE (IsNull(L.intTicketId, 0) <> 0 OR IsNull(L.intLoadHeaderId, 0) <> 0) AND (LD.intPContractDetailId = @intContractDetailId OR LD.intSContractDetailId = @intContractDetailId)
	IF (@intCount > 0)
	BEGIN
		RAISERROR('Item cannot be changed for this contract sequence. Already load / shipment has been assigned to a scale ticket / transport load.', 11, 1);
		RETURN;
	END

	UPDATE tblLGLoadDetail SET intItemId = @intItemId, intItemUOMId=@intItemUOMId WHERE intPContractDetailId = @intContractDetailId OR intSContractDetailId = @intContractDetailId AND intItemId <> @intItemId

	UPDATE tblLGLoadDetail SET intWeightItemUOMId = @intItemUOMId WHERE (intPContractDetailId = @intContractDetailId OR intSContractDetailId = @intContractDetailId) AND intWeightItemUOMId = intItemUOMId AND intItemUOMId <> @intItemUOMId

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH
