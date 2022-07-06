CREATE PROCEDURE [dbo].[uspGRUnpostAPClearingTransfer]
(
	@intTransferStorageId INT
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @APClearing AS APClearing;

BEGIN TRY

    DECLARE @strTransferStorageTicket VARCHAR(50);
    SELECT @strTransferStorageTicket = strTransferStorageTicket
    FROM tblGRTransferStorage
    WHERE intTransferStorageId = @intTransferStorageId

    INSERT INTO @APClearing
    (
        [intTransactionId],			--TRANSACTION ID
        [strTransactionId],			--TRANSACTION NUMBER E.G. IR-XXXX, PAT-XXXX
        [intTransactionType],		--TRANSACTION TYPE (DESIGNATED TRANSACTION NUMBERS ARE LISTED BELOW)
        [strReferenceNumber],		--TRANSACTION REFERENCE E.G. BOL NUMBER, INVOICE NUMBER
        [dtmDate],					--TRANSACTION POST DATE
        [intEntityVendorId],		--TRANSACTION VENDOR ID
        [intLocationId],			--TRANSACTION LOCATION ID
        --DETAIL
        [intTransactionDetailId],	--TRANSACTION DETAIL ID
        [intAccountId],				--TRANSACTION ACCOUNT ID
        [intItemId],				--TRANSACTION ITEM ID
        [intItemUOMId],				--TRANSACTION ITEM UOM ID
        [dblQuantity],				--TRANSACTION QUANTITY (WE CAN DIRECTLY PUT THE QUANTITY OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
        [dblAmount],				--TRANSACTION TOTAL (WE CAN DIRECTLY PUT THE AMOUNT OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
        --OFFSET TRANSACTION DETAILS
        [intOffsetId],				--TRANSACTION ID
        [strOffsetId],				--TRANSACTION NUMBER E.G. BL-XXXX
        [intOffsetDetailId],		--TRANSACTION DETAIL ID
        [intOffsetDetailTaxId],		--TRANSACTION DETAIL TAX ID
        --OTHER INFORMATION
        [strCode]					--TRANSACTION SOURCE MODULE E.G. IR, AP
    )
    -- APC Entries for Item
    SELECT
        [intTransactionId],			--TRANSACTION ID
        [strTransactionId],			--TRANSACTION NUMBER E.G. IR-XXXX, PAT-XXXX
        [intTransactionType],		--TRANSACTION TYPE (DESIGNATED TRANSACTION NUMBERS ARE LISTED BELOW)
        [strReferenceNumber],		--TRANSACTION REFERENCE E.G. BOL NUMBER, INVOICE NUMBER
        [dtmDate],					--TRANSACTION POST DATE
        [intEntityVendorId],		--TRANSACTION VENDOR ID
        [intLocationId],			--TRANSACTION LOCATION ID
        --DETAIL
        [intTransactionDetailId],	--TRANSACTION DETAIL ID
        [intAccountId],				--TRANSACTION ACCOUNT ID
        [intItemId],				--TRANSACTION ITEM ID
        [intItemUOMId],				--TRANSACTION ITEM UOM ID
        [dblQuantity],				--TRANSACTION QUANTITY (WE CAN DIRECTLY PUT THE QUANTITY OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
        [dblAmount],				--TRANSACTION TOTAL (WE CAN DIRECTLY PUT THE AMOUNT OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
        --OFFSET TRANSACTION DETAILS
        [intOffsetId],				--TRANSACTION ID
        [strOffsetId],				--TRANSACTION NUMBER E.G. BL-XXXX
        [intOffsetDetailId],		--TRANSACTION DETAIL ID
        [intOffsetDetailTaxId],		--TRANSACTION DETAIL TAX ID
        --OTHER INFORMATION
        [strCode]					--TRANSACTION SOURCE MODULE E.G. IR, AP
    FROM tblAPClearing
    WHERE
        (intTransactionId = @intTransferStorageId
            AND strTransactionId = @strTransferStorageTicket)
    OR
        (intOffsetId = @intTransferStorageId
            AND strOffsetId = @strTransferStorageTicket)
    
    EXEC uspAPClearing @APClearing = @APClearing, @post = 0;

END TRY

BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT,
	@ErrorNumber INT
	-- Grab error information from SQL functions
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH