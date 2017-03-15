CREATE PROCEDURE [dbo].[uspMFReverseAutoBlend]
	@intSalesOrderDetailId int=0,
	@intInvoiceDetailId int=0,
	@intLoadDistributionDetailId int=0,
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
Declare @strOrderType nvarchar(50)
Declare @intBatchId int
Declare @tblWO AS table
(
	intWorkOrderId int
)

If (ISNULL(@intSalesOrderDetailId,0)>0 AND ISNULL(@intInvoiceDetailId,0)>0 AND ISNULL(@intLoadDistributionDetailId,0)>0) 
OR (ISNULL(@intSalesOrderDetailId,0)=0 AND ISNULL(@intInvoiceDetailId,0)=0 AND ISNULL(@intLoadDistributionDetailId,0)=0)
	RaisError('Supply either Sales Order Detail Id or Invoice Detail Id or Load Distribution Detail Id.',16,1)

If ISNULL(@intSalesOrderDetailId,0)>0
	Set @strOrderType='SALES ORDER'

If ISNULL(@intInvoiceDetailId,0)>0
	Set @strOrderType='INVOICE'

If ISNULL(@intLoadDistributionDetailId,0)>0
	Set @strOrderType='LOAD DISTRIBUTION'

If @strOrderType='SALES ORDER'
Begin
	If ISNULL(@intSalesOrderDetailId,0)=0 OR NOT EXISTS (Select 1 From tblSOSalesOrderDetail Where intSalesOrderDetailId=ISNULL(@intSalesOrderDetailId,0))
		RaisError('Sales Order Detail does not exist.',16,1)

	If Not Exists (Select 1 From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId)
		RaisError('No blends produced using the Sales Order Detail.',16,1)

	If Not Exists (Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId IN 
	(Select intWorkOrderId From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId) AND ISNULL(ysnProductionReversed,0)=0)
		RaisError('Sales Order Line is already reversed.',16,1)
End

If @strOrderType='INVOICE'
Begin
	If ISNULL(@intInvoiceDetailId,0)=0 OR NOT EXISTS (Select 1 From tblARInvoiceDetail Where intInvoiceDetailId=ISNULL(@intInvoiceDetailId,0))
		RaisError('Invoice Detail does not exist.',16,1)

	If Not Exists (Select 1 From tblMFWorkOrder Where intInvoiceDetailId=@intInvoiceDetailId)
		RaisError('No blends produced using the Invoice Detail.',16,1)

	If Not Exists (Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId IN 
	(Select intWorkOrderId From tblMFWorkOrder Where intInvoiceDetailId=@intInvoiceDetailId) AND ISNULL(ysnProductionReversed,0)=0)
		RaisError('Invoice Line is already reversed.',16,1)
End

If @strOrderType='LOAD DISTRIBUTION'
Begin
	If ISNULL(@intLoadDistributionDetailId,0)=0 OR NOT EXISTS (Select 1 From tblTRLoadDistributionDetail Where intLoadDistributionDetailId=ISNULL(@intLoadDistributionDetailId,0))
		RaisError('Load Distribution Detail does not exist.',16,1)

	If Not Exists (Select 1 From tblMFWorkOrder Where intLoadDistributionDetailId=@intLoadDistributionDetailId)
		RaisError('No blends produced using the Load Distribution Detail.',16,1)

	If Not Exists (Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId IN 
	(Select intWorkOrderId From tblMFWorkOrder Where intLoadDistributionDetailId=@intLoadDistributionDetailId) AND ISNULL(ysnProductionReversed,0)=0)
		RaisError('Load Distribution Line is already reversed.',16,1)
End

If @strOrderType='SALES ORDER'
 Insert Into @tblWO(intWorkOrderId)
 Select intWorkOrderId From tblMFWorkOrderProducedLot Where intWorkOrderId in (Select intWorkOrderId From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId)
 AND ISNULL(ysnProductionReversed,0)=0

If @strOrderType='INVOICE'
 Insert Into @tblWO(intWorkOrderId)
 Select intWorkOrderId From tblMFWorkOrderProducedLot Where intWorkOrderId in (Select intWorkOrderId From tblMFWorkOrder Where intInvoiceDetailId=@intInvoiceDetailId)
 AND ISNULL(ysnProductionReversed,0)=0

If @strOrderType='LOAD DISTRIBUTION'
 Insert Into @tblWO(intWorkOrderId)
 Select intWorkOrderId From tblMFWorkOrderProducedLot Where intWorkOrderId in (Select intWorkOrderId From tblMFWorkOrder Where intLoadDistributionDetailId=@intLoadDistributionDetailId)
 AND ISNULL(ysnProductionReversed,0)=0

Select @intWorkOrderId=MIN(intWorkOrderId) From @tblWO

Begin Transaction

While @intWorkOrderId is not null
Begin
Select @strWorkOrderNo=strWorkOrderNo From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
Select TOP 1 @intBatchId=intBatchId From tblMFWorkOrderProducedLot Where intWorkOrderId=@intWorkOrderId

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
				,[strRateType]
		)
		EXEC dbo.uspICUnpostCosting
		 @intBatchId
		,@strWorkOrderNo
		,@strBatchId
		,@intUserId	

Update tblMFWorkOrderProducedLot Set ysnProductionReversed=1 Where intWorkOrderId=@intWorkOrderId

Select @intWorkOrderId=MIN(intWorkOrderId) From @tblWO Where intWorkOrderId > @intWorkOrderId

End

Commit Transaction

END TRY

BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
