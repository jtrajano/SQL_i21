CREATE PROCEDURE uspTMArchiveRestoreOrders 
	@OrderHistoryStaging TMOrderHistoryStagingTable READONLY
	,@intUserId INT
	
AS
BEGIN
	
	DECLARE @insertedHistory TABLE (intDispatchId INT,intDispatchSyncId INT)
	

	IF OBJECT_ID('tempdb..#tmpTMForDeleteOrders') IS NOT NULL DROP TABLE #tmpTMForDeleteOrders
	SELECT *
	INTO #tmpTMForDeleteOrders
	FROM @OrderHistoryStaging
	WHERE ysnDelete = 1
	ORDER BY intDispatchId


	IF OBJECT_ID('tempdb..#tmpTMForRestoreOrders') IS NOT NULL DROP TABLE #tmpTMForRestoreOrders
	SELECT *
	INTO #tmpTMForRestoreOrders
	FROM @OrderHistoryStaging
	WHERE ysnDelete = 0
	ORDER BY intDispatchId

	------------------------------------
	------- START DELETE
	------------------------------------
	BEGIN
		------------------------------------
		--insert in dispatch History
		------------------------------------
		INSERT INTO tblTMDispatchHistory (
			[intDispatchId]            
			,[intSiteId]
			,[intDeliveryHistoryId]                
			,[dblPercentLeft]           
			,[dblQuantity]              
			,[dblMinimumQuantity]       
			,[intProductId]             
			,[intSubstituteProductId]   
			,[dblPrice]                 
			,[dblTotal]                 
			,[dtmRequestedDate]         
			,[intPriority]              
			,[strComments]              
			,[ysnCallEntryPrinted]      
			,[intDriverId]              
			,[intDispatchDriverId]      
			,[strDispatchLoadNumber]    
			,[dtmCallInDate]            
			,[ysnSelected]              
			,[strRoute]                 
			,[strSequence]              
			,[intUserId]                
			,[dtmLastUpdated]           
			,[ysnDispatched]            
			,[strCancelDispatchMessage] 
			,[intDeliveryTermId]        
			,[dtmDispatchingDate]       
			,[strWillCallStatus]			
			,[strPricingMethod]			
			,[strOrderNumber]			
			,[dtmDeliveryDate]			
			,[dblDeliveryQuantity]		
			,[dblDeliveryPrice]			
			,[dblDeliveryTotal]			
			,[intContractId]				
			,[ysnLockPrice]				
			,[intRouteId]				
			,[ysnReceived]				
			,[ysnLeakCheckRequired]
			,[dblOriginalPercentLeft]		
			,[dtmReceivedDate]
			,intPaymentId
			,dblOveragePrice
			,dblOverageQty
			,strOriginalPricingMethod
		)	
		OUTPUT INSERTED.intDispatchId,INSERTED.intDispatchSyncId INTO @insertedHistory
		SELECT  
			[intDispatchId]				= A.[intDispatchID]
			,[intSiteId]				= A.intSiteID
			,[intDeliveryHistoryId]		= CASE WHEN B.intDeliveryHistoryId IS NULL THEN -1 ELSE B.intDeliveryHistoryId END
			,A.[dblPercentLeft]           
			,A.[dblQuantity]              
			,A.[dblMinimumQuantity]       
			,[intProductId]				= A.[intProductID] 
			,[intSubstituteProductId]   = A.[intSubstituteProductID]
			,A.[dblPrice]                 
			,A.[dblTotal]                 
			,A.[dtmRequestedDate]         
			,A.[intPriority]              
			,A.[strComments]              
			,A.[ysnCallEntryPrinted]      
			,[intDriverId]              = A.[intDriverID]              
			,[intDispatchDriverId]		= A.[intDispatchDriverID]   
			,A.[strDispatchLoadNumber]    
			,A.[dtmCallInDate]            
			,A.[ysnSelected]              
			,A.[strRoute]                 
			,A.[strSequence]              
			,[intUserId]				= A.[intUserID]
			,A.[dtmLastUpdated]           
			,A.[ysnDispatched]            
			,A.[strCancelDispatchMessage] 
			,[intDeliveryTermId]		= A.[intDeliveryTermID] 
			,A.[dtmDispatchingDate]       
			,A.[strWillCallStatus]			
			,A.[strPricingMethod]			
			,A.[strOrderNumber]			
			,A.[dtmDeliveryDate]			
			,A.[dblDeliveryQuantity]		
			,A.[dblDeliveryPrice]			
			,A.[dblDeliveryTotal]			
			,A.[intContractId]				
			,A.[ysnLockPrice]				
			,A.[intRouteId]				
			,A.[ysnReceived]				
			,A.[ysnLeakCheckRequired]
			,A.[dblOriginalPercentLeft]
			,A.[dtmReceivedDate]
			,A.intPaymentId
			,A.dblOveragePrice
			,A.dblOverageQty
			,A.strOriginalPricingMethod
		FROM tblTMDispatch A
		INNER JOIN #tmpTMForDeleteOrders B
			ON A.intDispatchID = B.intDispatchId

		------------------------------------
		--Insert to dispatch history source table
		------------------------------------
		INSERT INTO tblTMDispatchHistorySource (
			[intDispatchSyncId]
			,[intSourceType]
		)
		SELECT 
			[intDispatchSyncId] = A.intDispatchSyncId
			,[intSourceType] = B.intSourceType
		FROM @insertedHistory A
		INNER JOIN #tmpTMForDeleteOrders B
			ON A.intDispatchId = B.intDispatchId

	
		------------------------------------
		--DElete from tblTMDispatch
		------------------------------------
		DELETE 
		FROM tblTMDispatch 
		WHERE intDispatchID IN (SELECT intDispatchId FROM #tmpTMForDeleteOrders)

	END
	------------------------------------
	------- END DELETE
	------------------------------------


	------------------------------------
	------- START RESTORE
	------------------------------------
		--Restore Dispatch
		SET IDENTITY_INSERT tblTMDispatch ON

		INSERT INTO tblTMDispatch (
			[intDispatchID]            
			,[intSiteID]
			,[dblPercentLeft]           
			,[dblQuantity]              
			,[dblMinimumQuantity]       
			,[intProductID]             
			,[intSubstituteProductID]   
			,[dblPrice]                 
			,[dblTotal]                 
			,[dtmRequestedDate]         
			,[intPriority]              
			,[strComments]              
			,[ysnCallEntryPrinted]      
			,[intDriverID]              
			,[intDispatchDriverID]      
			,[strDispatchLoadNumber]    
			,[dtmCallInDate]            
			,[ysnSelected]              
			,[strRoute]                 
			,[strSequence]              
			,[intUserID]                
			,[dtmLastUpdated]           
			,[ysnDispatched]            
			,[strCancelDispatchMessage] 
			,[intDeliveryTermID]        
			,[dtmDispatchingDate]       
			,[strWillCallStatus]			
			,[strPricingMethod]			
			,[strOrderNumber]			
			,[dtmDeliveryDate]			
			,[dblDeliveryQuantity]		
			,[dblDeliveryPrice]			
			,[dblDeliveryTotal]			
			,[intContractId]				
			,[ysnLockPrice]				
			,[intRouteId]				
			,[ysnReceived]				
			,[ysnLeakCheckRequired]		
			,[dblOriginalPercentLeft]
			,[dtmReceivedDate]
			,intPaymentId
			,dblOveragePrice
			,dblOverageQty
			,strOriginalPricingMethod
		)	
		SELECT 
			[intDispatchID]				= [intDispatchId]
			,intSiteID					= [intSiteId]
			,[dblPercentLeft]           
			,[dblQuantity]              
			,[dblMinimumQuantity]       
			,[intProductID]				= [intProductId]
			,[intSubstituteProductID]   = [intSubstituteProductId]
			,[dblPrice]                 
			,[dblTotal]                 
			,[dtmRequestedDate]         
			,[intPriority]              
			,[strComments]              
			,[ysnCallEntryPrinted]      
			,[intDriverID]              = [intDriverId]              
			,[intDispatchDriverID]		= [intDispatchDriverId]   
			,[strDispatchLoadNumber]    
			,[dtmCallInDate]            
			,[ysnSelected]              
			,[strRoute]                 
			,[strSequence]              
			,[intUserID]				= [intUserId]
			,[dtmLastUpdated]           
			,[ysnDispatched]            
			,[strCancelDispatchMessage] 
			,[intDeliveryTermID]		= [intDeliveryTermId] 
			,[dtmDispatchingDate]       
			,[strWillCallStatus]			
			,[strPricingMethod]			
			,[strOrderNumber]			
			,[dtmDeliveryDate]			
			,[dblDeliveryQuantity]		
			,[dblDeliveryPrice]			
			,[dblDeliveryTotal]			
			,[intContractId]				
			,[ysnLockPrice]				
			,[intRouteId]				
			,[ysnReceived]				
			,[ysnLeakCheckRequired]
			,[dblOriginalPercentLeft]		
			,[dtmReceivedDate]
			,intPaymentId
			,dblOveragePrice
			,dblOverageQty
			,strOriginalPricingMethod
		FROM tblTMDispatchHistory 
		WHERE intDispatchId IS NOT NULL
			AND intDispatchId IN (SELECT intDispatchId 
								FROM #tmpTMForRestoreOrders)
			

		SET IDENTITY_INSERT tblTMDispatch OFF	

		---DELETE Entry from the tblTMDispatchHistory
		DELETE FROM tblTMDispatchHistory 
		WHERE intDispatchId IS NOT NULL
			AND intDispatchId IN (SELECT intDispatchId 
								FROM #tmpTMForRestoreOrders)
	------------------------------------
	------- END RESTORE
	------------------------------------
END

GO