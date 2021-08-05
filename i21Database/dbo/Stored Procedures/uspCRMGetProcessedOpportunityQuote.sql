﻿CREATE PROCEDURE [dbo].[uspCRMGetProcessedOpportunityQuote]
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	declare @queryResult cursor;
	declare @intSalesOrderId int;
	declare @intOpportunityId int;

	begin try
		set @queryResult = cursor for
			select
				a.intOpportunityId
				,c.intSalesOrderId
			from
				tblCRMOpportunityQuote a
				inner join tblSOSalesOrder b on b.intSalesOrderId = a.intSalesOrderId 
				inner join tblSOSalesOrder c on c.strSalesOrderOriginId = b.strSalesOrderNumber
			where
				b.strTransactionType = 'Quote'

		OPEN @queryResult
		fetch next
		from
			@queryResult
		into
			@intOpportunityId
			,@intSalesOrderId

		while @@FETCH_STATUS = 0
		begin
			if not exists (select * from tblCRMOpportunityQuote where intOpportunityId = @intOpportunityId and intSalesOrderId = @intSalesOrderId)
			begin
				insert into tblCRMOpportunityQuote (intOpportunityId, intSalesOrderId, intConcurrencyId) values (@intOpportunityId, @intSalesOrderId, 1)
			end

			fetch next
			from
				@queryResult
			into
				@intOpportunityId
				,@intSalesOrderId

		end

		close @queryResult
		deallocate @queryResult

	end try
	begin catch
		/*Don't put anything here..*/
	end catch

END