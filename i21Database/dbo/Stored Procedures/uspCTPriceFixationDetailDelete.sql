CREATE PROCEDURE [dbo].[uspCTPriceFixationDetailDelete]
	
	@intPriceFixationId			INT = NULL,
	@intPriceFixationDetailId	INT = NULL,
	@intUserId					INT
	
AS
BEGIN TRY
	
	DECLARE @ErrMsg	NVARChAR(MAX),
			@List	NVARChAR(MAX),
			@Id		INT

	SELECT  BL.intBillId AS Id
	INTO	#ItemBill
	FROM	tblCTPriceFixationDetailAPAR	DA
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblAPBill						BL	ON	BL.intBillId				=	DA.intBillId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	AND		ISNULL(BL.ysnPosted,0) = 0
	
	SELECT @Id = MIN(Id) FROM #ItemBill
	WHILE ISNULL(@Id,0) > 0
	BEGIN
		EXEC uspAPDeleteVoucher @Id,@intUserId
		SELECT @Id = MIN(Id) FROM #ItemBill WHERE Id > @Id
	END

	SELECT @List = NULL

	SELECT  DA.intInvoiceId AS Id
	INTO	#ItemInvoice
	FROM	tblCTPriceFixationDetailAPAR	DA
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblARInvoice					IV	ON	IV.intInvoiceId				=	DA.intInvoiceId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	AND		ISNULL(IV.ysnPosted,0) = 0

	SELECT @Id = MIN(Id) FROM #ItemInvoice
	WHILE ISNULL(@Id,0) > 0
	BEGIN
		EXEC uspARDeleteInvoice @Id,@intUserId
		SELECT @Id = MIN(Id) FROM #ItemInvoice WHERE Id > @Id
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH