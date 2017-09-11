CREATE PROCEDURE [dbo].[uspLGUpdateLoadShipmentOnInvoicePost] 
	 @InvoiceId INT
	,@Post BIT = 0
	,@LoadId INT = NULL
	,@UserId INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @intPContractDetailId INT
	DECLARE @dblLoadDetailQty NUMERIC(18, 6)
	DECLARE @intMinRecordId INT
	DECLARE @intLoadId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intInvoiceDetailId INT
	DECLARE @intPurchaseSale INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @tblInvoiceDetail TABLE (
		intRecordId INT IDENTITY(1, 1)
		,intInvoiceId INT
		,intInvoiceDetailId INT
		,intLoadDetailId INT
		)

	INSERT INTO @tblInvoiceDetail
	SELECT DISTINCT intInvoiceId
		,intInvoiceDetailId
		,intLoadDetailId
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @InvoiceId

	SELECT @intMinRecordId = MIN(intRecordId)
	FROM @tblInvoiceDetail

	WHILE (@intMinRecordId > 0)
	BEGIN
		SET @intPContractDetailId = NULL
		SET @dblLoadDetailQty = NULL
		SET @intLoadId = NULL
		SET @intLoadDetailId = NULL
		SET @intInvoiceDetailId = NULL

		SELECT @intLoadDetailId = intLoadDetailId
			,@intInvoiceDetailId = intInvoiceDetailId
		FROM @tblInvoiceDetail
		WHERE intRecordId = @intMinRecordId

		SELECT @intPContractDetailId = intPContractDetailId
			  ,@dblLoadDetailQty = CASE WHEN ISNULL(@Post,0) =  1 THEN dblQuantity ELSE -dblQuantity END
			  ,@intLoadId = intLoadId
		FROM tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intPurchaseSale = intPurchaseSale 
		FROM tblLGLoad 
		WHERE intLoadId = @intLoadId

		IF (@intPurchaseSale = 3)
		BEGIN
			EXEC uspCTUpdateSequenceBalance @intContractDetailId = @intPContractDetailId
				,@dblQuantityToUpdate = @dblLoadDetailQty
				,@intUserId = @UserId
				,@intExternalId = @intInvoiceDetailId
				,@strScreenName = 'Invoice'

			SET @dblLoadDetailQty = -@dblLoadDetailQty
			EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intPContractDetailId
				,@dblQuantityToUpdate =  @dblLoadDetailQty
				,@intUserId = @UserId
				,@intExternalId = @intInvoiceDetailId
				,@strScreenName = 'Invoice'
		END

		SELECT @intMinRecordId = MIN(intRecordId)
		FROM @tblInvoiceDetail
		WHERE intRecordId > @intMinRecordId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH