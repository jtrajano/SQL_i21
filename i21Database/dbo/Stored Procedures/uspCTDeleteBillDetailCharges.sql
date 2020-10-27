/*
This procedure is only called when deleting price layer if the bill detail to be deleted has charges
*/
CREATE PROCEDURE [dbo].[uspCTDeleteBillDetailCharges]
	@strBillDetailChargesId nvarchar(500)
	,@userId int
AS
begin try
	declare
		@ErrMsg nvarchar(max)
		,@ids as Id
		,@voucherIds as Id
		,@actionType AS NVARCHAR(50)
		,@billDetailId AS NVARCHAR(50)
		,@billCounter INT = 0
		,@totalRecords INT
		,@billId INT;

	declare @tmpBillDetailDelete TABLE(
		intBillDetailId INT
	)

	INSERT INTO @ids
	select distinct Item from fnSplitString(@strBillDetailChargesId, ',') where isnull(Item,0) > 0;

	if not exists (select top 1 1 from @ids)
	begin
		goto ExitTransaction;
	end

	EXEC uspAPUpdateVoucherPayable 
		@voucherDetailIds = @ids,
		@decrease = 1

	EXEC uspAPUpdateIntegrationPayableAvailableQty
		@billDetailIds = @ids,
		@decrease = 0

	INSERT INTO @voucherIds
	SELECT A.intBillId FROM tblAPBillDetail A
	INNER JOIN @ids B ON A.intBillDetailId = B.intId

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

	  SET @billCounter = @billCounter + 1
	  DELETE FROM @tmpBillDetailDelete WHERE intBillDetailId = @billDetailId
	END

	DELETE A
	FROM tblAPBillDetail A
	INNER JOIN @ids B ON A.intBillDetailId = B.intId

	EXEC uspAPUpdateVoucherTotal @voucherIds

	ExitTransaction:

end try
begin catch
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
end catch