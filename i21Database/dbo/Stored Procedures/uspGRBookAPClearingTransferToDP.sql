CREATE PROCEDURE [dbo].[uspGRBookAPClearingTransferToDP]
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
        --OTHER INFORMATION
        [strCode]					--TRANSACTION SOURCE MODULE E.G. IR, AP
    )
    -- APC Entries for Item
    SELECT
        -- HEADER
        [intTransactionId]          = TS.intTransferStorageId
        ,[strTransactionId]         = TS.strTransferStorageTicket
        ,[intTransactionType]       = 7 --TRANSFER ITEM
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_TO.intEntityId
        ,[intLocationId]            = CS_TO.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = TSR.intTransferStorageReferenceId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = TS.intItemId
        ,[intItemUOMId]             = TS.intItemUOMId
        ,[dblQuantity]              = TSR.dblUnitQty
        ,[dblAmount]                = (CS_TO.dblSettlementPrice + CS_TO.dblBasis) * TSR.dblUnitQty
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(TS.intItemId, CS_TO.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId

    -- APC Entries for Discounts
    UNION ALL
    SELECT
        -- HEADER
        [intTransactionId]          = TS.intTransferStorageId
        ,[strTransactionId]         = TS.strTransferStorageTicket
        ,[intTransactionType]       = 8 --TRANSFER CHARGE
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_TO.intEntityId
        ,[intLocationId]            = CS_TO.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = TSR.intTransferStorageReferenceId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = DSC.intItemId
        ,[intItemUOMId]             = ISNULL(IUOM_DISC.intItemUOMId, IUOM_ITEM.intItemUOMId)
        ,[dblQuantity]              = (CASE ITEM.strCostMethod
                                        WHEN 'Amount' THEN 1
                                        ELSE
                                            (CASE WHEN QM.strCalcMethod = '3'
                                            THEN CS_TO.dblGrossQuantity * (TSR.dblUnitQty / CS_TO.dblOriginalBalance)
                                            ELSE TSR.dblUnitQty
                                            END)
                                        END)
                                        * (CASE WHEN QM.dblDiscountAmount > 0 THEN 1 ELSE -1 END) * -1
        ,[dblAmount]                = -- Amount
                                        (CASE QM.strDiscountChargeType
                                        WHEN 'Percent'
                                            THEN QM.dblDiscountAmount * (CS_TO.dblBasis + CS_TO.dblSettlementPrice)
                                        WHEN 'Dollar'
                                            THEN QM.dblDiscountAmount
                                        END)
                                        *
                                        -- Qty
                                        (CASE WHEN QM.strCalcMethod = '3'
                                        THEN CS_TO.dblGrossQuantity * (TSR.dblUnitQty / CS_TO.dblOriginalBalance)
                                        ELSE TSR.dblUnitQty
                                        END)
                                        * (CASE WHEN QM.dblDiscountAmount > 0 THEN 1 ELSE -1 END) * -1
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.intDeliverySheetId IS NULL -- This will exclude discounts (if any) from delivery sheets.
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    --Discounts
    INNER JOIN tblQMTicketDiscount QM
        ON QM.intTicketFileId = CS_FROM.intCustomerStorageId
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
    -- APC Account ID
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(DSC.intItemId, CS_TO.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
        AND QM.dblDiscountAmount <> 0
    
    -- APC Entries for Fees
    UNION ALL
    SELECT
        -- HEADER
        [intTransactionId]          = TS.intTransferStorageId
        ,[strTransactionId]         = TS.strTransferStorageTicket
        ,[intTransactionType]       = 8 --TRANSFER CHARGE
        ,[strReferenceNumber]       = ''
        ,[dtmDate]                  = TS.dtmTransferStorageDate
        ,[intEntityVendorId]        = CS_TO.intEntityId
        ,[intLocationId]            = CS_TO.intCompanyLocationId
        -- DETAIL
        ,[intTransactionDetailId]   = TSR.intTransferStorageReferenceId
        ,[intAccountId]             = APC.intAccountId
        ,[intItemId]                = IRC.intChargeId
        ,[intItemUOMId]             = IRC.intCostUOMId
        ,[dblQuantity]              = (CASE IRC.strCostMethod WHEN 'Amount' THEN 1 ELSE TSR.dblUnitQty END)
                                        * (CASE WHEN IRC.ysnPrice = 1 THEN -1 ELSE 1 END)
        ,[dblAmount]                = (((IRC.dblAmount / IRI.dblNet) * TSR.dblUnitQty) + IRC.dblTax)
                                        * (CASE WHEN IRC.ysnPrice = 1 THEN -1 ELSE 1 END)
        ,[strCode]                  = 'TRA'
    FROM tblGRTransferStorageReference TSR
    INNER JOIN tblGRTransferStorage TS
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        AND CS_FROM.intDeliverySheetId IS NULL -- This will exclude discounts (if any) from delivery sheets.
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage  CS_TO
        ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    -- Fees from Ticket
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
    -- APC Account ID
    OUTER APPLY (
        SELECT [intAccountId] = dbo.fnGetItemGLAccount(IRC.intChargeId, CS_TO.intCompanyLocationId, 'AP Clearing')
    ) APC
    WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
        AND IRC.dblAmount <> 0

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