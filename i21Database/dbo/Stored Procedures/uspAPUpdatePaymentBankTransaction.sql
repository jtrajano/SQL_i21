﻿CREATE PROCEDURE [dbo].[uspAPUpdatePaymentBankTransaction]
	@paymentIds AS Id READONLY,
	@post BIT,
	@userId INT,
	@batchId NVARCHAR(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @post = 0
BEGIN
	-- Creating the temp table:
	DECLARE @isSuccessful BIT
	CREATE TABLE #tmpCMBankTransaction (
    --[intTransactionId] INT PRIMARY KEY,
    [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
    UNIQUE (strTransactionId))

	INSERT INTO #tmpCMBankTransaction
	SELECT 
		strPaymentRecordNum 
	FROM tblAPPayment A
	INNER JOIN @paymentIds B ON A.intPaymentId = B.intId

	-- Calling the stored procedure
	EXEC dbo.uspCMBankTransactionReversal @userId, DEFAULT, @isSuccessful OUTPUT

	IF @isSuccessful = 0
	BEGIN
		RAISERROR('Failed to reverse bank transaction.', 16, 1);
	END
END
ELSE IF @post = 1
BEGIN

	DECLARE @bankTransaction AS BankTransactionTable;
	INSERT INTO @bankTransaction(
		[strTransactionId]         
		,[intBankTransactionTypeId] 
		,[intBankAccountId]         
		,[intCurrencyId]            
		,[dblExchangeRate]          
		,[dtmDate]                  
		,[strPayee]                 
		,[intPayeeId]               
		,[strAddress]               
		,[strZipCode]               
		,[strCity]                  
		,[strState]                 
		,[strCountry]               
		,[dblAmount]                
		,[strAmountInWords]         
		,[strMemo]                  
		,[strReferenceNo]           
		--,[ysnCheckToBePrinted]      
		,[ysnCheckVoid]             
		,[ysnPosted]                
		,[strLink]                  
		,[ysnClr]                   
		,[dtmDateReconciled]        
		,[intEntityId]			   
		,[intCreatedUserId]         
		,[dtmCreated]               
		,[intLastModifiedUserId]    
		,[dtmLastModified]          
		,[intConcurrencyId]    					
		,[intAPPaymentId]     
	)
	SELECT
		[strTransactionId] = A.strPaymentRecordNum,
		[intBankTransactionTypeId] = CASE WHEN LOWER((SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId)) = 'echeck' THEN 20 
										WHEN LOWER((SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId)) = 'ach' THEN 22
										WHEN LOWER((SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId)) = 'check' THEN 16  
										ELSE 20 END,
		[intBankAccountId] = A.intBankAccountId,
		[intCurrencyId] = A.intCurrencyId,
		[dblExchangeRate] = A.dblExchangeRate,
		[dtmDate] = A.dtmDatePaid,
		[strPayee] = CASE WHEN A.ysnOverrideCheckPayee = 1 THEN A.strOverridePayee
						ELSE ISNULL(E.strCheckPayeeName, (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = B.intEntityId))
						END,
		[intPayeeId] = B.intEntityId,
		[strAddress] = E.strAddress,
		[strZipCode] = E.strZipCode,
		[strCity] = E.strCity,
		[strState] = E.strState,
		[strCountry] = E.strCountry,
		[dblAmount] = A.dblAmountPaid,
		[strAmountInWords] = dbo.fnConvertNumberToWord(A.dblAmountPaid),
		[strMemo] = A.strNotes,
		[strReferenceNo] = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE A.strPaymentInfo END,
		--[ysnCheckToBePrinted] = CASE WHEN LOWER((SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId)) = 'Cash' THEN 0 ELSE 1 END,
		[ysnCheckVoid] = 0,
		[ysnPosted] = 1,
		[strLink] = @batchId,
		[ysnClr] = 0,
		[dtmDateReconciled] = NULL,
		[intEntityId] = A.intEntityId,
		[intCreatedUserId] = @userId,
		[dtmCreated] = GETDATE(),
		[intLastModifiedUserID] = NULL,
		[dtmLastModified] = GETDATE(),
		[intConcurrencyId] = 1,
		[intAPPaymentId] = A.intPaymentId
	FROM tblAPPayment A
		INNER JOIN tblAPVendor B
			ON A.[intEntityVendorId] = B.[intEntityId]
		INNER JOIN tblEMEntityLocation E ON A.intPayToAddressId = E.intEntityLocationId
		--CROSS APPLY
		--(
		--	SELECT 
		--		TOP 1 
		--		E.strAddress,
		--		E.strCity,
		--		E.strZipCode,
		--		E.strState,
		--		E.strCountry,
		--		E.strCheckPayeeName
		--	FROM tblAPPaymentDetail C
		--	INNER JOIN tblAPBill D ON C.intBillId = D.intBillId
		--	INNER JOIN tblEMEntityLocation E ON D.intPayToAddressId = E.intEntityLocationId AND D.intEntityVendorId = E.intEntityId
		--	WHERE C.intPaymentId = A.intPaymentId
		--) PayTo
	WHERE A.intPaymentId IN (SELECT intId FROM @paymentIds)

	EXEC uspCMCreateBankTransactionEntries @BankTransactionEntries = @bankTransaction
END
