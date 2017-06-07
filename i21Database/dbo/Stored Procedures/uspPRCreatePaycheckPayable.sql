CREATE PROCEDURE [dbo].[uspPRCreatePaycheckPayable]
	@intPaycheckIds NVARCHAR(MAX)
	,@strInvoiceNo NVARCHAR(100)
	,@intUserId AS INT
	,@ysnVoid BIT = 0
	,@isSuccessful BIT = 1 OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

/* Localize Parameters */
DECLARE @intUser INT
		,@strInvoice NVARCHAR(100)
		,@isVoid BIT
		,@xmlPaychecks XML

SELECT @xmlPaychecks = CAST('<A>'+ REPLACE(@intPaycheckIds, ',', '</A><A>')+ '</A>' AS XML) 
	  ,@strInvoice = @strInvoiceNo
	  ,@intUser = @intUserId
	  ,@isVoid = @ysnVoid

--Parse the Paychecks Parameter to Temporary Table
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intPaycheckId
INTO #tmpPaychecks
FROM @xmlPaychecks.nodes('/A') AS X(T) 
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

/* Get all Vendor Ids from Payable Taxes and Deductions */
SELECT DISTINCT intVendorId INTO #tmpVendors FROM
(SELECT intVendorId FROM tblPRTypeTax TT INNER JOIN tblPRPaycheckTax PT ON TT.intTypeTaxId = PT.intTypeTaxId
	WHERE PT.intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TT.intExpenseAccountId IS NOT NULL AND TT.intVendorId IS NOT NULL 
	AND ((@isVoid = 0 AND PT.intBillId IS NULL) OR (@isVoid = 1 AND PT.intBillId IS NOT NULL))
 UNION ALL
 SELECT intVendorId FROM tblPRTypeDeduction TD INNER JOIN tblPRPaycheckDeduction PD ON TD.intTypeDeductionId = PD.intTypeDeductionId
	WHERE PD.intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TD.intExpenseAccountId IS NOT NULL AND TD.intVendorId IS NOT NULL 
	AND ((@isVoid = 0 AND PD.intBillId IS NULL) OR (@isVoid = 1 AND PD.intBillId IS NOT NULL))
) PayableTaxesAndDeductions

/* Set Invoice Number as Paycheck Id + Void for Void entries */
IF (@ysnVoid = 1) 
	SELECT @strInvoice = 'VOID-' + strPaycheckId FROM tblPRPaycheck 
	WHERE intPaycheckId IN (SELECT TOP 1 intPaycheckId FROM #tmpPaychecks)

/* Validate Vendor Invoice No */
DECLARE @strMsg NVARCHAR(200) = ''
SELECT TOP 1 @strMsg = 'Invoice No. already exists for Vendor ''' + tblEMEntity.strEntityNo + '''!'
	FROM tblAPBill INNER JOIN tblEMEntity ON tblAPBill.intEntityVendorId = tblEMEntity.intEntityId
WHERE strVendorOrderNumber = @strInvoiceNo AND intEntityVendorId IN (SELECT intVendorId FROM #tmpVendors)

IF (LEN(@strMsg) > 0)
BEGIN
	RAISERROR(@strMsg, 11, 1)
	GOTO Process_Exit
END

DECLARE @intVendorEntityId INT
DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory
DECLARE @intBillId INT
DECLARE @intBillIds AS Id;
DECLARE @billRecordNumber NVARCHAR(50)
DECLARE @intStartingNumberId INT

/* Check if valid AP Account */
DECLARE @intAPAccount INT = NULL
SELECT @intAPAccount = intAPAccount FROM tblSMCompanyLocation 
WHERE intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId 
								FROM tblSMUserSecurity WHERE [intEntityId] = @intUserId)

IF (@intAPAccount IS NULL)
BEGIN
	RAISERROR('No default AP Account setup for this Location.', 11, 1)
	GOTO Process_Exit
END

/* Loop through each vendor and create Vouchers */
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpVendors)
BEGIN
	SELECT TOP 1 @intVendorEntityId = intVendorId FROM #tmpVendors

	SET @intStartingNumberId = CASE WHEN (@ysnVoid = 1) THEN 18 ELSE 9 END
	EXEC uspSMGetStartingNumber @intStartingNumberId, @billRecordNumber OUTPUT
	
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
	FROM dbo.fnAPCreateBillData(@intVendorEntityId, @intUser, CASE WHEN (@ysnVoid = 1) THEN 3 ELSE 1 END, DEFAULT, DEFAULT, @intAPAccount, DEFAULT, NULL) A

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
		(SELECT 
			intVendorId = TT.intVendorId, 
			intAccountId = CASE WHEN (PT.strPaidBy = 'Company') THEN PT.intAccountId ELSE PT.intExpenseAccountId END, 
			strItem = TT.strTax, dblTotal = SUM(PT.dblTotal)
			FROM tblPRTypeTax TT INNER JOIN tblPRPaycheckTax PT ON TT.intTypeTaxId = PT.intTypeTaxId
			WHERE PT.dblTotal > 0 AND PT.intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TT.intExpenseAccountId IS NOT NULL
			  AND TT.intVendorId = @intVendorEntityId AND ((@isVoid = 0 AND PT.intBillId IS NULL) OR (@isVoid = 1 AND PT.intBillId IS NOT NULL))
			GROUP BY TT.intVendorId, PT.intExpenseAccountId, PT.intAccountId, TT.strTax, PT.strPaidBy
		 UNION ALL
		 SELECT 
			intVendorId = TD.intVendorId, 
			intAccountId = CASE WHEN (PD.strPaidBy = 'Company') THEN PD.intAccountId ELSE PD.intExpenseAccountId END,
			strItem = TD.strDeduction, 
			dblTotal = SUM(PD.dblTotal)
			FROM tblPRTypeDeduction TD INNER JOIN tblPRPaycheckDeduction PD ON TD.intTypeDeductionId = PD.intTypeDeductionId
			WHERE PD.dblTotal > 0 AND PD.intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TD.intExpenseAccountId IS NOT NULL
				AND TD.intVendorId = @intVendorEntityId AND ((@isVoid = 0 AND PD.intBillId IS NULL) OR (@isVoid = 1 AND PD.intBillId IS NOT NULL))
			GROUP BY TD.intVendorId, PD.intExpenseAccountId, PD.intAccountId, TD.strDeduction, PD.strPaidBy
		) A
		INNER JOIN tblAPVendor B ON A.intVendorId = B.[intEntityId]
		INNER JOIN tblEMEntity C ON B.[intEntityId] = C.intEntityId
		LEFT JOIN tblAP1099Category D ON C.str1099Type = D.strCategory

	/* Update Voucher Total */
	IF EXISTS (SELECT TOP 1 1 FROM @intBillIds) 
		EXEC uspAPUpdateVoucherTotal @intBillIds

	/* Update Paycheck Taxes Bill Id */
	UPDATE tblPRPaycheckTax SET intBillId = @intBillId 
	FROM tblPRTypeTax TT INNER JOIN tblPRPaycheckTax ON TT.intTypeTaxId = tblPRPaycheckTax.intTypeTaxId
	WHERE dblTotal > 0 AND intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TT.intExpenseAccountId IS NOT NULL AND TT.intVendorId = @intVendorEntityId
	  AND ((@isVoid = 0 AND tblPRPaycheckTax.intBillId IS NULL) OR (@isVoid = 1 AND tblPRPaycheckTax.intBillId IS NOT NULL))

	/* Update Paycheck Deductions Bill Id */
	UPDATE tblPRPaycheckDeduction SET intBillId = @intBillId 
	FROM tblPRTypeDeduction TD INNER JOIN tblPRPaycheckDeduction ON TD.intTypeDeductionId = tblPRPaycheckDeduction.intTypeDeductionId
	WHERE dblTotal > 0 AND intPaycheckId IN (SELECT intPaycheckId FROM #tmpPaychecks) AND TD.intExpenseAccountId IS NOT NULL AND TD.intVendorId = @intVendorEntityId
	  AND ((@isVoid = 0 AND tblPRPaycheckDeduction.intBillId IS NULL) OR (@isVoid = 1 AND tblPRPaycheckDeduction.intBillId IS NOT NULL))

	DELETE FROM #tmpVendors WHERE intVendorId = @intVendorEntityId
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillData')) DROP TABLE #tmpBillData
END

Process_Exit:

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVendors')) DROP TABLE #tmpVendors
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPaychecks')) DROP TABLE #tmpPaychecks

GO