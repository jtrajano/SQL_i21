/*  
 This stored procedure is used as data source for "Check Voucher Middle Sub Report AP Payment"
*/  
CREATE PROCEDURE uspCMVoucherCheckMiddleSubReportAPPayment  
	@intTransactionIdFrom INT = 0   
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
DECLARE @BANK_DEPOSIT INT = 1  
  ,@BANK_WITHDRAWAL INT = 2  
  ,@MISC_CHECKS INT = 3  
  ,@BANK_TRANSFER INT = 4  
  ,@BANK_TRANSACTION INT = 5  
  ,@CREDIT_CARD_CHARGE INT = 6  
  ,@CREDIT_CARD_RETURNS INT = 7  
  ,@CREDIT_CARD_PAYMENTS INT = 8  
  ,@BANK_TRANSFER_WD INT = 9  
  ,@BANK_TRANSFER_DEP INT = 10  
  ,@ORIGIN_DEPOSIT AS INT = 11  
  ,@ORIGIN_CHECKS AS INT = 12  
  ,@ORIGIN_EFT AS INT = 13  
  ,@ORIGIN_WITHDRAWAL AS INT = 14  
  ,@ORIGIN_WIRE AS INT = 15  
  ,@AP_PAYMENT AS INT = 16
  ,@BANK_STMT_IMPORT AS INT = 17
  ,@AR_PAYMENT AS INT = 18
  ,@VOID_CHECK AS INT = 19
  ,@AP_ECHECK AS INT = 20
  ,@PAYCHECK AS INT = 21
  
-- Sample XML string structure:  
--SET @xmlparam = '  
--<xmlparam>  
-- <filters>  
--  <filter>  
--   <fieldname>intTransactionId</fieldname>  
--   <condition>Between</condition>  
--   <from>14973</from>  
--   <to>14973</to>  
--   <join>And</join>  
--   <begingroup>0</begingroup>  
--   <endgroup>0</endgroup>  
--   <datatype>String</datatype>  
--  </filter>  
-- </filters>  
-- <options />  
--</xmlparam>'  
  
-- Sanitize the @xmlParam   
--IF LTRIM(RTRIM(@xmlParam)) = ''   
-- SET @xmlParam = NULL   
  
---- Declare the variables.  
--DECLARE @intTransactionIdFrom AS INT  
  
--  -- Declare the variables for the XML parameter  
--  ,@xmlDocumentId AS INT  
    
---- Create a table variable to hold the XML data.     
--DECLARE @temp_xml_table TABLE (  
-- [fieldname] NVARCHAR(50)  
-- ,condition NVARCHAR(20)        
-- ,[from] NVARCHAR(50)  
-- ,[to] NVARCHAR(50)  
-- ,[join] NVARCHAR(10)  
-- ,[begingroup] NVARCHAR(50)  
-- ,[endgroup] NVARCHAR(50)  
-- ,[datatype] NVARCHAR(50)  
--)  
  
---- Prepare the XML   
--EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
---- Insert the XML to the xml table.     
--INSERT INTO @temp_xml_table  
--SELECT *  
--FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
--WITH (  
-- [fieldname] nvarchar(50)  
-- , condition nvarchar(20)  
-- , [from] nvarchar(50)  
-- , [to] nvarchar(50)  
-- , [join] nvarchar(10)  
-- , [begingroup] nvarchar(50)  
-- , [endgroup] nvarchar(50)  
-- , [datatype] nvarchar(50)  
--)  
  
---- Gather the variables values from the xml table.   
--SELECT @intTransactionIdFrom = [from]  
--FROM @temp_xml_table   
--WHERE [fieldname] = 'intTransactionId'  
  
-- Sanitize the parameters  
--SET @intTransactionIdFrom = CASE WHEN ISNULL(@intTransactionIdFrom, 0) = 0 THEN NULL ELSE @intTransactionIdFrom END  
  
-- Report Query:  
SELECT  TOP 10 * FROM(
	SELECT  
			intTransactionId = F.intTransactionId
			,strBillId = BILL.strBillId
			,strInvoice = BILL.strVendorOrderNumber
			,dtmDate = BILL.dtmBillDate
			,strComment = SUBSTRING(BILL.strComment,1,25)
			,dblAmount = CASE WHEN BILL.intTransactionType = 3
						THEN BILL.dblTotal * -1
						ELSE BILL.dblTotal
						END
			,dblDiscount = CASE WHEN PYMTDetail.dblDiscount <> 0 
						THEN PYMTDetail.dblDiscount 
						ELSE  PYMTDetail.dblInterest 
						END
			,dblNet = CASE WHEN BILL.intTransactionType = 3
						THEN PYMTDetail.dblPayment * -1
						ELSE PYMTDetail.dblPayment
						END
			--,CONTRACTHEADER.strContractNumber
			--,strPPDType = CASE WHEN BILLDETAIL.intPrepayTypeId = 3
			--			THEN 'Percentage'
			--			WHEN BILLDETAIL.intPrepayTypeId = 2
			--			THEN 'Unit'
			--			ELSE 'Standard'
			--			END
			--,BILLDETAIL.dblTotal
			--,BILLDETAIL.dblQtyOrdered
			,BILL.intTransactionType
			--,ITEM.strItemNo
			--,ITEM.strDescription
			,PYMTDetail.intPaymentDetailId
	FROM	[dbo].[tblCMBankTransaction] F INNER JOIN [dbo].[tblAPPayment] PYMT
				ON F.strTransactionId = PYMT.strPaymentRecordNum
			INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
				ON PYMT.intPaymentId = PYMTDetail.intPaymentId
			INNER JOIN [dbo].[tblAPBill] BILL
				ON PYMTDetail.intBillId = BILL.intBillId
			--INNER JOIN [dbo].[tblAPBillDetail] BILLDETAIL
			--	ON BILL.intBillId = BILLDETAIL.intBillId
			--LEFT JOIN [dbo].[tblCTContractHeader] CONTRACTHEADER
			--	ON BILLDETAIL.intContractHeaderId = CONTRACTHEADER.intContractHeaderId
			--LEFT JOIN [dbo].tblICItem ITEM
			--	ON BILLDETAIL.intItemId = ITEM.intItemId
	WHERE	F.intTransactionId = ISNULL(@intTransactionIdFrom, F.intTransactionId)
			AND F.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK)

	--Include Invoice
	UNION ALL SELECT
			intTransactionId = F.intTransactionId
			,strBillId = INV.strInvoiceNumber
			,strInvoice = ''
			,dtmDate = INV.dtmDate
			,strComment = SUBSTRING(INV.strComments,1,25)
			,dblAmount = INV.dblInvoiceTotal
			,dblDiscount = CASE WHEN PYMTDetail.dblDiscount <> 0 
						THEN PYMTDetail.dblDiscount 
						ELSE  PYMTDetail.dblInterest 
						END
			,dblNet = PYMTDetail.dblPayment
			--,CONTRACTHEADER.strContractNumber
			--,strPPDType = ''
			--,INVDETAIL.dblTotal
			--,INVDETAIL.dblQtyOrdered
			,'' AS intTransactionType
			--,ITEM.strItemNo
			--,ITEM.strDescription
			,PYMTDetail.intPaymentDetailId
	FROM	[dbo].[tblCMBankTransaction] F INNER JOIN [dbo].[tblAPPayment] PYMT
				ON F.strTransactionId = PYMT.strPaymentRecordNum
			INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
				ON PYMT.intPaymentId = PYMTDetail.intPaymentId
			INNER JOIN [dbo].[tblARInvoice] INV
				ON PYMTDetail.intInvoiceId = INV.intInvoiceId
			--INNER JOIN [dbo].[tblARInvoiceDetail] INVDETAIL
			--	ON INV.intInvoiceId = INVDETAIL.intInvoiceId
			--LEFT JOIN [dbo].[tblCTContractHeader] CONTRACTHEADER
			--	ON INVDETAIL.intContractHeaderId = CONTRACTHEADER.intContractHeaderId
			--LEFT JOIN [dbo].tblICItem ITEM
			--	ON INVDETAIL.intItemId = ITEM.intItemId
	WHERE	F.intTransactionId = ISNULL(@intTransactionIdFrom, F.intTransactionId)
			AND F.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK)
) as tbl order by intPaymentDetailId