CREATE PROCEDURE [dbo].[uspGRBookAPClearingTransferToOS]
(
	@intTransferStorageReferenceId INT
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @APClearing AS APClearing;

BEGIN TRY
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
    -- APC Offset Entries for Item
    -- DP (From Ticket IR) to OS
    SELECT
        -- HEADER
        [intTransactionId]          = IR.intInventoryReceiptId
        ,[strTransactionId]         = IR.strReceiptNumber
        ,[intTransactionType]       = 1 -- Receipt (Source Transaction)
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_FROM.intEntityId
        ,[intLocationId]            = CS_FROM.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = IRI.intInventoryReceiptItemId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = TS.intItemId
        ,[intItemUOMId]             = TS.intItemUOMId
        ,[dblQuantity]              = TSR.dblUnitQty * -1
        ,[dblAmount]                = (CS_FROM.dblSettlementPrice + CS_FROM.dblBasis) * TSR.dblUnitQty * -1
        -- OFFSET TRANSACTION
        ,[intOffsetId]				= TS.intTransferStorageId
        ,[strOffsetId]				= TS.strTransferStorageTicket
        ,[intOffsetDetailId]		= TSR.intTransferStorageReferenceId
        ,[intOffsetDetailTaxId]		= NULL
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.ysnTransferStorage = 0
        AND CS_FROM.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    INNER JOIN tblGRStorageHistory SH
        ON SH.intCustomerStorageId = CS_FROM.intCustomerStorageId
    INNER JOIN tblICInventoryReceipt IR
        ON IR.intInventoryReceiptId = SH.intInventoryReceiptId
    INNER JOIN tblICInventoryReceiptItem IRI
        ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
        AND IRI.intItemId = CS_FROM.intItemId
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(TS.intItemId, CS_FROM.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
        AND IR.ysnPosted = 1

    -- APC Offset Entries for Discounts
    -- DP (From Ticket IR) to OS
    UNION ALL
    SELECT
        -- HEADER
        [intTransactionId]          = IR.intInventoryReceiptId
        ,[strTransactionId]         = IR.strReceiptNumber
        ,[intTransactionType]       = 2 -- Receipt Charges (Source Transaction)
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_FROM.intEntityId
        ,[intLocationId]            = CS_FROM.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = IRC.intInventoryReceiptChargeId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = IRC.intChargeId
        ,[intItemUOMId]             = IRC.intCostUOMId
        ,[dblQuantity]              = (CASE IRC.strCostMethod WHEN 'Amount' THEN 1 ELSE TSR.dblUnitQty END)
                                        * (CASE IRC.ysnPrice WHEN 1 THEN 1 ELSE -1 END)
        ,[dblAmount]                = (CASE IRC.strCostMethod
                                            WHEN 'Amount' THEN ((ISNULL(IRC.dblAmount, 0) / ISNULL(IRI.dblNet, 0)) * TSR.dblUnitQty)
                                            WHEN 'Per Unit' THEN (TSR.dblUnitQty * ISNULL(IRC.dblRate, 0))
                                            ELSE ((ISNULL(IRC.dblAmount, 0) / ISNULL(IRI.dblNet, 0)) * TSR.dblUnitQty)
                                        END
                                        + ISNULL(IRC.dblTax, 0)
                                        )
                                        * (CASE IRC.ysnPrice WHEN 1 THEN 1 ELSE -1 END)
        -- OFFSET TRANSACTION
        ,[intOffsetId]				= TS.intTransferStorageId
        ,[strOffsetId]				= TS.strTransferStorageTicket
        ,[intOffsetDetailId]		= TSR.intTransferStorageReferenceId
        ,[intOffsetDetailTaxId]		= NULL
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.ysnTransferStorage = 0
        AND CS_FROM.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    INNER JOIN tblGRStorageHistory SH
        ON SH.intCustomerStorageId = CS_FROM.intCustomerStorageId
    INNER JOIN tblICInventoryReceipt IR
        ON IR.intInventoryReceiptId = SH.intInventoryReceiptId
    INNER JOIN tblICInventoryReceiptItem IRI
        ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
    INNER JOIN tblICInventoryReceiptCharge IRC
        ON IRC.intInventoryReceiptId = IR.intInventoryReceiptId
        AND IRC.strChargesLink = IRI.strChargesLink
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(IRC.intChargeId, CS_FROM.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
        AND IR.ysnPosted = 1

    -- APC Offset Entries for Item
    -- DP (from transfer) to OS
    UNION ALL
    SELECT
        -- HEADER
        [intTransactionId]          = TS_SOURCE.intTransferStorageId
        ,[strTransactionId]         = TS_SOURCE.strTransferStorageTicket
        ,[intTransactionType]       = 7 --TRANSFER ITEM
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_FROM.intEntityId
        ,[intLocationId]            = CS_FROM.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = TSR_SOURCE.intTransferStorageReferenceId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = TS.intItemId
        ,[intItemUOMId]             = TS.intItemUOMId
        ,[dblQuantity]              = TSR.dblUnitQty * -1
        ,[dblAmount]                = (CS_FROM.dblSettlementPrice + CS_FROM.dblBasis) * TSR.dblUnitQty * -1
        -- OFFSET TRANSACTION
        ,[intOffsetId]				= TS.intTransferStorageId
        ,[strOffsetId]				= TS.strTransferStorageTicket
        ,[intOffsetDetailId]		= TSR.intTransferStorageReferenceId
        ,[intOffsetDetailTaxId]		= NULL
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.ysnTransferStorage = 1 -- Only get DP receipts from transfer storage
        AND CS_FROM.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    INNER JOIN tblGRTransferStorageReference TSR_SOURCE
        ON TSR_SOURCE.intToCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRTransferStorage TS_SOURCE
        ON TS_SOURCE.intTransferStorageId = TSR_SOURCE.intTransferStorageId
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(TS.intItemId, CS_FROM.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId

    -- APC Offset Entries for Discount
    -- DP (from transfer) to OS
    UNION ALL
    SELECT
        -- HEADER
        [intTransactionId]          = TS_SOURCE.intTransferStorageId
        ,[strTransactionId]         = TS_SOURCE.strTransferStorageTicket
        ,[intTransactionType]       = 8 --TRANSFER CHARGES
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_FROM.intEntityId
        ,[intLocationId]            = CS_FROM.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = TSR_SOURCE.intTransferStorageReferenceId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = DSC.intItemId
        ,[intItemUOMId]             = ISNULL(IUOM_DISC.intItemUOMId, IUOM_ITEM.intItemUOMId)
        ,[dblQuantity]              = (CASE ITEM.strCostMethod
                                        WHEN 'Amount' THEN 1
                                        ELSE
                                            (CASE WHEN QM.strCalcMethod = 3
                                            THEN CS_TO.dblGrossQuantity * ( TSR.dblUnitQty / CS_TO.dblOriginalBalance)
                                            ELSE TSR.dblUnitQty
                                            END)
                                        END)
                                        * (CASE WHEN QM.dblDiscountAmount > 0 THEN 1 ELSE -1 END)
        ,[dblAmount]                =   -- Amount
                                        (CASE QM.strDiscountChargeType
                                        WHEN 'Percent'
                                            THEN QM.dblDiscountAmount * (CS_TO.dblBasis + CS_TO.dblSettlementPrice)
                                        WHEN 'Dollar'
                                            THEN QM.dblDiscountAmount
                                        END)
                                        *
                                        -- Qty
                                        (CASE WHEN QM.strCalcMethod = 3
                                        THEN CS_TO.dblGrossQuantity * ( TSR.dblUnitQty / CS_TO.dblOriginalBalance)
                                        ELSE TSR.dblUnitQty
                                        END) * (CASE WHEN QM.dblDiscountAmount > 0 THEN 1 ELSE -1 END)
        -- OFFSET TRANSACTION
        ,[intOffsetId]				= TS.intTransferStorageId
        ,[strOffsetId]				= TS.strTransferStorageTicket
        ,[intOffsetDetailId]		= TSR.intTransferStorageReferenceId
        ,[intOffsetDetailTaxId]		= NULL
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.ysnTransferStorage = 1 -- Only get DP receipts from transfer storage
        AND CS_FROM.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    INNER JOIN tblGRTransferStorageReference TSR_SOURCE
        ON TSR_SOURCE.intToCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRTransferStorage TS_SOURCE
        ON TS_SOURCE.intTransferStorageId = TSR_SOURCE.intTransferStorageId
    --Discounts
    INNER JOIN tblQMTicketDiscount QM
        ON QM.intTicketFileId = CS_TO.intCustomerStorageId
        AND QM.strSourceType = 'Storage'
    INNER JOIN tblGRDiscountScheduleCode DSC
        ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
    INNER JOIN tblICItem ITEM
        ON ITEM.intItemId = DSC.intItemId
    LEFT JOIN tblICItemUOM IUOM_DISC
        ON IUOM_DISC.intItemId = DSC.intItemId
        AND IUOM_DISC.intUnitMeasureId = DSC.intUnitMeasureId
    LEFT JOIN tblICItemUOM IUOM_ITEM
        ON IUOM_ITEM.intItemId = DSC.intItemId
        AND IUOM_ITEM.ysnStockUnit = 1
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(DSC.intItemId, CS_FROM.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
        AND ISNULL(QM.dblDiscountAmount, 0) <> 0

    -- APC Offset Entries for Item
    -- DP (From Delivery Sheet) to OS
    UNION ALL
    SELECT
        -- HEADER
        [intTransactionId]          = IR.intInventoryReceiptId
        ,[strTransactionId]         = IR.strReceiptNumber
        ,[intTransactionType]       = 1 -- Receipt (Source Transaction)
        ,[strReferenceNumber]       = DS.strDeliverySheetNumber
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_FROM.intEntityId
        ,[intLocationId]            = CS_FROM.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = IRI.intInventoryReceiptItemId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = TS.intItemId
        ,[intItemUOMId]             = TS.intItemUOMId
        ,[dblQuantity]              = SIR.dblTransactionUnits * -1
        ,[dblAmount]                = (CS_FROM.dblSettlementPrice + CS_FROM.dblBasis) * SIR.dblTransactionUnits * -1
        -- OFFSET TRANSACTION
        ,[intOffsetId]				= TS.intTransferStorageId
        ,[strOffsetId]				= TS.strTransferStorageTicket
        ,[intOffsetDetailId]		= TSR.intTransferStorageReferenceId
        ,[intOffsetDetailTaxId]		= NULL
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.ysnTransferStorage = 0
        AND CS_FROM.intDeliverySheetId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    INNER JOIN tblSCDeliverySheet DS
        ON CS_FROM.intDeliverySheetId = DS.intDeliverySheetId
    INNER JOIN tblGRStorageInventoryReceipt SIR
        ON SIR.intTransferStorageReferenceId = TSR.intTransferStorageReferenceId
    INNER JOIN tblICInventoryReceipt IR
        ON IR.intInventoryReceiptId = SIR.intInventoryReceiptId
    INNER JOIN tblICInventoryReceiptItem IRI
        ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
        AND IRI.intInventoryReceiptItemId = SIR.intInventoryReceiptItemId
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(TS.intItemId, CS_FROM.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
        AND DS.ysnPost = 1

    -- APC Offset Entries for Fees
    -- DP (Both IR and transfer) to OS
    UNION ALL
    SELECT
        -- HEADER
        [intTransactionId]          = CASE CS_FROM.ysnTransferStorage
                                        WHEN 1 THEN TS_SOURCE.intTransferStorageId -- Source came from transfer storage
                                        ELSE IR.intInventoryReceiptId -- Source came from IR charges
                                      END
        ,[strTransactionId]         = CASE CS_FROM.ysnTransferStorage
                                        WHEN 1 THEN TS_SOURCE.strTransferStorageTicket -- Source came from transfer storage
                                        ELSE IR.strReceiptNumber -- Source came from IR charges
                                      END
        ,[intTransactionType]       = CASE CS_FROM.ysnTransferStorage
                                        WHEN 1 THEN 8 -- Source came from transfer storage
                                        ELSE 2 -- Source came from IR charges
                                      END
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_FROM.intEntityId
        ,[intLocationId]            = CS_FROM.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = CASE CS_FROM.ysnTransferStorage
                                        WHEN 1 THEN TSR_SOURCE.intTransferStorageReferenceId -- Source came from transfer storage
                                        ELSE IRC.intInventoryReceiptChargeId -- Source came from IR charges
                                      END
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = IRC.intChargeId
        ,[intItemUOMId]             = IRC.intCostUOMId
        ,[dblQuantity]              = (CASE IRC.strCostMethod WHEN 'Amount' THEN 1 ELSE TSR.dblUnitQty END)
                                        * (CASE WHEN IRC.ysnPrice = 1 THEN 1 ELSE -1 END)
        ,[dblAmount]                = (((IRC.dblAmount / IRI.dblNet) * TSR.dblUnitQty) + IRC.dblTax)
                                        * (CASE WHEN IRC.ysnPrice = 1 THEN 1 ELSE -1 END)
        -- OFFSET TRANSACTION
        ,[intOffsetId]				= TS.intTransferStorageId
        ,[strOffsetId]				= TS.strTransferStorageTicket
        ,[intOffsetDetailId]		= TSR.intTransferStorageReferenceId
        ,[intOffsetDetailTaxId]		= NULL
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.intTicketId IS NOT NULL
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    INNER JOIN tblGRTransferStorageReference TSR_SOURCE
        ON TSR_SOURCE.intToCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRTransferStorage TS_SOURCE
        ON TS_SOURCE.intTransferStorageId = TSR_SOURCE.intTransferStorageId
    -- Ticket Fees
    INNER JOIN tblSCTicket SC
		ON SC.intTicketId = CS_FROM.intTicketId
	INNER JOIN tblSCScaleSetup SCS
		ON SCS.intScaleSetupId = SC.intScaleSetupId
	INNER JOIN tblICInventoryReceiptItem IRI
		ON IRI.intSourceId = SC.intTicketId
	INNER JOIN tblICInventoryReceipt IR
		ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		AND IR.intSourceType IN (1, 7) -- Scale Ticket
		AND IR.intEntityVendorId = SC.intEntityId
	INNER JOIN tblICInventoryReceiptCharge IRC
		ON IRC.intInventoryReceiptId = IR.intInventoryReceiptId
		AND IRC.strChargesLink = IRI.strChargesLink
        AND IRC.intChargeId = ISNULL(SCS.intDefaultFeeItemId, IRC.intChargeId)
    INNER JOIN vyuICGetCompactItem CI
		ON CI.intItemId = IRC.intChargeId	
		AND CI.strType = 'Other Charge'
		AND CI.strCostType IS NOT NULL
		AND CI.strCostType NOT IN ('Grain Discount', 'Storage Charge')
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(IRC.intChargeId, CS_FROM.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
        AND ISNULL(IRC.dblAmount, 0) <> 0

    -- SELECT * FROM @APClearing;
    EXEC uspAPClearing @APClearing = @APClearing, @post = 1;

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