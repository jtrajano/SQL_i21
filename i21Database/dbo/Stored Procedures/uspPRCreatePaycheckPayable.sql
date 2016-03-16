﻿CREATE PROCEDURE [dbo].[uspPRCreatePaycheckPayable]
	@intPaycheckIds NVARCHAR(MAX)
	,@strInvoiceNo NVARCHAR(100)
	,@intUserId AS INT
	,@isSuccessful BIT = 1 OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

/* Localize Parameters */
DECLARE @intUser INT
		,@xmlPaychecks XML

SELECT @xmlPaychecks = CAST('<A>'+ REPLACE(@intPaycheckIds, ',', '</A><A>')+ '</A>' AS XML) 
	  ,@intUser = @intUserId

--Parse the Paychecks Parameter to Temporary Table
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intPaycheckId
INTO #tmpPaychecks
FROM @xmlPaychecks.nodes('/A') AS X(T) 
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

/* Get all Vendor Ids from Payable Taxes and Deductions */
SELECT DISTINCT intVendorId INTO #tmpVendors FROM
(SELECT intVendorId FROM tblPRTypeTax TT INNER JOIN tblPRPaycheckTax PT ON TT.intTypeTaxId = PT.intTypeTaxId
	WHERE PT.intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TT.intVendorId IS NOT NULL
 UNION ALL
 SELECT intVendorId FROM tblPRTypeDeduction TD INNER JOIN tblPRPaycheckDeduction PD ON TD.intTypeDeductionId = PD.intTypeDeductionId
	WHERE PD.intPaycheckId = (SELECT intPaycheckId FROM #tmpPaychecks) AND TD.intVendorId IS NOT NULL
) PayableTaxesAndDeductions

DECLARE @intVendorEntityId INT
DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory
DECLARE @intBillId INT
DECLARE @intBillIds AS Id;
DECLARE @billRecordNumber NVARCHAR(50)

/* Loop through each vendor and create Vouchers */
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpVendors)
BEGIN
	SELECT TOP 1 @intVendorEntityId = intVendorId FROM #tmpVendors

	EXEC uspSMGetStartingNumber 9, @billRecordNumber OUTPUT

	/* Get Voucher Header */
	SELECT 
		[intTermsId]			=	A.[intTermsId],
		[dtmDueDate]			=	A.[dtmDueDate],
		[intAccountId]			=	A.[intAccountId],
		[intEntityId]			=	A.[intEntityId],
		[intEntityVendorId]		=	A.[intEntityVendorId],
		[intTransactionType]	=	A.[intTransactionType],
		[strBillId]				=	@billRecordNumber,
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
		[intShipToId]			=	A.[intShipToId],
		[intShipViaId]			=	A.[intShipViaId],
		[intContactId]			=	A.[intContactId],
		[intOrderById]			=	A.[intOrderById],
		[intCurrencyId]			=	A.[intCurrencyId]
	INTO #tmpBillData
	FROM dbo.fnAPCreateBillData(@intVendorEntityId, @intUser, 1, DEFAULT, DEFAULT, DEFAULT, DEFAULT, NULL) A

	/* Insert Voucher Header */
	INSERT INTO tblAPBill
	(
		[intTermsId]			
		,[dtmDueDate]			
		,[intAccountId]			
		,[intEntityId]			
		,[intEntityVendorId]		
		,[intTransactionType]	
		,[strBillId]				
		,[strShipToAttention]	
		,[strShipToAddress]		
		,[strShipToCity]			
		,[strShipToState]		
		,[strShipToZipCode]		
		,[strShipToCountry]		
		,[strShipToPhone]		
		,[strShipFromAttention]	
		,[strShipFromAddress]	
		,[strShipFromCity]		
		,[strShipFromState]		
		,[strShipFromZipCode]	
		,[strShipFromCountry]	
		,[strShipFromPhone]		
		,[intShipFromId]			
		,[intShipToId]			
		,[intShipViaId]			
		,[intContactId]			
		,[intOrderById]			
		,[intCurrencyId]			
	)
	SELECT * FROM #tmpBillData
	SET @intBillId = SCOPE_IDENTITY()

	/* Update Voucher Invoice Number */
	UPDATE tblAPBill SET 
		strVendorOrderNumber = @strInvoiceNo
	WHERE intBillId = @intBillId 

	INSERT INTO @intBillIds (intId) SELECT @intBillId

	/* Generate Voucher Details */
	INSERT INTO tblAPBillDetail(
		[intBillId]						
		,[intAccountId]					
		,[intItemId]						
		,[strMiscDescription]			
		,[dblTotal]						
		,[dblQtyOrdered]					
		,[dblQtyReceived]				
		,[dblDiscount]					
		,[dblCost]						
		,[int1099Form]					
		,[int1099Category]				
		,[intLineNo]						
		,[intTaxGroupId]		
	)
	SELECT
		[intBillId]				=	@intBillId
		,[intAccountId]			=	A.intAccountId
		,[intItemId]			=	NULL
		,[strMiscDescription]	=	A.strItem
		,[dblTotal]				=	A.dblTotal
		,[dblQtyOrdered]		=	1
		,[dblQtyReceived]		=	1
		,[dblDiscount]			=	0
		,[dblCost]				=	A.dblTotal
		,[int1099Form]			=	(CASE WHEN C.str1099Form = '1099-MISC' THEN 1
												WHEN C.str1099Form = '1099-INT' THEN 2
												WHEN C.str1099Form = '1099-B' THEN 3
											ELSE 0 END)
		,[int1099Category]		=	ISNULL(D.int1099CategoryId, 0)
		,[intLineNo]			=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))
		,[intTaxGroupId]		=	NULL			
	FROM 
		(SELECT intVendorId = TT.intVendorId, intAccountId = PT.intExpenseAccountId, strItem = TT.strTax, dblTotal = SUM(PT.dblTotal)
			FROM tblPRTypeTax TT INNER JOIN tblPRPaycheckTax PT ON TT.intTypeTaxId = PT.intTypeTaxId
			WHERE PT.dblTotal > 0 AND PT.intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TT.intVendorId = @intVendorEntityId
			GROUP BY TT.intVendorId, PT.intExpenseAccountId, TT.strTax
		 UNION ALL
		 SELECT intVendorId = TD.intVendorId, intAccountId = PD.intExpenseAccountId, strItem = TD.strDeduction, dblTotal = SUM(PD.dblTotal)
			FROM tblPRTypeDeduction TD INNER JOIN tblPRPaycheckDeduction PD ON TD.intTypeDeductionId = PD.intTypeDeductionId
			WHERE PD.dblTotal > 0 AND PD.intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TD.intVendorId = @intVendorEntityId
			GROUP BY TD.intVendorId, PD.intExpenseAccountId, TD.strDeduction
		) A
		INNER JOIN tblAPVendor B ON A.intVendorId = B.intEntityVendorId
		INNER JOIN tblEntity C ON B.intEntityVendorId = C.intEntityId
		LEFT JOIN tblAP1099Category D ON C.str1099Type = D.strCategory

	DELETE FROM #tmpVendors WHERE intVendorId = @intVendorEntityId
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillData')) DROP TABLE #tmpBillData
END

/* Update Voucher Total */
IF EXISTS (SELECT TOP 1 1 FROM @intBillIds) 
	EXEC uspAPUpdateVoucherTotal @intBillIds

/* Update Paycheck Bill Id */
UPDATE tblPRPaycheck SET intBillId = @intBillId WHERE intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks)

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVendors')) DROP TABLE #tmpVendors
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPaychecks')) DROP TABLE #tmpPaychecks

GO