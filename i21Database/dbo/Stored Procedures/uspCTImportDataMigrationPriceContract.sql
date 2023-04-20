CREATE PROCEDURE [dbo].[uspCTImportDataMigrationPriceContract]
	@FileLocation nvarchar(max) = null
AS

	BEGIN TRY

		DECLARE
			@guiUniqueId uniqueidentifier = newid()
			,@intUserId int = 1
			,@ErrMsg nvarchar(max)
			,@intPriceContractId int
			,@intContractPriceImportId int
			,@intContractHeaderId int
			,@intContractDetailId int
			,@intFinalCurrencyId int
			,@intFinalPriceUOMId int
			,@dtmFixationDate datetime
			,@dblQuantity numeric(18,6)
			,@dblFutures numeric(18,6)
			,@validationErrorMsg nvarchar(max)
			,@currDate date = dateadd(day,1,getdate())
			;

		declare @tempImport table (
			intContractPriceImportId int
			,intContractHeaderId int
			,intContractDetailId int
			,intFinalCurrencyId int
			,intFinalPriceUOMId int
			,dtmFixationDate datetime
			,dblQuantity numeric(18,6)
			,dblFutures numeric(18,6)
			,intPricingTypeId int
			,dblNoOfLots numeric(18,6)
		);

		SELECT TOP 1 
			@intUserId = intEntityId 
		FROM 
			tblSMUserSecurity 		
		WHERE 
			lower(strUserName) IN ('irelyadmin', 'aussup');

		if (isnull(ltrim(rtrim(@FileLocation)),'') = '')
		begin
			select @FileLocation = 'C:\Import\Contract\ContractPrice.csv';
		end

		exec('
			BULK INSERT tblCTContractPriceImportTemp
			FROM ''' + @FileLocation + '''
			WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = '','',
				ROWTERMINATOR = ''\n'',
				CODEPAGE = ''ACP'',
				TABLOCK
			)	
		');

		insert into tblCTContractPriceImport (
			strContractNumber
			,intContractSeq
			,strCurrency
			,strUOM
			,dtmDate
			,dblQuantity
			,dblFuturesPrice
			,guiUniqueId
			,intImportFrom
		)
		select
			strContractNumber = substring(ltrim(rtrim(strContractNumber)),1,50)
			,intContractSeq = intContractSeq
			,strCurrency = substring(ltrim(rtrim(strCurrency)),1,50)
			,strUOM = substring(ltrim(rtrim(strUOM)),1,50)
			,dtmDate = dtmDate
			,dblQuantity = dblQuantity
			,dblFuturesPrice = dblFuturesPrice
			,guiUniqueId = @guiUniqueId
			,intImportFrom = 2
		from tblCTContractPriceImportTemp;

		truncate table tblCTContractPriceImportTemp;

		insert into @tempImport(
			intContractPriceImportId
			,intContractHeaderId
			,intContractDetailId
			,intFinalCurrencyId
			,intFinalPriceUOMId
			,dtmFixationDate
			,dblQuantity
			,dblFutures
			,intPricingTypeId
			,dblNoOfLots
		)
		select
			intContractPriceImportId = tmp.intContractPriceImportId
			,intContractHeaderId = ch.intContractHeaderId
			,intContractDetailId = cd.intContractDetailId
			,intFinalCurrencyId = c.intCurrencyID
			,intFinalPriceUOMId = ium.intItemUOMId
			,dtmFixationDate = tmp.dtmDate
			,dblQuantity = tmp.dblQuantity
			,dblFutures = tmp.dblFuturesPrice
			,intPricingTypeId = cd.intPricingTypeId
			,dblNoOfLots = cd.dblNoOfLots
		from
			tblCTContractPriceImport tmp
			left join tblCTContractHeader ch on ch.strContractNumber = tmp.strContractNumber
			left join tblCTContractDetail cd on cd.intContractHeaderId = ch.intContractHeaderId and cd.intContractSeq = tmp.intContractSeq
			left join tblSMCurrency c on c.strCurrency = tmp.strCurrency
			left join tblICUnitMeasure um on um.strUnitMeasure = tmp.strUOM
			left join tblICItemUOM ium on ium.intItemId = cd.intItemId and ium.intUnitMeasureId = um.intUnitMeasureId
		where
			tmp.guiUniqueId = @guiUniqueId

		if exists( select top 1 1 from @tempImport)
		begin
			while exists (select top 1 1 from @tempImport)
			begin

				select top 1
					@intContractPriceImportId = intContractPriceImportId
					,@intContractHeaderId = intContractHeaderId
					,@intContractDetailId = intContractDetailId
					,@intFinalCurrencyId = intFinalCurrencyId
					,@intFinalPriceUOMId = intFinalPriceUOMId
					,@dtmFixationDate = dtmFixationDate
					,@dblQuantity = dblQuantity
					,@dblFutures  = dblFutures
				from
					@tempImport;

				select
					@validationErrorMsg = 
					case
					when isnull(t.intContractHeaderId,0) = 0 then 'Contract Number: ' + i.strContractNumber + ' does not exists.'
					when isnull(t.intContractDetailId,0) = 0 then 'Contract Sequence: contract number ' + i.strContractNumber + ' does not have ' + convert(nvarchar(20),i.intContractSeq) + ' sequence number.'
					when isnull(t.intFinalCurrencyId,0) = 0 then 'Currency: ' + i.strCurrency + ' does not exists.'
					when isnull(t.intFinalPriceUOMId,0) = 0 then 'UOM: ' + i.strUOM + ' does not exists.'
					when t.dtmFixationDate is null then 'Fixation Date is missing.'
					when t.dtmFixationDate >= @currDate then 'Fixation Date must be equal to or before today''s date'
					when isnull(t.dblQuantity,0) = 0 then 'Quantity is not valid.'
					when isnull(t.dblFutures,0) = 0 then 'Quantity is not valid.'
					when isnull(t.intPricingTypeId,0) <> 2 then 'Contract ' + i.strContractNumber + ', sequence ' + convert(nvarchar(20),i.intContractSeq) + ' is not available for pricing because it''s not a Basis.'
					when t.dblNoOfLots is null then 'Contract ' + i.strContractNumber + ', sequence ' + convert(nvarchar(20),i.intContractSeq) + ' is missing No Of Lots.'
					else @validationErrorMsg
					end
				from
					@tempImport t
					join tblCTContractPriceImport i on i.intContractPriceImportId = t.intContractPriceImportId
				where
					t.intContractPriceImportId = @intContractPriceImportId

				if (isnull(@validationErrorMsg,'') <> '')
				begin
					RAISERROR(@validationErrorMsg,16,1);
				end

				exec uspCTCreatePrice
					@intContractDetailId = @intContractDetailId
					,@dblQuantityToPrice = @dblQuantity
					,@dblFutures = @dblFutures
					,@intUserId = @intUserId
					,@intAssignFuturesToContractSummaryId = default
					,@ysnAllowToPriceRemainingQtyToPrice = 0
					,@dblAssignedLots = default

				delete @tempImport where intContractPriceImportId = @intContractPriceImportId;

				UPDATE	tblCTContractPriceImport
				SET		ysnImported				=	1,
						intImportedById			=	@intUserId,
						dtmImported				=	GETDATE(),
						intPriceContractId		=	@intPriceContractId,
						ysnIsProcessed			=   1
				WHERE	guiUniqueId = @guiUniqueId AND intContractPriceImportId = @intContractPriceImportId
				
			end
		end

		select [Import Status] = 'Successful.';

	END TRY
	BEGIN CATCH
		SET @ErrMsg = ERROR_MESSAGE() 
		UPDATE	tblCTContractPriceImport
		SET		ysnImported			=	0,
				intImportedById		=	@intUserId,
				dtmImported			=	GETDATE(),
				strErrorMsg			=	@ErrMsg,
				ysnIsProcessed		=   1
		WHERE	guiUniqueId = @guiUniqueId AND intContractPriceImportId = @intContractPriceImportId
		select [Import Status]= 'Failed: ' + @ErrMsg;
	END CATCH
