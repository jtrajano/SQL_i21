﻿CREATE PROCEDURE uspLGPostLoadSchedule
	@intLoadId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT,
	@ysnRecap BIT = 0,
	@strBatchId NVARCHAR(40) = NULL OUTPUT,
	@dtmPostedDate DATETIME = NULL
AS
BEGIN TRY
	DECLARE @intPurchaseSale INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ysnUnShip BIT
	DECLARE @ysnValidateExternalShipmentNo BIT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strExternalShipmentNumber NVARCHAR(100)
	DECLARE @strFOBPoint NVARCHAR(50)
	DECLARE @intSourceType INT
	DECLARE @strInvoiceNo NVARCHAR(1000)
	DECLARE @strMsg NVARCHAR(MAX)
	DECLARE @ysnCancel BIT
	DECLARE @strAuditLogActionType NVARCHAR(200)
	DECLARE @ysnApproveQualitySourceType BIT

	SELECT @intPurchaseSale = intPurchaseSale
		  ,@strLoadNumber = strLoadNumber
		  ,@intSourceType = intSourceType
		  ,@ysnCancel = ISNULL(ysnCancelled, 0)
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @ysnApproveQualitySourceType = CASE WHEN ISNULL(@intSourceType,0) = 9 THEN 1 ELSE 0 END

	SELECT @ysnValidateExternalShipmentNo = ISNULL(ysnValidateExternalShipmentNo,0)
	FROM tblLGCompanyPreference 

	SELECT @ysnUnShip = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END

	SELECT @strFOBPoint = FT.strFobPoint 
	FROM tblLGLoad L
	JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId 
	WHERE intLoadId = @intLoadId

	IF ISNULL(@intSourceType,0) = 1
	BEGIN
		UPDATE tblLGLoad SET ysnPosted = @ysnPost, dtmPostedDate=ISNULL(@dtmPostedDate, GETDATE()) WHERE intLoadId = @intLoadId AND @ysnRecap = 0

		SELECT @strAuditLogActionType = CASE WHEN ISNULL(@ysnPost,0) = 1 THEN 'Posted' ELSE 'Unposted' END
		EXEC uspSMAuditLog	
				@keyValue	=	@intLoadId,
				@screenName =	'Logistics.view.ShipmentSchedule',
				@entityId	=	@intEntityUserSecurityId,
				@actionType =	@strAuditLogActionType,
				@actionIcon =	'small-tree-modified',
				@details	=	''
	END
	ELSE 
	BEGIN
		--Validate if Load has posted Weight Claim
		IF EXISTS (SELECT TOP 1 1 FROM tblLGWeightClaim WHERE intLoadId = @intLoadId AND ysnPosted = 1 AND @ysnRecap = 0)
			BEGIN
				SELECT TOP 1 @strInvoiceNo = tblLGWeightClaim.strReferenceNumber 
				FROM tblLGWeightClaim WHERE intLoadId = @intLoadId

				SET @strMsg = 'Weight Claim ' + @strInvoiceNo + ' has been created for ' + @strLoadNumber 
								+ '. Cannot unpost. Please delete the claim and try again.'

				RAISERROR (@strMsg,16,1);

				RETURN 0;
		END

		IF @intPurchaseSale = 1
		BEGIN
		
			IF ISNULL(@ysnValidateExternalShipmentNo,0) = 1 AND @ysnRecap = 0
			BEGIN
				SELECT @strExternalShipmentNumber = strExternalShipmentNumber
				FROM tblLGLoad
				WHERE intLoadId = @intLoadId

				IF(ISNULL(@strExternalShipmentNumber,'') = '')
				BEGIN
					RAISERROR('External shipment no. has not been received. Cannot continue.', 16, 1)
				END
			END
		
			IF(ISNULL(@strFOBPoint,'') = 'Origin')
				-- Skip in-transit posting for 'Approved Quality' source type
				AND @ysnApproveQualitySourceType = 0
			BEGIN		
				EXEC uspLGPostInTransitCosting 
					 @intLoadId = @intLoadId
					,@ysnPost = @ysnPost
					,@intPurchaseSale = 1
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@ysnRecap = @ysnRecap
					,@strBatchId = @strBatchId OUTPUT

				-- Increase the Inbound In-Transit Qty.
				IF (@ysnRecap = 0)
					EXEC uspLGUpdateInboundIntransitQty 
						@intLoadId = @intLoadId
						,@ysnInventorize = @ysnPost
						,@ysnUnShip = @ysnUnShip
						,@intEntityUserSecurityId = @intEntityUserSecurityId
			END
			ELSE
			BEGIN
				SELECT @strAuditLogActionType = CASE WHEN ISNULL(@ysnPost,0) = 1 THEN 'Posted' ELSE 'Unposted' END
				EXEC uspSMAuditLog	
						@keyValue	=	@intLoadId,
						@screenName =	'Logistics.view.ShipmentSchedule',
						@entityId	=	@intEntityUserSecurityId,
						@actionType =	@strAuditLogActionType,
						@actionIcon =	'small-tree-modified',
						@details	=	''
			END

			IF (@ysnRecap = 0)
			BEGIN
				IF(@ysnPost = 0)
				BEGIN
					UPDATE tblLGLoad SET intShipmentStatus = 1, ysnPosted = @ysnPost, dtmPostedDate = NULL WHERE intLoadId = @intLoadId AND @ysnCancel = 0
				END
				ELSE 
				BEGIN
					UPDATE tblLGLoad SET intShipmentStatus = 3, ysnPosted = @ysnPost, dtmPostedDate = ISNULL(@dtmPostedDate, GETDATE()) WHERE intLoadId = @intLoadId AND @ysnCancel = 0
					EXEC uspLGProcessReweighs @intLoadId, NULL, NULL
				END

				IF(ISNULL(@strFOBPoint,'') = 'Origin')
					-- Skip payables posting for 'Approved Quality' source type
					AND @ysnApproveQualitySourceType = 0
				BEGIN	
					IF (@ysnCancel = 1) 
						EXEC dbo.uspLGProcessPayables @intLoadId, NULL, 0, @intEntityUserSecurityId
					ELSE
						EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId
				END

				IF @ysnApproveQualitySourceType = 1 AND @ysnPost = 1
				BEGIN
					DECLARE
						@intLoadDetailId INT
						,@strRowState NVARCHAR(50)

					DECLARE @C AS CURSOR;
					SET @C = CURSOR FAST_FORWARD FOR
						SELECT
							intLoadDetailId
							,[strRowState] = CASE WHEN intConcurrencyId > 1 THEN 'Modified' ELSE 'Added' END
						FROM tblLGLoadDetail WHERE intLoadId = @intLoadId
					OPEN @C 
					FETCH NEXT FROM @C INTO @intLoadDetailId, @strRowState
					WHILE @@FETCH_STATUS = 0
					BEGIN
						PRINT CAST(@intLoadDetailId AS NVARCHAR(50))
						PRINT @strRowState
						EXEC uspIPProcessOrdersToFeed @intLoadId, @intLoadDetailId, @intEntityUserSecurityId, @strRowState
						FETCH NEXT FROM @C INTO @intLoadDetailId, @strRowState
					END
					CLOSE @C
					DEALLOCATE @C
				END
			END

		END
		ELSE IF @intPurchaseSale = 2
		BEGIN
			IF EXISTS (
					SELECT TOP 1 1
					FROM tblLGLoad L
					JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
					WHERE L.intLoadId = @intLoadId
					AND I.ysnReturned = 0 and I.strTransactionType NOT IN ('Credit Memo', 'Proforma Invoice')
					)
			BEGIN
				SELECT TOP 1 @strInvoiceNo = I.strInvoiceNumber
				FROM tblLGLoad L
				JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
				WHERE L.intLoadId = @intLoadId
					AND I.ysnReturned = 0 and I.strTransactionType NOT IN ('Credit Memo', 'Proforma Invoice')

				IF (@ysnRecap = 1)
					SET @strMsg = 'Invoice ' + @strInvoiceNo + ' has been generated for ' + @strLoadNumber + '. Cannot show unpost preview.';
				ELSE
					SET @strMsg = 'Invoice ' + @strInvoiceNo + ' has been generated for ' + @strLoadNumber + '. Cannot unpost. Please delete the invoice and try again.';

				RAISERROR (@strMsg,16,1);

				RETURN 0;
			END

			EXEC uspLGPostInventoryShipment 
					@ysnPost = @ysnPost
					,@strTransactionId = @strLoadNumber
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@ysnRecap = @ysnRecap
					,@strBatchId = @strBatchId OUTPUT

			IF (@ysnRecap = 0)
			BEGIN
				IF(@ysnPost = 0)
				BEGIN
					UPDATE tblLGLoad SET intShipmentStatus = 1, ysnPosted = @ysnPost, dtmPostedDate = ISNULL(@dtmPostedDate, GETDATE()) WHERE intLoadId = @intLoadId AND @ysnCancel = 0
				END

				IF(ISNULL(@strFOBPoint,'') = 'Origin')
				BEGIN	
					IF (@ysnCancel = 1) 
						EXEC dbo.uspLGProcessPayables @intLoadId, NULL, 0, @intEntityUserSecurityId
					ELSE
						EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId
				END

				--Insert Pending Claim for Outbound
				EXEC dbo.uspLGAddPendingClaim @intLoadId, 2, NULL, @ysnPost
			END
		END
		ELSE IF @intPurchaseSale = 3
		BEGIN
			--Validate if an invoice exist before unposting
			IF EXISTS (
				SELECT TOP 1 strInvoiceNo = I.strInvoiceNumber
				FROM tblLGLoad L
				JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
				WHERE L.intLoadId = @intLoadId
					AND I.ysnReturned = 0 and I.strTransactionType NOT IN ('Credit Memo', 'Proforma Invoice')
				) AND @ysnPost = 0
			BEGIN
				SELECT TOP 1 @strInvoiceNo = I.strInvoiceNumber
				FROM tblLGLoad L
				JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
				WHERE L.intLoadId = @intLoadId
				SET @strMsg = 'Invoice ' + @strInvoiceNo + ' has been generated for ' + @strLoadNumber + '. Cannot unpost. Please delete the invoice and try again.';
				RAISERROR (@strMsg,16,1);
				RETURN 0;
			END

			-- Validate if a Voucher has been created before unposting
			IF EXISTS (
				SELECT TOP 1 B.strBillId 
				FROM tblAPBillDetail BD
				INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
				WHERE intLoadId = @intLoadId
				) AND @ysnPost = 0
			BEGIN
				SELECT TOP 1 @strInvoiceNo = B.strBillId
				FROM tblAPBillDetail BD
				INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
				WHERE intLoadId = @intLoadId
				SELECT @strMsg = 'Voucher ' + @strInvoiceNo + ' has been generated for ' + @strLoadNumber + '. Cannot unpost. Please delete the voucher and try again.';
				RAISERROR (@strMsg,16,1);
				RETURN 0;
			END

			EXEC uspLGPostInTransitCosting 
				@intLoadId = @intLoadId
				,@ysnPost = @ysnPost
				,@intPurchaseSale = @intPurchaseSale
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@ysnRecap = @ysnRecap
				,@strBatchId = @strBatchId OUTPUT

			IF (@ysnRecap = 0)
			BEGIN
				-- Increase the Inbound In-Transit Qty.
				EXEC uspLGUpdateInboundIntransitQty 
					@intLoadId = @intLoadId
					,@ysnInventorize = @ysnPost
					,@ysnUnShip = @ysnUnShip
					,@intEntityUserSecurityId = @intEntityUserSecurityId

				UPDATE tblLGLoad
				SET ysnPosted = @ysnPost
					,dtmPostedDate = ISNULL(@dtmPostedDate, GETDATE())
					,intShipmentStatus = CASE 
						WHEN @ysnPost = 1
							THEN 6
						ELSE 1
						END
				WHERE intLoadId = @intLoadId
					AND @ysnCancel = 0

				UPDATE Detail
					SET dblDeliveredQuantity = CASE WHEN (@ysnPost = 1) THEN Detail.dblQuantity ELSE 0 END
						,dblDeliveredGross = CASE WHEN (@ysnPost = 1) THEN Detail.dblGross ELSE 0 END
						,dblDeliveredTare = CASE WHEN (@ysnPost = 1) THEN Detail.dblTare ELSE 0 END
						,dblDeliveredNet = CASE WHEN (@ysnPost = 1) THEN Detail.dblNet ELSE 0 END
					FROM dbo.tblLGLoadDetail Detail
						INNER JOIN dbo.tblLGLoad Header ON Detail.intLoadId = Header.intLoadId 
					WHERE Header.intLoadId = @intLoadId

				IF(ISNULL(@strFOBPoint,'') = 'Origin')
				BEGIN 
					IF (@ysnCancel = 1) 
						EXEC dbo.uspLGProcessPayables @intLoadId, NULL, 0, @intEntityUserSecurityId
					ELSE
						EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId
				END
			
				--Insert Pending Claim for Inbound and Outbound
				EXEC dbo.uspLGAddPendingClaim @intLoadId, 3, NULL, @ysnPost
			END
		END
		ELSE IF @intPurchaseSale = 4
		BEGIN
			EXEC uspLGPostInventoryTransfer 
					@ysnPost = @ysnPost
					,@strTransactionId = @strLoadNumber
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@ysnRecap = @ysnRecap
					,@strBatchId = @strBatchId OUTPUT
		END
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH