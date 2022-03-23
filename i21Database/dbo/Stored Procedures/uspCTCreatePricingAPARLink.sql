CREATE PROCEDURE [dbo].[uspCTCreatePricingAPARLink]
	@intPriceFixationDetailId int --Price Layer ID
	,@intHeaderId int --Invoice/Bill ID
	,@intDetailId int --Invoice Detail/Bill Detail ID
	,@intSourceHeaderId int --Inventory Shipment/Inventory Receipt ID
	,@intSourceDetailId int --Inventory Shipment Item/Inventory Receipt Item ID
	,@dblQuantity numeric(18,6) -- Transaction Quantity
	,@strScreen nvarchar(50) -- the value must be 'Invoice' or 'Voucher'
	,@ysnReturn bit = 0

as
begin

	declare
		@error nvarchar(max);

	begin try

		INSERT INTO tblCTPriceFixationDetailAPAR(
			intPriceFixationDetailId
			,intBillId
			,intBillDetailId
			,intInvoiceId
			,intInvoiceDetailId
			,intSourceId
			,dblQuantity
			,dtmCreatedDate
			,ysnMarkDelete
			,ysnReturn
			,intConcurrencyId  
		)  
		SELECT   
			intPriceFixationDetailId = @intPriceFixationDetailId  
			,intBillId = (case when @strScreen = 'Voucher' then @intHeaderId else null end)  
			,intBillDetailId = (case when @strScreen = 'Voucher' then @intDetailId else null end)  
			,intInvoiceId = (case when @strScreen = 'Invoice' then @intHeaderId else null end)  
			,intInvoiceDetailId = (case when @strScreen = 'Invoice' then @intDetailId else null end)  
			,intSourceId = @intSourceDetailId
			,dblQuantity = @dblQuantity
			,dtmCreatedDate = GETUTCDATE()
			,ysnMarkDelete = null
			,ysnReturn = @ysnReturn
			,intConcurrencyId = 1 

	end try
	begin catch
		set @error = ERROR_MESSAGE()  
		raiserror (@error,18,1,'WITH NOWAIT')  
	end catch
end