CREATE PROCEDURE [dbo].[uspAPUpdateInvoiceNumInGLDetail]
	@invoiceNumber NVARCHAR(100),
	@intBillId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF;

CREATE TABLE #tmpVoucherData (
	[strBillId] NVARCHAR(100) PRIMARY KEY,
	UNIQUE ([strBillId])
);

BEGIN
	DECLARE @strBillId AS NVARCHAR(100)
	
	INSERT INTO #tmpVoucherData SELECT strBillId FROM tblAPBill WHERE intBillId = @intBillId AND ysnPosted = 1

	SELECT @strBillId = strBillId FROM #tmpVoucherData
END

IF (@strBillId IS NOT NULL)
	BEGIN	
		UPDATE tblGLDetail
		SET strDocument = @invoiceNumber, strSourceDocumentId = @invoiceNumber
		WHERE strTransactionId = @strBillId
			AND intTransactionId = @intBillId
	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVoucherData')) DROP TABLE #tmpVoucherData