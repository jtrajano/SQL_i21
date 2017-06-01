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
		,@intTransactionId INT
		,@intUserId INT
		,@ysnPost BIT
--THIS IS A HICCUP		
SET @intTransactionId = @TransactionId
SET @intUserId = @userId
SET @ysnPost = @post
SET @UserEntityID = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WITH (NOLOCK) WHERE intEntityId = @intUserId), @intUserId) 
SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
SELECT @ForDelete = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END

-- Get the details from the invoice 
BEGIN 
	DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
	INSERT INTO @ItemsFromInvoice 	
	EXEC dbo.[uspARGetItemsFromInvoice] @intInvoiceId = @intTransactionId

	-- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
	UPDATE @ItemsFromInvoice SET [dblQtyShipped] = [dblQtyShipped] * CASE WHEN @ysnPost = 1 THEN 1 ELSE -1 END 
END

--Contracts
EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @intUserId

--Prepaids

EXEC dbo.[uspARUpdatePrepaymentAndCreditMemo] @intTransactionId, @ysnPost

UPDATE ARID
SET
	ARID.dblContractBalance = CTCD.dblBalance
FROM
	(SELECT intInvoiceId, dblContractBalance, intContractDetailId FROM dbo.tblARInvoiceDetail WITH (NOLOCK) ) ARID
INNER JOIN
	(SELECT intContractDetailId, dblBalance FROM dbo.tblCTContractDetail WITH (NOLOCK))  CTCD
	ON ARID.intContractDetailId = CTCD.intContractDetailId
WHERE 
	ARID.intInvoiceId = @intTransactionId
	AND ARID.dblContractBalance <> CTCD.dblBalance

--Sales Order Status 
EXEC dbo.[uspARUpdateSOStatusFromInvoice] @intTransactionId, @ForDelete

--Committed QUatities - should call [[uspARUpdateSOStatusFromInvoice]] first
EXEC dbo.[uspARUpdateCommitted] @intTransactionId, @ysnPost, @intUserId, 1

--Reserved QUatities
EXEC dbo.[uspARUpdateReservedStock] @intTransactionId, 0, @intUserId, 1, @ysnPost

--In Transit Outbound Quantities 
EXEC dbo.[uspARUpdateInTransit] @intTransactionId, @ysnPost, 0

DECLARE	@EntityCustomerId INT
		,@LoadId INT

SELECT TOP 1 
	@EntityCustomerId	= intEntityCustomerId
	,@LoadId			= intLoadId
FROM
	tblARInvoice WITH (NOLOCK)
WHERE
	intInvoiceId = @intTransactionId

--Update Total AR
EXEC dbo.[uspARUpdateCustomerTotalAR] @InvoiceId = @intTransactionId, @CustomerId = @EntityCustomerId


--Update LG - Load Shipment
EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost]
	@InvoiceId	= @intTransactionId
	,@Post		= @ysnPost
	,@LoadId	= @LoadId
	,@UserId	= @intUserId

--Patronage
DECLARE	@successfulCount INT
		,@invalidCount INT
		,@success BIT
		

EXEC [dbo].[uspPATInvoiceToCustomerVolume]
	 @intEntityCustomerId	= @EntityCustomerId
	,@intInvoiceId			= @intTransactionId
	,@ysnPosted				= @ysnPost
	,@successfulCount		= @successfulCount OUTPUT
	,@invalidCount			= @invalidCount OUTPUT
	,@success				= @success OUTPUT

--Audit Log          
EXEC dbo.uspSMAuditLog 
	 @keyValue			= @intTransactionId					-- Primary Key Value of the Invoice. 
	,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
	,@entityId			= @UserEntityID						-- Entity Id.
	,@actionType		= @actionType						-- Action Type
	,@changeDescription	= ''								-- Description
	,@fromValue			= ''								-- Previous Value
	,@toValue			= ''								-- New Value
