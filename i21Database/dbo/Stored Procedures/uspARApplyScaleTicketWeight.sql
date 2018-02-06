﻿CREATE PROCEDURE [dbo].[uspARApplyScaleTicketWeight]
	  @intSalesOrderId	INT
	, @intScaleUOMId    INT = NULL
	, @intUserId		INT = NULL
	, @dblGrossWeight	NUMERIC(18, 6) = 0
    , @dblTareWeight	NUMERIC(18, 6) = 0
	, @dblNetWeight		NUMERIC(18, 6) = 0
	, @intNewInvoiceId	INT = NULL OUTPUT
AS
BEGIN
	DECLARE @intScaleItem			INT = NULL
		  , @intStockUOMId			INT = NULL
		  , @intItemUOMId			INT = NULL
		  , @intSalesOrderDetailId	INT = NULL
		  , @dblTotalTreatment		NUMERIC(18, 6) = 0

	SELECT TOP 1 @intScaleItem			= SOD.intItemId
			   , @intStockUOMId			= I.intUnitMeasureId
			   , @intItemUOMId			= SOD.intItemUOMId
			   , @intSalesOrderDetailId = SOD.intSalesOrderDetailId
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT I.intItemId
			 , IUOM.intUnitMeasureId
		FROM dbo.tblICItem I WITH (NOLOCK)
		INNER JOIN (
			SELECT intItemId
				 , intUnitMeasureId
			FROM dbo.tblICItemUOM WITH (NOLOCK)
			WHERE ysnStockUnit = 1
		) IUOM ON I.intItemId = IUOM.intItemId
		WHERE I.ysnUseWeighScales = 1
	) I ON SOD.intItemId = I.intItemId
	WHERE intSalesOrderId = @intSalesOrderId

	IF ISNULL(@intSalesOrderId, 0) = 0
		BEGIN
			RAISERROR('Sales Order ID is required.', 16, 1)
			RETURN;
		END

	IF ISNULL(@dblNetWeight, 0) = 0
		BEGIN
			RAISERROR('Net Weight should not be zero.', 16, 1)
			RETURN;
		END

	IF NOT EXISTS (SELECT NULL FROM tblSOSalesOrder WHERE intSalesOrderId = @intSalesOrderId)
		BEGIN
			RAISERROR('Sales Order is not existing.', 16, 1)
			RETURN;
		END

	IF ISNULL(@intScaleItem, 0) = 0
		BEGIN
			RAISERROR('Sales Order doesn''t have scale item.', 16, 1)
			RETURN;
		END

	SELECT @dblTotalTreatment = ISNULL(dbo.fnCalculateQtyBetweenUOM(@intScaleUOMId, SOD.intItemUOMId, SUM(dblQtyOrdered)), 0)
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT intItemId
		FROM dbo.tblICItem WITH (NOLOCK)
		WHERE ysnUseWeighScales = 0
	) ITEM ON SOD.intItemId = ITEM.intItemId
	WHERE SOD.intSalesOrderId = @intSalesOrderId
	GROUP BY SOD.intItemUOMId

	UPDATE tblSOSalesOrderDetail
	SET dblQtyOrdered = ISNULL(dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, @intScaleUOMId, @dblNetWeight - @dblTotalTreatment), 0)
	WHERE intSalesOrderDetailId = @intSalesOrderDetailId
	  AND intSalesOrderId = @intSalesOrderId
	  AND intItemId = @intScaleItem

	EXEC dbo.uspSOProcessToInvoice @SalesOrderId = @intSalesOrderId
								 , @UserId = @intUserId
								 , @NewInvoiceId = @intNewInvoiceId OUT

	IF ISNULL(@intNewInvoiceId, 0) = 0
		BEGIN
			RAISERROR('Failed to Create Invoice.', 16, 1)
			RETURN;
		END	
END