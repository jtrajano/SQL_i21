CREATE PROCEDURE [dbo].[uspGRCalculateSettleDiscountForContract]
	@intSettleStorageId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @SettleStorageKey INT
	DECLARE @intSettleStorageTicketId INT
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @dblDiscountUnPaid DECIMAL(24, 10)
	DECLARE @SettleContractKey INT
	DECLARE @intContractDetailId INT
	DECLARE @dblContractUnits DECIMAL(24, 10)
	DECLARE @dblCashPrice DECIMAL(24, 10)
	DECLARE @intPricingTypeId INT
	DECLARE @dblSpotUnits DECIMAL(24, 10)
	DECLARE @dblSpotPrice DECIMAL(24, 10)
	DECLARE @dblSpotBasis DECIMAL(24, 10)
	DECLARE @dblSpotCashPrice DECIMAL(24, 10)
	DECLARE @intSettleDiscountKey INT

	DECLARE @SettleStorage AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblRemainingUnits DECIMAL(24, 10)
		,dblDiscountUnPaid DECIMAL(24, 10)
	)

	DECLARE @SettleContract AS TABLE 
	(
		 intSettleContractKey INT IDENTITY(1, 1)
		,intSettleContractId INT
		,intContractDetailId INT
		,dblContractUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
		,intPricingTypeId INT
	)
	
	DECLARE @SettleDiscountForContract AS TABLE 
	(
		 intSettleDiscountKey INT IDENTITY(1, 1)
		,[strType] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[intItemId] INT
		,[strItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblGradeReading] DECIMAL(24, 10) NULL
		,intContractDetailId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblDiscountUnPaid DECIMAL(24, 10)
		,intPricingTypeId INT
	)

	SELECT @dblSpotUnits = dblSpotUnits
		,@dblSpotCashPrice = dblCashPrice
	FROM tblGRSettleStorage
	WHERE intSettleStorageId = @intSettleStorageId

	INSERT INTO @SettleStorage 
	(
		 intSettleStorageTicketId
		,intCustomerStorageId
		,dblStorageUnits
		,dblRemainingUnits
		,dblDiscountUnPaid
	)
	SELECT 
		 SST.intSettleStorageTicketId
		,SST.intCustomerStorageId
		,SST.dblUnits AS dblStorageUnits
		,SST.dblUnits AS dblRemainingUnits
		,SSV.dblDiscountUnPaid AS dblDiscountUnPaid
	FROM tblGRSettleStorageTicket SST
	JOIN vyuGRStorageSearchView SSV ON SSV.intCustomerStorageId = SST.intCustomerStorageId
	WHERE SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
	ORDER BY SST.intSettleStorageTicketId

	INSERT INTO @SettleContract 
	(
		 intSettleContractId
		,intContractDetailId
		,dblContractUnits
		,dblCashPrice
		,intPricingTypeId
	)
	SELECT 
		 SSC.intSettleContractId AS intSettleContractId
		,SSC.intContractDetailId AS intContractDetailId
		,SSC.dblUnits AS dblContractUnits
		,CD.dblCashPriceInCommodityStockUOM AS dblCashPrice
		,CD.intPricingTypeId AS intPricingTypeId
	FROM tblGRSettleContract SSC
	JOIN vyuGRGetContracts CD ON CD.intContractDetailId = SSC.intContractDetailId
	WHERE intSettleStorageId = @intSettleStorageId AND SSC.dblUnits > 0
	ORDER BY SSC.intSettleContractId

	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM @SettleStorage
	WHERE dblRemainingUnits > 0

	SET @intSettleStorageTicketId = NULL
	SET @intCustomerStorageId = NULL
	SET @dblStorageUnits = NULL
	SET @dblDiscountUnPaid = NULL

	WHILE @SettleStorageKey > 0
	BEGIN
		SELECT 
			 @intSettleStorageTicketId = intSettleStorageTicketId
			,@intCustomerStorageId = intCustomerStorageId
			,@dblStorageUnits = dblRemainingUnits
			,@dblDiscountUnPaid = dblDiscountUnPaid
		FROM @SettleStorage
		WHERE intSettleStorageKey = @SettleStorageKey

		IF EXISTS (
					SELECT 1
					FROM @SettleContract
					WHERE dblContractUnits > 0
				  )
		BEGIN
			SELECT @SettleContractKey = MIN(intSettleContractKey)
			FROM @SettleContract
			WHERE dblContractUnits > 0

			SET @intContractDetailId = NULL
			SET @dblContractUnits = NULL
			SET @dblCashPrice = NULL
			SET @intPricingTypeId = NULL

			WHILE @SettleContractKey > 0
			BEGIN
				SELECT 
					 @intContractDetailId = intContractDetailId
					,@intPricingTypeId = intPricingTypeId
					,@dblContractUnits = dblContractUnits
					,@dblCashPrice = dblCashPrice
					,@intPricingTypeId = intPricingTypeId
				FROM @SettleContract
				WHERE intSettleContractKey = @SettleContractKey

				IF @dblStorageUnits <= @dblContractUnits
				BEGIN
					UPDATE @SettleContract
					SET dblContractUnits = dblContractUnits - @dblStorageUnits
					WHERE intSettleContractKey = @SettleContractKey

					UPDATE @SettleStorage
					SET dblRemainingUnits = 0
					WHERE intSettleStorageKey = @SettleStorageKey

					IF @dblDiscountUnPaid > 0
					BEGIN
						INSERT INTO @SettleDiscountForContract 
						(
							 strType
							,intSettleStorageTicketId
							,intCustomerStorageId
							,strStorageTicketNumber
							,intItemId
							,strItem
							,dblGradeReading
							,intContractDetailId
							,dblStorageUnits
							,dblDiscountUnPaid
							,intPricingTypeId
						)
						SELECT 
							 'Contract' AS strType
							,@intSettleStorageTicketId
							,@intCustomerStorageId
							,CS.strStorageTicketNumber
							,DItem.intItemId AS intItemId
							,DItem.strItemNo AS strItem
							,QM.dblGradeReading
							,@intContractDetailId
							,@dblStorageUnits
							,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
							,@intPricingTypeId
						FROM tblGRCustomerStorage CS
						JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
						JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
						JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
						JOIN tblICItem DItem ON DItem.intItemId = a.intItemId
						WHERE CS.intCustomerStorageId = @intCustomerStorageId
					END

					BREAK;
				END
				ELSE
				BEGIN
					UPDATE @SettleContract
					SET dblContractUnits = dblContractUnits - @dblContractUnits
					WHERE intSettleContractKey = @SettleContractKey

					UPDATE @SettleStorage
					SET dblRemainingUnits = dblRemainingUnits - @dblContractUnits
					WHERE intSettleStorageKey = @SettleStorageKey

					IF @dblDiscountUnPaid > 0
					BEGIN
						
						INSERT INTO @SettleDiscountForContract 
						(
							 strType
							,intSettleStorageTicketId
							,intCustomerStorageId
							,strStorageTicketNumber
							,intItemId
							,strItem
							,dblGradeReading
							,intContractDetailId
							,dblStorageUnits
							,dblDiscountUnPaid
							,intPricingTypeId
						)
						SELECT 
							'Contract' AS strType
							,@intSettleStorageTicketId
							,@intCustomerStorageId
							,CS.strStorageTicketNumber
							,DItem.intItemId AS intItemId
							,DItem.strItemNo AS strItem
							,QM.dblGradeReading
							,@intContractDetailId
							,@dblContractUnits
							,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
							,@intPricingTypeId
						FROM tblGRCustomerStorage CS
						JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
						JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
						JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
						JOIN tblICItem DItem ON DItem.intItemId = a.intItemId
						WHERE CS.intCustomerStorageId = @intCustomerStorageId
					END

					BREAK;
				END

				SELECT @SettleContractKey = MIN(intSettleContractKey)
				FROM @SettleContract
				WHERE intSettleContractKey > @SettleContractKey AND dblContractUnits > 0
			END

			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage
			WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0
		END
		ELSE IF @dblSpotUnits > 0
		BEGIN
			SET @intPricingTypeId = NULL

			IF @dblStorageUnits <= @dblSpotUnits
			BEGIN
				UPDATE @SettleStorage
				SET dblRemainingUnits = dblRemainingUnits - @dblStorageUnits
				WHERE intSettleStorageKey = @SettleStorageKey

				SET @dblSpotUnits = @dblSpotUnits - @dblStorageUnits

				IF @dblDiscountUnPaid > 0
				BEGIN
					INSERT INTO @SettleDiscountForContract 
					(
					 strType
					,intSettleStorageTicketId
					,intCustomerStorageId
					,strStorageTicketNumber
					,intItemId
					,strItem
					,dblGradeReading
					,intContractDetailId
					,dblStorageUnits
					,dblDiscountUnPaid
					,intPricingTypeId
					)
					SELECT 
						'Spot' AS strType
						,@intSettleStorageTicketId
						,@intCustomerStorageId
						,CS.strStorageTicketNumber
						,DItem.intItemId AS intItemId
						,DItem.strItemNo AS strItem
						,QM.dblGradeReading
						,NULL AS intContractDetailId
						,@dblStorageUnits AS dblStorageUnits
						,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)) AS dblDiscountUnPaid
						,@intPricingTypeId AS intPricingTypeId
					FROM tblGRCustomerStorage CS
					JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
					JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
					JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
					JOIN tblICItem DItem ON DItem.intItemId = a.intItemId
					WHERE CS.intCustomerStorageId = @intCustomerStorageId
                END
			END
			ELSE
			BEGIN
				UPDATE @SettleStorage
				SET dblRemainingUnits = dblRemainingUnits - @dblSpotUnits
				WHERE intSettleStorageKey = @SettleStorageKey

				IF @dblDiscountUnPaid > 0
				BEGIN
					INSERT INTO @SettleDiscountForContract 
					(
					 strType
					,intSettleStorageTicketId
					,intCustomerStorageId
					,strStorageTicketNumber
					,intItemId
					,strItem
					,dblGradeReading
					,intContractDetailId
					,dblStorageUnits
					,dblDiscountUnPaid
					,intPricingTypeId
				  )
				    SELECT 
					'Spot' AS strType
					,@intSettleStorageTicketId
					,@intCustomerStorageId
					,CS.strStorageTicketNumber
					,DItem.intItemId AS intItemId
					,DItem.strItemNo AS strItem
					,QM.dblGradeReading
					,NULL AS intContractDetailId
					,@dblSpotUnits AS dblStorageUnits
					,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)) AS dblDiscountUnPaid
					,@intPricingTypeId AS intPricingTypeId
				FROM tblGRCustomerStorage CS
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
				JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
				JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				JOIN tblICItem DItem ON DItem.intItemId = a.intItemId
				WHERE CS.intCustomerStorageId = @intCustomerStorageId

				END

				SET @dblSpotUnits = 0
			END

			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage
			WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0
		END
		ELSE
			BREAK;
	END

	SELECT *
	FROM @SettleDiscountForContract

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

