CREATE PROCEDURE [dbo].[uspSCGetLoadContractsAndAllocate]  
 @intTicketId AS INT  
 ,@intLoadDetailId AS INT  
 , @dblNetUnits AS NUMERIC(18,6)  
 , @strInOutFlad AS NVARCHAR(5)  
AS  
BEGIN  
	DECLARE @intLoadId INT  
	DECLARE @dblUnitsRemaining NUMERIC(18,6)  
	DECLARE @dblSelectedLoadQuantity NUMERIC(18,6)  
	DECLARE @dblTotalLoadQuantity NUMERIC(18,6)  
	DECLARE @intSelectedContractDetailId INT  
	DECLARE @dblSelectedPrice NUMERIC(18,6)  
	DECLARE @dblDistributedQuantity NUMERIC(18,6)  
	DECLARE @intLoopCurrentId INT
  
  
	DECLARE @Processed TABLE  
	(  
	intContractDetailId INT,  
	dblUnitsDistributed NUMERIC(18,6),  
	dblUnitsRemaining NUMERIC(18,6),
	intLoadDetaiId INT  
	)    
  
	SET @dblUnitsRemaining = @dblNetUnits  
  
	SELECT  
		@intLoadId = intLoadId  
		,@dblSelectedLoadQuantity = dblQuantity  
		,@intSelectedContractDetailId = CASE WHEN @strInOutFlad = 'I' THEN intPContractDetailId ELSE intSContractDetailId END  
	FROM tblLGLoadDetail  
	WHERE intLoadDetailId = @intLoadDetailId  
    
	SELECT @dblTotalLoadQuantity = SUM(dblQuantity)  
	FROM tblLGLoadDetail  
	WHERE intLoadId = @intLoadId  
  
   
	-- IF(@dblTotalLoadQuantity < @dblNetUnits)  
	-- BEGIN  
	-- 	RAISERROR ('The entire ticket quantity can not be applied to the load.',16,1,'WITH NOWAIT')   
	-- END  
  
  
   
  
	IF(@dblSelectedLoadQuantity > @dblNetUnits )  
	BEGIN  
		SET @dblUnitsRemaining = @dblUnitsRemaining - @dblNetUnits  
		SET @dblDistributedQuantity = @dblNetUnits  
	END  
	ELSE  
	BEGIN  
		SET @dblUnitsRemaining = @dblUnitsRemaining - @dblSelectedLoadQuantity  
		SET @dblDistributedQuantity = @dblSelectedLoadQuantity  
	END   
   
  
	-- insert the selected load contract   
	INSERT INTO @Processed(  
		intContractDetailId   
		,dblUnitsDistributed   
		,dblUnitsRemaining 
		,intLoadDetaiId 
	)  
	SELECT   
		@intSelectedContractDetailId  
		,@dblDistributedQuantity  
		,@dblUnitsRemaining  
		,@intLoadDetailId
   
	IF(@dblUnitsRemaining > 0)  
	BEGIN  
		SELECT   
			*  
		INTO #tmpOtherLoadContract  
		FROM tblLGLoadDetail  
		WHERE intLoadId = @intLoadId  
			AND intLoadDetailId <> @intLoadDetailId  
		ORDER BY intLoadDetailId  

			SET @intLoadDetailId = NULL  
		SELECT @intLoadDetailId = MIN(intLoadDetailId) FROM #tmpOtherLoadContract  
  
		WHILE (@intLoadDetailId IS NOT NULL AND @dblUnitsRemaining > 0)  
		BEGIN   
			SET @intLoopCurrentId = @intLoadDetailId
		
  
			SELECT  
				@intLoadId = @intLoadId  
				,@dblSelectedLoadQuantity = dblQuantity  
				,@intSelectedContractDetailId = CASE WHEN @strInOutFlad = 'I' THEN intPContractDetailId ELSE intSContractDetailId END  
				,@dblSelectedPrice = dblUnitPrice  
			FROM #tmpOtherLoadContract  
			WHERE intLoadDetailId = @intLoadDetailId  
  
			IF(@dblUnitsRemaining > @dblSelectedLoadQuantity)  
			BEGIN  
				SET @dblUnitsRemaining = @dblUnitsRemaining - @dblSelectedLoadQuantity  
				SET @dblDistributedQuantity = @dblSelectedLoadQuantity  
			END  
			ELSE  
			BEGIN  
				SET @dblDistributedQuantity = @dblUnitsRemaining   
				SET @dblUnitsRemaining = 0  
			END   
  
  
			-- insert the selected load contract   
			INSERT INTO @Processed(  
				intContractDetailId   
				,dblUnitsDistributed   
				,dblUnitsRemaining
				,intLoadDetaiId  
			)  
			SELECT   
				@intSelectedContractDetailId  
				,@dblDistributedQuantity  
				,@dblUnitsRemaining  
				,@intLoadDetailId
     
			SET @intLoadDetailId = NULL  
			SELECT TOP 1 @intLoadDetailId = MIN(intLoadDetailId)   
			FROM #tmpOtherLoadContract  
			WHERE intLoadDetailId > @intLoopCurrentId
		END  
	END  
  
  
	SELECT   
	@intTicketId  
	,PR.intContractDetailId  
	,PR.dblUnitsDistributed  
	,PR.dblUnitsRemaining  
	,dblCost = CASE WHEN CD.intPricingTypeId = 2  
			THEN ISNULL(dblSeqBasis,0)  
			WHEN CD.intPricingTypeId = 3  
			THEN ISNULL(dblSeqFutures,0)  
			ELSE ISNULL(CD.dblCashPrice,0)  
		END  
	,CD.intInvoiceCurrencyId
	,PR.intLoadDetaiId  
	FROM @Processed PR  
	INNER JOIN tblCTContractDetail CD   
	ON CD.intContractDetailId = PR.intContractDetailId  
	CROSS  APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD  
   
END   
  
  
  