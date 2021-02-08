CREATE PROCEDURE [dbo].[uspAGUpdateWOShippedQty]

@intAGWorkOrderId INT = NULL,
@intItemId INT = NULL,
@dblQtyShipped NUMERIC(18,6) = 0.000000,
@intUserId INT = NULL,
@strAuditDescription NVARCHAR(150) = N'Updated'

AS
BEGIN
	SET QUOTED_IDENTIFIER OFF    
	SET ANSI_NULLS ON    
	SET NOCOUNT ON    
	SET XACT_ABORT ON    
	SET ANSI_WARNINGS OFF

    IF((@intAGWorkOrderId IS NULL OR @intItemId IS NULL) OR @intUserId IS NULL)
    BEGIN
        RAISERROR('CHECK SP PARAMETERS!', 16, 1)
    END

    DECLARE @intAGWorkOrderDetailId INT
    DECLARE @valueFrom NUMERIC(18,6) = 0.000000
    DECLARE @valueTo NUMERIC(18,6)  = @dblQtyShipped
    

    IF EXISTS(SELECT 1 FROM tblAGWorkOrderDetail WHERE intWorkOrderId = @intAGWorkOrderId AND intItemId = @intItemId)
    BEGIN
        UPDATE tblAGWorkOrderDetail SET dblQtyShipped = @dblQtyShipped WHERE intItemId = @intItemId AND intWorkOrderId = @intAGWorkOrderId

       (SELECT 
          @intAGWorkOrderDetailId = intWorkOrderDetailId,
          @valueFrom = dblQtyShipped
            FROM tblAGWorkOrderDetail WHERE intWorkOrderId = @intAGWorkOrderId AND intItemId = @intItemId)
        
        DECLARE @details NVARCHAR(MAX) = '{"change": "tblAGWorkOrderDetails", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Updated", "change": "Updated-Record: '+CAST(@intAGWorkOrderDetailId AS VARCHAR(15))+'", "keyValue": '+CAST(@intAGWorkOrderDetailId AS VARCHAR(15))+', "iconCls": "small-new-modified", "children": [{"change": "Shipped Qty", "from": "'+ CAST(@valueFrom AS VARCHAR(15)) +'", "to": "'+ CAST(@valueTo AS VARCHAR(15)) +'", "leaf": true, "iconCls": "small-gear" }] }]}'

        EXEC uspSMAuditLog
            @screenName = 'Agronomy.view.WorkOrder',
            @entityId = @intUserId,
            @actionType = @strAuditDescription,
            @actionIcon = 'small-tree-modified',
            @keyValue = @intAGWorkOrderId,
            @details = @details  


    END

END