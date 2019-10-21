CREATE PROCEDURE [dbo].[uspGRCreateScaleTicket]
	@intExternalId			INT,
	@strTicketNo			NVARCHAR(40),	
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
			@strScaleOperatorUser       NVARCHAR(100),
			@SQL						NVARCHAR(MAX)
			
	SELECT @strScaleOperatorUser = strName FROM tblEMEntity WHERE intEntityId = @intUserId

    IF ISNULL(@strTicketNo,'') = ''
	BEGIN
			SET @ErrMsg = 'Ticket No is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strData,'') = '')
	BEGIN
			SET @ErrMsg = 'Data Column in import file cannot be blank. It should be Header or Detail.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strTicketType,'') = '')
	BEGIN
			SET @ErrMsg = 'Type is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND strTicketType NOT IN (SELECT strTicketType FROM tblSCListTicketTypes))
	BEGIN
			SET @ErrMsg = 'Invalid Type.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END 
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strEntityName,'') = '')
	BEGIN
			SET @ErrMsg = 'Entity is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND strEntityName NOT IN (SELECT strName FROM tblEMEntity))
	BEGIN
			SET @ErrMsg = 'Invalid Entity.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strItemNo,'') = '')
	BEGIN
			SET @ErrMsg = 'Item is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND strItemNo NOT IN (SELECT strItemNo FROM tblICItem))
	BEGIN
			SET @ErrMsg = 'Invalid Item.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strLocationName,'') = '')
	BEGIN
			SET @ErrMsg = 'Location is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND strLocationName NOT IN (SELECT strLocationName FROM tblSMCompanyLocation))
	BEGIN
			SET @ErrMsg = 'Invalid Location.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strScaleStationImport,'') = '')
	BEGIN
			SET @ErrMsg = 'Scale Station is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND strScaleStationImport NOT IN (SELECT strStationShortDescription FROM tblSCScaleSetup))
	BEGIN
			SET @ErrMsg = 'Invalid Scale Station.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END    
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND dtmTicketDateTime IS NULL)
	BEGIN
			SET @ErrMsg = 'Scale Date is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(dblGrossWeight,0) = 0)
	BEGIN
			SET @ErrMsg = 'Gross Weight is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(dblTareWeight,0) = 0)
	BEGIN
			SET @ErrMsg = 'Tare Weight is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(dblGrossUnits,0) = 0)
	BEGIN
			SET @ErrMsg = 'Gross Units is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(dblNetUnits,0) = 0)
	BEGIN
			SET @ErrMsg = 'Net Units is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strDiscountId,'') = '')
	BEGIN
			SET @ErrMsg = 'Discount Schedule is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND strDiscountId NOT IN (SELECT strDiscountId FROM tblGRDiscountId))
	BEGIN
			SET @ErrMsg = 'Invalid Discount Schedule.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END 
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND ISNULL(strDistributionOption,'') = '')
	BEGIN
			SET @ErrMsg = 'Distribution is missing.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF EXISTS(SELECT 1 FROM tblSCTicketLVStaging WHERE intTicketLVStagingId = @intExternalId AND strDistributionOption NOT IN (SELECT strStorageTypeDescription FROM tblGRStorageType))
	BEGIN
			SET @ErrMsg = 'Invalid Distribution.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
	ELSE IF NOT EXISTS(  
						 SELECT 1 FROM tblSCTicketLVStaging CI
						 JOIN tblGRDiscountId DiscountId ON DiscountId.strDiscountId = CI.strDiscountId
						 JOIN	tblICItem IM ON	IM.strItemNo		=	CI.strItemNo
						 JOIN tblGRDiscountCrossReference CRef ON CRef.intDiscountId = DiscountId.intDiscountId						 
						 JOIN tblGRDiscountSchedule DiscountSchedule ON DiscountSchedule.intDiscountScheduleId = CRef.intDiscountScheduleId
						 AND DiscountSchedule.intCommodityId = IM.intCommodityId
						 WHERE CI.intTicketLVStagingId = @intExternalId
						)
	BEGIN
			SET @ErrMsg = 'Discount Schedule With Commodity same as Item is missing in Discount Table mapping.'
			RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
	END
				
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
	FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tmpTicket%' 
	AND IS_NULLABLE = 'NO' 
	AND COLUMN_NAME NOT IN('intTicketId','intTicketDiscountId') 
	FOR xml path('')) ,1,1,'')
	
	IF EXISTS(SELECT 1 FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tmpTicket%' AND COLUMN_NAME IN ('blbPlateNumber'))
	BEGIN
		  SET @SQL = @SQL + ' ALTER TABLE #tmpTicket DROP COLUMN blbPlateNumber '
	END
	
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
			 [strData]							NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[strType]							NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[strEntityName]					NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[strItemNo]						NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[strLocationName]					NVARCHAR(500) COLLATE Latin1_General_CI_AS
			,[strTicketStatus]					NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[strTicketNumber]					NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[intScaleSetupId]					INT
			,[intTicketPoolId]					INT
			,[intTicketLocationId]				INT
			,[intTicketType]					INT
			,[strInOutFlag]						NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[dtmTicketDateTime]				DATETIME
			,[intProcessingLocationId]			INT
			,[strScaleOperatorUser]				NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[intEntityScaleOperatorId]			INT
			,[strTruckName]						NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[strDriverName]					NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[dblGrossWeight]					DECIMAL(13, 3)
			,[dblTareWeight]					DECIMAL(13, 3)
			,[dblGrossUnits]					DECIMAL(13, 3)
			,[dblShrink]						DECIMAL(13, 3)
			,[dblNetUnits]						DECIMAL(13, 3)
			,[intSplitId]						INT
			,[intStorageScheduleTypeId]			INT
			,[strDistributionOption]			NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[intDiscountSchedule]				INT
			,[strContractNumber]				NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[intContractSequence]				INT
			,[dblUnitPrice]						NUMERIC(38, 20)
			,[dblUnitBasis]						NUMERIC(38, 20)
			,[dblTicketFees]					NUMERIC(38, 20)
			,[intCurrencyId]					INT
			,[strTicketComment]					NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[strCustomerReference]				NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[intHaulerId]						INT
			,[dblFreightRate]					NUMERIC(38, 20)
			,[ysnFarmerPaysFreight]				BIT
			,[ysnCusVenPaysFees]				BIT
			,[intAxleCount]						INT
			,[strDiscountComment]				NVARCHAR(400) COLLATE Latin1_General_CI_AS
			,[intCommodityId]					INT
			,[intDiscountId] 					INT
			,[intContractId] 					INT
			,[intItemId] 						INT
			,[intEntityId]						INT
			,[intSubLocationId] 				INT
			,[intStorageLocationId]				INT
			,[intStorageScheduleId] 			INT
			,[intDeliverySheetId]				INT
			,[intConcurrencyId]					INT
			,[intItemUOMIdFrom]					INT
			,[intItemUOMIdTo]					INT
			,[intTicketTypeId]					INT
			,[ysnRailCar]						BIT 
			,[ysnDeliverySheetPost]				BIT
			,[ysnDestinationWeightGradePost]	BIT
			,[ysnReadyToTransfer]				BIT
			,[ysnHasGeneratedTicketNumber]		BIT
			,[dblConvertedUOMQty]				NUMERIC(38, 20) NULL,
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

		INSERT INTO #tmpExtracted
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
			,intStorageScheduleTypeId
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
			,[strDiscountComment]	
			,[intCommodityId]
			,[intDiscountId] 
			,[intContractId] 
			,[intItemId] 
			,[intEntityId]	
			,[intSubLocationId] 
			,[intStorageLocationId]
			,[intStorageScheduleId] 
			,[intDeliverySheetId]
			,[intConcurrencyId]
			,[intItemUOMIdFrom]
			,[intItemUOMIdTo]
			,[intTicketTypeId]		
			,[ysnRailCar]
			,[ysnDeliverySheetPost]
			,[ysnDestinationWeightGradePost]
			,[ysnReadyToTransfer]
			,[ysnHasGeneratedTicketNumber]
			,dblConvertedUOMQty
		)
		SELECT	
			[strData]					 = CI.strData
			,[strType]					 = CI.strTicketType
			,[strEntityNo]				 = CI.strEntityName
			,[strItemNo]				 = CI.strItemNo
			,[strLocationNumber]		 = CI.strLocationNumber
			,[strTicketStatus]           = 'O'
			,[strTicketNumber] 			 = CI.strTicketNumber
			,[intScaleSetupId] 			 = SCS.intScaleSetupId
			,[intTicketPoolId] 			 = SCS.intTicketPoolId
			,[intTicketLocationId]		 = CL.intCompanyLocationId
			,[intTicketType] 			 = SCTicketType.intTicketType
			,[strInOutFlag] 			 = SCTicketType.strInOutIndicator
			,[dtmTicketDateTime]		 = CI.dtmTicketDateTime
			,[intProcessingLocationId]	 = CL.intCompanyLocationId
			,[strScaleOperatorUser]		 = @strScaleOperatorUser
			,[intEntityScaleOperatorId]	 = @intUserId
			,[strTruckName]				 = CI.strTruckName
			,[strDriverName]			 = CI.strDriverName
			,[dblGrossWeight] 			 = CI.dblGrossWeight
			,[dblTareWeight]			 = CI.dblTareWeight
			,[dblGrossUnits]			 = CI.dblGrossUnits
			,[dblShrink]				 = CI.dblShrink
			,[dblNetUnits] 				 = CI.dblNetUnits
			,[intSplitId]				 = CI.intSplitId
			,intStorageScheduleTypeId	 = ST.intStorageScheduleTypeId
			,[strDistributionOption]	 = ST.strStorageTypeCode
			,[intDiscountSchedule]    	 = DiscountSchedule.intDiscountScheduleId
			,[strContractNumber]		 = CI.strContractNumber
			,[intContractSequence]     	 = CI.intContractSequence
			,[dblUnitPrice]				 = CI.dblUnitPrice
			,[dblUnitBasis]				 = CI.dblUnitBasis
			,[dblTicketFees]			 = CI.dblTicketFees
			,[intCurrencyId]			 = CASE WHEN SCTicketType.strInOutIndicator = 'I' THEN APV.intCurrencyId ELSE ARC.intCurrencyId END
			,[strTicketComment]			 = CI.strTicketComment
			,[strCustomerReference]		 = CI.strCustomerReference
			,[intHaulerId]				 = CI.intHaulerId
			,[dblFreightRate]			 = CI.dblFreightRate
			,[ysnFarmerPaysFreight]		 = CI.ysnFarmerPaysFreight
			,[ysnCusVenPaysFees]		 = CI.ysnCusVenPaysFees
			,[intAxleCount]				 = CI.intAxleCount
			,[strDiscountComment]		 = NULL
			,[intCommodityId]			 = IM.intCommodityId
			,[intDiscountId] 			 = DiscountId.intDiscountId
			,[intContractId] 			 = CD.intContractDetailId
			,[intItemId] 				 = IM.intItemId
			,[intEntityId]				 = CASE WHEN SCTicketType.strInOutIndicator = 'I' THEN APV.intEntityId ELSE ARC.intEntityId END
			,[intSubLocationId] 		 = SubLocation.intCompanyLocationSubLocationId
			,[intStorageLocationId]		 = Bin.intStorageLocationId
			,[intStorageScheduleId] 	 = SS.intStorageScheduleRuleId
			,[intDeliverySheetId]		 = DS.intDeliverySheetId
			,[intConcurrencyId]			 = 1
			,[intItemUOMIdFrom]			 = SCS.intItemUOMId
			,[intItemUOMIdTo]			 = UOM.intItemUOMId
			,[intTicketTypeId]			 = SCTicketType.intTicketTypeId
			,[ysnRailCar]				 = 0
			,[ysnDeliverySheetPost]		 = 0
			,[ysnDestinationWeightGradePost] = 0
			,[ysnReadyToTransfer]		 = 0
			,[ysnHasGeneratedTicketNumber] = 1
			,dblConvertedUOMQty			   = UN.dblUnitQty

		FROM tblSCTicketLVStaging	    CI	
		LEFT JOIN	tblSMCompanyLocation		CL	ON	CL.strLocationName	=	CI.strLocationName		
		LEFT JOIN	tblICItem					IM	ON	IM.strItemNo		=	CI.strItemNo
		LEFT JOIN	tblICItemUOM				UOM	ON	UOM.intItemId		=	IM.intItemId AND UOM.ysnStockUnit = 1
		LEFT JOIN	vyuAPVendor					APV	ON APV.strName	=	CI.strEntityName
		LEFT JOIN	vyuARCustomer				ARC	ON ARC.strName	=	CI.strEntityName
		LEFT JOIN tblGRDiscountId DiscountId ON DiscountId.strDiscountId = CI.strDiscountId
		LEFT JOIN tblGRDiscountCrossReference CRef ON CRef.intDiscountId = DiscountId.intDiscountId 
		LEFT JOIN tblGRDiscountSchedule DiscountSchedule ON DiscountSchedule.intDiscountScheduleId = CRef.intDiscountScheduleId 
														AND DiscountSchedule.intCommodityId = IM.intCommodityId 
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.strSubLocationName = CI.strStorageLocation
		LEFT JOIN tblICStorageLocation Bin ON Bin.strName = CI.strBinNumber AND Bin.intSubLocationId=SubLocation.intCompanyLocationSubLocationId
		LEFT JOIN tblGRStorageType ST ON ST.strStorageTypeDescription = CI.strDistributionOption
		LEFT JOIN tblGRStorageScheduleRule SS ON SS.strScheduleId = CI.strStorageSchedule AND SS.intCommodity = IM.intCommodityId 
		LEFT JOIN tblSCDeliverySheet DS ON DS.strDeliverySheetNumber = CI.strDeliverySheet
		LEFT JOIN tblCTContractHeader CH ON CH.strContractNumber = CI.strContractNumber
		LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId AND CD.intContractSeq = CI.intContractSequence
		LEFT JOIN tblSCListTicketTypes SCTicketType ON SCTicketType.strTicketType = CI.strTicketType
		OUTER APPLY (
			SELECT SCSetup.intScaleSetupId, SCSetup.strStationShortDescription, SCSetup.intTicketPoolId,ScaleUOM.intItemUOMId FROM tblSCScaleSetup SCSetup
			LEFT JOIN tblICItemUOM ScaleUOM ON ScaleUOM.intUnitMeasureId = SCSetup.intUnitMeasureId AND ScaleUOM.intItemId = IM.intItemId
			WHERE SCSetup.strStationShortDescription = CI.strScaleStationImport
		) SCS
		LEFT JOIN	tblICItemUOM UN	ON	UN.intItemUOMId = SCS.intItemUOMId
		WHERE strTicketNumber = @strTicketNo 
		AND CI.intTicketLVStagingId = @intExternalId
		AND CI.strData = 'Header' 
		AND DiscountSchedule.intDiscountScheduleId IS NOT NULL
		AND CI.ysnImported IS NULL

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
			,intStorageScheduleTypeId
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
			,[intDeliverySheetId] 
			,[intConcurrencyId]
			,[intItemUOMIdFrom]
			,[intItemUOMIdTo]
			,[intTicketTypeId]			
			,[ysnRailCar]
			,[ysnDeliverySheetPost]
			,[ysnDestinationWeightGradePost]
			,[ysnReadyToTransfer]
			,[ysnHasGeneratedTicketNumber]
			,dblConvertedUOMQty 
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
			,intStorageScheduleTypeId
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
			,[intDeliverySheetId] 
			,[intConcurrencyId]
			,[intItemUOMIdFrom]
			,[intItemUOMIdTo]
			,[intTicketTypeId]		
			,[ysnRailCar]
			,[ysnDeliverySheetPost]
			,[ysnDestinationWeightGradePost]
			,[ysnReadyToTransfer]
			,[ysnHasGeneratedTicketNumber]
			,dblConvertedUOMQty 
		FROM #tmpExtracted 
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
				,intTicketFileId				= null
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
