
CREATE PROCEDURE [dbo].[uspAGCalculateWOTotal]
@intAGWorkOrderId int,
@newAGTotal numeric(18,6) = 0.000000 output ,
@newAGSubTotal numeric(18,6) = 0.000000 output 

as

begin

SET QUOTED_IDENTIFIER OFF    
	SET ANSI_NULLS ON    
	SET NOCOUNT ON    
	SET XACT_ABORT ON    
	SET ANSI_WARNINGS OFF


    DECLARE @lineTotal NUMERIC(18,6) = 0.000000
	DECLARE @linePrice NUMERIC(18,6) = 0.000000
	


		--UPDATE HEADER , loop through details
		declare @table table
		(	
			id int identity(1,1),
			intWorkOrderId int,
			intWorkOrderDetailId int,
			dblTotal numeric(18,6)
		)

		declare @dblSubTotal decimal(18,6) = 0.000000;
		declare @dblShipping decimal(18,6) = 0.000000;
		declare @dblTax      decimal(18,6) = 0.000000;

		

		insert into @table (intWorkOrderId, intWorkOrderDetailId, dblTotal)
			select intWorkOrderId,intWorkOrderDetailId,dblTotal from tblAGWorkOrderDetail where intWorkOrderId = @intAGWorkOrderId

		while exists(select top 1 1 from @table)
		begin
			declare @id int = (select top 1 id from @table)

			declare @workOrderId int
			declare @workOrderDetailId int
			declare @dblTotal numeric(18,6)

			select 
				@workOrderId = intWorkOrderId,
				@workOrderDetailId = intWorkOrderDetailId,
				@dblTotal = dblTotal 
			from @table where id = @id

			set @dblSubTotal = (@dblSubTotal + isnull(@dblTotal, 0))

			delete from @table where id = @id
		end

		select 
			@dblShipping = dblShipping,
			@dblTax		 = dblTax 
		from
			tblAGWorkOrder where intWorkOrderId = @intAGWorkOrderId

		DECLARE @total numeric(18,6) = (@dblSubTotal + @dblShipping + @dblTax)

		UPDATE tblAGWorkOrder
			SET dblWorkOrderSubtotal = @dblSubTotal,
				dblWorkOrderTotal = @total --(@dblSubTotal + @dblShipping + @dblTax)
		WHERE intWorkOrderId = @intAGWorkOrderId

		select 
			@newAGTotal = @total,
			@newAGSubTotal = @dblSubTotal


end