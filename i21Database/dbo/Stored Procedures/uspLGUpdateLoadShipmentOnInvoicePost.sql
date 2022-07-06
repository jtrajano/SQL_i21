﻿CREATE PROCEDURE [dbo].[uspLGUpdateLoadShipmentOnInvoicePost] 
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
	DECLARE @intShipmentStatus INT
	DECLARE @ysnFromReturn BIT

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
			,@ysnFromReturn = CASE WHEN I.[strTransactionType] = 'Credit Memo' AND RI.[intInvoiceId] IS NOT NULL THEN 1 ELSE 0 END
		FROM tblARInvoice I
		OUTER APPLY (
			SELECT TOP 1 intInvoiceId 
			FROM tblARInvoice RET
			WHERE RET.strTransactionType = 'Invoice'
			  AND RET.ysnReturned = 1
			  AND RET.strInvoiceNumber = I.strInvoiceOriginId
			  AND RET.intInvoiceId = I.intOriginalInvoiceId
		) RI
		WHERE I.intInvoiceId = @InvoiceId

		SELECT @intPContractDetailId = intPContractDetailId
		      ,@intSContractDetailId = intSContractDetailId
			  ,@dblLoadDetailQty = CASE WHEN ISNULL(@Post,0) = 1 THEN 
										dblQuantity 
									ELSE -dblQuantity END
									* CASE WHEN (@strInvoiceType = 'Credit Memo') 
										THEN -1 ELSE 1 END
			  ,@intLoadId = intLoadId
		FROM tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intPurchaseSale = intPurchaseSale
			,@intShipmentStatus = intShipmentStatus 
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
				SET dblInvoicedQty = ISNULL(dblInvoicedQty, 0) 
									+ (CASE WHEN ISNULL(@Post,0) =  1 THEN @dblPurchasedLotQty ELSE @dblPurchasedLotQty *(-1) END 
										* CASE WHEN (@strInvoiceType = 'Credit Memo') THEN -1 ELSE 1 END)
				WHERE intContractDetailId = @intAllocationPContractDetailId

				/* When Posting Credit Memo from Return, Unpost and Cancel LS */
				IF (ISNULL(@ysnFromReturn, 0) = 1 AND @intShipmentStatus NOT IN (4, 12))
				BEGIN
					IF (@Post = 1)
					BEGIN
						EXEC dbo.[uspLGPostLoadSchedule] @intLoadId = @intLoadId, @ysnPost = 0, @intEntityUserSecurityId = @UserId
						EXEC dbo.[uspLGCancelLoadSchedule] @intLoadId = @intLoadId, @ysnCancel = 1, @intEntityUserSecurityId = @UserId, @intShipmentType = 1
					END
					ELSE
					BEGIN
						EXEC dbo.[uspLGCancelLoadSchedule] @intLoadId = @intLoadId, @ysnCancel = 0, @intEntityUserSecurityId = @UserId, @intShipmentType = 1
						EXEC dbo.[uspLGPostLoadSchedule] @intLoadId = @intLoadId, @ysnPost = 1, @intEntityUserSecurityId = @UserId
					END
				END
			END
		END
		ELSE IF (@intPurchaseSale = 3)
		BEGIN
			SET @dblLoadDetailQty = -@dblLoadDetailQty
			SET @dblInvoicedQty = NUll
            IF @intPContractDetailId IS NOT NULL AND @dblLoadDetailQty IS NOT NULL
            BEGIN
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

				UPDATE tblCTContractDetail
				SET dblInvoicedQty = ISNULL(dblInvoicedQty, 0) + (@dblInvoicedQty * -1)
				WHERE intContractDetailId = @intSContractDetailId
			END
		END

		IF ISNULL(@Post,0) = 1
		BEGIN
			IF(@strInvoiceType IN ('Provisional', 'Standard'))
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 11 WHERE intLoadId = @intLoadId AND intShipmentStatus NOT IN (4, 12)
			END
		END
		ELSE 
		BEGIN
			UPDATE tblLGLoad SET intShipmentStatus = 6 WHERE intLoadId = @intLoadId AND intShipmentStatus NOT IN (4, 12)
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