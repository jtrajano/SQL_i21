CREATE PROCEDURE [dbo].[uspCTUpdateBasisComponents]
	@BasisComponent AS BasisComponent READONLY,
	@userId INT
AS
BEGIN TRY

	--------------------------------------------------------------------------------------------------------------------------------
	---------------- V A R I A B L E S ---------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	DECLARE @ErrMsg				NVARCHAR(MAX),
			@totalRate			DECIMAL(18,6),
			@contractHeaderId	INT,
			@contractDetailId	INT

	--------------------------------------------------------------------------------------------------------------------------------
	---------------- V A L I D A T I O N S -----------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	-- CHECK IF [ysnBasisComponentSales] WAS NOT SET TO TRUE THEN EXIT THE PROCESS
	IF EXISTS (SELECT 1 FROM tblCTCompanyPreference WHERE ysnBasisComponentSales <> 1)
	BEGIN
		RETURN
	END

	-- CHECK IF UDT CONTAINS MORE THAN ONE CONTRACT DETAIL
	IF EXISTS(SELECT 1 FROM @BasisComponent HAVING COUNT(DISTINCT intContractDetailId) > 1)
	BEGIN
		RAISERROR('Different contract detail detected, must have same contract detail.', 1, 1);
	END

	-- GET CONTRACT DETAIL ID
	SELECT TOP 1 @contractDetailId = intContractDetailId 
	FROM @BasisComponent
	
	-- GET CONTRACT HEADER ID
	SELECT TOP 1 @contractHeaderId = intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @contractDetailId

	-- CHECK IF CONTRACT TYPE IS NOT SALE
	IF EXISTS (SELECT 1 FROM tblCTContractHeader WHERE intContractTypeId <> 2 AND intContractHeaderId = @contractHeaderId)
	BEGIN
		RETURN
	END

	-- CHECK IF USER ID IS NULL OR 0
	IF @userId IS NULL OR @userId = 0
	BEGIN
		RAISERROR('User Id cannot be null or 0.', 1, 1);
	END

	-- CHECK IF THERE IS ACCRUED OTHER CHARGES THAT HAVE NOT VENDOR
	IF EXISTS (SELECT TOP 1 1 FROM @BasisComponent WHERE ysnAccrue = 1 AND intVendorId IS NULL)
	BEGIN
		RAISERROR('Vendor is required for accrued other chrages.', 1, 1);
	END
	
	-- GET TOTAL RATE FROM CONTRACT DETAIL
	SELECT @totalRate = SUM(dblRate)
	FROM tblCTContractCost
	WHERE intContractDetailId = @contractDetailId

	-- CHECK IF UDT AND CONTRACT DETAIL TOTAL [dblRate] ARE NOT EQUAL
	IF EXISTS(SELECT 1 FROM @BasisComponent HAVING SUM(dblRate) <> @totalRate)
	BEGIN
		SELECT @ErrMsg = 'The basis component total rate is' +
							CASE WHEN SUM(dblRate) > @totalRate
								THEN ' greater '
								ELSE ' less '
							END + 'than on the current sequence'
		FROM @BasisComponent
		RAISERROR(@ErrMsg, 1, 1);
	END

	--------------------------------------------------------------------------------------------------------------------------------
	----------------- P R O C E S S E S --------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	-- UPDATE CURRENT CONTRACT DETAIL'S COSTS WITH UDT VALUES
	UPDATE CC SET
		[intItemId]					= BC.[intItemId]
		,[intVendorId]				= BC.[intVendorId]			
		,[strCostMethod]			= BC.[strCostMethod]		
		,[intCurrencyId]			= BC.[intCurrencyId]		
		,[dblRate]					= BC.[dblRate]				
		,[intItemUOMId]				= BC.[intItemUOMId]			
		,[intRateTypeId]			= BC.[intRateTypeId]		
		,[dblFX]					= BC.[dblFX]				
		,[ysnAccrue]				= BC.[ysnAccrue]			
		,[ysnMTM]					= BC.[ysnMTM]				
		,[ysnPrice]					= BC.[ysnPrice]				
		,[ysnAdditionalCost]		= BC.[ysnAdditionalCost]	
		,[ysnBasis]					= 1				
		,[ysnReceivable]			= BC.[ysnReceivable]		
		,[strParty]					= BC.[strParty]				
		,[strPaidBy]				= BC.[strPaidBy]			
		,[dtmDueDate]				= BC.[dtmDueDate]			
		,[strReference]				= BC.[strReference]			
		,[ysn15DaysFromShipment]	= BC.[ysn15DaysFromShipment]
		,[strRemarks]				= BC.[strRemarks]
		,[strStatus]				= BC.[strStatus]			
		,[strCostStatus]			= BC.[strCostStatus]		
		,[dblReqstdAmount]			= BC.[dblReqstdAmount]		
		,[dblRcvdPaidAmount]		= BC.[dblRcvdPaidAmount]	
		,[dblActualAmount]			= BC.[dblActualAmount]		
		,[dblAccruedAmount]			= BC.[dblAccruedAmount]		
		,[dblRemainingPercent]		= BC.[dblRemainingPercent]	
		,[dtmAccrualDate]			= BC.[dtmAccrualDate]		
		,[strAPAR]					= BC.[strAPAR]				
		,[strPayToReceiveFrom]		= BC.[strPayToReceiveFrom]	
		,[strReferenceNo]			= BC.[strReferenceNo]		
		,[intContractCostRefId]		= BC.[intContractCostRefId]
		,[ysnFromBasisComponent]	= BC.[ysnFromBasisComponent]
		,[intConcurrencyId]			= (ISNULL(BC.[intConcurrencyId],0) + 1)
	FROM tblCTContractCost CC
	INNER JOIN @BasisComponent BC ON CC.intContractCostId = BC.intContractCostId

	-- INSERT NEW CONTRACT COST FROM UDT WHERE [intContractCostId] IS NULL
	INSERT INTO tblCTContractCost
	(
		[intContractDetailId]		
		,[intItemId]					
		,[intVendorId]				
		,[strCostMethod]				
		,[intCurrencyId]				
		,[dblRate]					
		,[intItemUOMId]				
		,[intRateTypeId]				
		,[dblFX]						
		,[ysnAccrue]					
		,[ysnMTM]					
		,[ysnPrice]					
		,[ysnAdditionalCost]			
		,[ysnBasis]					
		,[ysnReceivable]				
		,[strParty]					
		,[strPaidBy]					
		,[dtmDueDate]				
		,[strReference]				
		,[ysn15DaysFromShipment]		
		,[strRemarks]				
		,[strStatus]					
		,[strCostStatus]				
		,[dblReqstdAmount]			
		,[dblRcvdPaidAmount]			
		,[dblActualAmount]			
		,[dblAccruedAmount]			
		,[dblRemainingPercent]		
		,[dtmAccrualDate]			
		,[strAPAR]					
		,[strPayToReceiveFrom]		
		,[strReferenceNo]			
		,[intContractCostRefId]		
		,[ysnFromBasisComponent]		
		,[intConcurrencyId]			
	)
	SELECT [intContractDetailId]
		,[intItemId]
		,[intVendorId]
		,[strCostMethod]
		,[intCurrencyId]
		,[dblRate]
		,[intItemUOMId]
		,[intRateTypeId]
		,[dblFX]
		,[ysnAccrue]
		,[ysnMTM]
		,[ysnPrice]
		,[ysnAdditionalCost]
		,1
		,[ysnReceivable]
		,[strParty]
		,[strPaidBy]
		,[dtmDueDate]
		,[strReference]
		,[ysn15DaysFromShipment]
		,[strRemarks]
		,[strStatus]
		,[strCostStatus]
		,[dblReqstdAmount]
		,[dblRcvdPaidAmount]
		,[dblActualAmount]
		,[dblAccruedAmount]
		,[dblRemainingPercent]
		,[dtmAccrualDate]
		,[strAPAR]
		,[strPayToReceiveFrom]
		,[strReferenceNo]
		,[intContractCostRefId]
		,1
		,1
	FROM @BasisComponent BC
	WHERE intContractCostId IS NULL

	-- CHECK IF [ysnCreateOtherCostPayable] WAS SET TO TRUE
	IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1 AND ysnAllowBasisComponentToAccrue = 1)
	BEGIN
		-- CHECK IF THERE ARE ACCRUED OTHER CHARGES
		IF EXISTS (SELECT TOP 1 1 FROM @BasisComponent WHERE ysnAccrue = 1)
		BEGIN
			-- ADD/UPDATE VOUCHER'S PAYABLES
			EXEC uspCTManagePayable @contractHeaderId, 'header', 0, @userId
		END
	END	

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH