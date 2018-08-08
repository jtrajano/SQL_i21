CREATE PROCEDURE [dbo].[uspARUpdateContractOnInvoiceFromTicket]  
	 @TransactionId	INT   
	,@ForDelete		BIT = 0
	,@UserId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  



-- Get the details from the invoice 

DECLARE @ErrMsg AS NVARCHAR(MAX)
BEGIN TRY
		IF(OBJECT_ID('tempdb..#tempContractInvoice') IS NOT NULL)
		BEGIN
			DROP TABLE #tempContractInvoice
		END

		SELECT intInvoiceDetailId,intTicketId,CASE WHEN ARID.dblQtyShipped > ARID.dblQtyOrdered THEN ARID.dblQtyShipped - ARID.dblQtyOrdered ELSE ARID.dblQtyShipped END as dblQtyShipped,ARID.intContractDetailId,ARI.intInvoiceId,SOD.intSalesOrderId,SOD.intSalesOrderDetailId INTO #tempContractInvoice FROM tblARInvoice ARI
		INNER JOIN tblARInvoiceDetail ARID
			ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN tblSOSalesOrderDetail SOD
			ON SOD.intSalesOrderDetailId = ARID.intSalesOrderDetailId
		WHERE ARID.intInvoiceId = @TransactionId AND ARID.intContractDetailId IS NOT NULL AND intTicketId IS NOT NULL AND ARID.intContractDetailId = SOD.intContractDetailId
		AND ARID.dblQtyShipped <> SOD.dblQtyOrdered
			
		DECLARE UpdateContract CURSOR
		FOR SELECT intInvoiceDetailId,intTicketId,dblQtyShipped,intContractDetailId,intInvoiceId,intSalesOrderId,intSalesOrderDetailId FROM #tempContractInvoice 
		OPEN UpdateContract
		DECLARE @_intInvoiceDetailId INT,
				@_dblQtyShipped NUMERIC(18,6),
				@_intTicketId INT,
				@_intContractDetailId INT,
				@_intInvoiceID INT,
				@_intSalesOrderId INT,
				@_intSalesOrderDetailId INT
		FETCH NEXT FROM UpdateContract 
		INTO @_intInvoiceDetailId, @_intTicketId,@_dblQtyShipped,@_intContractDetailId,@_intInvoiceID,@_intSalesOrderId,@_intSalesOrderDetailId

		WHILE (@@FETCH_STATUS = 0)
			BEGIN
				IF(@ForDelete = 1)
				BEGIN
					SET @_dblQtyShipped = @_dblQtyShipped * -1
				END
				EXEC	uspCTUpdateScheduleQuantity
								@intContractDetailId	=	@_intContractDetailId,
								@dblQuantityToUpdate	=	@_dblQtyShipped,
								@intUserId				=	@UserId,
								@intExternalId			=	@_intInvoiceDetailId,
								@strScreenName			=	'Invoice'			

		FETCH NEXT FROM UpdateContract INTO @_intInvoiceDetailId, @_intTicketId,@_dblQtyShipped,@_intContractDetailId,@_intInvoiceID,@_intSalesOrderId,@_intSalesOrderDetailId
		END
		CLOSE UpdateContract
		DEALLOCATE UpdateContract

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO
