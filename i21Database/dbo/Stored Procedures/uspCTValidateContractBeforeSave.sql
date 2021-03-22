CREATE PROCEDURE [dbo].[uspCTValidateContractBeforeSave]
	@ysnLoad bit
	,@ysnUnlimitedQuantity bit
	,@userId int
	,@strXML NVARCHAR(MAX)
	,@error NVARCHAR(1000) = NULL OUTPUT
AS
BEGIN TRY

	DECLARE 
	@idoc INT
	,@PrepareXmlStatus INT  
	,@intUniqueId INT
	,@strRowState varchar(50)
	,@intNoOfLoad int
	,@intContractDetailId int
	,@dblQuantityPerLoad numeric(18,10)
	,@dblQuantity numeric(18,10)
	,@dblBalance numeric(18,10)
	,@strContractStatus numeric(18,10)
	,@dblBalanceLoad numeric(18,10)
	,@RowState varchar(50)
	,@dtmEndDate datetime
	,@intLastModifiedById int
	,@dtmLastModified datetime
	,@intCreatedById int
	,@dtmCreated datetime

	DECLARE 
		@_intNoOfLoad int,
		@_dblQuantity numeric(18,10),
		@_dblScheduleQty numeric(18,10),
		@_dblBalanceLoad numeric(18,10),
		@_dblScheduleLoad numeric(18,10),
		@_dblBalance numeric(18,10),
		@_intContractStatusId int,
		@_intPricingTypeId int

	EXEC @PrepareXmlStatus = sp_xml_preparedocument @idoc OUTPUT, @strXML  

	IF OBJECT_ID('tempdb..#tblContractDetails') IS NOT NULL  	
		DROP TABLE #tblContractDetails	

	/* string to xml to temp table */
	SELECT 
	ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,* 
	INTO #tblContractDetails
	FROM OPENXML(@idoc, '/tblCTContractDetails/tblCTContractDetail', 2)  
	WITH (
		[intContractDetailId] int
		,[intContractHeaderId] int
		,[strRowState] varchar(50)
		,[RowState] varchar(50)
		,[dtmEndDate] datetime
		,[intNoOfLoad] int
		,[dblQuantityPerLoad] numeric(18,10)
		,[dblQuantity] numeric(18,10)
		,[dblBalance] numeric(18,10)
		,[dblBalanceLoad] numeric(18,10)
	)  

	SELECT @intUniqueId = MIN(intUniqueId) FROM #tblContractDetails

	/* loop results in #tblContractDetails */
	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN

		/* get single results of temp table */
		SELECT	@intContractDetailId = intContractDetailId
				,@intNoOfLoad = [intNoOfLoad]
				,@dblQuantityPerLoad = dblQuantityPerLoad
				,@dblQuantity =	dblQuantity
				,@strRowState =	strRowState
				,@dblBalance = dblBalance
				--,@strContractStatus = strContractStatus
				,@RowState = RowState
				,@dtmEndDate = dtmEndDate
				--,@intCreatedById = intCreatedById
		FROM	#tblContractDetails 
		WHERE	intUniqueId = @intUniqueId
		
		/* update balance*/
		IF(@strRowState = 'Added')
		BEGIN

			UPDATE #tblContractDetails
			SET dblBalance = CASE WHEN @ysnLoad = 1 THEN @intNoOfLoad * @dblQuantityPerLoad ELSE @dblQuantity END
			,dblBalanceLoad = CASE WHEN @ysnLoad = 1 THEN @intNoOfLoad ELSE dblBalanceLoad END
			WHERE intUniqueId = @intUniqueId

		END
		ELSE IF(@strRowState = 'Modified')
		BEGIN

			SELECT	@_intNoOfLoad = [intNoOfLoad]
					,@_dblQuantity = dblQuantity
					,@_dblBalance = dblQuantityPerLoad
					,@_dblScheduleQty = dblScheduleQty
					,@_dblBalanceLoad = dblBalanceLoad
					,@_dblScheduleLoad = dblScheduleLoad
			FROM tblCTContractDetail 
			WHERE intContractDetailId = @intContractDetailId

			IF(@ysnLoad = 1)
			BEGIN

				IF(@intNoOfLoad != @_intNoOfLoad)
				BEGIN
					
					IF(@_intNoOfLoad = @_dblBalanceLoad)
					BEGIN

						UPDATE #tblContractDetails
						SET dblBalanceLoad = @intNoOfLoad
					
					END
					ELSE IF (@_intNoOfLoad - @_dblBalanceLoad > 0)
					BEGIN
						
						UPDATE #tblContractDetails
						SET dblBalanceLoad = @intNoOfLoad - (@_intNoOfLoad - @_dblBalanceLoad)

					END
					ELSE
					BEGIN

						UPDATE #tblContractDetails
						SET dblBalanceLoad += @intNoOfLoad - @_intNoOfLoad

					END

					UPDATE #tblContractDetails
					SET dblBalance = dblBalance * dblQuantityPerLoad

				END
				
			END
			ELSE
			BEGIN
				
				IF(@dblQuantity != @_dblQuantity)
				BEGIN
					
					IF(@_dblQuantity = @_dblBalance)
					BEGIN
						UPDATE #tblContractDetails
						SET dblBalance = @dblQuantity
					END
					ELSE IF(@_dblQuantity - @_dblBalance > 0)
					BEGIN
						UPDATE #tblContractDetails
						SET dblBalance = @dblQuantity - (@_dblQuantity - @_dblBalance)
					END
					ELSE
					BEGIN
						UPDATE #tblContractDetails
						SET dblBalance += @dblQuantity - @_dblQuantity
					END

				END
			END
		END

		/* Change Status */
		IF(@strRowState = 'Modified')
		BEGIN

			SELECT	@_intContractStatusId = intContractStatusId
					,@_intPricingTypeId = intPricingTypeId
					,@_dblBalance = dblBalance
			FROM tblCTContractDetail 
			WHERE intContractDetailId = @intContractDetailId

			IF (@dblBalance = 0)
			BEGIN
				IF(@ysnUnlimitedQuantity = 1
				and @_intPricingTypeId in (1,6,7)
				and @_intContractStatusId in (1,4)
				and @intContractDetailId in (1,4))
				BEGIN
					UPDATE #tblContractDetails
					SET @_intContractStatusId = 5,
					strContractStatus = 'Complete'
				END
			END
			ELSE IF (@_dblBalance = 0)
			BEGIN
				IF(@_intContractStatusId = 5 and @intContractDetailId = 5)
				BEGIN
					UPDATE #tblContractDetails
					SET @_intContractStatusId = 4,
					strContractStatus = 'Re-Open'
				END
			END


		END

		/* Set Creation and Modification Info */
		UPDATE #tblContractDetails
		set RowState = @strRowState
		,dtmEndDate = DATEADD(SECOND, 86399, DATEDIFF(dd, 0, @dtmEndDate))

		IF(@strRowState = 'Modified')
		BEGIN
			UPDATE #tblContractDetails
			SET intLastModifiedById = @userId
			,dtmLastModified = GETUTCDATE()
		END
		ELSE IF(@strRowState = 'Modified')
		BEGIN
			UPDATE #tblContractDetails
			SET intCreateById = @userId
			,@dtmCreated = GETUTCDATE()
		END

		/* preview results on debug */
		DECLARE @preview nvarchar(max) = (SELECT * FROM #tblContractDetails FOR JSON AUTO)

		/* preview results on query execution */
		--SELECT *
		--FROM	#tblContractDetails 
		--WHERE	intUniqueId = @intUniqueId

		SET @intUniqueId = (SELECT MIN(intUniqueId) FROM #tblContractDetails WHERE intUniqueId > @intUniqueId)

	END


end try
begin catch
	set @error = ERROR_MESSAGE()  
	raiserror (@error,18,1,'WITH NOWAIT')  
end catch