CREATE TABLE [dbo].[tblCTPriceFixationDetailAPAR]
(
	intPriceFixationDetailAPARId	INT IDENTITY NOT NULL,
	intPriceFixationDetailId		INT	NOT NULL,
	intBillId						INT,
	intBillDetailId					INT,
	intInvoiceId					INT,
	intInvoiceDetailId				INT,
	ysnMarkDelete					BIT,
	[intConcurrencyId]				INT NOT NULL,

	CONSTRAINT [PK_tblCTPriceFixationDetailAPAR_intPriceFixationDetailAPARId] PRIMARY KEY CLUSTERED (intPriceFixationDetailAPARId ASC),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblCTPriceFixationDetail_intPriceFixationDetailId] FOREIGN KEY (intPriceFixationDetailId) REFERENCES tblCTPriceFixationDetail(intPriceFixationDetailId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblAPBill_intBillId] FOREIGN KEY (intBillId) REFERENCES tblAPBill(intBillId),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblAPBillDetail_intBillDetailId] FOREIGN KEY (intBillDetailId) REFERENCES tblAPBillDetail(intBillDetailId),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblARInvoice_intInvoiceId] FOREIGN KEY (intInvoiceId) REFERENCES tblARInvoice(intInvoiceId),
	CONSTRAINT [FK_tblCTPriceFixationDetailAPAR_tblARInvoiceDetail_intInvoiceDetailId] FOREIGN KEY (intInvoiceDetailId) REFERENCES tblARInvoiceDetail(intInvoiceDetailId) ON DELETE CASCADE
)

GO

CREATE TRIGGER [dbo].[trgCTPriceFixationDetailAPARInsertDelete]
	ON [dbo].[tblCTPriceFixationDetailAPAR]
    AFTER DELETE
AS
BEGIN	
    SET NOCOUNT ON;

    declare @intPriceFixationId int;
    declare @intContractPriceId int;
    declare @intPriceFixationDetailId int;
    declare @intInvoiceDetailId int;
	declare @dblPricedQuantity numeric(18,6);
	declare @dblInvoiceDetailQuantity numeric(18,6);
	declare @intContractDetailId int;
	declare @UserId int = null;

	select
		@intInvoiceDetailId = intInvoiceDetailId
		,@intPriceFixationDetailId = intPriceFixationDetailId
	from
		DELETED
	where isnull(ysnMarkDelete,0) <> 1;
	
	if (@intInvoiceDetailId is not null)
	BEGIN

		SELECT top 1
			@dblInvoiceDetailQuantity = dblQtyShipped
			,@UserId = null
		FROM
			tblARTransactionDetail
		where
			intTransactionDetailId = @intInvoiceDetailId
		ORDER BY intId DESC

		set @dblInvoiceDetailQuantity = isnull(@dblInvoiceDetailQuantity,0)

		exec uspCTProcessInvoiceDelete
			@dblInvoiceDetailQuantity = @dblInvoiceDetailQuantity
			,@intPriceFixationDetailId = @intPriceFixationDetailId
			,@UserId = @UserId
	
	END

END

GO