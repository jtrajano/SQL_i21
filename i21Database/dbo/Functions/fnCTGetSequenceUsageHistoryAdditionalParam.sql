CREATE FUNCTION [dbo].[fnCTGetSequenceUsageHistoryAdditionalParam]
(
	@intContractDetailId	INT,
	@strScreenName			NVARCHAR(50),
	@intExternalId			INT,
	@intUserId				INT
)
RETURNS @returntable	TABLE
(
	intExternalHeaderId	INT,
	intContractHeaderId	INT,
	intContractSeq		INT,
	strNumber			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strUserName			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strHeaderIdColumn	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	DECLARE @intExternalHeaderId	INT,
			@intContractHeaderId	INT,
			@intContractSeq			INT,
			@strNumber				NVARCHAR(MAX),
			@strUserName			NVARCHAR(MAX), 
			@strHeaderIdColumn		NVARCHAR(MAX) 

	SELECT	@intContractHeaderId	=	intContractHeaderId,
			@intContractSeq			=	intContractSeq 
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId
	
	SELECT	@strUserName			=	strUserName
	FROM	tblSMUserSecurity 
	WHERE	[intEntityId]	=	@intUserId
	
	IF	@strScreenName IN ('Inventory Receipt', 'Receipt Return')
	BEGIN
		SELECT	@intExternalHeaderId			=	HR.intInventoryReceiptId,
				@strNumber						=	HR.strReceiptNumber,
				@strHeaderIdColumn				=	'intInventoryReceiptId'
		FROM	tblICInventoryReceiptItem		DL
		JOIN	tblICInventoryReceipt			HR	ON	HR.intInventoryReceiptId	=	DL.intInventoryReceiptId
		WHERE	DL.intInventoryReceiptItemId	=	@intExternalId
	END
	ELSE IF @strScreenName = 'Invoice'
	BEGIN
		SELECT	@intExternalHeaderId	=	HR.intInvoiceId,
				@strNumber				=	HR.strInvoiceNumber,
				@strHeaderIdColumn		=	'intInvoiceId'
		FROM	tblARInvoiceDetail		DL
		JOIN	tblARInvoice			HR	ON	HR.intInvoiceId	=	DL.intInvoiceId 
		WHERE	DL.intInvoiceDetailId	=	@intExternalId
	END
	ELSE IF @strScreenName = 'Load Schedule'
	BEGIN
		SELECT	@intExternalHeaderId	=	HR.intLoadId,
				@strNumber				=	HR.strLoadNumber,
				@strHeaderIdColumn		=	'intLoadId'
		FROM	tblLGLoadDetail			DL
		JOIN	tblLGLoad				HR	ON	HR.intLoadId	=	DL.intLoadId 
		WHERE	DL.intLoadDetailId		=	@intExternalId
	END
	ELSE IF @strScreenName = 'Transport Purchase'
	BEGIN
		SELECT	@intExternalHeaderId			=	HR.intLoadHeaderId,
				@strNumber						=	HR.strTransaction,
				@strHeaderIdColumn				=	'intLoadHeaderId'
		FROM	tblTRLoadReceipt				DL
		JOIN	tblTRLoadHeader					HR	ON	HR.intLoadHeaderId	=	DL.intLoadHeaderId
		WHERE	DL.intLoadReceiptId				=	@intExternalId
	END
	ELSE IF @strScreenName = 'Transport Sale'
	BEGIN
		SELECT	@intExternalHeaderId			=	HR.intLoadHeaderId,
				@strNumber						=	HR.strTransaction,
				@strHeaderIdColumn				=	'intLoadHeaderId'
		FROM	tblTRLoadDistributionDetail		DD
		JOIN	tblTRLoadDistributionHeader		DL	ON	DL.intLoadDistributionHeaderId	=	DD.intLoadDistributionHeaderId 
		JOIN	tblTRLoadHeader					HR	ON	HR.intLoadHeaderId				=	DL.intLoadHeaderId
		WHERE	DD.intLoadDistributionDetailId	=	@intExternalId
	END
	ELSE IF @strScreenName = 'Scale'
	BEGIN
		SELECT	@intExternalHeaderId	=	HR.intTicketId,
				@strNumber				=	HR.strTicketNumber,
				@strHeaderIdColumn		=	'intTicketId'
		FROM	tblSCTicket				HR
		WHERE	HR.intTicketId			=	@intExternalId
		AND		strTicketStatus <> 'V'
	END
	ELSE IF @strScreenName = 'Purchase Order'
	BEGIN
		SELECT	@intExternalHeaderId	=	HR.intPurchaseId,
				@strNumber				=	HR.strPurchaseOrderNumber,
				@strHeaderIdColumn		=	'intPurchaseId'
		FROM	tblPOPurchaseDetail		DL
		JOIN	tblPOPurchase			HR	ON	HR.intPurchaseId	=	DL.intPurchaseId 
		WHERE	DL.intPurchaseDetailId	=	@intExternalId
	END
	ELSE IF @strScreenName = 'Settle Storage'
	BEGIN
		SELECT	@intExternalHeaderId	=	HR.intCustomerStorageId,
				@strNumber				=	HR.strStorageTicketNumber,
				@strHeaderIdColumn		=	'intCustomerStorageId'
		FROM	tblGRCustomerStorage	HR	
		WHERE	HR.intCustomerStorageId	=	@intExternalId
	END
	ELSE IF @strScreenName = 'Transfer Storage'
	BEGIN
		SELECT	@intExternalHeaderId	=	HR.intCustomerStorageId,
				@strNumber				=	HR.strStorageTicketNumber,
				@strHeaderIdColumn		=	'intCustomerStorageId'
		FROM	tblGRCustomerStorage	HR	
		WHERE	HR.intCustomerStorageId	=	@intExternalId
	END
	ELSE IF @strScreenName = 'Inventory Shipment'
	BEGIN
		SELECT	@intExternalHeaderId			=	HR.intInventoryShipmentId,
				@strNumber						=	HR.strShipmentNumber,
				@strHeaderIdColumn				=	'intInventoryShipmentId'
		FROM	tblICInventoryShipmentItem		DL
		JOIN	tblICInventoryShipment			HR	ON	HR.intInventoryShipmentId	=	DL.intInventoryShipmentId
		WHERE	DL.intInventoryShipmentItemId	=	@intExternalId
	END
	ELSE IF @strScreenName = 'Contract AdjustMent'
	BEGIN
		SELECT	@intExternalHeaderId			=	CA.intAdjustmentId,
				@strNumber						=	CA.strAdjustmentNo,
				@strHeaderIdColumn				=	'intAdjustmentId'
		FROM	tblCTContractAdjustment CA
		WHERE	CA.intAdjustmentId	=	@intExternalId
	END
	
	IF ISNULL(@strNumber,'')  = ''
	BEGIN
		SELECT TOP 1 @strNumber = strNumber FROM tblCTSequenceUsageHistory WHERE strScreenName = @strScreenName AND intExternalId = @intExternalId
	END
	
	INSERT @returntable
	(
			intExternalHeaderId, 
			intContractHeaderId, 
			intContractSeq,
			strNumber,
			strUserName,
			strHeaderIdColumn
	)
	SELECT	@intExternalHeaderId, 
			@intContractHeaderId, 
			@intContractSeq,
			@strNumber,
			@strUserName,
			@strHeaderIdColumn
		
	RETURN;
END