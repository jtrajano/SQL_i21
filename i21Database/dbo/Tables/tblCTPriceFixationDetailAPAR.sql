CREATE TABLE [dbo].[tblCTPriceFixationDetailAPAR]
(
	intPriceFixationDetailAPARId	INT IDENTITY NOT NULL,
	intPriceFixationDetailId		INT	NOT NULL,
	intBillId						INT,
	intBillDetailId					INT,
	intInvoiceId					INT,
	intInvoiceDetailId				INT,
	ysnReverse						BIT NULL,
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

-- CREATE TRIGGER [dbo].[trgCTPriceFixationDetailAPARInsert]
--     ON [dbo].[tblCTPriceFixationDetailAPAR]
--     AFTER INSERT
-- AS
-- BEGIN
--        SET NOCOUNT ON;

-- 	   DECLARE @ysnVoucher BIT
-- 	   DECLARE @intDetailId INT
-- 	   DECLARE @intContractHeaderId INT
-- 	   DECLARE @intContractDetailId INT
-- 	   DECLARE @strProcess NVARCHAR(20)
-- 	   DECLARE @contractDetails AS [dbo].[ContractDetailTable]

--        SELECT @ysnVoucher = CASE WHEN intBillId IS NOT NULL THEN 1 ELSE 0 END
--        FROM INSERTED

-- 	   IF @ysnVoucher = 1
-- 	   BEGIN
-- 			SELECT @intDetailId = intBillDetailId
-- 			FROM INSERTED

-- 			SELECT @intContractHeaderId = intContractHeaderId
-- 				  ,@intContractDetailId = intContractDetailId 
-- 			FROM tblAPBillDetail
-- 			WHERE intBillDetailId = @intDetailId
-- 	   END
-- 	   ELSE
-- 	   BEGIN
-- 			SELECT @intDetailId = intInvoiceDetailId
-- 			FROM INSERTED

-- 			SELECT @intContractHeaderId = intContractHeaderId
-- 				  ,@intContractDetailId = intContractDetailId 
-- 			FROM tblARInvoiceDetail
-- 			WHERE intInvoiceDetailId = @intDetailId
-- 	   END

-- 	   SELECT @strProcess = CASE WHEN @ysnVoucher = 1 THEN 'Voucher' ELSE 'Invoice' END

-- 	   EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
-- 							@intContractDetailId 	= 	@intContractDetailId,
-- 							@strSource			 	= 	'Pricing',
-- 							@strProcess			 	= 	@strProcess,
-- 							@contractDetail 		= 	@contractDetails
-- END

-- GO

-- CREATE TRIGGER [dbo].[trgCTPriceFixationDetailAPARInsertDelete]
-- 	ON [dbo].[tblCTPriceFixationDetailAPAR]
--     AFTER DELETE
-- AS
-- BEGIN	
--        SET NOCOUNT ON;

-- 	   DECLARE @ysnVoucher BIT
-- 	   DECLARE @intDetailId INT
-- 	   DECLARE @intContractHeaderId INT
-- 	   DECLARE @intContractDetailId INT
-- 	   DECLARE @strProcess NVARCHAR(20)
-- 	   DECLARE @contractDetails AS [dbo].[ContractDetailTable]

-- 	   IF NOT EXISTS (SELECT TOP 1 1 FROM DELETED)
-- 	   BEGIN
-- 			RETURN
-- 	   END

--        SELECT @ysnVoucher = CASE WHEN intBillId IS NOT NULL THEN 1 ELSE 0 END
--        FROM DELETED

-- 	   IF @ysnVoucher = 1
-- 	   BEGIN
-- 			SELECT @intContractHeaderId = 	c.intContractHeaderId
-- 				  ,@intContractDetailId = 	c.intContractDetailId
-- 			FROM DELETED a
-- 			INNER JOIN tblCTPriceFixationDetail b ON a.intPriceFixationDetailId = b.intPriceFixationDetailId
-- 			INNER JOIN tblCTPriceFixation c ON b.intPriceFixationId = c.intPriceFixationId
-- 	   END
-- 	   ELSE
-- 	   BEGIN
-- 	   		SELECT @intContractHeaderId = 	c.intContractHeaderId
-- 				  ,@intContractDetailId = 	c.intContractDetailId
-- 			FROM DELETED a
-- 			INNER JOIN tblCTPriceFixationDetail b ON a.intPriceFixationDetailId = b.intPriceFixationDetailId
-- 			INNER JOIN tblCTPriceFixation c ON b.intPriceFixationId = c.intPriceFixationId
-- 	   END

-- 	   SELECT @strProcess = CASE WHEN @ysnVoucher = 1 THEN 'Voucher Delete' ELSE 'Invoice Delete' END

-- 	   EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
-- 							@intContractDetailId 	= 	@intContractDetailId,
-- 							@strSource			 	= 	'Pricing',
-- 							@strProcess			 	= 	@strProcess,
-- 							@contractDetail 		= 	@contractDetails
-- END

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
			,@UserId = intEntityUserId
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
