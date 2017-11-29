﻿CREATE PROCEDURE [dbo].[uspAPCreateBasisAdvance]
    @userId INT,
    @createdBasisAdvance NVARCHAR(MAX) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @billId INT;
DECLARE @billRecordNumber NVARCHAR(50);
DECLARE @voucherIds AS Id;

CREATE TABLE #tmpVoucherCreated(intBillId INT, intTicketId INT, intContractDetailId INT)

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

IF OBJECT_ID('tempdb..#tmpBillData') IS NOT NULL DROP TABLE #tmpBillData
SELECT 
    [intTermsId]			=	A.[intTermsId],
    [dtmDueDate]			=	A.[dtmDueDate],
    [dtmDate]				=	A.[dtmDate],
    [dtmBillDate]			=	A.[dtmDate],
    [intAccountId]			=	loc.[intPurchaseAdvAccount],
    [intEntityId]			=	A.[intEntityId],
    [intEntityVendorId]		=	A.[intEntityVendorId],
    [intTransactionType]	=	A.[intTransactionType],
    [strVendorOrderNumber]	=	NULL,
    [strBillId]				=	CAST('' AS NVARCHAR(50)),
    [strShipToAttention]	=	A.[strShipToAttention],
    [strShipToAddress]		=	A.[strShipToAddress],
    [strShipToCity]			=	A.[strShipToCity],
    [strShipToState]		=	A.[strShipToState],
    [strShipToZipCode]		=	A.[strShipToZipCode],
    [strShipToCountry]		=	A.[strShipToCountry],
    [strShipToPhone]		=	A.[strShipToPhone],
    [strShipFromAttention]	=	A.[strShipFromAttention],
    [strShipFromAddress]	=	A.[strShipFromAddress],
    [strShipFromCity]		=	A.[strShipFromCity],
    [strShipFromState]		=	A.[strShipFromState],
    [strShipFromZipCode]	=	A.[strShipFromZipCode],
    [strShipFromCountry]	=	A.[strShipFromCountry],
    [strShipFromPhone]		=	A.[strShipFromPhone],
    [intShipFromId]			=	A.[intShipFromId],
    [intPayToAddressId]		=	A.[intShipFromId],
    [intShipToId]			=	A.[intShipToId],
    [intStoreLocationId]	=	A.[intShipToId],
    [intShipViaId]			=	A.[intShipViaId],
    [intContactId]			=	A.[intContactId],
    [intOrderById]			=	A.[intOrderById],
    [intCurrencyId]			=	A.[intCurrencyId],
    [intTicketId]           =   basisAdvance.intTicketId,
    [intContractDetailId]   =   basisAdvance.intContractDetailId,
    [intKey]                =   ROW_NUMBER() OVER(ORDER BY (SELECT 1))
INTO #tmpBillData
FROM tblAPBasisAdvanceStaging basisStaging
INNER JOIN vyuAPBasisAdvance basisAdvance 
    ON basisStaging.intTicketId = basisAdvance.intTicketId AND basisStaging.intContractDetailId = basisAdvance.intContractDetailId
INNER JOIN tblSMCompanyLocation loc ON basisAdvance.intCompanyLocationId = loc.intCompanyLocationId
OUTER APPLY (
    SELECT 
        *
    FROM dbo.fnAPCreateBillData(
        basisAdvance.intEntityId
        ,@userId
        ,13
        ,DEFAULT
        ,DEFAULT
        ,DEFAULT
        ,basisAdvance.intShipFromId
        ,basisAdvance.intCompanyLocationId
    ) voucherData
) A
WHERE --basisAdvance.dblFuturesPrice + basisAdvance.dblUnitBasis > 0;
basisAdvance.dblAmountToAdvance > 0

--GENERATE RECORD NUMBER
DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR
    SELECT intKey FROM #tmpBillData
OPEN c;
FETCH NEXT FROM c INTO @billId

WHILE @@FETCH_STATUS = 0 
BEGIN
    EXEC uspSMGetStartingNumber 124, @billRecordNumber OUTPUT
    UPDATE A
        SET A.strBillId = @billRecordNumber
    FROM #tmpBillData A
    WHERE A.intKey = @billId
    FETCH NEXT FROM c INTO @billId
END
CLOSE c; DEALLOCATE c;

MERGE 
INTO tblAPBill
USING (SELECT * FROM #tmpBillData) AS Source
ON 1 = 0
WHEN NOT MATCHED THEN
INSERT (
    [intTermsId]			,
    [dtmDueDate]			,
    [dtmDate]				,
    [dtmBillDate]			,
    [intAccountId]			,
    [intEntityId]			,
    [intEntityVendorId]		,
    [intTransactionType]	,
    [strVendorOrderNumber]	,
    [strBillId]				,
    [strShipToAttention]	,
    [strShipToAddress]		,
    [strShipToCity]			,
    [strShipToState]		,
    [strShipToZipCode]		,
    [strShipToCountry]		,
    [strShipToPhone]		,
    [strShipFromAttention]	,
    [strShipFromAddress]	,
    [strShipFromCity]		,
    [strShipFromState]		,
    [strShipFromZipCode]	,
    [strShipFromCountry]	,
    [strShipFromPhone]		,
    [intShipFromId]			,
    [intPayToAddressId]		, 
    [intShipToId]			,
    [intStoreLocationId]	,
    [intShipViaId]			,
    [intContactId]			,
    [intOrderById]			,
    [intCurrencyId]			
)
VALUES (
    [intTermsId]			,
    [dtmDueDate]			,
    [dtmDate]				,
    [dtmBillDate]			,
    [intAccountId]			,
    [intEntityId]			,
    [intEntityVendorId]		,
    [intTransactionType]	,
    [strVendorOrderNumber]	,
    [strBillId]				,
    [strShipToAttention]	,
    [strShipToAddress]		,
    [strShipToCity]			,
    [strShipToState]		,
    [strShipToZipCode]		,
    [strShipToCountry]		,
    [strShipToPhone]		,
    [strShipFromAttention]	,
    [strShipFromAddress]	,
    [strShipFromCity]		,
    [strShipFromState]		,
    [strShipFromZipCode]	,
    [strShipFromCountry]	,
    [strShipFromPhone]		,
    [intShipFromId]			,
    [intPayToAddressId]		, 
    [intShipToId]			,
    [intStoreLocationId]	,
    [intShipViaId]			,
    [intContactId]			,
    [intOrderById]			,
    [intCurrencyId]			
)
OUTPUT inserted.intBillId, Source.intTicketId, Source.intContractDetailId INTO #tmpVoucherCreated;

IF OBJECT_ID('tempdb..#tmpBillDetailData') IS NOT NULL DROP TABLE #tmpBillDetailData
SELECT
    [intBillId]                         = voucherCreated.intBillId,
    [intPrepayTypeId]                   = 1,
    [intScaleTicketId]                  = basisAdvance.intTicketId,
    [intContractHeaderId]               = basisAdvance.intContractHeaderId,
    [intContractDetailId]               = basisAdvance.intContractDetailId,
    [intContractSeq]                    = basisAdvance.intContractSeq,
    [intItemId]                         = receiptItem.intItemId,
    -- [intInventoryReceiptItemId]         = receiptItem.intInventoryReceiptItemId,
    [dblQtyOrdered]                     = 1,--receiptItem.dblOpenReceive,
    [dblQtyReceived]                    = 1,--receiptItem.dblOpenReceive,
    [dblRate]                           = ISNULL(receiptItem.dblForexRate,1),
    [intCurrencyExchangeRateTypeId]     = receiptItem.intForexRateTypeId,
    [ysnSubCurrency]                    = receiptItem.ysnSubCurrency,
    [intTaxGroupId]                     = receiptItem.intTaxGroupId,
    [intAccountId]                      = loc.intAPAccount,
    [dblTotal]                          = basisAdvance.dblAmountToAdvance,
    [dblContractCost]                   = basisAdvance.dblFuturesPrice + basisAdvance.dblUnitBasis,
    [dblCost]                           = basisAdvance.dblAmountToAdvance,
    [dblOldCost]                        = NULL,
    [dblNetWeight]                      = 0,
    [dblWeightLoss]                     = 0,
    [intUnitOfMeasureId]                = NULL,
    [intCostUOMId]                      = NULL,
    [intWeightUOMId]                    = NULL,
    [intLineNo]                         = 1,
    [dblWeightUnitQty]                  = 0,
    [dblCostUnitQty]                    = 0,
    [dblUnitQty]                        = 0,
    [intCurrencyId]                     = NULL,
    [intStorageLocationId]              = receiptItem.intStorageLocationId,
    [int1099Form]                       = 0,
    [int1099Category]                   = 0,
    [strBillOfLading]                   = basisAdvance.strBillOfLading
INTO #tmpBillDetailData
FROM #tmpVoucherCreated voucherCreated
INNER JOIN vyuAPBasisAdvance basisAdvance 
    ON voucherCreated.intTicketId = basisAdvance.intTicketId AND voucherCreated.intContractDetailId = basisAdvance.intContractDetailId
INNER JOIN tblSMCompanyLocation loc ON basisAdvance.intCompanyLocationId = loc.intCompanyLocationId
INNER JOIN tblICInventoryReceiptItem receiptItem
    ON basisAdvance.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId


MERGE INTO tblAPBillDetail
USING (SELECT * FROM #tmpBillDetailData) AS Source
ON 1 = 0
WHEN NOT MATCHED THEN
    INSERT(
        [intBillId]                        
        ,[intPrepayTypeId]                  
        ,[intScaleTicketId]  
        ,[intContractHeaderId]
        ,[intContractDetailId]
        ,[intContractSeq]
        ,[intItemId]                        
        -- ,[intInventoryReceiptItemId]        
        ,[dblQtyOrdered]                    
        ,[dblQtyReceived]                   
        ,[dblRate]                          
        ,[intCurrencyExchangeRateTypeId]    
        ,[ysnSubCurrency]                   
        ,[intTaxGroupId]                    
        ,[intAccountId]                     
        ,[dblTotal]                         
        ,[dblCost]   
        ,[dblContractCost]
        ,[dblOldCost]                       
        ,[dblNetWeight]                     
        ,[dblWeightLoss]                    
        ,[intUnitOfMeasureId]               
        ,[intCostUOMId]                     
        ,[intWeightUOMId]                   
        ,[intLineNo]                        
        ,[dblWeightUnitQty]                 
        ,[dblCostUnitQty]                   
        ,[dblUnitQty]                       
        ,[intCurrencyId]                    
        ,[intStorageLocationId]             
        ,[int1099Form]                      
        ,[int1099Category]                  
        ,[strBillOfLading]                  
    )
    VALUES
    (
        [intBillId]                        
        ,[intPrepayTypeId]                  
        ,[intScaleTicketId]
        ,[intContractHeaderId]
        ,[intContractDetailId]      
        ,[intContractSeq]  
        ,[intItemId]                        
        -- ,[intInventoryReceiptItemId]        
        ,[dblQtyOrdered]                    
        ,[dblQtyReceived]                   
        ,[dblRate]                          
        ,[intCurrencyExchangeRateTypeId]    
        ,[ysnSubCurrency]                   
        ,[intTaxGroupId]                    
        ,[intAccountId]                     
        ,[dblTotal]                         
        ,[dblCost]     
        ,[dblContractCost]                     
        ,[dblOldCost]                       
        ,[dblNetWeight]                     
        ,[dblWeightLoss]                    
        ,[intUnitOfMeasureId]               
        ,[intCostUOMId]                     
        ,[intWeightUOMId]                   
        ,[intLineNo]                        
        ,[dblWeightUnitQty]                 
        ,[dblCostUnitQty]                   
        ,[dblUnitQty]                       
        ,[intCurrencyId]                    
        ,[intStorageLocationId]             
        ,[int1099Form]                      
        ,[int1099Category]                  
        ,[strBillOfLading]      
    );

INSERT INTO @voucherIds
SELECT intBillId FROM #tmpVoucherCreated

EXEC uspAPUpdateVoucherTotal @voucherIds

DELETE A
FROM tblAPBasisAdvanceStaging A
INNER JOIN #tmpVoucherCreated B ON A.intContractDetailId = B.intContractDetailId AND B.intTicketId = A.intTicketId

SELECT @createdBasisAdvance = COALESCE(@createdBasisAdvance + ',', '') +  CONVERT(VARCHAR(12),intBillId)
FROM #tmpVoucherCreated
ORDER BY intBillId


IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
            @ErrorNumber   INT,
            @ErrorMessage nvarchar(4000),
            @ErrorState INT,
            @ErrorLine  INT,
            @ErrorProc nvarchar(200);
        -- Grab error information from SQL functions
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorNumber   = ERROR_NUMBER()
    SET @ErrorMessage  = ERROR_MESSAGE()
    SET @ErrorState    = ERROR_STATE()
    SET @ErrorLine     = ERROR_LINE()
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Problem creating basis advance.' + CHAR(13) + 
			'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
			' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH