
IF (OBJECT_ID(N'dbo.trgCTPriceFixationDetailAPARDelete') IS NOT NULL)
BEGIN
     exec ('disable trigger dbo.trgCTPriceFixationDetailAPARDelete on tblCTPriceFixationDetailAPAR');
END

IF OBJECT_ID(N'tblCTMiscellaneous') IS NOT NULL
BEGIN
	IF not EXISTS
		(
			SELECT
				1
			FROM
				sys.columns 
			WHERE
				Name = N'ysnFixedPriceAndInvoiceLink'
				AND Object_ID = Object_ID(N'tblCTMiscellaneous')
		)
		BEGIN
			exec('alter table tblCTMiscellaneous add ysnFixedPriceAndInvoiceLink bit not null default 0');
		END
END

IF OBJECT_ID(N'tempdb..#tmpB') IS NOT NULL
BEGIN
	exec('drop table #tmpB');
END	
create table #tmpB (intPriceFixationDetailAPARId int);

IF OBJECT_ID(N'tempdb..#tmpA') IS NOT NULL
BEGIN
	exec('drop table #tmpA');
END
create table #tmpA (intValue int);
IF OBJECT_ID(N'tblCTMiscellaneous') IS NOT NULL
BEGIN
	exec('insert into #tmpA select top 1 1 from tblCTMiscellaneous where ysnFixedPriceAndInvoiceLink = 1');
END

if exists (select top 1 1 from #tmpA)
begin
	goto _Exit;
end

	IF OBJECT_ID(N'tblCTPriceFixationDetailAPAR') IS NOT NULL
	begin
		IF NOT EXISTS
			(
				SELECT
					1
				FROM
					sys.columns 
				WHERE
					Name = N'ysnPreDeploymentFix'
					AND Object_ID = Object_ID(N'tblCTPriceFixationDetailAPAR')
			)
			BEGIN
				exec('alter table tblCTPriceFixationDetailAPAR add ysnPreDeploymentFix bit null default 0');
			END
	end



	IF OBJECT_ID(N'tblCTContractDetail') IS NOT NULL
	begin
		exec ('

			declare @InvoiceDetail table (
				intInvoiceDetailId int
				,intInvoiceId int
				,intContractDetailId int
				,dblPrice numeric(18,6)
				,dblQtyShipped numeric(18,6)
			)

			declare
				@intInvoiceDetailId int = 0
				,@intActiveInvoiceDetailId int = 0
				,@intInvoiceId int
				,@intContractDetailId int
				,@dblPrice numeric(18,6)
				,@dblQtyShipped numeric(18,6)
				,@intPriceFixationDetailId int
				;

			insert into @InvoiceDetail
			select distinct
				intInvoiceDetailId = tbl.intInvoiceDetailId
				,intInvoiceId = tbl.intInvoiceId
				,intContractDetailId = tbl.intContractDetailId
				,dblPrice = tbl.dblPrice
				,dblQtyShipped = tbl.dblQtyShipped from
			(
			select distinct di.intInvoiceDetailId, di.intInvoiceId, di.intContractDetailId, di.dblPrice, di.dblQtyShipped, pfd.intPriceFixationDetailId, ar.intPriceFixationDetailAPARId
			from
				tblCTContractDetail cd
				join tblARInvoiceDetail di on isnull(di.intContractHeaderId,0) = cd.intContractHeaderId and isnull(di.intContractDetailId,0) = cd.intContractDetailId
				join tblCTPriceFixation pf on pf.intContractHeaderId = cd.intContractHeaderId and pf.intContractDetailId = cd.intContractDetailId
				join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
				left join tblCTPriceFixationDetailAPAR ar on ar.intInvoiceDetailId = di.intInvoiceDetailId and ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
			where
				pfd.dblCashPrice = di.dblPrice
			)tbl
			where tbl.intPriceFixationDetailId is not null and tbl.intPriceFixationDetailAPARId is null

			select @intInvoiceDetailId = min(intInvoiceDetailId) from @InvoiceDetail where intInvoiceDetailId > @intInvoiceDetailId;
			while (@intInvoiceDetailId is not null)
			begin
				select @intInvoiceId = intInvoiceId, @intContractDetailId = intContractDetailId, @dblPrice = dblPrice, @dblQtyShipped = dblQtyShipped from @InvoiceDetail where intInvoiceDetailId = @intInvoiceDetailId;

				select @intPriceFixationDetailId = tbl.intPriceFixationDetailId
				from
				(
				select top 1
					pfd.intPriceFixationDetailId
					,pfd.dblCashPrice
					,pfd.dblQuantity
					,dblQtyShipped = isnull(sum(di.dblQtyShipped),0)
				from
					tblCTPriceFixation pf 
					join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
					left join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
					left join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId and di.intInventoryShipmentChargeId is null
				where
					pf.intContractDetailId = @intContractDetailId
				group by
					pfd.intPriceFixationDetailId
					,pfd.dblCashPrice
					,pfd.dblQuantity
				)tbl
				where
					tbl.dblCashPrice = @dblPrice		
					and @dblQtyShipped <= (tbl.dblQuantity - tbl.dblQtyShipped)

				if (isnull(@intPriceFixationDetailId,0) > 0)
				begin

					insert into tblCTPriceFixationDetailAPAR
					(
						intPriceFixationDetailId
						,intBillId
						,intBillDetailId
						,intInvoiceId
						,intInvoiceDetailId
						,intConcurrencyId
					)
					select
						intPriceFixationDetailId = @intPriceFixationDetailId
						,intBillId = null
						,intBillDetailId = null
						,intInvoiceId = @intInvoiceId
						,intInvoiceDetailId = @intInvoiceDetailId
						,intConcurrencyId = 1
						
					insert into #tmpB select intPriceFixationDetailAPARId = SCOPE_IDENTITY();

				end

				set @intActiveInvoiceDetailId = @intInvoiceDetailId;
				
				select
					@intInvoiceDetailId = null
					,@intContractDetailId = null
					,@dblPrice = null
					,@dblQtyShipped = null
					,@intPriceFixationDetailId = null;

				select @intInvoiceDetailId = min(intInvoiceDetailId) from @InvoiceDetail where intInvoiceDetailId > @intActiveInvoiceDetailId;
			end

		');
	end


IF (OBJECT_ID(N'dbo.trgCTPriceFixationDetailAPARDelete') IS NOT NULL)
BEGIN
     exec('enable trigger dbo.trgCTPriceFixationDetailAPARDelete on tblCTPriceFixationDetailAPAR');
END

IF OBJECT_ID(N'tblCTMiscellaneous') IS NOT NULL
BEGIN
	exec('update tblCTMiscellaneous set ysnFixedPriceAndInvoiceLink = 1');
END

IF OBJECT_ID(N'tblCTPriceFixationDetailAPAR') IS NOT NULL
begin
	exec('Update tblCTPriceFixationDetailAPAR set ysnPreDeploymentFix = 1 where intPriceFixationDetailAPARId in (select intPriceFixationDetailAPARId from #tmpB)');
end


_Exit:
