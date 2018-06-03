CREATE PROCEDURE [dbo].[uspGRCreateScaleTicket]
	@intExternalId			INT,
	@strTicketNo			Nvarchar(40),	
	@intUserId				INT,
	@XML					NVARCHAR(MAX),
	@intTicketId			INT	OUTPUT
AS
BEGIN TRY

	DECLARE @ErrMsg						NVARCHAR(MAX),
			@idoc						INT,
			@strTblXML					NVARCHAR(MAX),
			
			@intEntityId				INT,
			@intTicketDiscountId		INT,
			@intDiscountScheduleId		INT,
			@SQL						NVARCHAR(MAX)
				
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML

	IF OBJECT_ID('tempdb..#tmpTicket') IS NOT NULL  					
		DROP TABLE #tmpTicket					

	SELECT * INTO #tmpTicket FROM tblSCTicket WHERE 1 = 2
	
	SET @SQL = NULL
	
	SELECT @SQL =  STUFF((SELECT ' ALTER TABLE #tmpTicket ALTER COLUMN '+COLUMN_NAME+' ' + DATA_TYPE + 
	CASE	WHEN DATA_TYPE LIKE '%varchar' THEN '('+LTRIM(CHARACTER_MAXIMUM_LENGTH)+')' 
			WHEN DATA_TYPE = 'numeric' THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
			ELSE ''
	END + ' NULL' 
	FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tmpTicket%' AND IS_NULLABLE = 'NO' AND COLUMN_NAME NOT IN('intTicketId','intTicketDiscountId') FOR xml path('')) ,1,1,'')

	EXEC sp_executesql @SQL 
	
	IF OBJECT_ID('tempdb..#tmpTicketDiscount') IS NOT NULL  					
		DROP TABLE #tmpTicketDiscount					

	SELECT * INTO #tmpTicketDiscount FROM tblQMTicketDiscount WHERE 1 = 2
	
	SET @SQL = NULL
	
	SELECT @SQL =  STUFF((SELECT ' ALTER TABLE ##tmpTicketDiscount ALTER COLUMN '+COLUMN_NAME+' ' + DATA_TYPE + 
	CASE	WHEN DATA_TYPE LIKE '%varchar' THEN '('+LTRIM(CHARACTER_MAXIMUM_LENGTH)+')' 
			WHEN DATA_TYPE = 'numeric' THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
			ELSE ''
	END + ' NULL' 
	FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '##tmpTicketDiscount%' AND IS_NULLABLE = 'NO' AND COLUMN_NAME <> 'intTicketDiscountId' FOR xml path('')) ,1,1,'')
	
	EXEC sp_executesql @SQL 

	IF OBJECT_ID('tempdb..#tmpExtracted') IS NOT NULL  					
		DROP TABLE #tmpExtracted	
	
		CREATE TABLE #tmpExtracted
		(
			 [strData]					 NVARCHAR(40)
			,[strType]					 NVARCHAR(40)
			,[strEntityName]				 NVARCHAR(40)
			,[strItemNo]				 NVARCHAR(40)
			,[strLocationName]			 NVARCHAR(50)
			,[strTicketStatus]			 NVARCHAR(40)
			,[strTicketNumber]			 NVARCHAR(40)
			,[intScaleSetupId]			 INT
			,[intTicketPoolId]			 INT
			,[intTicketLocationId]		 INT
			,[intTicketType]			 INT
			,[strInOutFlag]				 NVARCHAR(40)
			,[dtmTicketDateTime]		 DATETIME
			,[intProcessingLocationId]   INT
			,[strScaleOperatorUser]		 NVARCHAR(40)
			,[intEntityScaleOperatorId]  INT
			,[strTruckName]			     NVARCHAR(40)
			,[strDriverName]		     NVARCHAR(40)
			,[dblGrossWeight]			 DECIMAL(13, 3)
			,[dblTareWeight]			 DECIMAL(13, 3)
			,[dblGrossUnits]			 DECIMAL(13, 3)
			,[dblShrink]				 DECIMAL(13, 3)
			,[dblNetUnits]				 DECIMAL(13, 3)
			,[intSplitId]				 INT
			,[strDistributionOption]	 NVARCHAR(40)
			,[intDiscountSchedule]		 INT
			,[strContractNumber]	     NVARCHAR(40)
			,[intContractSequence]       INT
			,[dblUnitPrice]				 NUMERIC(38, 20)
			,[dblUnitBasis]				 NUMERIC(38, 20)
			,[dblTicketFees]			 NUMERIC(38, 20)
			,[intCurrencyId]			 INT
			,[strTicketComment]			 NVARCHAR(40)
			,[strCustomerReference]		 NVARCHAR(40)
			,[intHaulerId]				 INT
			,[dblFreightRate]			 NUMERIC(38, 20)
			,[ysnFarmerPaysFreight]      BIT
			,[ysnCusVenPaysFees]		 BIT
			,[intAxleCount]				 INT
			,[strBinNumber]				 NVARCHAR(40)
			,[strDiscountComment]		 NVARCHAR(40)	
			,[intCommodityId]			 INT
			,[intDiscountId] 			 INT
			,[intContractId] 			 INT
			,[intItemId] 				 INT
			,[intEntityId]				 INT
			,[intSubLocationId] 		 INT
			,[intStorageLocationId]		 INT
			,[intStorageScheduleId] 	 INT
			,[intConcurrencyId]			 INT
			,[intItemUOMIdFrom]			 INT
			,[intItemUOMIdTo]			 INT
			,[intTicketTypeId]			 INT
			,[intStorageScheduleTypeId]	 INT
			,ysnRailCar					 BIT 
			,strOfflineGuid				 NVARCHAR(100)
			,ysnDeliverySheetPost		 BIT
			,ysnDestinationWeightGradePost BIT
			,ysnReadyToTransfer			  BIT
		
		); 

	IF OBJECT_ID('tempdb..#tmpXMLHeader') IS NOT NULL  					
		DROP TABLE #tmpXMLHeader	

	IF ISNULL(@XML,'') <> ''
	BEGIN
		SELECT	@intEntityId	=	intEntityId
		FROM	OPENXML(@idoc, 'overrides',2)
		WITH
		(
				intEntityId		INT
		)
	END

	BEGIN

		INSERT	INTO	#tmpExtracted
		(
			 [strData]
			,[strType]
			,[strEntityName]
			,[strItemNo]			
			,[strLocationName]				
			,[strTicketStatus]  
			,[strTicketNumber] 
			,[intScaleSetupId] 
			,[intTicketPoolId] 
			,[intTicketLocationId]
			,[intTicketType] 
			,[strInOutFlag] 
			,[dtmTicketDateTime]
			,[intProcessingLocationId]
			,[strScaleOperatorUser]
			,[intEntityScaleOperatorId]
			,[strTruckName]
			,[strDriverName]
			,[dblGrossWeight] 
			,[dblTareWeight]
			,[dblGrossUnits]
			,[dblShrink]
			,[dblNetUnits] 
			,[intSplitId]
			,[strDistributionOption]
			,[intDiscountSchedule]    
			,[strContractNumber]
			,[intContractSequence]     
			,[dblUnitPrice]
			,[dblUnitBasis]
			,[dblTicketFees]
			,[intCurrencyId]
			,[strTicketComment]
			,[strCustomerReference]
			,[intHaulerId]
			,[dblFreightRate]
			,[ysnFarmerPaysFreight]
			,[ysnCusVenPaysFees]
			,[intAxleCount]
			,[strBinNumber]
			,[strDiscountComment]	
			,[intCommodityId]
			,[intDiscountId] 
			,[intContractId] 
			,[intItemId] 
			,[intEntityId]	
			,[intSubLocationId] 
			,[intStorageLocationId]
			,[intStorageScheduleId] 
			,[intConcurrencyId]
			,[intItemUOMIdFrom]
			,[intItemUOMIdTo]
			,[intTicketTypeId]
			,[intStorageScheduleTypeId]
			,ysnRailCar
			,strOfflineGuid
			,ysnDeliverySheetPost
			,ysnDestinationWeightGradePost
			,ysnReadyToTransfer
	
		)
		SELECT	
				 [strData]					 = CI.strData
				,[strType]					 = CI.strTicketType
				,[strEntityNo]				 = CI.strEntityName
				,[strItemNo]				 = CI.strItemNo
				,[strLocationNumber]		 = CI.strLocationNumber
				,[strTicketStatus]           = 'O'
				,[strTicketNumber] 			 = CI.strTicketNumber
				,[intScaleSetupId] 			 = ScaleSetup.intScaleSetupId
				,[intTicketPoolId] 			 = ScaleSetup.intTicketPoolId
				,[intTicketLocationId]		 = CL.intCompanyLocationId
				,[intTicketType] 			 = CASE 
													WHEN CI.strTicketType = 'Load In'  THEN 1
													WHEN CI.strTicketType = 'Load Out' THEN 2
											   END	
				,[strInOutFlag] 			 = CASE 
											   	WHEN CI.strTicketType = 'Load In'  THEN 'I'
											   	WHEN CI.strTicketType = 'Load Out' THEN 'O'
											   END
				,[dtmTicketDateTime]		 = CI.dtmTicketDateTime
				,[intProcessingLocationId]	 = CL.intCompanyLocationId
				,[strScaleOperatorUser]		 = 1
				,[intEntityScaleOperatorId]	 = @intUserId
				,[strTruckName]				 = CI.strTruckName
				,[strDriverName]			 = CI.strDriverName
				,[dblGrossWeight] 			 = CI.dblGrossWeight
				,[dblTareWeight]			 = CI.dblTareWeight
				,[dblGrossUnits]			 = CI.dblGrossUnits
				,[dblShrink]				 = CI.dblShrink
				,[dblNetUnits] 				 = CI.dblNetUnits
				,[intSplitId]				 = CI.intSplitId
				,[strDistributionOption]	 = CI.strDistributionOption
				,[intDiscountSchedule]    	 = DiscountSchedule.intDiscountScheduleId
				,[strContractNumber]		 = CI.strContractNumber
				,[intContractSequence]     	 = CI.intContractSequence
				,[dblUnitPrice]				 = CI.dblUnitPrice
				,[dblUnitBasis]				 = CI.dblUnitBasis
				,[dblTicketFees]			 = CI.dblTicketFees
				,[intCurrencyId]			 =  EY.intCurrencyId
				,[strTicketComment]			 = CI.strTicketComment
				,[strCustomerReference]		 = CI.strCustomerReference
				,[intHaulerId]				 = CI.intHaulerId
				,[dblFreightRate]			 = CI.dblFreightRate
				,[ysnFarmerPaysFreight]		 = CI.ysnFarmerPaysFreight
				,[ysnCusVenPaysFees]		 = CI.ysnCusVenPaysFees
				,[intAxleCount]				 = CI.intAxleCount
				,[strBinNumber]				 = CI.strBinNumber
				,[strDiscountComment]		 = NULL
				,[intCommodityId]			 = IM.intCommodityId
				,[intDiscountId] 			 = DiscountId.intDiscountId
				,[intContractId] 			 = CD.intContractDetailId
				,[intItemId] 				 = IM.intItemId
				,[intEntityId]				 = EY.intEntityId
				,[intSubLocationId] 		 = SubLocation.intCompanyLocationSubLocationId
				,[intStorageLocationId]		 = Bin.intStorageLocationId
				,[intStorageScheduleId] 	 = SS.intStorageScheduleRuleId
				,[intConcurrencyId]			 = 1
				,[intItemUOMIdFrom]			 = ScaleUOM.intItemUOMId
				,[intItemUOMIdTo]			 = UOM.intItemUOMId
				,[intTicketTypeId]			 = CASE 
													WHEN CI.strTicketType = 'Load In'  THEN 1
													WHEN CI.strTicketType = 'Load Out' THEN 2
											   END
				,[intStorageScheduleTypeId]	 = SS.intStorageScheduleRuleId
				,ysnRailCar					 = 0
				,strOfflineGuid				 = ''
				,ysnDeliverySheetPost		 = 0
				,ysnDestinationWeightGradePost = 0
				,ysnReadyToTransfer = 0

		FROM		tblSCTicketLVStaging	    CI	
		LEFT JOIN	tblSMCompanyLocation		CL	ON	CL.strLocationName	=	CI.strLocationName		
		LEFT JOIN	tblICItem					IM	ON	IM.strItemNo		=	CI.strItemNo
		LEFT JOIN	tblICItemUOM				UOM	ON	UOM.intItemId		=	IM.intItemId AND UOM.ysnStockUnit = 1
		LEFT JOIN	vyuCTEntity					EY	ON	EY.strEntityName	=	CI.strEntityName
												AND	EY.strEntityType		=	CASE 
																					WHEN CI.strTicketType = 'Load In'  THEN 'Vendor'
																					WHEN CI.strTicketType = 'Load Out' THEN 'Customer'
																				END
		LEFT JOIN tblGRDiscountId DiscountId ON DiscountId.strDiscountId = CI.strDiscountId
		LEFT JOIN tblGRDiscountCrossReference CRef ON CRef.intDiscountId = DiscountId.intDiscountId 
		LEFT JOIN tblGRDiscountSchedule DiscountSchedule ON DiscountSchedule.intDiscountScheduleId = CRef.intDiscountScheduleId 
														AND DiscountSchedule.intCommodityId = IM.intCommodityId 
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.strSubLocationName = CI.strStorageLocation
		LEFT JOIN tblICStorageLocation Bin ON Bin.strName = CI.strBinNumber
		LEFT JOIN tblGRStorageScheduleRule SS ON SS.strScheduleId = CI.strStorageSchedule
		LEFT JOIN tblCTContractHeader CH ON CH.strContractNumber = CI.strContractNumber
		LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId AND CD.intContractSeq = CI.intContractSequence
		LEFT JOIN 
		(
		 SELECT TOP 1 * FROM tblSCScaleSetup
		)ScaleSetup ON 1 =1
		LEFT JOIN tblICItemUOM ScaleUOM ON ScaleUOM.intUnitMeasureId = ScaleSetup.intUnitMeasureId AND ScaleUOM.intItemId = IM.intItemId
		--WHERE	intTicketLVStagingId	= @intExternalId 
		WHERE strTicketNumber = @strTicketNo AND CI.strData = 'Header' AND DiscountSchedule.intDiscountScheduleId IS NOT NULL

		INSERT INTO #tmpExtracted
		(
			 strData
			,strType
			,strTicketNumber
			,strEntityName
			,strLocationName
			,strItemNo
		)
		SELECT 
		 strData
		,strTicketType
		,strTicketNumber
		,strEntityName
		,strLocationName
		,strItemNo
		FROM tblSCTicketLVStaging WHERE strTicketNumber = @strTicketNo AND strData = 'Detail'
	END
	
	IF EXISTS(SELECT * FROM #tmpExtracted)
	BEGIN

		INSERT	INTO #tmpTicket
		(
			 [strTicketStatus]  
			,[strTicketNumber] 
			,[intScaleSetupId] 
			,[intTicketPoolId] 
			,[intTicketLocationId]
			,[intTicketType] 
			,[strInOutFlag] 
			,[dtmTicketDateTime]
			,[intProcessingLocationId]
			,[strScaleOperatorUser]
			,[intEntityScaleOperatorId]
			,[strTruckName]
			,[strDriverName]
			,[dblGrossWeight] 
			,[dblTareWeight]
			,[dblGrossUnits]
			,[dblShrink]
			,[dblNetUnits] 
			,[intSplitId]
			,[strDistributionOption]
			,[intDiscountSchedule]    
			,[strContractNumber]
			,[intContractSequence]     
			,[dblUnitPrice]
			,[dblUnitBasis]
			,[dblTicketFees]
			,[intCurrencyId]
			,[strTicketComment]
			,[strCustomerReference]
			,[intHaulerId]
			,[dblFreightRate]
			,[ysnFarmerPaysFreight]
			,[ysnCusVenPaysFees]
			,[intAxleCount]
			,[strBinNumber]
			,[strDiscountComment]	
			,[intCommodityId]
			,[intDiscountId] 
			,[intContractId] 
			,[intItemId] 
			,[intEntityId]	
			,[intSubLocationId] 
			,[intStorageLocationId]
			,[intStorageScheduleId] 
			,[intConcurrencyId]
			,[intItemUOMIdFrom]
			,[intItemUOMIdTo]
			,[intTicketTypeId]
			,[intStorageScheduleTypeId]
			,ysnRailCar		
			,strOfflineGuid
			,ysnDeliverySheetPost
			,ysnDestinationWeightGradePost
			,ysnReadyToTransfer	
		)
		SELECT	
		 [strTicketStatus]  
		,[strTicketNumber] 
		,[intScaleSetupId] 
		,[intTicketPoolId] 
		,[intTicketLocationId]
		,[intTicketType] 
		,[strInOutFlag] 
		,[dtmTicketDateTime]
		,[intProcessingLocationId]
		,[strScaleOperatorUser]
		,[intEntityScaleOperatorId]
		,[strTruckName]
		,[strDriverName]
		,[dblGrossWeight] 
		,[dblTareWeight]
		,[dblGrossUnits]
		,[dblShrink]
		,[dblNetUnits] 
		,[intSplitId]
		,[strDistributionOption]
		,[intDiscountSchedule]    
		,[strContractNumber]
		,[intContractSequence]     
		,[dblUnitPrice]
		,[dblUnitBasis]
		,[dblTicketFees]
		,[intCurrencyId]
		,[strTicketComment]
		,[strCustomerReference]
		,[intHaulerId]
		,[dblFreightRate]
		,[ysnFarmerPaysFreight]
		,[ysnCusVenPaysFees]
		,[intAxleCount]
		,[strBinNumber]
		,[strDiscountComment]	
		,[intCommodityId]
		,[intDiscountId] 
		,[intContractId] 
		,[intItemId] 
		,[intEntityId]	
		,[intSubLocationId] 
		,[intStorageLocationId]
		,[intStorageScheduleId] 
		,[intConcurrencyId]
		,[intItemUOMIdFrom]
		,[intItemUOMIdTo]
		,[intTicketTypeId]
		,[intStorageScheduleTypeId]
		,ysnRailCar		
		,strOfflineGuid
		,ysnDeliverySheetPost
		,ysnDestinationWeightGradePost
		,ysnReadyToTransfer	
		FROM	#tmpExtracted 
		WHERE strData = 'Header' 

		EXEC	uspCTGetTableDataInXML '#tmpTicket',null,@strTblXML OUTPUT,'tblSCTicket'
		EXEC	uspCTInsertINTOTableFromXML 'tblSCTicket',@strTblXML,@intTicketId OUTPUT

		SELECT @intDiscountScheduleId = intDiscountSchedule FROM	#tmpExtracted WHERE strData = 'Header'


				INSERT	INTO #tmpTicketDiscount
				(
					 intConcurrencyId
					,dblGradeReading
					,strCalcMethod
					,strShrinkWhat
					,dblShrinkPercent
					,dblDiscountAmount
					,dblDiscountDue
					,dblDiscountPaid
					,ysnGraderAutoEntry
					,intDiscountScheduleCodeId					
					,intTicketId
					,intTicketFileId
					,strSourceType
					,intSort
					,strDiscountChargeType
				)

			SELECT 
				 intConcurrencyId				= 1
				,dblGradeReading				= CAST(Extracted.strEntityName AS DECIMAL(24,10))
				,strCalcMethod					= QM.strCalcMethod
				,strShrinkWhat					= QM.strShrinkWhat
				,dblShrinkPercent				= CAST(Extracted.strLocationName AS DECIMAL(24,10))
				,dblDiscountAmount				= CAST(Extracted.strItemNo AS DECIMAL(24,10))
				,dblDiscountDue					= CAST(Extracted.strItemNo AS DECIMAL(24,10))
				,dblDiscountPaid				= 0
				,ysnGraderAutoEntry				= 0
				,intDiscountScheduleCodeId		= QM.intDiscountScheduleCodeId				
				,intTicketId					= @intTicketId
				,intTicketFileId				= @intTicketId
				,strSourceType					= 'Scale'
				,intSort						= 1
				,strDiscountChargeType			= 'Dollar'
		FROM	#tmpExtracted Extracted
		LEFT JOIN	
		(
			SELECT 
			 strCalcMethod					= DCode.intDiscountCalculationOptionId
			,strShrinkWhat					= CP.strDiscountCalculationOption
			,intDiscountScheduleCodeId		= DCode.intDiscountScheduleCodeId
			,strItemNo						= Item.strItemNo
			FROM tblGRDiscountScheduleCode DCode 
			JOIN tblICItem Item ON Item.intItemId = DCode.intItemId
			JOIN tblGRDiscountCalculationOption CP ON CP.intDiscountCalculationOptionId = DCode.intDiscountCalculationOptionId
			WHERE DCode.intDiscountScheduleId = @intDiscountScheduleId
		) QM ON QM.strItemNo = Extracted.strType COLLATE  Latin1_General_CS_AS		
		WHERE Extracted.strData ='Detail'AND Extracted.strTicketNumber = @strTicketNo

		UPDATE a
		SET a.intSort=b.[Rank]
		FROM #tmpTicketDiscount a
		JOIN
		(	  SELECT
			  DENSE_RANK() OVER ( PARTITION BY intTicketFileId ORDER BY intTicketDiscountId) AS [Rank]
			  FROM #tmpTicketDiscount
		) AS b ON 1 = 1

		EXEC	uspCTGetTableDataInXML '#tmpTicketDiscount',null,@strTblXML OUTPUT,'tblQMTicketDiscount'
		EXEC	uspCTInsertINTOTableFromXML 'tblQMTicketDiscount',@strTblXML,@intTicketDiscountId OUTPUT
		
	END


END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
