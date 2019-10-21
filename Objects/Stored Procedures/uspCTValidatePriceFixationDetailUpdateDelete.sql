﻿CREATE PROCEDURE [dbo].[uspCTValidatePriceFixationDetailUpdateDelete]
		
	@intPriceFixationId			INT = NULL,
	@intPriceFixationDetailId	INT = NULL,
	@intPriceFixationTicketId	INT = NULL
	
AS
BEGIN TRY
	
	DECLARE @ErrMsg		NVARChAR(MAX),
			@List		NVARChAR(MAX)

	SELECT  @List = COALESCE(@List + ',', '') + BL.strBillId
	FROM	tblCTPriceFixationDetailAPAR	DA LEFT
	JOIN	vyuCTPriceFixationTicket		FT	ON	FT.intDetailId				=	DA.intBillDetailId
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblAPBill						BL	ON	BL.intBillId				=	DA.intBillId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	-- Perfomance hit
	AND		ISNULL(FT.intPriceFixationTicketId, 0)	=   CASE WHEN @intPriceFixationTicketId IS NOT NULL THEN @intPriceFixationTicketId ELSE ISNULL(FT.intPriceFixationTicketId,0) END
	AND		BL.ysnPosted = 1

	SELECT  @List = COALESCE(@List + ',', '') + IV.strInvoiceNumber
	FROM	tblCTPriceFixationDetailAPAR	DA LEFT
	JOIN	vyuCTPriceFixationTicket		FT	ON	FT.intDetailId				=	DA.intBillDetailId
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblARInvoice					IV	ON	IV.intInvoiceId				=	DA.intInvoiceId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	-- Perfomance hit
	AND		ISNULL(FT.intPriceFixationTicketId, 0)	=   CASE WHEN @intPriceFixationTicketId IS NOT NULL THEN @intPriceFixationTicketId ELSE ISNULL(FT.intPriceFixationTicketId,0) END
	AND		IV.ysnPosted = 1

	IF ISNULL(@List,'') <> ''
	BEGIN
		SET @ErrMsg = 'Cannot delete pricing as following Invoice/Vouchers are available. ' + @List + '. Unpost those Invoice/Vocuher to continue delete the price.'
		RAISERROR(@ErrMsg,16,1)
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH