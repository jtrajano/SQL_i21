CREATE PROCEDURE [dbo].[uspAPConvertFinalVoucherToDebitMemo]  
  @billId INT,  
  @debitMemoNo NVARCHAR(100) OUTPUT  
AS  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRY  
  DECLARE @transCount INT = @@TRANCOUNT;  
  IF @transCount = 0 BEGIN TRANSACTION   
  
  --MAKE SURE Finalize Voucher Only and amount is negative  
  IF NOT EXISTS (SELECT 1 FROM tblAPBill WHERE intBillId = @billId AND intTransactionType = 1 AND ISNULL(ysnFinalVoucher,0) = 1 AND dblAmountDue - dblProvisionalTotal < 0)   
  BEGIN  
    RAISERROR('Unable to convert to Debit Memo. Only finalize voucher with negative amount due can be converted', 16, 1)  
    RETURN  
  END  
  
  IF EXISTS (SELECT 1  
  FROM tempdb..sysobjects  
  WHERE id = OBJECT_ID('tempdb..#tmpBillDetail')) DROP TABLE #tmpBillDetail  
  
  DECLARE @diffTotal DECIMAL(18,6) = 0,   
          @diffWeight DECIMAL(18,6) = 0,  
          @diffCost DECIMAL(18,6) = 0,  
          @cost DECIMAL(18,6) = 0,  
          @weight DECIMAL(18,6) = 0,  
          @averageCost DECIMAL(18,6) = 0,  
          @detailTotal DECIMAL(18,6) = 0,  
          @rowCount INT = 0,  
        @intBillDetailId INT = 0,  
          @percentage DECIMAL(18,6) = 0,  
          @rowNum INT = 1  
  
  SELECT ROW_NUMBER() OVER (  
  ORDER BY intBillDetailId ASC   
  ) RowNum,  
    intBillDetailId,  
    dblTotal,  
    dblCost,  
    dblNetWeight,  
    dblProvisionalTotal,  
    dblProvisionalCost,  
    dblProvisionalPercentage,  
    dblProvisionalWeight 
  INTO #tmpBillDetail FROM tblAPBillDetail  
  WHERE intBillId = @billId  
  
  
  SELECT @rowCount = COUNT(*) FROM #tmpBillDetail  
  
  WHILE @rowNum <= @rowCount  
  BEGIN  
    SELECT  
      @diffTotal = dblTotal - dblProvisionalTotal,  
      @diffCost = dblCost - dblProvisionalCost,  
      @diffWeight = dblNetWeight - dblProvisionalWeight,  
      @cost = CASE WHEN @diffCost <> 0 THEN @diffCost ELSE dblCost END,  
      @weight = CASE WHEN @diffWeight <> 0 THEN @diffWeight ELSE dblNetWeight END,  
      @percentage = dblProvisionalPercentage / 100,  
      @intBillDetailId = intBillDetailId  
    FROM #tmpBillDetail WHERE RowNum = @rowNum  
  
    IF (@diffTotal = 0)  
    BEGIN  
      UPDATE #tmpBillDetail SET dblTotal = 0.000000, dblNetWeight = 0.000000 WHERE intBillDetailId = @intBillDetailId  
      CONTINUE;  
    END  
      
    SET @averageCost = @diffTotal / @weight  
  
    --set the final cost as new cost if the average cost is 0  
    IF (@averageCost = 0) 
    BEGIN  
      SET @averageCost = @cost  
    END  
     
    --Set always the cost to positive value  
    BEGIN  
      SET @averageCost = ABS(@averageCost)   
    END  
      
    IF (@diffTotal < 0)  
    BEGIN  
      SET @weight = ABS(@weight)  
    END  
    ELSE  
    BEGIN  
      SET @weight = -ABS(@weight)  
    END  
         
    --Compute the line item total  
    SET @detailTotal = @weight * @averageCost  
  
    UPDATE #tmpBillDetail 
      SET dblTotal = @detailTotal  
         ,dblNetWeight = @weight   
         ,dblCost = @averageCost  
      WHERE intBillDetailId = @intBillDetailId  
      SET @rowNum = @rowNum +  1  
  END  
  
  UPDATE A  
  SET  A.dblTotal = B.dblTotal  
       ,A.dblNetWeight = B.dblNetWeight  
       ,A.dblCost = B.dblCost  
       ,A.dblTax = (TX.dblTax * @percentage) - TX.dblAdjustedTax
  FROM tblAPBillDetail A INNER JOIN #tmpBillDetail B  
  ON A.intBillDetailId = B.intBillDetailId AND A.intBillId = @billId  
  CROSS APPLY (
    SELECT 
       SUM(dblAdjustedTax) dblAdjustedTax
      ,SUM(dblTax) dblTax
    FROM tblAPBillDetailTax BDT WHERE BDT.intBillDetailId = A.intBillDetailId
    GROUP BY BDT.intBillDetailId
  ) TX
  
  UPDATE A
  SET A.dblAdjustedTax = (A.dblTax * @percentage) - A.dblAdjustedTax
     ,A.dblTax = (A.dblTax * @percentage) - A.dblAdjustedTax
     ,ysnTaxAdjusted = (CAST 0 AS BIT)
  FROM tblAPBillDetailTax A
  INNER JOIN #tmpBillDetail B
    ON A.intBillDetailId = B.intBillDetailId
  INNER JOIN tblAPBillDetail C
    ON A.intBillDetailId = C.intBillDetailId
  WHERE C.intBillId = @billId
  
  DECLARE @debitMemoStartNum INT = 0;    
  DECLARE @debitMemoPref NVARCHAR(50)  
   
 --Debit Memo  
  UPDATE A   
     SET A.intConcurrencyId = A.intConcurrencyId + 1    
        ,@debitMemoStartNum = A.intNumber    
        ,@debitMemoPref = A.strPrefix  
        ,A.intNumber = A.intNumber + 1  
     FROM tblSMStartingNumber A WHERE A.intStartingNumberId = 18  
    
  UPDATE A    
   SET A.strBillId = @debitMemoPref + CAST(@debitMemoStartNum AS NVARCHAR)  
       ,@debitMemoNo = @debitMemoPref + CAST(@debitMemoStartNum AS NVARCHAR)    
       ,@debitMemoStartNum = @debitMemoStartNum + 1  
       ,dblTotal = ABS(A.dblAmountDue - A.dblProvisionalTotal)  
       ,dblAmountDue = ABS(A.dblAmountDue - A.dblProvisionalTotal) 
       ,dblSubtotal = ABS(A.dblAmountDue - A.dblProvisionalTotal)  
       ,dblTotalController = ABS(A.dblAmountDue - A.dblProvisionalTotal)  
       ,intTransactionType = 3 --Debit Memo
       ,ysnFinalVoucher = 0
       ,ysnConvertedToDebitMemo = 1
       ,strReference = REPLACE(strReference, 'Final Voucher of', 'Debit Memo of')
   FROM tblAPBill A WHERE A.intBillId = @billId  
  
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
   IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION  
   RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)  
END CATCH
