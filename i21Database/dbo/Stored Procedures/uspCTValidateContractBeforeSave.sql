CREATE PROCEDURE [dbo].[uspCTValidateContractBeforeSave]
	@ysnLoad bit
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
	,@dblBalanceLoad numeric(18,10)

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
		FROM	#tblContractDetails 
		WHERE	intUniqueId = @intUniqueId
		
		/* update balance*/
		IF(@strRowState = 'Added')
		BEGIN

			UPDATE #tblContractDetails
			SET dblBalance = IIF(@ysnLoad = 1, @intNoOfLoad * @dblQuantityPerLoad, @dblQuantity)
			,dblBalanceLoad = IIF(@ysnLoad = 1, @intNoOfLoad, dblBalanceLoad)
			WHERE intUniqueId = @intUniqueId

		END
		ELSE IF(@strRowState = 'Modified')
		BEGIN
			
			IF OBJECT_ID('tempdb..#tblContractDetailsOld') IS NOT NULL  	
			DROP TABLE #tblContractDetailsOld	
			
			
            --_intNoOfLoad = detail.intNoOfLoad.GetValueOrDefault();
            --_dblQuantity = detail.dblQuantity;
            --_dblBalance = detail.dblBalance.GetValueOrDefault();
            --_dblScheduleQty = detail.dblScheduleQty.GetValueOrDefault();
            --_dblBalanceLoad = detail.dblBalanceLoad.GetValueOrDefault();
            --_dblScheduleLoad = detail.dblScheduleLoad.GetValueOrDefault();

			DECLARE 
				@_intNoOfLoad int,
				@_dblQuantity int,
				@_dblBalance int,
				@_dblScheduleQty int,
				@_dblBalanceLoad int,
				@_dblScheduleLoad int
			
			--SELECT	@intContractDetailIdOld = intContractDetailId
			--		,@intNoOfLoadOld = [intNoOfLoad]
			--		,@dblQuantityOld =	dblQuantity
			--		,@dblQuantityPerLoadOld = dblQuantityPerLoad
			--INTO #tblContractDetailsOld
			--FROM	tblCTContractDetail 
			--WHERE intContractDetailId = @intContractDetailId

			SELECT top 1 *
			INTO #tblContractDetailsOld
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intContractDetailId

			IF(@ysnLoad = 1)
			BEGIN

				DECLARE @sample varchar(50) = ''
				
			END

		END

		
		SELECT	*
		FROM	#tblContractDetails 
		WHERE	intUniqueId = @intUniqueId

		SET @intUniqueId = (SELECT MIN(intUniqueId) FROM #tblContractDetails WHERE intUniqueId > @intUniqueId)

	END


end try
begin catch
	set @error = ERROR_MESSAGE()  
	raiserror (@error,18,1,'WITH NOWAIT')  
end catch