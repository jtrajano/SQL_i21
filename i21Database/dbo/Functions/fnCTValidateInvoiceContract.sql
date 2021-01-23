CREATE FUNCTION [dbo].[fnCTValidateInvoiceContract]
(
	@Invoices [dbo].[InvoicePostingTable] Readonly
)
RETURNS @returntable TABLE
(
	intInvoiceId INT NOT NULL
	, strInvoiceNumber NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, intInvoiceDetailId INT NULL
	, intItemId INT NULL
	, strItemNo NVARCHAR(50) NULL
	, strBatchId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	, strPostingError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN
	DECLARE @intContractDetailId INT
		, @intContractHeaderId INT
		, @intInvoiceId INT
		, @intInvoiceDetailId INT
		, @dblInvoiceQty NUMERIC(18, 6)
		, @dblQtyShipped NUMERIC(18, 6)
		, @strInvoiceNumber NVARCHAR(25)
		, @strTransactionType NVARCHAR(25)
		, @strBatchId NVARCHAR(25)
		, @intItemId INT
		, @strItemNo NVARCHAR(50)
		, @ErrMsg NVARCHAR(MAX)
		, @ysnAllowOverSchedule BIT
		, @intContractStatusId INT
		, @dblQuantity NUMERIC(18, 6)
		, @dblScheduleQty NUMERIC(18, 6)
		, @dblOrgScheduleQty NUMERIC(18, 6)
		, @dblBalance NUMERIC(18, 6)
		, @ysnUnlimitedQuantity BIT
		, @intPricingTypeId INT
		, @strContractNumber NVARCHAR(50)
		, @strContractSeq NVARCHAR(50)
		, @dblAvailableQty NUMERIC(18, 6)
		, @ysnLoad BIT
		, @intCommodityUnitMeasureId INT
		, @intItemUOMId INT
		, @dblTolerance NUMERIC(18, 6) = 0.0001
		, @dblQtyToIncrease NUMERIC(18, 6)
		, @dblOrigInvoiceQty NUMERIC(18, 6)

	DECLARE @intCtr INT
	SELECT @intCtr = MIN(intInvoiceDetailId) FROM @Invoices

	WHILE (ISNULL(@intCtr, 0) > 0)
	BEGIN
		SELECT TOP 1 @intContractDetailId = intContractDetailId
			, @intContractHeaderId = intContractHeaderId
			, @intInvoiceId = intInvoiceId
			, @intInvoiceDetailId = intInvoiceDetailId
			, @dblInvoiceQty = dblQuantity
			, @dblOrigInvoiceQty = dblQuantity
			, @dblQtyShipped = dblQtyShipped
			, @strInvoiceNumber = strInvoiceNumber
			, @strTransactionType = strTransactionType
			, @intItemId = intItemId
			, @strItemNo = strItemNo
			, @strBatchId = strBatchId
		FROM @Invoices
		WHERE intInvoiceDetailId = @intCtr

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			INSERT INTO @returntable (intInvoiceId
				, strInvoiceNumber
				, strTransactionType
				, intInvoiceDetailId
				, intItemId
				, strItemNo
				, strBatchId
				, strPostingError)
			SELECT @intInvoiceId
				, @strInvoiceNumber
				, @strTransactionType
				, @intInvoiceDetailId
				, @intItemId
				, @strItemNo
				, @strBatchId
				, 'Contract Sequence no longer exists.'
			RETURN
		END
		
		SELECT @ysnAllowOverSchedule = ISNULL(ysnAllowOverSchedule, 0) FROM tblCTCompanyPreference
		
		SELECT @dblInvoiceQty = CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN @dblInvoiceQty ELSE @dblInvoiceQty / ABS(@dblInvoiceQty) END
			, @intContractStatusId = CD.intContractStatusId
			, @dblQuantity = CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN ISNULL(CD.dblQuantity, 0) ELSE ISNULL(CD.intNoOfLoad, 0) END
			, @dblScheduleQty = case when (isnull(CD.dblScheduleQty,0) = 0 or isnull(CD.dblScheduleLoad,0) = 0) and @dblOrigInvoiceQty < 0 then (CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN abs(@dblOrigInvoiceQty) ELSE 1 END) else (CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN ISNULL(CD.dblScheduleQty, 0) - @dblOrigInvoiceQty ELSE ISNULL(CD.dblScheduleLoad, 0) -1 END) end--CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN ISNULL(CD.dblScheduleQty, 0) - @dblOrigInvoiceQty ELSE ISNULL(CD.dblScheduleLoad, 0) -1 END
			, @dblOrgScheduleQty = CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN ISNULL(CD.dblScheduleQty, 0) - @dblOrigInvoiceQty ELSE ISNULL(CD.dblScheduleLoad, 0) - 1 END
			, @dblBalance = CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN ISNULL(CD.dblBalance, 0) ELSE ISNULL(CD.dblBalanceLoad, 0) END
			, @ysnUnlimitedQuantity = ISNULL(CH.ysnUnlimitedQuantity, 0)
			, @intPricingTypeId = CD.intPricingTypeId
			, @strContractNumber = CH.strContractNumber
			, @strContractSeq = LTRIM(CD.intContractSeq)
			, @dblAvailableQty = CASE WHEN ISNULL(ysnLoad, 0) = 0 THEN ISNULL(dblBalance, 0) - (ISNULL(dblScheduleQty, 0) - @dblOrigInvoiceQty) ELSE ISNULL(dblBalanceLoad, 0) - (ISNULL(dblScheduleLoad, 0) - 1) END
			, @intCommodityUnitMeasureId = CH.intCommodityUOMId
			, @intItemUOMId = intItemUOMId
			, @ysnLoad = CH.ysnLoad
		FROM tblCTContractDetail CD
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE intContractDetailId = @intContractDetailId
		
		IF @dblScheduleQty + @dblInvoiceQty > @dblBalance
		BEGIN
			IF @ysnUnlimitedQuantity = 1 OR @intPricingTypeId = 5
			BEGIN
				SET @dblQtyToIncrease	= (@dblBalance - (@dblScheduleQty + @dblInvoiceQty)) * -1
	
				IF ABS(@dblQtyToIncrease)- @dblAvailableQty < @dblTolerance AND ABS(@dblQtyToIncrease)- @dblAvailableQty >0
				BEGIN
					 SET @dblQtyToIncrease= - @dblAvailableQty
				END

				IF	@dblAvailableQty + @dblQtyToIncrease < 0
				BEGIN
					SET @ErrMsg = 'Quantity cannot be reduced below ' + LTRIM(@dblQuantity - @dblAvailableQty) + '.'
					INSERT INTO @returntable (intInvoiceId
						, strInvoiceNumber
						, strTransactionType
						, intInvoiceDetailId
						, intItemId
						, strItemNo
						, strBatchId
						, strPostingError)
					SELECT @intInvoiceId
						, @strInvoiceNumber
						, @strTransactionType
						, @intInvoiceDetailId
						, @intItemId
						, @strItemNo
						, @strBatchId
						, @ErrMsg
					RETURN
				END
	
				IF ISNULL(@ysnLoad, 0) = 0 
				BEGIN
					DECLARE @intFromUOMId INT
						, @intToUOMId INT

					SELECT	@intFromUOMId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId
					SELECT	@intToUOMId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityUnitMeasureId = @intCommodityUnitMeasureId

					SELECT	@dblQtyToIncrease = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intFromUOMId,@intToUOMId,@dblQtyToIncrease)
				END

				IF @dblQtyToIncrease = NULL
				BEGIN
					INSERT INTO @returntable (intInvoiceId
						, strInvoiceNumber
						, strTransactionType
						, intInvoiceDetailId
						, intItemId
						, strItemNo
						, strBatchId
						, strPostingError)
					SELECT @intInvoiceId
						, @strInvoiceNumber
						, @strTransactionType
						, @intInvoiceDetailId
						, @intItemId
						, @strItemNo
						, @strBatchId
						, 'UOM configured in the header not available in the sequence.'
					RETURN
				END
			END
			ELSE IF @ysnAllowOverSchedule = 1
			BEGIN
				IF @dblInvoiceQty <= @dblBalance
				BEGIN
					SELECT @dblScheduleQty = (@dblQuantity + @dblInvoiceQty - @dblScheduleQty) - (@dblQuantity - @dblScheduleQty)
				END
				ELSE
				BEGIN
					INSERT INTO @returntable (intInvoiceId
						, strInvoiceNumber
						, strTransactionType
						, intInvoiceDetailId
						, intItemId
						, strItemNo
						, strBatchId
						, strPostingError)
					SELECT @intInvoiceId
						, @strInvoiceNumber
						, @strTransactionType
						, @intInvoiceDetailId
						, @intItemId
						, @strItemNo
						, @strBatchId
						, 'Balance quantity for the contract ' + @strContractNumber + ' and sequence ' + @strContractSeq + ' is ' + CAST(@dblBalance AS NVARCHAR(50)) + ', which is insufficient to Save/Post a quantity of ' + CAST(@dblInvoiceQty AS NVARCHAR(50)) + ' therefore could not Save/Post this transaction.'
					RETURN
				END
			END
			ELSE
			BEGIN
				IF ((@dblScheduleQty + @dblInvoiceQty) - @dblBalance) > @dblTolerance
				BEGIN
					INSERT INTO @returntable (intInvoiceId
						, strInvoiceNumber
						, strTransactionType
						, intInvoiceDetailId
						, intItemId
						, strItemNo
						, strBatchId
						, strPostingError)
					SELECT @intInvoiceId
						, @strInvoiceNumber
						, @strTransactionType
						, @intInvoiceDetailId
						, @intItemId
						, @strItemNo
						, @strBatchId
						, 'Available quantity for the contract ' + @strContractNumber + ' and sequence ' + @strContractSeq + ' is ' + CAST(@dblAvailableQty AS NVARCHAR(50)) + ', which is insufficient to Save/Post a quantity of ' + CAST(@dblInvoiceQty AS NVARCHAR(50)) + ' therefore could not Save/Post this transaction.'
					RETURN
				END
				--ELSE
				--BEGIN
				--	SET @dblInvoiceQty = @dblInvoiceQty - ((@dblScheduleQty + @dblInvoiceQty) - @dblBalance)
				--END
			END
		END
	
		IF	@dblScheduleQty + @dblInvoiceQty < 0 
		BEGIN
			IF @ysnAllowOverSchedule = 1
			BEGIN
				SET @dblScheduleQty = ABS(@dblInvoiceQty) + @dblScheduleQty
			END
			ELSE
			BEGIN
				IF ABS(@dblScheduleQty + @dblInvoiceQty) > @dblTolerance
				BEGIN
					SET @ErrMsg = 'Total scheduled quantity cannot be less than zero for contract ' + @strContractNumber + ' and sequence ' + @strContractSeq +'.'
					INSERT INTO @returntable (intInvoiceId
						, strInvoiceNumber
						, strTransactionType
						, intInvoiceDetailId
						, intItemId
						, strItemNo
						, strBatchId
						, strPostingError)
					SELECT @intInvoiceId
						, @strInvoiceNumber
						, @strTransactionType
						, @intInvoiceDetailId
						, @intItemId
						, @strItemNo
						, @strBatchId
						, @ErrMsg
					RETURN
				END
				--ELSE
				--BEGIN
				--	SET @dblInvoiceQty = @dblInvoiceQty - (@dblScheduleQty + @dblInvoiceQty)
				--END 
			END
		END

		SELECT @intCtr = MIN(intInvoiceDetailId) FROM @Invoices WHERE intInvoiceDetailId > @intCtr
	END

	RETURN
END
