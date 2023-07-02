CREATE PROCEDURE [dbo].[uspQMUpdateLoadShipmentDetail]
	@intBatchId			INT
	,@intEntityUserId	INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
	
    /* #1 - Validations */
	DECLARE @strBatchId NVARCHAR(50), @strError NVARCHAR(MAX)
	SELECT @strBatchId = strBatchId FROM tblMFBatch WHERE intBatchId = @intBatchId AND ISNULL(strIBDNo, '') <> ''

	IF (ISNULL(@strBatchId, '') <> '')
	BEGIN
		SET @strError = 'Batch ' + @strBatchId + ' already has an IBD number. Unable to update the sample entry.'
		RAISERROR (@strError, 16, 1)
	END

    IF NOT EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intBatchId = @intBatchId)
        RETURN

    /* #2 - Save load detail values before update for contract scheduled qty and audit logs */
    IF OBJECT_ID('tempdb..#tmpLGLoadDetailForUpdate') IS NOT NULL
        DROP TABLE #tmpLGLoadDetailForUpdate
    
    SELECT
        intLoadDetailId
        ,dblUnitPrice
        ,dblQuantity
        ,dblGross
        ,dblNet
        ,dblTare
        ,dblAmount
        ,dblForexAmount
        ,intItemUOMId
    INTO #tmpLGLoadDetailForUpdate
    FROM tblLGLoadDetail LG
    WHERE LG.intBatchId = @intBatchId

    /* #3 - Actual load detail update */
	UPDATE LG
	SET dblUnitPrice	    = B.dblBoughtPrice
		, dblQuantity	    = B.dblPackagesBought
		, dblGross		    = B.dblTotalQuantity
		, dblNet			= B.dblTotalQuantity		  
		, dblTare			= 0
		, dblAmount 		= B.dblBoughtPrice * B.dblTotalQuantity
		, dblForexAmount	= B.dblBoughtPrice * B.dblTotalQuantity
		, intItemUOMId	    = IUOM.intItemUOMId
	FROM tblLGLoadDetail LG
    INNER JOIN tblMFBatch B ON B.intBatchId = LG.intBatchId
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemId = B.intTealingoItemId AND IUOM.intUnitMeasureId = B.intPackageUOMId
    WHERE B.intBatchId = @intBatchId

    /* #4 - Contract scheduled qty update */
    DECLARE
        @intContractDetailId INT
        ,@dblQuantityToUpdate DECIMAL(18, 6)
        ,@intLoadId INT
        ,@intExternalId INT
        ,@strScreenName NVARCHAR(50) = 'Load Schedule'
        ,@intSourceItemUOMId INT

    SELECT
        @intContractDetailId = intPContractDetailId
        ,@dblQuantityToUpdate = LGN.dblQuantity - dbo.fnCalculateQtyBetweenUOM(LGO.intItemUOMId, LGN.intItemUOMId, LGO.dblQuantity)
        ,@intExternalId = LGN.intLoadDetailId
        ,@intSourceItemUOMId = LGN.intItemUOMId
        ,@intLoadId = LGN.intLoadId
    FROM tblLGLoadDetail LGN
    INNER JOIN #tmpLGLoadDetailForUpdate LGO ON LGO.intLoadDetailId = LGN.intLoadDetailId

    IF(ISNULL(@dblQuantityToUpdate, 0) <> 0)
        EXEC [dbo].[uspCTUpdateScheduleQuantityUsingUOM]
            @intContractDetailId,
            @dblQuantityToUpdate,
            @intEntityUserId,
            @intExternalId,
            @strScreenName,
            @intSourceItemUOMId

    /* #5 - Audit logs */
    DECLARE @auditLog BatchAuditLogParamNested
    DELETE FROM @auditLog

    INSERT INTO @auditLog (
        [Id]
        ,[RecordId]
        ,[Action]
        ,[Description]
        ,[From]
        ,[To]
        ,[ParentId]
    )
    SELECT
        [Id]            = 1
        ,[RecordId]     = @intLoadId
        ,[Action]       = 'Updated'
        ,[Description]  = NULL
        ,[From]         = NULL
        ,[To]           = NULL
        ,[ParentId]     = NULL
    UNION ALL
    SELECT
        [Id]            = 1 + ROW_NUMBER() OVER(ORDER BY (SELECT 1))
        ,[RecordId]     = @intLoadId
        ,[Action]       = NULL
        ,[Description]  = C.strFieldName
        ,[From]         = C.strOldValue
        ,[To]           = C.strNewValue
        ,[ParentId]     = 1
    FROM tblLGLoadDetail LGN
    INNER JOIN #tmpLGLoadDetailForUpdate LGO ON LGN.intLoadDetailId = LGO.intLoadDetailId
    INNER JOIN tblICItemUOM IUOMN ON IUOMN.intItemUOMId = LGN.intItemUOMId
    INNER JOIN tblICItemUOM IUOMO ON IUOMO.intItemUOMId = LGO.intItemUOMId
    INNER JOIN tblICUnitMeasure UMN ON UMN.intUnitMeasureId = IUOMN.intUnitMeasureId
    INNER JOIN tblICUnitMeasure UMO ON UMO.intUnitMeasureId = IUOMO.intUnitMeasureId
    -- Unpivot columns to rows
    CROSS APPLY (
        SELECT 'Unit Price', CAST(LGO.dblUnitPrice AS NVARCHAR), CAST(LGN.dblUnitPrice AS NVARCHAR)
        UNION ALL
        SELECT 'Quantity', CAST(LGO.dblQuantity AS NVARCHAR), CAST(LGN.dblQuantity AS NVARCHAR)
        UNION ALL
        SELECT 'UOM', UMO.strUnitMeasure, UMN.strUnitMeasure
        UNION ALL
        SELECT 'Gross Weight', CAST(LGO.dblGross AS NVARCHAR), CAST(LGN.dblGross AS NVARCHAR)
        UNION ALL
        SELECT 'Net Weight', CAST(LGO.dblNet AS NVARCHAR), CAST(LGN.dblNet AS NVARCHAR)
        UNION ALL
        SELECT 'Tare Weight', CAST(LGO.dblTare AS NVARCHAR), CAST(LGN.dblTare AS NVARCHAR)
        UNION ALL
        SELECT 'Amount', CAST(LGO.dblAmount AS NVARCHAR), CAST(LGN.dblAmount AS NVARCHAR)
        UNION ALL
        SELECT 'Forex Amount', CAST(LGO.dblForexAmount AS NVARCHAR), CAST(LGN.dblForexAmount AS NVARCHAR)
    ) C (strFieldName, strOldValue, strNewValue)
    WHERE LGN.intLoadDetailId = LGO.intLoadDetailId
    AND ISNULL(C.strOldValue, '') <> ISNULL(C.strNewValue, '')

    IF EXISTS (SELECT 1 FROM @auditLog)
    BEGIN
        EXEC dbo.uspSMBatchAuditLogNested
            @strScreenName      = 'Logistics.view.ShipmentSchedule'
            ,@intEntityId		= @intEntityUserId
            ,@tblAuditLogParam 	= @auditLog
    END

    DROP TABLE #tmpLGLoadDetailForUpdate

    /* #6 - Trigger PO Feed */
    IF EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ysnPosted = 1)
        EXEC uspIPProcessOrdersToFeed
            @intLoadId  		= @intLoadId
            , @intLoadDetailId	= @intExternalId
            , @intEntityId		= @intEntityUserId
            , @strRowState		= 'Modified'
END