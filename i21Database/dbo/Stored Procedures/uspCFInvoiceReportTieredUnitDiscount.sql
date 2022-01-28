CREATE PROCEDURE [dbo].[uspCFInvoiceReportTieredUnitDiscount](
	 @InvoiceDate DATETIME 
	,@UserId NVARCHAR(MAX) 
	,@StatementType NVARCHAR(MAX) 
	,@ysnInvoiceBillingCycleFee BIT = 0 
	,@ysnInvoiceMonthyFee BIT = 0 
	,@ysnInvoiceAnnualFee BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		
		SET @UserId = LOWER(@UserId)
		SET @StatementType = LOWER(@StatementType)
		
		DECLARE @tblTieredUnitDiscountFees TABLE 
		(
			 intFeeProfileId				INT NULL,
			 strFeeProfileId				NVARCHAR(MAX) NULL,
			 strFeeDetailDescription		NVARCHAR(MAX) NULL,
			 strInvoiceFormat				NVARCHAR(MAX) NULL,
			 intFeeProfileDetailId			INT NULL,
			 intFeeId						INT NULL,
			 strFeeProfileDescription		NVARCHAR(MAX) NULL,
			 dtmEndDate						DATETIME NULL,
			 dtmStartDate					DATETIME NULL,
			 strFee							NVARCHAR(MAX) NULL,
			 strFeeDescription				NVARCHAR(MAX) NULL,
			 strCalculationType				NVARCHAR(MAX) NULL,
			 strCalculationCard				NVARCHAR(MAX) NULL,
			 strCalculationFrequency		NVARCHAR(MAX) NULL,
			 ysnExtendedRemoteTrans			BIT NULL,
			 ysnRemotesTrans				BIT NULL,
			 ysnLocalTrans					BIT NULL,
			 ysnForeignTrans				BIT NULL,
			 intNetworkId					INT NULL,
			 intCardTypeId					INT NULL,
			 intMinimumThreshold			INT NULL,
			 intMaximumThreshold			INT NULL,
			 dblFeeRate						NUMERIC(18,6) NULL,
			 intGLAccountId					INT NULL,
			 intItemId						INT NULL,
			 intRestrictedByProduct			INT NULL,
			 intDiscountScheduleId			INT NULL
		)


	INSERT INTO @tblTieredUnitDiscountFees(
		 intFeeProfileId				
		,strFeeProfileId				
		,strFeeDetailDescription		
		,strInvoiceFormat				
		,intFeeProfileDetailId			
		,intFeeId						
		,strFeeProfileDescription		
		,dtmEndDate						
		,dtmStartDate					
		,strFee							
		,strFeeDescription				
		,strCalculationType				
		,strCalculationCard				
		,strCalculationFrequency		
		,ysnExtendedRemoteTrans			
		,ysnRemotesTrans				
		,ysnLocalTrans					
		,ysnForeignTrans				
		,intNetworkId					
		,intCardTypeId					
		,intMinimumThreshold			
		,intMaximumThreshold			
		,dblFeeRate						
		,intGLAccountId					
		,intItemId						
		,intRestrictedByProduct				
		,intDiscountScheduleId		
	)	
	SELECT
		 tblCFFeeProfile.intFeeProfileId			
		,strFeeProfileId			
		,tblCFFeeProfileDetail.strDescription	
		,strInvoiceFormat			
		,intFeeProfileDetailId		
		,tblCFFee.intFeeId					
		,tblCFFeeProfile.strDescription	
		,dtmEndDate					
		,dtmStartDate				
		,strFee						
		,strFeeDescription			
		,strCalculationType			
		,strCalculationCard			
		,strCalculationFrequency	
		,ysnExtendedRemoteTrans		
		,ysnRemotesTrans			
		,ysnLocalTrans				
		,ysnForeignTrans			
		,intNetworkId				
		,intCardTypeId				
		,intMinimumThreshold		
		,intMaximumThreshold		
		,dblFeeRate					
		,intGLAccountId				
		,intItemId					
		,intRestrictedByProduct				
		,intDiscountScheduleId		
	FROM tblCFFeeProfile
	LEFT JOIN tblCFFeeProfileDetail ON tblCFFeeProfile.intFeeProfileId = tblCFFeeProfileDetail.intFeeProfileId
	LEFT JOIN tblCFFee ON tblCFFeeProfileDetail.intFeeId = tblCFFee.intFeeId
	WHERE strCalculationType = 'Tiered Unit Discount' 
	AND ((tblCFFee.strCalculationFrequency = 'Billing Cycle' AND @ysnInvoiceBillingCycleFee = 1)
			OR (tblCFFee.strCalculationFrequency = 'Annual' AND @ysnInvoiceAnnualFee = 1)
			OR (tblCFFee.strCalculationFrequency = 'Monthly' AND @ysnInvoiceMonthyFee = 1))
	AND @InvoiceDate >= tblCFFeeProfileDetail.dtmStartDate AND @InvoiceDate <= tblCFFeeProfileDetail.dtmEndDate
		

	DECLARE @tblCFGroupVolumeDisctinct TABLE
	(
			intCustomerGroupId INT,
			[dblEligibleGallons] NUMERIC(18,6),
			[strGroupName] NVARCHAR(MAX)
	)

	DECLARE @tblCFAccountVolumeDisctinct TABLE
	(
			intAccountId INT,
			[dblEligibleGallons] NUMERIC(18,6)
	)


	

	INSERT INTO @tblCFGroupVolumeDisctinct
	(
		 intCustomerGroupId 
		,[strGroupName]
		,[dblEligibleGallons]
	)
	SELECT 
		[intCustomerGroupId],
		[strGroupName],
		[dblEligibleGallons] = SUM(cfInv.dblQuantity)
	FROM tblCFInvoiceReportTempTable AS cfInv
	INNER JOIN dbo.vyuCFCardAccount AS cfCardAccount 
	ON cfInv.intAccountId = cfCardAccount.intAccountId 
	AND cfInv.intCardId = cfCardAccount.intCardId
	INNER JOIN @tblTieredUnitDiscountFees
	ON [@tblTieredUnitDiscountFees].intFeeProfileId = cfCardAccount.intFeeProfileId
	WHERE ISNULL(intInvoiceId,0) != 0
	AND LOWER(cfInv.strUserId) = @UserId
	AND ISNULL(cfInv.ysnExpensed,0) = 0
	AND LOWER(cfInv.strStatementType) = @StatementType
	AND (intCustomerGroupId IS NOT NULL AND intCustomerGroupId != 0)
	AND ((strTransactionType = 'Local/Network' AND [@tblTieredUnitDiscountFees].ysnLocalTrans = 1)
	OR (strTransactionType = 'Remote' AND [@tblTieredUnitDiscountFees].ysnRemotesTrans = 1)
	OR (strTransactionType = 'Extended Remote' AND [@tblTieredUnitDiscountFees].ysnExtendedRemoteTrans = 1
	OR (strTransactionType = 'Foreign Sale' AND [@tblTieredUnitDiscountFees].ysnForeignTrans = 1)))
	AND (ISNULL([@tblTieredUnitDiscountFees].intNetworkId,0) = 0 OR ISNULL([@tblTieredUnitDiscountFees].intNetworkId,0) = cfCardAccount.intNetworkId)
	GROUP BY intCustomerGroupId , [strGroupName]


	INSERT INTO @tblCFAccountVolumeDisctinct
	(
		 intAccountId 
		,[dblEligibleGallons]
	)
	SELECT 
		cfCardAccount.intAccountId,
		[dblEligibleGallons] = SUM(cfInv.dblQuantity)
	FROM tblCFInvoiceReportTempTable AS cfInv
	INNER JOIN dbo.vyuCFCardAccount AS cfCardAccount 
	ON cfInv.intAccountId = cfCardAccount.intAccountId 
	AND cfInv.intCardId = cfCardAccount.intCardId
	INNER JOIN @tblTieredUnitDiscountFees
	ON [@tblTieredUnitDiscountFees].intFeeProfileId = cfCardAccount.intFeeProfileId
	WHERE ISNULL(intInvoiceId,0) != 0
	AND  LOWER(cfInv.strUserId) = @UserId
	AND ISNULL(cfInv.ysnExpensed,0) = 0
	AND LOWER(cfInv.strStatementType) = @StatementType
	AND (intCustomerGroupId IS NULL OR intCustomerGroupId = 0)
	AND ((strTransactionType = 'Local/Network' AND [@tblTieredUnitDiscountFees].ysnLocalTrans = 1)
	OR (strTransactionType = 'Remote' AND [@tblTieredUnitDiscountFees].ysnRemotesTrans = 1)
	OR (strTransactionType = 'Extended Remote' AND [@tblTieredUnitDiscountFees].ysnExtendedRemoteTrans = 1
	OR (strTransactionType = 'Foreign Sale' AND [@tblTieredUnitDiscountFees].ysnForeignTrans = 1)))
	AND (ISNULL([@tblTieredUnitDiscountFees].intNetworkId,0) = 0 OR ISNULL([@tblTieredUnitDiscountFees].intNetworkId,0) = cfCardAccount.intNetworkId)
	GROUP BY cfCardAccount.intAccountId 



	INSERT INTO tblCFInvoiceReportTieredUnitDiscountTempTable 
	(	 
		 [strGuid]												
		,[strUserId]												
		,[strStatementType]										
		,[intAccountId]											
		,[intCustomerGroupId]									
		,[strGroupName]											
		,[dblEligibleGallons]
		,[intDiscountScheduleId]
		,[dblRate]
		,[intFeeProfileId]
		,[dblQuantity]
		,[dblAmount]
		,[intFeeId]			
		,[intTransactionId]	
	) 
	SELECT 
		 [strGuid]
		,[strUserId]				
		,[strStatementType]			
		,cfInv.[intAccountId]				
		,[intCustomerGroupId]		
		,[strGroupName]				
		,0
		,[@tblTieredUnitDiscountFees].[intDiscountScheduleId]	
		,0
		,cfCardAccount.[intFeeProfileId]
		,[dblQuantity]
		,0
		,[intFeeId]	
		,[intTransactionId]
	FROM tblCFInvoiceReportTempTable AS cfInv
	INNER JOIN dbo.vyuCFCardAccount AS cfCardAccount 
	ON cfInv.intAccountId = cfCardAccount.intAccountId 
	INNER JOIN @tblTieredUnitDiscountFees
	ON [@tblTieredUnitDiscountFees].intFeeProfileId = cfCardAccount.intFeeProfileId
	AND cfInv.intCardId = cfCardAccount.intCardId
	WHERE ISNULL(intInvoiceId,0) != 0
	AND  LOWER(cfInv.strUserId) = @UserId
	AND ISNULL(cfInv.ysnExpensed,0) = 0
	AND LOWER(cfInv.strStatementType) = @StatementType
	AND ((strTransactionType = 'Local/Network' AND [@tblTieredUnitDiscountFees].ysnLocalTrans = 1)
	OR (strTransactionType = 'Remote' AND [@tblTieredUnitDiscountFees].ysnRemotesTrans = 1)
	OR (strTransactionType = 'Extended Remote' AND [@tblTieredUnitDiscountFees].ysnExtendedRemoteTrans = 1
	OR (strTransactionType = 'Foreign Sale' AND [@tblTieredUnitDiscountFees].ysnForeignTrans = 1)))
	AND (ISNULL([@tblTieredUnitDiscountFees].intNetworkId,0) = 0 OR ISNULL([@tblTieredUnitDiscountFees].intNetworkId,0) = cfCardAccount.intNetworkId)

	

	

	UPDATE tblCFInvoiceReportTieredUnitDiscountTempTable
	SET tblCFInvoiceReportTieredUnitDiscountTempTable.[dblEligibleGallons] = [@tblCFAccountVolumeDisctinct].[dblEligibleGallons]
	FROM @tblCFAccountVolumeDisctinct
	WHERE [@tblCFAccountVolumeDisctinct].intAccountId = tblCFInvoiceReportTieredUnitDiscountTempTable.intAccountId


	UPDATE tblCFInvoiceReportTieredUnitDiscountTempTable
	SET tblCFInvoiceReportTieredUnitDiscountTempTable.[dblEligibleGallons] = [@tblCFGroupVolumeDisctinct].[dblEligibleGallons]
	FROM @tblCFGroupVolumeDisctinct
	WHERE [@tblCFGroupVolumeDisctinct].intCustomerGroupId = tblCFInvoiceReportTieredUnitDiscountTempTable.intCustomerGroupId

	




	UPDATE tblCFInvoiceReportTieredUnitDiscountTempTable
	SET tblCFInvoiceReportTieredUnitDiscountTempTable.dblRate = ISNULL(tblCFDiscountSchedule.dblRate,0)
	FROM 
		(
		SELECT 
			 tblCFDiscountSchedule.intDiscountScheduleId
			,tblCFDiscountSchedule.strDiscountSchedule
			,tblCFDiscountSchedule.strDescription
			,tblCFDiscountSchedule.ysnDiscountOnRemotes
			,tblCFDiscountSchedule.ysnDiscountOnExtRemotes
			,tblCFDiscountSchedule.ysnShowOnCFInvoice
			,tblCFDiscountScheduleDetail.intFromQty
			,tblCFDiscountScheduleDetail.intThruQty
			,tblCFDiscountScheduleDetail.dblRate

		FROM tblCFDiscountSchedule
		INNER JOIN tblCFDiscountScheduleDetail ON tblCFDiscountSchedule.intDiscountScheduleId = tblCFDiscountScheduleDetail.intDiscountScheduleId
		) as tblCFDiscountSchedule
	WHERE [tblCFDiscountSchedule].intDiscountScheduleId = tblCFInvoiceReportTieredUnitDiscountTempTable.intDiscountScheduleId
	AND  tblCFInvoiceReportTieredUnitDiscountTempTable.[dblEligibleGallons] >= [tblCFDiscountSchedule].intFromQty AND tblCFInvoiceReportTieredUnitDiscountTempTable.[dblEligibleGallons] <= [tblCFDiscountSchedule].intThruQty


	UPDATE tblCFInvoiceReportTieredUnitDiscountTempTable
	SET tblCFInvoiceReportTieredUnitDiscountTempTable.dblAmount = ABS(ROUND(tblCFInvoiceReportTieredUnitDiscountTempTable.dblRate * tblCFInvoiceReportTieredUnitDiscountTempTable.dblQuantity,2)) * -1
	FROM tblCFInvoiceReportTieredUnitDiscountTempTable

	
	SELECT * FROM tblCFInvoiceReportTieredUnitDiscountTempTable



	END TRY
	BEGIN CATCH
			
		declare @error int, @message varchar(4000), @xstate int;
		select @error = ERROR_NUMBER(),
		@message = ERROR_MESSAGE(), 
		@xstate = XACT_STATE();
	
	END CATCH
END