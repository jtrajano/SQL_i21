CREATE PROCEDURE [dbo].[uspAPCreateBasisAdvance]
    @userId INT
AS

DECLARE @billId INT;
DECLARE @billRecordNumber NVARCHAR(50);
CREATE TABLE #tmpVoucherCreated(intBillId INT, intTicketId INT, intContractDetailId INT)

IF OBJECT_ID('tempdb..#tmpBillData') IS NOT NULL DROP TABLE #tmpBillData
SELECT 
    [intTermsId]			=	A.[intTermsId],
    [dtmDueDate]			=	A.[dtmDueDate],
    [dtmDate]				=	A.[dtmDate],
    [dtmBillDate]			=	A.[dtmDate],
    [intAccountId]			=	A.[intAccountId],
    [intEntityId]			=	A.[intEntityId],
    [intEntityVendorId]		=	A.[intEntityVendorId],
    [intTransactionType]	=	A.[intTransactionType],
    [strVendorOrderNumber]	=	NULL,
    [strBillId]				=	NULL,
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
    [intCurrencyId]			=	A.[intCurrencyId]
INTO #tmpBillData
FROM tblAPBasisAdvanceStaging basisStaging
INNER JOIN vyuAPBasisAdvance basisAdvance ON basisStaging.intTicketId = basisAdvance.intTicketId
CROSS APPLY (
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


--GENERATE RECORD NUMBER
DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR
    SELECT intBillId FROM #tmpBillData
OPEN c;
FETCH c INTO @billId
WHILE @@FETCH_STATUS = 0 
BEGIN
    EXEC uspSMGetStartingNumber 124, @billRecordNumber OUTPUT
    UPDATE A
        SET A.strBillId = @billRecordNumber
    FROM #tmpBillData A
    WHERE A.intBillId = @billId
    FETCH c INTO @billId
END
CLOSE c; DEALLOCATE c;

INSERT INTO tblAPBill
(
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
OUTPUT inserted.intBillId, #tmpBillData.intTicketId, #tmpBillData.intContractDetailId INTO #tmpVoucherCreated
SELECT * FROM #tmpBillData

IF OBJECT_ID('tempdb..#tmpBillDetailData') IS NOT NULL DROP TABLE #tmpBillDetailData
SELECT
    [intBillId]                         = voucherCreated.intBillId,
    [intItemId]                         = basisAdvance.intItemId,
    [intInventoryReceiptItemId]         = basis.intInventoryReceiptItemId,
    [dblQtyOrdered]                     = ,
    [dblQtyReceived]                    =,
    [dblRate]                           =,
    [intCurrencyExchangeRateTypeId]     =,
    [ysnSubCurrency]                    =,
    [intTaxGroupId]                     =,
    [intAccountId]                      =,
    [dblTotal]                          =,
    [dblCost]                           =,
    [dblOldCost]                        =,
    [dblNetWeight]                      =,
    [dblWeightLoss]                     =,
    [intUnitOfMeasureId]                =,
    [intCostUOMId]                      =,
    [intWeightUOMId]                    =,
    [intLineNo]                         =,
    [dblWeightUnitQty]                  =,
    [dblCostUnitQty]                    =,
    [dblUnitQty]                        =,
    [intCurrencyId]                     =,
    [intStorageLocationId]              =,
    [int1099Form]                       =,
    [int1099Category]                   =,
    [strBillOfLading]
INTO #tmpBillDetailData
FROM #tmpVoucherCreated voucherCreated
INNER JOIN vyuAPBasisAdvance basisAdvance 
    ON voucherCreated.intTicketId = basisAdvance.intTicketId AND voucherCreated.intContractDetailId = basisAdvance.intContractDetailId


