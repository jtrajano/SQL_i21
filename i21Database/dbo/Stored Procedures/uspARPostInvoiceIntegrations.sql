﻿CREATE PROCEDURE [dbo].[uspARPostInvoiceIntegrations]
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
	EXEC dbo.[uspARGetItemsFromInvoice] @intInvoiceId = @intTransactionId, @forContract = 1

	-- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
	UPDATE @ItemsFromInvoice SET [dblQtyShipped] = [dblQtyShipped] * CASE WHEN @ysnPost = 1 THEN 1 ELSE -1 END 
END

--Contracts 
IF(NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE intTicketId IS NOT NULL and intInvoiceId = @intTransactionId))
BEGIN
	EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @intUserId
END
--Prepaids

--EXEC dbo.[uspARUpdatePrepaymentAndCreditMemo] @intTransactionId, @ysnPost
--Auto Apply
IF @ysnPost = 1
	BEGIN
		DECLARE @tblInvoiceIds Id
		INSERT INTO @tblInvoiceIds
		SELECT @intTransactionId

		EXEC dbo.uspARAutoApplyPrepaids @tblInvoiceIds = @tblInvoiceIds
	END
ELSE
	BEGIN
		DELETE CF 
		FROM tblCMUndepositedFund CF
		INNER JOIN tblARInvoice I ON CF.intSourceTransactionId = I.intInvoiceId AND CF.strSourceTransactionId = I.strInvoiceNumber
		WHERE CF.strSourceSystem = 'AR'
		AND I.intInvoiceId = @intTransactionId
	END

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

--Committed QUatities
EXEC dbo.[uspARUpdateCommitted] @intTransactionId, @ysnPost, @intUserId, 1

--Reserved QUatities
-- EXEC dbo.[uspARUpdateReservedStock] @intTransactionId, 0, @intUserId, 1, @ysnPost

--In Transit Outbound Quantities 
EXEC dbo.[uspARUpdateInTransit] @intTransactionId, @ysnPost, 0

--In Transit Direct Quantities
EXEC dbo.[uspARUpdateInTransitDirect] @intTransactionId, @ysnPost

DECLARE	@EntityCustomerId INT
		,@LoadId INT

SELECT TOP 1 
	@EntityCustomerId	= intEntityCustomerId
	,@LoadId			= intLoadId
FROM
	tblARInvoice WITH (NOLOCK)
WHERE
	intInvoiceId = @intTransactionId

--Update LG - Load Shipment
EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost]
	@InvoiceId	= @intTransactionId
	,@Post		= @ysnPost
	,@LoadId	= @LoadId
	,@UserId	= @intUserId

--Patronage
DECLARE	@successfulCount INT
	   ,@strTransactionId NVARCHAR(MAX)

SET @strTransactionId = CONVERT(NVARCHAR(MAX), @intTransactionId)

EXEC [dbo].[uspPATGatherVolumeForPatronage]
	 @transactionIds	= @strTransactionId
	,@post				= @ysnPost
	,@type				= 2
	,@successfulCount	= @successfulCount OUTPUT
-- Update CT - Sequence Balance
EXEC [uspARInvoiceUpdateSequenceBalance] 
	 @post = @ysnPost,
	 @TransactionId = @intTransactionId,
	 @UserId = @intUserId

--Audit Log          
EXEC dbo.uspSMAuditLog 
	 @keyValue			= @intTransactionId					-- Primary Key Value of the Invoice. 
	,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
	,@entityId			= @UserEntityID						-- Entity Id.
	,@actionType		= @actionType						-- Action Type
	,@changeDescription	= ''								-- Description
	,@fromValue			= ''								-- Previous Value
	,@toValue			= ''								-- New Value