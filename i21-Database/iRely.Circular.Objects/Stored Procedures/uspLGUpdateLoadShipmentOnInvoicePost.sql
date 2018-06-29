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
	DECLARE @intSContractDetailId INT
	DECLARE @dblInvoicedQty NUMERIC(18,6)
	DECLARE @intAllocationDetailId INT
	DECLARE @intAllocationPContractDetailId INT
	DECLARE @dblPurchasedLotQty NUMERIC(18,6)
	DECLARE @intOutboundLoadDetailId INT
	DECLARE @intInboundLoadDetailId INT
	DECLARE @strInvoiceType NVARCHAR(100)

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
		SET @intPurchaseSale = NULL
		SET @strInvoiceType = NULL

		SELECT @intLoadDetailId = intLoadDetailId
			,@intInvoiceDetailId = intInvoiceDetailId
		FROM @tblInvoiceDetail
		WHERE intRecordId = @intMinRecordId

		SELECT @strInvoiceType = strType 
		FROM tblARInvoice 
		WHERE intInvoiceId = @InvoiceId

		SELECT @intPContractDetailId = intPContractDetailId
		      ,@intSContractDetailId = intSContractDetailId
			  ,@dblLoadDetailQty = CASE WHEN ISNULL(@Post,0) =  1 THEN dblQuantity ELSE -dblQuantity END
			  ,@intLoadId = intLoadId
		FROM tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intPurchaseSale = intPurchaseSale 
		FROM tblLGLoad 
		WHERE intLoadId = @intLoadId

		IF (@intPurchaseSale = 2)
		BEGIN
			IF @intSContractDetailId IS NOT NULL AND @dblLoadDetailQty IS NOT NULL
            BEGIN
				UPDATE tblCTContractDetail
				SET dblInvoicedQty = ISNULL(dblInvoicedQty, 0) + @dblLoadDetailQty
				WHERE intContractDetailId = @intSContractDetailId

				SELECT @intAllocationDetailId = intAllocationDetailId
					,@intOutboundLoadDetailId = intLoadDetailId
				FROM tblLGLoadDetail
				WHERE intSContractDetailId = @intSContractDetailId
					AND intLoadId = @intLoadId

				SELECT @intAllocationPContractDetailId = intPContractDetailId
				FROM tblLGAllocationDetail
				WHERE intAllocationDetailId = @intAllocationDetailId
				
				SELECT @dblPurchasedLotQty = SUM(LDL.dblLotQuantity)
				FROM tblLGLoad L
				JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
				JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
				WHERE LD.intLoadDetailId = @intOutboundLoadDetailId
						
				UPDATE tblCTContractDetail
				SET dblInvoicedQty = ISNULL(dblInvoicedQty, 0) + CASE WHEN ISNULL(@Post,0) =  1 THEN @dblPurchasedLotQty ELSE @dblPurchasedLotQty *(-1) END
				WHERE intContractDetailId = @intAllocationPContractDetailId
			END
		END
		ELSE IF (@intPurchaseSale = 3)
		BEGIN
			IF @intPContractDetailId IS NOT NULL AND @dblLoadDetailQty IS NOT NULL
            BEGIN
				EXEC uspCTUpdateSequenceBalance @intContractDetailId = @intPContractDetailId
					,@dblQuantityToUpdate = @dblLoadDetailQty
					,@intUserId = @UserId
					,@intExternalId = @intInvoiceDetailId
					,@strScreenName = 'Invoice'
			END

			SET @dblInvoicedQty = NUll
			IF @intSContractDetailId IS NOT NULL AND @dblLoadDetailQty IS NOT NULL
			BEGIN
				SELECT @dblInvoicedQty = CASE @Post
						WHEN 1
							THEN dblDeliveredQuantity
						ELSE dblDeliveredQuantity * (- 1)
						END
				FROM tblLGLoadDetail
				WHERE intSContractDetailId = @intSContractDetailId AND intLoadId = @intLoadId

				EXEC uspCTUpdateSequenceBalance @intContractDetailId = @intSContractDetailId
					,@dblQuantityToUpdate	=	@dblInvoicedQty
					,@intUserId				=	@UserId
					,@intExternalId			=	@intInvoiceDetailId
					,@strScreenName			=	'Invoice' 
			END

			SET @dblLoadDetailQty = -@dblLoadDetailQty
			SET @dblInvoicedQty = NUll
            IF @intPContractDetailId IS NOT NULL AND @dblLoadDetailQty IS NOT NULL
            BEGIN
				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intPContractDetailId
					,@dblQuantityToUpdate =  @dblLoadDetailQty
					,@intUserId = @UserId
					,@intExternalId = @intInvoiceDetailId
					,@strScreenName = 'Invoice'
				
				UPDATE tblCTContractDetail
				SET dblInvoicedQty = ISNULL(dblInvoicedQty, 0) + + (@dblLoadDetailQty * -1)
				WHERE intContractDetailId = @intPContractDetailId
			END

            IF @intSContractDetailId IS NOT NULL AND @dblLoadDetailQty IS NOT NULL
            BEGIN
				SELECT @dblInvoicedQty = CASE ISNULL(@Post,0)
						WHEN 0
							THEN dblDeliveredQuantity
						ELSE dblDeliveredQuantity * (- 1)
						END
				FROM tblLGLoadDetail
				WHERE intSContractDetailId = @intSContractDetailId AND intLoadId = @intLoadId

				EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intSContractDetailId
					,@dblQuantityToUpdate	=	@dblInvoicedQty
					,@intUserId				=	@UserId
					,@intExternalId			=	@intInvoiceDetailId
					,@strScreenName			=	'Invoice' 

				UPDATE tblCTContractDetail
				SET dblInvoicedQty = ISNULL(dblInvoicedQty, 0) + (@dblInvoicedQty * -1)
				WHERE intContractDetailId = @intSContractDetailId
			END
		END

		IF ISNULL(@Post,0) = 1
		BEGIN
			IF(@strInvoiceType = 'Standard')
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 11 WHERE intLoadId = @intLoadId
			END
		END
		ELSE 
		BEGIN
			UPDATE tblLGLoad SET intShipmentStatus = 6 WHERE intLoadId = @intLoadId
		END

		SELECT @intMinRecordId = MIN(intRecordId)
		FROM @tblInvoiceDetail
		WHERE intRecordId > @intMinRecordId
	END
	
	IF (ISNULL(@Post,0) =  1)
		EXEC uspARPopulateInvoiceStg @intInvoiceId = @InvoiceId

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH