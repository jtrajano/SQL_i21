CREATE PROCEDURE [dbo].[uspMFReverseAutoBlend]
	@intSalesOrderDetailId int,
	@intUserId int
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @ErrMsg NVARCHAR(MAX)
Declare @intWorkOrderId INT
Declare @strBatchId nvarchar(40)
Declare @strWorkOrderNo nvarchar(50)
DECLARE @STARTING_NUMBER_BATCH AS INT = 3
DECLARE @GLEntries AS RecapTableType 

If ISNULL(@intSalesOrderDetailId,0)=0 OR NOT EXISTS (Select 1 From tblSOSalesOrderDetail Where intSalesOrderDetailId=ISNULL(@intSalesOrderDetailId,0))
	RaisError('Sales Order Detail does not exist.',16,1)

If Not Exists (Select 1 From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId)
	RaisError('No blends produced using the Sales Order Detail.',16,1)

If Not Exists (Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId IN 
(Select intWorkOrderId From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId))
	RaisError('No blends produced using the Sales Order Detail.',16,1)

If Exists (Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId IN 
(Select intWorkOrderId From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId) AND ISNULL(ysnProductionReversed,0)=1)
	RaisError('Sales Order Line is already reversed.',16,1)

Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId

Begin Transaction

While @intWorkOrderId is not null
Begin
Select @strWorkOrderNo=strWorkOrderNo From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

Set @strBatchId=''
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT 

Delete From @GLEntries

INSERT INTO @GLEntries (
				[dtmDate] 
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,[ysnIsUnposted]
				,[intUserId]
				,[intEntityId]
				,[strTransactionId]
				,[intTransactionId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
				,[intConcurrencyId]
				,[dblDebitForeign]	
				,[dblDebitReport]	
				,[dblCreditForeign]	
				,[dblCreditReport]	
				,[dblReportingRate]	
				,[dblForeignRate]
		)
		EXEC dbo.uspICUnpostCosting
		 @intWorkOrderId
		,@strWorkOrderNo
		,@strBatchId
		,@intUserId	

Update tblMFWorkOrderProducedLot Set ysnProductionReversed=1 Where intWorkOrderId=@intWorkOrderId

Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId AND intWorkOrderId > @intWorkOrderId
End

Commit Transaction

END TRY

BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
