CREATE PROCEDURE [dbo].[uspTRLoadProcessToInvoice]
	 @intLoadHeaderId AS INT
	, @intUserId AS INT	
	, @ysnRecap AS BIT
	, @ysnPostOrUnPost AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId INT; 
DECLARE @ErrMsg NVARCHAR(MAX);

DECLARE @InvoiceStagingTable InvoiceStagingTable,
        @strReceiptLink NVARCHAR(100),
		@strBOL NVARCHAR(50),
        @total INT;

DECLARE @InvoiceOutputTable TABLE (
	intId INT IDENTITY PRIMARY KEY CLUSTERED
	, intSourceId INT
	, intInvoiceId INT )
DECLARE @InvoicePostOutputTable TABLE (
	intId INT IDENTITY PRIMARY KEY CLUSTERED
	, intInvoiceId INT )

BEGIN TRY

	IF @ysnPostOrUnPost = 0 AND @ysnRecap = 0
	BEGIN
		INSERT INTO @InvoiceOutputTable
		SELECT DH.intLoadDistributionHeaderId
			, DH.intInvoiceId
		FROM tblTRLoadDistributionHeader DH
		WHERE DH.intLoadHeaderId = @intLoadHeaderId
			AND DH.strDestination = 'Customer'
			AND ISNULL(DH.intInvoiceId,0) != 0
		
		SELECT @total = COUNT(*) FROM @InvoiceOutputTable;
		IF (@total = 0)
			BEGIN
				RETURN
			END
		ELSE
			BEGIN
				GOTO _PostOrUnPost
			END
	END
	
	-- Insert Entries to Stagging table that needs to processed to Transport Load
	INSERT into @InvoiceStagingTable(
		intEntityCustomerId
		, intLocationId
		, intItemId
		, intItemUOMId
		, dtmDate
		, intContractDetailId
		, intShipViaId
		, intSalesPersonId
		, dblQty
		, dblPrice
		, intCurrencyId
		, dblExchangeRate
		, dblFreightRate
		, strComments
		, strSourceId
		, intSourceId
		, strPurchaseOrder
		, strDeliverPickup
		, dblSurcharge
		, ysnFreightInPrice
		, intTaxGroupId
		, strActualCostId
		, intShipToLocationId
		, strBOLNumber
		, intInvoiceId
		, strSourceScreenName
		)
	SELECT
		MIN(DH.intEntityCustomerId)
		, MIN(DH.intCompanyLocationId)
		, MIN(DD.intItemId)
		, intItemUOMId = (CASE WHEN MIN(DD.intContractDetailId) IS NULL THEN MIN(IC.intIssueUOMId)
							WHEN MIN(DD.intContractDetailId) IS NOT NULL THEN (SELECT TOP 1 intItemUOMId FROM vyuCTContractDetailView CT WHERE CT.intContractDetailId = MIN(DD.intContractDetailId))
						END)
		, MIN(DH.dtmInvoiceDateTime)
		, MIN(DD.intContractDetailId)
		, MIN(TL.intShipViaId)
		, MIN(DH.intEntitySalespersonId)
		, MIN(DD.dblUnits)
		, MIN(DD.dblPrice)
		, intCurrencyId = (SELECT TOP 1 CP.intDefaultCurrencyId
							FROM dbo.tblSMCompanyPreference CP
							WHERE CP.intCompanyPreferenceId = 1) -- USD default from company Preference
		, 1 -- Need to check this
		, MIN(DD.dblFreightRate)
		, strComments = (CASE WHEN MIN(TR.intSupplyPointId) IS NULL AND MIN(TL.intLoadId) IS NULL THEN RTRIM(MIN(DH.strComments))
							WHEN MIN(TR.intSupplyPointId) IS NOT NULL AND MIN(TL.intLoadId) IS NULL THEN 'Origin:' + RTRIM(MIN(ee.strSupplyPoint)) + ' ' + RTRIM(MIN(DH.strComments))
							WHEN (MIN(TR.intSupplyPointId)) IS NULL AND MIN(TL.intLoadId) IS NOT NULL THEN 'Load #:' + RTRIM(MIN(LG.strExternalLoadNumber)) + ' ' + RTRIM(MIN(DH.strComments))
							WHEN (MIN(TR.intSupplyPointId)) IS NOT NULL AND MIN(TL.intLoadId) IS NOT NULL THEN 'Origin:' + RTRIM(MIN(ee.strSupplyPoint))  + ' Load #:' + RTRIM(MIN(LG.strExternalLoadNumber)) + ' ' + RTRIM(MIN(DH.strComments))
						END)
		, MIN(TL.strTransaction)
		, MIN(DH.intLoadDistributionHeaderId)
		, MIN(DH.strPurchaseOrder)
		, 'Deliver'
		, MIN(DD.dblDistSurcharge)
		, CAST(MIN(CAST(DD.ysnFreightInPrice AS INT)) AS BIT)
		, MIN(DD.intTaxGroupId)
		, strActualCostId = (CASE WHEN MIN(TR.strOrigin) = 'Terminal' AND MIN(DH.strDestination) = 'Customer' THEN MIN(TL.strTransaction)
								ELSE NULL END)
		, MIN(DH.intShipToLocationId)
		, NULL
		, MIN(DH.intInvoiceId)
		, 'Transport Loads'
	FROM dbo.tblTRLoadHeader TL
		JOIN dbo.tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
		JOIN dbo.tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
		LEFT JOIN dbo.vyuLGLoadView LG ON LG.intLoadId = TL.intLoadId
		LEFT JOIN dbo.vyuICGetItemStock IC ON IC.intItemId = DD.intItemId AND IC.intLocationId = DH.intCompanyLocationId
		LEFT JOIN dbo.tblTRLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId AND TR.strReceiptLine IN (SELECT Item FROM dbo.fnTRSplit(DD.strReceiptLink,','))
		LEFT JOIN ( SELECT DISTINCT intLoadDistributionDetailId
						, STUFF(( SELECT DISTINCT ', ' + CD.strSupplyPoint
									FROM dbo.vyuTRLinkedReceipts CD
									WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
										AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
									FOR XML PATH('')), 1, 2, '') strSupplyPoint
					FROM dbo.vyuTRLinkedReceipts CH) ee ON ee.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
	WHERE TL.intLoadHeaderId = @intLoadHeaderId
		AND DH.strDestination = 'Customer'
	GROUP BY DH.intLoadDistributionHeaderId
		, DD.intLoadDistributionDetailId
	
	--No Records to process so exit
	SELECT @total = COUNT(*) FROM @InvoiceStagingTable
	IF (@total = 0)
		RETURN;

	EXEC dbo.uspARAddInvoice @InvoiceStagingTable, @intUserId;

	INSERT INTO @InvoiceOutputTable
	SELECT IE.intSourceId
		, IV.intInvoiceId
	FROM @InvoiceStagingTable IE
		JOIN tblARInvoice IV ON IE.intSourceId = IV.intLoadDistributionHeaderId

_PostOrUnPost:
	
	DECLARE @incval INT
		, @SouceId INT
		, @InvoiceId INT;
		
	DECLARE @minId INT = 0
		, @maxId INT
		, @SuccessCount INT
		, @InvCount INT
		, @IsSuccess BIT
		, @batchId NVARCHAR(20);
	
	SET @incval = 1
	WHILE @incval <= @total
	BEGIN
		SELECT @SouceId = intSourceId
			, @InvoiceId = intInvoiceId
		FROM @InvoiceOutputTable
		WHERE @incval = intId
		
		UPDATE tblTRLoadDistributionHeader
		SET intInvoiceId = @InvoiceId
		WHERE @SouceId = intLoadDistributionHeaderId 
		
		SET @strReceiptLink = (SELECT dbo.fnTRConcatString('', @InvoiceId, ',', 'strReceiptLink'))
		SET @strBOL = (SELECT dbo.fnTRConcatString(@strReceiptLink, @intLoadHeaderId, ',', 'strBillOfLading'))
		
		UPDATE tblARInvoice
		SET strBOLNumber = @strBOL
		WHERE intInvoiceId = @InvoiceId
		
		SET @incval += 1;
	END;
	
	IF @ysnRecap = 0
	BEGIN
		IF (@ysnPostOrUnPost = 0 AND @ysnRecap = 0)
		BEGIN
			INSERT INTO @InvoicePostOutputTable
			SELECT DISTINCT DH.intInvoiceId
			FROM tblTRLoadDistributionHeader DH
			WHERE DH.intLoadHeaderId = @intLoadHeaderId
				AND DH.strDestination = 'Customer'
				AND ISNULL(DH.intInvoiceId,0) != 0
		END
		ELSE
		BEGIN
			INSERT INTO @InvoicePostOutputTable
			SELECT DISTINCT IV.intInvoiceId
			FROM @InvoiceStagingTable IE
				JOIN tblARInvoice IV ON IE.intSourceId = IV.intLoadDistributionHeaderId
		END
		
		SELECT @total = COUNT(*) FROM @InvoicePostOutputTable;
		SET @incval = 1
		WHILE (@incval <= @total)
		BEGIN
			SELECT @InvoiceId = intInvoiceId
			FROM @InvoicePostOutputTable
			WHERE @incval = intId
			
			EXEC [dbo].[uspARPostInvoice]
					@batchId = NULL
					, @post = @ysnPostOrUnPost
					, @recap = 0
					, @param = NULL
					, @userId = @intUserId
					, @beginDate = NULL
					, @endDate = NULL
					, @beginTransaction = @InvoiceId
					, @endTransaction = @InvoiceId
					, @exclude = NULL
					, @successfulCount = @SuccessCount OUTPUT
					, @invalidCount = @InvCount OUTPUT
					, @success = @IsSuccess OUTPUT
					, @batchIdUsed = @batchId OUTPUT
					, @recapId = NULL
					, @transType = N'Invoice'
					, @raiseError = 1
			
			IF @IsSuccess = 0
			BEGIN
				RAISERROR('Invoice did not Post/UnPost', 16, 1);
			END
			
			SET @incval += 1;
		END;
		
		--Post the invoice that was created
	END

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH