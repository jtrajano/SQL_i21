CREATE PROCEDURE [dbo].[uspARPostInvoiceIntegrations]
	 @post			BIT = 0  
	,@TransactionId	INT = NULL   
	,@userId		INT = NULL     
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF


DECLARE @UserEntityID INT
		,@actionType AS NVARCHAR(50)
		,@ForDelete BIT = 0
--THIS IS A HICCUP		

SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @userId),@userId) 
SELECT @actionType = CASE WHEN @post = 1 THEN 'Posted'  ELSE 'Unposted' END 
SELECT @ForDelete = CASE WHEN @post = 1 THEN 0 ELSE 1 END

-- Get the details from the invoice 
BEGIN 
	DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
	INSERT INTO @ItemsFromInvoice 
	--(
	--	-- Header
	--	 [intInvoiceId]
	--	,[strInvoiceNumber]
	--	,[intEntityCustomerId]
	--	,[dtmDate]
	--	,[intCurrencyId]
	--	,[intCompanyLocationId]
	--	,[intDistributionHeaderId]

	--	-- Detail 
	--	,[intInvoiceDetailId]
	--	,[intItemId]
	--	,[strItemNo]
	--	,[strItemDescription]
	--	,[intSCInvoiceId]
	--	,[strSCInvoiceNumber]
	--	,[intItemUOMId]
	--	,[dblQtyOrdered]
	--	,[dblQtyShipped]
	--	,[dblDiscount]
	--	,[dblPrice]
	--	,[dblTotalTax]
	--	,[dblTotal]
	--	,[intServiceChargeAccountId]
	--	,[intInventoryShipmentItemId]
	--	,[intSalesOrderDetailId]
	--	,[intShipmentPurchaseSalesContractId]	
	--	,[intSiteId]
	--	,[strBillingBy]
	--	,[dblPercentFull]
	--	,[dblNewMeterReading]
	--	,[dblPreviousMeterReading]
	--	,[dblConversionFactor]
	--	,[intPerformerId]
	--	,[intContractHeaderId]
	--	,[strContractNumber]
	--	,[strMaintenanceType]
	--	,[strFrequency]
	--	,[dtmMaintenanceDate]
	--	,[dblMaintenanceAmount]
	--	,[dblLicenseAmount]
	--	,[intContractDetailId]
	--	,[intTicketId]
	--	,[ysnLeaseBilling]

	--)
	EXEC dbo.[uspARGetItemsFromInvoice]
			@intInvoiceId = @TransactionId

	-- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
	UPDATE @ItemsFromInvoice
		SET [dblQtyShipped] = [dblQtyShipped] * CASE WHEN @post = 1 THEN 1 ELSE -1 END 
END

--Contracts
EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @userId

--Prepaids

EXEC dbo.[uspARUpdatePrepaymentAndCreditMemo] @TransactionId, @post

UPDATE ARID
SET
	ARID.dblContractBalance = CTCD.dblBalance
FROM
	dbo.tblARInvoiceDetail ARID
INNER JOIN
	dbo.tblCTContractDetail  CTCD
	ON ARID.intContractDetailId = CTCD.intContractDetailId
WHERE 
	ARID.dblContractBalance <> CTCD.dblBalance
	AND ARID.intInvoiceId = @TransactionId

--Committed QUatities
EXEC dbo.[uspARUpdateCommitted] @TransactionId, @post, @userId, 1

--Reserved QUatities
EXEC dbo.[uspARUpdateReservedStock] @TransactionId, @post, @userId, 1

--In Transit Outbound Quantities 
EXEC dbo.[uspARUpdateInTransit] @TransactionId, @post, 0

--Sales Order Status
EXEC dbo.[uspARUpdateSOStatusFromInvoice] @TransactionId, @ForDelete

DECLARE	@EntityCustomerId INT

SELECT TOP 1 @EntityCustomerId = intEntityCustomerId FROM tblARInvoice WHERE intInvoiceId = @TransactionId

--Update Total AR
EXEC dbo.[uspARUpdateCustomerTotalAR] @InvoiceId = @TransactionId, @CustomerId = @EntityCustomerId

--Patronage
DECLARE	@successfulCount INT
		,@invalidCount INT
		,@success BIT
		

EXEC [dbo].[uspPATInvoiceToCustomerVolume]
	 @intEntityCustomerId	= @EntityCustomerId
	,@intInvoiceId			= @TransactionId
	,@ysnPosted				= @post
	,@successfulCount		= @successfulCount OUTPUT
	,@invalidCount			= @invalidCount OUTPUT
	,@success				= @success OUTPUT

--Audit Log          
EXEC dbo.uspSMAuditLog 
	 @keyValue			= @TransactionId					-- Primary Key Value of the Invoice. 
	,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
	,@entityId			= @UserEntityID						-- Entity Id.
	,@actionType		= @actionType						-- Action Type
	,@changeDescription	= ''								-- Description
	,@fromValue			= ''								-- Previous Value
	,@toValue			= ''								-- New Value
