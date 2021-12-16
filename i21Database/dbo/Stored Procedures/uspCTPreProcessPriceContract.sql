CREATE PROCEDURE [dbo].[uspCTPreProcessPriceContract]    
	@strXML    NVARCHAR(MAX),    
	@intUserId INT    

AS    

BEGIN 

	begin try

		DECLARE
			@intId INT
			, @intContractHeaderId INT
			, @intPriceContractId INT
			, @strPriceContractState NVARCHAR(50)
			, @intPriceFixationId INT
			, @strPriceFixationState NVARCHAR(50)
			, @intPriceFixationDetailId INT
			, @strPriceFixationDetailState NVARCHAR(50)
			, @dblTransactionQuantity numeric(18,6)
			, @dblFuturePrice numeric(18,6)
			, @strPostedInvoices nvarchar(500)
			, @strBillIds nvarchar(max)
			, @List nvarchar(max)
			, @intFutOptTransactionId int
			, @intFutOptTransactionHeaderId int
			, @intActivePriceFixationDetailId int

			, @strErrorMessage nvarchar(max)
			, @ysnLoad BIT = 0
			, @xmlDocumentId INT
			, @intContractDetailId int
			, @ysnDeleteWholePricing bit = 0
			;

		DECLARE @PriceContractXML TABLE(    
			intId INT IDENTITY    
			, intPriceContractId INT    
			, strPriceContractState NVARCHAR(50)    
			, intPriceFixationId INT    
			, strPriceFixationState NVARCHAR(50)    
			, intPriceFixationDetailId INT    
			, strPriceFixationDetailState NVARCHAR(50)    
			, dblTransactionQuantity numeric(18,6)    
			, dblFuturePrice numeric(18,6)    
		)    

		DECLARE @PriceContractXMLStaging TABLE(    
			intPriceContractId INT    
			, strPriceContractState NVARCHAR(50)    
			, intPriceFixationId INT    
			, strPriceFixationState NVARCHAR(50)    
			, intPriceFixationDetailId INT    
			, strPriceFixationDetailState NVARCHAR(50)    
			, dblTransactionQuantity numeric(18,6)    
			, dblFuturePrice numeric(18,6)    
		)    

		declare @ValidateResult table (    
			intInvoiceId int    
			, intInvoiceDetailId int    
			, strMessage nvarchar(1000)    
		)    

		EXEC sp_xml_preparedocument @xmlDocumentId output, @strXML      

		INSERT INTO @PriceContractXML    
		(    
			intPriceContractId    
			, strPriceContractState    
			, intPriceFixationId    
			, strPriceFixationState    
			, intPriceFixationDetailId    
			, strPriceFixationDetailState    
			, dblTransactionQuantity    
			, dblFuturePrice    
		)    
		SELECT
			*
		FROM OPENXML(@xmlDocumentId, 'PreProcessXMLs/PreProcessXML', 2)      
		WITH (
			intPriceContractId    INT    
			, strPriceContractState   NVARCHAR(20)    
			, intPriceFixationId    INT    
			, strPriceFixationState   NVARCHAR(50)    
			, intPriceFixationDetailId  INT    
			, strPriceFixationDetailState  NVARCHAR(50)    
			, dblTransactionQuantity   numeric(18,6)    
			, dblFuturePrice     numeric(18,6)      
		)

		if exists (select top 1 1 from @PriceContractXML where isnull(intPriceContractId,0) > 0 and strPriceContractState = 'Deleted')    
		begin    
			insert into @PriceContractXMLStaging    
			select    
				intPriceContractId = pc.intPriceContractId    
				, strPriceContractState = 'Deleted'    
				, intPriceFixationId = 0    
				, strPriceFixationState = 'Deleted'    
				, intPriceFixationDetailId = pfd.intPriceFixationDetailId    
				, strPriceFixationDetailState = 'Deleted'    
				, dblTransactionQuantity = pfd.dblQuantity    
				, dblFuturePrice = pfd.dblFutures    
			from    
				@PriceContractXML pc    
				,tblCTPriceFixation pf    
				,tblCTPriceFixationDetail pfd    
			where    
				isnull(pc.intPriceContractId,0) > 0    
				and pc.strPriceContractState = 'Deleted'    
				and pf.intPriceContractId = pc.intPriceContractId    
				and pfd.intPriceFixationId = pf.intPriceFixationId    

			delete    
			from    
				@PriceContractXML    
			where    
				isnull(intPriceContractId,0) > 0    
				and strPriceContractState = 'Deleted'    
		end    

		if exists (select top 1 1 from @PriceContractXML where isnull(intPriceFixationId,0) > 0 and strPriceFixationState = 'Deleted')    
		begin    
			insert into
				@PriceContractXMLStaging    
			select    
				intPriceContractId = 0    
				, strPriceContractState = 'Deleted'    
				, intPriceFixationId = 0    
				, strPriceFixationState = 'Deleted'    
				, intPriceFixationDetailId = pfd.intPriceFixationDetailId    
				, strPriceFixationDetailState = 'Deleted'    
				, dblTransactionQuantity = pfd.dblQuantity    
				, dblFuturePrice = pfd.dblFutures    
			from    
				@PriceContractXML pc    
				,tblCTPriceFixationDetail pfd    
			where    
				isnull(pc.intPriceFixationId,0) > 0    
				and pc.strPriceFixationState = 'Deleted'    
				and pfd.intPriceFixationId = pc.intPriceFixationId    

			delete    
			from    
				@PriceContractXML    
			where    
				isnull(intPriceFixationId,0) > 0    
				and strPriceFixationState = 'Deleted'    
		end    

		if exists (select top 1 1 from @PriceContractXMLStaging)    
		begin    
			insert into @PriceContractXML select * from @PriceContractXMLStaging    
		end    

		WHILE EXISTS (SELECT TOP 1 1 FROM @PriceContractXML)    
		BEGIN    
			SELECT TOP 1    
				@intId = pc.intId    
				, @intPriceContractId = pc.intPriceContractId    
				, @strPriceContractState = pc.strPriceContractState  
				, @ysnDeleteWholePricing = (case when pc.strPriceContractState = 'Deleted' then 1 else 0 end)
				, @intPriceFixationId = pc.intPriceFixationId    
				, @strPriceFixationState = pc.strPriceFixationState    
				, @intPriceFixationDetailId = pc.intPriceFixationDetailId    
				, @strPriceFixationDetailState = case when pc.strPriceFixationDetailState = 'Modified' then 'update' when pc.strPriceFixationDetailState = 'Deleted' then 'delete' else pc.strPriceFixationDetailState end    
				, @dblTransactionQuantity = pc.dblTransactionQuantity    
				, @dblFuturePrice = pc.dblFuturePrice    
			FROM    
				@PriceContractXML pc    

			--------------------------    
			-- Call all validations --    
			--------------------------    
			-- CALL [uspCTValidatePricingUpdateDelete], also include validation on fnCTGetPricingDetailVoucherInvoice     

			if (@strPriceContractState = 'Deleted' and isnull(@intPriceContractId,0) > 0)  
			begin  

				SELECT
					@List = COALESCE(@List + ',', '') + IV.strInvoiceNumber  
				FROM
					tblCTPriceFixationDetailAPAR DA LEFT  
					JOIN tblCTPriceFixationDetail  FD ON FD.intPriceFixationDetailId = DA.intPriceFixationDetailId  
					JOIN tblCTPriceFixation    PF ON PF.intPriceFixationId  = FD.intPriceFixationId  
					JOIN tblARInvoice     IV ON IV.intInvoiceId    = DA.intInvoiceId  
				WHERE
					PF.intPriceContractId = @intPriceContractId  
					AND IV.ysnPosted = 1  

				IF ISNULL(@List,'') <> ''  
				BEGIN  
					SET @strErrorMessage = 'Cannot delete pricing as following Invoices are available. ' + @List + '. Unpost those Invoices to continue delete the price.'  
					RAISERROR(@strErrorMessage,16,1)  
				END  

				EXEC [dbo].[uspCTInterCompanyPriceContract]  
					@intPriceContractId = @intPriceContractId  
					,@ysnApprove = 0  
					,@strRowState = 'Delete'  

				update
					si
				set
					si.ysnAllowInvoice = 0
				from
					tblCTPriceFixation pf
					join tblICInventoryShipmentItem si on si.intLineNo = pf.intContractDetailId
				where
					pf.intPriceContractId = @intPriceContractId

			end  

			if (@strPriceFixationState = 'Deleted' and isnull(@intPriceFixationId,0) > 0)  
			begin  

				SELECT
					@List = COALESCE(@List + ',', '') + IV.strInvoiceNumber  
				FROM
					tblCTPriceFixationDetailAPAR DA LEFT  
					JOIN tblCTPriceFixationDetail  FD ON FD.intPriceFixationDetailId = DA.intPriceFixationDetailId  
					JOIN tblCTPriceFixation    PF ON PF.intPriceFixationId  = FD.intPriceFixationId  
					JOIN tblARInvoice     IV ON IV.intInvoiceId    = DA.intInvoiceId  
				WHERE
					PF.intPriceFixationId = @intPriceFixationId  
					AND IV.ysnPosted = 1  

				IF ISNULL(@List,'') <> ''  
				BEGIN  
					SET @strErrorMessage = 'Cannot delete pricing as following Invoices are available. ' + @List + '. Unpost those Invoices to continue delete the price.'  
					RAISERROR(@strErrorMessage,16,1)  
				END  

				EXEC uspCTPriceFixationDetailDelete
					@intPriceFixationId = @intPriceFixationId
					,@intUserId = @intUserId
					,@ysnDeleteWholePricing = @ysnDeleteWholePricing

				SELECT
					@intActivePriceFixationDetailId = MIN(intPriceFixationDetailId)
				FROM
					tblCTPriceFixationDetail
				WHERE
					intPriceFixationId = @intPriceFixationId  

				WHILE ISNULL(@intPriceFixationDetailId,0) > 0  
				BEGIN  

					SELECT
						@intFutOptTransactionId = FD.intFutOptTransactionId   
					FROM
						tblCTPriceFixationDetail FD  
					WHERE
						FD.intPriceFixationDetailId = @intActivePriceFixationDetailId  

					IF ISNULL(@intFutOptTransactionId,0) > 0  
					BEGIN  
						-- DERIVATIVE ENTRY HISTORY  
						SELECT
							@intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
						FROM
							tblRKFutOptTransaction
						WHERE
							intFutOptTransactionId = @intFutOptTransactionId  
					
						EXEC uspRKFutOptTransactionHistory
							@intFutOptTransactionId
							,@intFutOptTransactionHeaderId
							,'Price Contracts'
							,@intUserId
							,'DELETE'  
					
						UPDATE
							tblCTPriceFixationDetail
						SET
							intFutOptTransactionId = NULL
						WHERE
							intPriceFixationDetailId = @intPriceFixationDetailId  
					
						EXEC uspRKDeleteAutoHedge
							@intFutOptTransactionId
							,@intUserId  
					END  

					SELECT @intActivePriceFixationDetailId = MIN(intPriceFixationDetailId) FROM tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId  
			
				END  

			end  

			if (isnull(@intPriceFixationId,0) > 0)  
			begin  
				EXEC uspCTPriceFixationSave @intPriceFixationId,@strPriceFixationState,@intUserId  
			end  

			delete from @ValidateResult;  

			if (isnull(@intPriceFixationDetailId,0) > 0)    
			begin  

				if (@strPriceFixationDetailState = 'delete')  
				begin  
					select  
						@strBillIds = STUFF(  
							(  
								select  
									', ' + tbl.strBillId  
								from  
								(  
									select  
										ap.intBillId  
										,dblPriceBilled = sum(bd.dblQtyReceived)  
										,tb.dblTotalBilled  
										,tb.strBillId  
									from  
										tblCTPriceFixationDetailAPAR ap  
										join tblCTPriceFixationDetail pfd on pfd.intPriceFixationDetailId = ap.intPriceFixationDetailId  
										join tblAPBillDetail bd on bd.intBillDetailId = ap.intBillDetailId  
										left join (  
											select  
												b.intBillId  
												,b.strBillId  
												,ysnPaid = isnull(b.ysnPaid,0)  
												,dblTotalBilled = sum(bbd.dblQtyReceived)  
											from  
												tblAPBill b  
												join tblAPBillDetail bbd on bbd.intBillId = b.intBillId  
											group by  
												b.intBillId  
												,b.strBillId  
												,b.ysnPaid  
										) tb on tb.intBillId = ap.intBillId  
									where  
										ap.intPriceFixationDetailId = @intPriceFixationDetailId  
										and tb.ysnPaid = 1  
									group by  
										ap.intBillId  
										,tb.dblTotalBilled  
										,tb.strBillId  
								) tbl  
								where
									tbl.dblPriceBilled < tbl.dblTotalBilled  

								FOR xml path('')  
							)  
							, 1  
							, 1  
							, ''  
						)  

					if (@strBillIds is not null)  
					BEGIN  
						SET @strErrorMessage = 'Unable to delete the price.' + @strBillIds + ' voucher(s) also exist in other price layer.';  
						RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT')  
					END  

					SELECT
						@List = COALESCE(@List + ',', '') + IV.strInvoiceNumber  
					FROM
						tblCTPriceFixationDetailAPAR DA LEFT  
						JOIN tblCTPriceFixationDetail  FD ON FD.intPriceFixationDetailId = DA.intPriceFixationDetailId  
						JOIN tblCTPriceFixation    PF ON PF.intPriceFixationId  = FD.intPriceFixationId  
						JOIN tblARInvoice     IV ON IV.intInvoiceId    = DA.intInvoiceId  
					WHERE
						DA.intPriceFixationDetailId = @intPriceFixationDetailId  
						AND IV.ysnPosted = 1  

					IF ISNULL(@List,'') <> ''  
					BEGIN  
						SET @strErrorMessage = 'Cannot delete pricing as following Invoices are available. ' + @List + '. Unpost those Invoices to continue delete the price.'  
						RAISERROR(@strErrorMessage,16,1)  
					END  

					EXEC uspCTPriceFixationDetailDelete
						@intPriceFixationDetailId = @intPriceFixationDetailId
						,@intUserId = @intUserId 
						,@ysnDeleteWholePricing = @ysnDeleteWholePricing 

					SELECT
						@intFutOptTransactionId = FD.intFutOptTransactionId   
					FROM
						tblCTPriceFixationDetail FD  
					WHERE
						FD.intPriceFixationDetailId = @intPriceFixationDetailId  

					IF ISNULL(@intFutOptTransactionId,0) > 0  
					BEGIN  
						-- DERIVATIVE ENTRY HISTORY  
						SELECT
							@intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
						FROM
							tblRKFutOptTransaction
						WHERE
							intFutOptTransactionId = @intFutOptTransactionId  
					
						EXEC uspRKFutOptTransactionHistory
							@intFutOptTransactionId
							,@intFutOptTransactionHeaderId
							,'Price Contracts'
							,@intUserId
							,'DELETE'  
					
						UPDATE
							tblCTPriceFixationDetail
						SET
							intFutOptTransactionId = NULL
						WHERE
							intPriceFixationDetailId = @intPriceFixationDetailId  
					
						EXEC uspRKDeleteAutoHedge
							@intFutOptTransactionId
							,@intUserId  
					END  

				end  

				insert into @ValidateResult  
				exec uspCTValidatePricingUpdateDelete    
					@intPriceFixationDetailId = @intPriceFixationDetailId    
					,@dblPricedQuantity = @dblTransactionQuantity 
					,@strTransaction = @strPriceFixationDetailState
					,@dblFuturePrice = @dblFuturePrice 

				if exists (select top 1 1 from @ValidateResult where strMessage <> 'success')    
				begin    
					select top 1    
						@strErrorMessage =  
						case    
							when @strPriceFixationDetailState = 'delete'    
							then    
								case    
									when isnull(@intPriceContractId,0) = 0    
									then    
										case    
											when strMessage like '%,%'    
											then 'Unable to delete the price layer. Posted Invoices (' + ltrim(rtrim(strMessage)) + ') exist. Unpost these invoices and then delete the price layer.'    
											else 'Unable to delete the price layer. Posted Invoice (' + ltrim(rtrim(strMessage)) + ') exist. Unpost this invoice and then delete the price layer.'    
										end    
									else    
										case    
											when strMessage like '%,%'    
											then 'Unable to delete this record. Posted Invoices (' + ltrim(rtrim(strMessage)) + ') exist. Unpost these invoices and then delete this record.'    
											else 'Unable to delete this record. Posted Invoice (' + ltrim(rtrim(strMessage)) + ') exist. Unpost this invoice and then delete this record.'    
										end    
								end    
							else strMessage    
						end    
					from    
						@ValidateResult    

					RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT')     
				end    
				else    
				begin 

					select @strPostedInvoices = STUFF(    
						(    
							select    
								', ' + convert(nvarchar(20),intInvoiceDetailId)    
							from    
								@ValidateResult    

							FOR xml path('')    
						)    
						, 1    
						, 1    
						, ''    
					)  

					if (isnull(@strPostedInvoices,'') <> '')  
					begin  
						exec uspCTDeleteUnpostedInvoiceFromPricingUpdate
							@InvoiceDetailIds = @strPostedInvoices
							,@intUserId = @intUserId;  
					end  

					if (@strPriceFixationDetailState = 'update')  
					begin  
						exec uspCTProcessSummaryLogOnPriceUpdate
							@intPriceFixationDetailId = @intPriceFixationDetailId
							,@dblTransactionQuantity = @dblTransactionQuantity
							,@intUserId = @intUserId;  
					end  

				end    
			end    

			-------------------------    
			-- End all validations --    
			-------------------------    



			--------------------------------------------    
			-- Call all pre process after validations --    
			--------------------------------------------    

			--uspCTBeforeSavePriceContract    
			-- Take note to not call routines that should be on the post process SP instead of the pre process    
			-- uspCTSequencePriceChanged    
			-- split routines    
			-- ammendment and approval routines    


			--uspCTDeleteUnpostedInvoiceFromPricingUpdate    

			--uspCTProcessSummaryLogOnPriceUpdate    

			-------------------------    
			-- End all pre process --    
			-------------------------    

			DELETE FROM @PriceContractXML WHERE intId = @intId    
		END    

	end try    
	begin catch    
		SET @strErrorMessage = ERROR_MESSAGE()      
		RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT')     
	end catch    


END;