CREATE PROCEDURE [dbo].[uspAPDeleteVoucherDetail]
	@billDetailIds AS Id READONLY   
	,@userId	INT
	,@callerModule INT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT;
DECLARE @ids AS Id;
DECLARE @voucherIds AS Id;

INSERT INTO @ids
SELECT intId FROM @billDetailIds

EXEC uspAPUpdateVoucherPayable 
	@voucherDetailIds = @ids,
	@decrease = 1

EXEC uspAPUpdateIntegrationPayableAvailableQty
	@billDetailIds = @ids,
	@decrease = 0

EXEC uspAPLogVoucherDetailRisk @voucherDetailIds = @ids, @remove = 1

INSERT INTO @voucherIds
SELECT DISTINCT A.intBillId FROM tblAPBillDetail A
INNER JOIN @ids B ON A.intBillDetailId = B.intId

DECLARE @strDescription AS NVARCHAR(100) 
  ,@actionType AS NVARCHAR(50)
  ,@billDetailId AS NVARCHAR(50);
DECLARE @billCounter INT = 0;
DECLARE @totalRecords INT;
DECLARE @billId INT;
DECLARE @tmpBillDetailDelete TABLE(intBillDetailId INT)
SELECT @actionType = 'Deleted'

INSERT INTO @tmpBillDetailDelete
SELECT intId FROM @ids

SELECT @totalRecords = COUNT(*) FROM @tmpBillDetailDelete

WHILE(@billCounter != (@totalRecords))
BEGIN

	SELECT TOP(1) @billId = B.intBillId, @billDetailId = A.intBillDetailId
	FROM @tmpBillDetailDelete A
	INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId

	DECLARE @details NVARCHAR(max) = '{"change": "tblAPBillDetails", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Deleted", "change": "Deleted-Record: '+CAST(@billDetailId as varchar(15))+'", "keyValue": '+CAST(@billDetailId as varchar(15))+', "iconCls": "small-new-minus", "leaf": true}]}';

	EXEC uspSMAuditLog
	@screenName = 'AccountsPayable.view.Voucher',
	@entityId = @userId,
	@actionType = 'Updated',
	@actionIcon = 'small-tree-modified',
	@keyValue = @billId,
	@details = @details

	BEGIN TRY
		DECLARE @SingleAuditLogParam SingleAuditLogParam
		INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
				SELECT 1, '', 'Updated', 'Updated - Record: ' + CAST(@billId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
				UNION ALL
				SELECT 2, '', '', 'tblAPBillDetails', NULL, NULL, 'Details', NULL, NULL, 1
				UNION ALL
				SELECT 3, CAST(@billDetailId as varchar(15)), 'Deleted', 'Deleted-Record: '+CAST(@billDetailId as varchar(15)), NULL, NULL, NULL, NULL, NULL, 2

		EXEC uspSMSingleAuditLog 
			@screenName     = 'AccountsPayable.view.Voucher',
			@recordId       = @billId,
			@entityId       = @userId,
			@AuditLogParam  = @SingleAuditLogParam
    END TRY
    BEGIN CATCH
    END CATCH

  SET @billCounter = @billCounter + 1
  DELETE FROM @tmpBillDetailDelete WHERE intBillDetailId = @billDetailId
END

DELETE A
FROM tblAPBillDetail A
INNER JOIN @ids B ON A.intBillDetailId = B.intId

EXEC uspAPUpdateVoucherTotal @voucherIds

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
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
