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

    
    DECLARE @lineTotal NUMERIC(18,6) = 0.000000
	DECLARE @linePrice NUMERIC(18,6) = 0.000000

	DECLARE @fromSubTotal NUMERIC(18,6) = 0.000000
	DECLARE @fromTotal NUMERIC(18,6) = 0.000000
    

    IF EXISTS(SELECT 1 FROM tblAGWorkOrderDetail WHERE intWorkOrderId = @intAGWorkOrderId AND intItemId = @intItemId)
    BEGIN

       (SELECT 
          @intAGWorkOrderDetailId = intWorkOrderDetailId,
          @valueFrom = dblQtyShipped,
          @linePrice = ISNULL(dblPrice, 0)
            FROM tblAGWorkOrderDetail WHERE intWorkOrderId = @intAGWorkOrderId AND intItemId = @intItemId)

            --calculate line item total
		SET @lineTotal = (ISNULL(@linePrice,0) * ISNULL(@dblQtyShipped,0))

        
        UPDATE tblAGWorkOrderDetail 
        SET dblQtyShipped = @dblQtyShipped,
            dblTotal      = @lineTotal
        WHERE intItemId = @intItemId AND intWorkOrderId = @intAGWorkOrderId

        
		--GET THE FROM OF SUBTOTAL AND TOTAL FROM HEADER
		SELECT 
		@fromSubTotal = dblWorkOrderSubtotal,
		@fromTotal    = dblWorkOrderTotal
		FROM tblAGWorkOrder where intWorkOrderId = @intAGWorkOrderId

        	--update totals/subtotals
		declare @outAGTotal numeric(18,6) 
		declare @outAGSubTotal numeric(18,6) 

		exec uspAGCalculateWOTotal 
			@intAGWorkOrderId = @intAGWorkOrderId,
			@newAGTotal = @outAGTotal out,
			@newAGSubTotal = @outAGSubTotal out
        
        DECLARE @header NVARCHAR(MAX) = '{"change": "dblWorkOrderSubtotal", "from": '+cast(@fromSubTotal as varchar(max))+', "to": '+cast(@outAGSubTotal as varchar(max))+', "iconCls": "small-new-modified", "keyValue": '+CAST(@intAGWorkOrderDetailId AS VARCHAR(20)) +', "changeDescription": "Subtotal" }, {"change": "dblWorkOrderTotal", "from": '+cast(@fromTotal as varchar(max))+', "to": '+cast(@outAGTotal as varchar(max))+', "iconCls": "small-new-modified", "keyValue": ' + CAST(@intAGWorkOrderDetailId AS VARCHAR(20)) +', "changeDescription": "Total"  },'

        DECLARE @details NVARCHAR(MAX) = @header + '{"change": "tblAGWorkOrderDetails", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Updated", "change": "Updated-Record: '+CAST(@intAGWorkOrderDetailId AS VARCHAR(15))+'", "keyValue": '+CAST(@intAGWorkOrderDetailId AS VARCHAR(15))+', "iconCls": "small-new-modified", "children": [{"change": "Shipped Qty", "from": "'+ CAST(@valueFrom AS VARCHAR(15)) +'", "to": "'+ CAST(@valueTo AS VARCHAR(15)) +'", "leaf": true, "iconCls": "small-gear" }] }]}'

        EXEC uspSMAuditLog
            @screenName = 'Agronomy.view.WorkOrder',
            @entityId = @intUserId,
            @actionType = @strAuditDescription,
            @actionIcon = 'small-tree-modified',
            @keyValue = @intAGWorkOrderId,
            @details = @details  


    END

END