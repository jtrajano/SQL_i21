CREATE PROCEDURE [dbo].[uspLGDeleteLoadDetail]
	@intLoadDetailId INT,
	@intEntityUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	IF EXISTS (SELECT 1 FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId AND (intPContractDetailId IS NOT NULL OR intSContractDetailId IS NOT NULL))
	BEGIN
        DECLARE
            @intContractDetailId INT
            ,@dblQty NUMERIC(18, 6)
            ,@intItemUOMId INT
            ,@intLoadId INT

        SELECT
            @intContractDetailId = intPContractDetailId
            ,@dblQty = -dblQuantity
            ,@intItemUOMId = intItemUOMId
            ,@intLoadId = intLoadId
        FROM tblLGLoadDetail
        WHERE intLoadDetailId = @intLoadDetailId

        -- Return contract scheduled quantity
        EXEC uspCTUpdateScheduleQuantityUsingUOM
			@intContractDetailId
			,@dblQty
			,@intEntityUserId
			,@intLoadDetailId
			,'Load Schedule'
			,@intItemUOMId

        -- Audit log
        -- TODO: Upgrade implementation of audit log with the new method in higher versions
        DECLARE @details NVARCHAR(MAX)

        SELECT @details = '{"change": "tblLGLoadDetails", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Deleted", "change": "Deleted - Record: ' + V.strName + ' (P.Contract: ' + CH.strContractNumber + '-' + CAST(CD.intContractSeq AS NVARCHAR(4)) + ')", "keyValue": ' + CAST(@intLoadDetailId as varchar(15)) + ', "iconCls": "small-new-minus", "leaf": true}]}'
        FROM tblLGLoadDetail LD
        INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
        INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
        INNER JOIN tblEMEntity V ON V.intEntityId = CH.intEntityId
        WHERE LD.intLoadDetailId = @intLoadDetailId

        EXEC uspSMAuditLog
            @screenName = 'Logistics.view.ShipmentSchedule',
            @entityId = @intEntityUserId,
            @actionType = 'Updated',
            @actionIcon = 'small-tree-modified',
            @keyValue = @intLoadId,
            @details = @details

	END
    
    -- Delete load detail from the table
    DELETE FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text
		@ErrorSeverity, -- Severity
		@ErrorState -- State
	);
END CATCH