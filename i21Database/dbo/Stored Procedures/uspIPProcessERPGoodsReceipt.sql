CREATE PROCEDURE uspIPProcessERPGoodsReceipt @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	--SET ANSI_WARNINGS OFF
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strError NVARCHAR(MAX)
	DECLARE @intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intStageItemId INT
		,@strItemNo NVARCHAR(100)
		,@strDescription NVARCHAR(250)
		,@strShortName NVARCHAR(50)
		,@strCommodity NVARCHAR(50)
		,@strCategoryCode NVARCHAR(50)
		,@strLotTracking NVARCHAR(50)
		,@intLifeTime INT
		,@strLifeTimeType NVARCHAR(50)
		,@strItemStatus NVARCHAR(50)
		,@ysnFairTradeCompliance BIT
		,@ysnOrganicItem BIT
		,@ysnRainForestCertified BIT
		,@strExternalGroup NVARCHAR(50)
		,@strOrigin NVARCHAR(100)
		,@strProductType NVARCHAR(100)
	DECLARE @intCompanyLocationId INT
		,@intItemId INT
		,@intCommodityId INT
		,@intCategoryId INT
		,@intOriginId INT
		,@intProductTypeId INT
		,@intCountryID INT
		,@intNewStageItemId INT
	DECLARE @tblICItem TABLE (
		strOldDescription NVARCHAR(250)
		,strOldShortName NVARCHAR(50)
		,intOldLifeTime INT
		,strOldLifeTimeType NVARCHAR(50)
		,strOldItemStatus NVARCHAR(50)
		,ysnOldFairTradeCompliance BIT
		,ysnOldOrganicItem BIT
		,ysnOldRainForestCertified BIT
		,strOldExternalGroup NVARCHAR(50)
		,intOldOriginId INT
		,intOldProductTypeId INT
		,strNewDescription NVARCHAR(250)
		,strNewShortName NVARCHAR(50)
		,intNewLifeTime INT
		,strNewLifeTimeType NVARCHAR(50)
		,strNewItemStatus NVARCHAR(50)
		,ysnNewFairTradeCompliance BIT
		,ysnNewOrganicItem BIT
		,ysnNewRainForestCertified BIT
		,strNewExternalGroup NVARCHAR(50)
		,intNewOriginId INT
		,intNewProductTypeId INT
		)
	DECLARE @tblICItemUOM TABLE (
		intItemUOMId INT
		,intUnitMeasureId INT
		)

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @intStageItemId = MIN(intStageItemId)
	FROM tblIPItemStage

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(strItemNo, '') + ', '
	FROM tblIPItemStage

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strShortName, '') + ', '
	FROM (
		SELECT DISTINCT strShortName
		FROM tblIPItemStage
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intStageItemId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strItemNo = NULL
				,@strDescription = NULL
				,@strShortName = NULL
				,@strCommodity = NULL
				,@strCategoryCode = NULL
				,@strLotTracking = NULL
				,@intLifeTime = NULL
				,@strLifeTimeType = NULL
				,@strItemStatus = NULL
				,@ysnFairTradeCompliance = NULL
				,@ysnOrganicItem = NULL
				,@ysnRainForestCertified = NULL
				,@strExternalGroup = NULL
				,@strOrigin = NULL
				,@strProductType = NULL

			SELECT @intCompanyLocationId = NULL
				,@intItemId = NULL
				,@intCommodityId = NULL
				,@intCategoryId = NULL
				,@intOriginId = NULL
				,@intProductTypeId = NULL
				,@intCountryID = NULL
				,@intNewStageItemId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreated
				,@strCreatedBy = strCreatedUserName
				,@strItemNo = strItemNo
				,@strDescription = strDescription
				,@strShortName = strShortName
				,@strCommodity = strCommodity
				,@strCategoryCode = strCategoryCode
				,@strLotTracking = strLotTracking
				,@intLifeTime = intLifeTime
				,@strLifeTimeType = strLifeTimeType
				,@strItemStatus = strItemStatus
				,@ysnFairTradeCompliance = ysnFairTradeCompliance
				,@ysnOrganicItem = ysnOrganicItem
				,@ysnRainForestCertified = ysnRainForestCertified
				,@strExternalGroup = strExternalGroup
				,@strOrigin = strOrigin
				,@strProductType = strProductType
			FROM tblIPItemStage
			WHERE intStageItemId = @intStageItemId

			IF EXISTS (
					SELECT 1
					FROM tblIPItemArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo is exists in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intItemId = intItemId
			FROM dbo.tblICItem WITH (NOLOCK)
			WHERE strItemNo = @strItemNo

			SELECT @intCommodityId = intCommodityId
			FROM dbo.tblICCommodity WITH (NOLOCK)
			WHERE strCommodityCode = @strCommodity

			SELECT @intCategoryId = intCategoryId
			FROM dbo.tblICCategory WITH (NOLOCK)
			WHERE strCategoryCode = @strCategoryCode

			SELECT @intCountryID = intCountryID
			FROM dbo.tblSMCountry WITH (NOLOCK)
			WHERE strCountry = @strOrigin

			SELECT @intOriginId = intCommodityAttributeId
			FROM dbo.tblICCommodityAttribute WITH (NOLOCK)
			WHERE intCommodityId = @intCommodityId
				AND strType = 'Origin'
				AND strDescription = @strOrigin

			SELECT @intProductTypeId = intCommodityAttributeId
			FROM dbo.tblICCommodityAttribute WITH (NOLOCK)
			WHERE intCommodityId = @intCommodityId
				AND strType = 'ProductType'
				AND strDescription = @strProductType

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strItemNo, '') = ''
			BEGIN
				SELECT @strError = 'Item No cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strDescription, '') = ''
			BEGIN
				SELECT @strError = 'Description cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intCommodityId IS NULL
			BEGIN
				SELECT @strError = 'Commodity not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intCategoryId IS NULL
			BEGIN
				SELECT @strError = 'Category not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strLotTracking, '') NOT IN (
					'Yes - Manual'
					,'Yes - Serial Number'
					,'Yes - Manual/Serial Number'
					,'No'
					)
			BEGIN
				SELECT @strError = 'Lot Tracking not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@intLifeTime, 0) <= 0
			BEGIN
				SELECT @strError = 'Life Time should be greater than 0.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strLifeTimeType, '') NOT IN (
					'Days'
					,'Months'
					,'Years'
					)
			BEGIN
				SELECT @strError = 'Life Time Unit not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strItemStatus, '') NOT IN (
					'Active'
					,'Phased Out'
					,'Discontinued'
					)
			BEGIN
				SELECT @strError = 'Item Status not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF ISNULL(@strOrigin, '') <> ''
				AND @intCountryID IS NULL
			BEGIN
				SELECT @strError = 'Origin not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF (
					SELECT COUNT(1)
					FROM tblIPItemUOMStage
					WHERE intStageItemId = @intStageItemId
						AND ysnStockUnit = 1
					) > 1
			BEGIN
				RAISERROR (
						'Received multiple stock UOMs.'
						,16
						,1
						)
			END

			BEGIN TRAN

			IF @intActionId = 1
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblICItem I
						JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
							AND IL.intLocationId = @intCompanyLocationId
						WHERE I.strItemNo = @strItemNo
						)
				BEGIN
					SELECT @strError = 'Item ''' + @strItemNo + ''' already exists.'

					RAISERROR (
							@strError
							,16
							,1
							)
				END

				IF NOT EXISTS (
						SELECT 1
						FROM tblIPItemUOMStage
						WHERE intStageItemId = @intStageItemId
						)
				BEGIN
					RAISERROR (
							'UOM is required.'
							,16
							,1
							)
				END
			END

			IF @intActionId = 1
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblICItem I
						WHERE I.intItemId = @intItemId
						)
				BEGIN
					INSERT INTO tblICItem (
						intConcurrencyId
						,strItemNo
						,strDescription
						,strShortName
						,strType
						,intCommodityId
						,intCategoryId
						,strLotTracking
						,strInventoryTracking
						,intLifeTime
						,strLifeTimeType
						,strStatus
						,ysnFairTradeCompliant
						,ysnOrganic
						,ysnRainForestCertified
						,strExternalGroup
						,intOriginId
						,intProductTypeId
						)
					SELECT 1
						,@strItemNo
						,@strDescription
						,@strShortName
						,'Inventory'
						,@intCommodityId
						,@intCategoryId
						,@strLotTracking
						,'Lot Level'
						,@intLifeTime
						,@strLifeTimeType
						,@strItemStatus
						,@ysnFairTradeCompliance
						,@ysnOrganicItem
						,@ysnRainForestCertified
						,@strExternalGroup
						,@intOriginId
						,@intProductTypeId

					SELECT @intItemId = SCOPE_IDENTITY()

					EXEC uspSMAuditLog @keyValue = @intItemId
						,@screenName = 'Inventory.view.Item'
						,@entityId = @intUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@details = ''
				END

				INSERT INTO tblICItemUOM (
					intConcurrencyId
					,intItemId
					,intUnitMeasureId
					,dblUnitQty
					,ysnStockUnit
					,ysnAllowPurchase
					,ysnAllowSale
					)
				SELECT 1
					,@intItemId
					,um.intUnitMeasureId
					,iu.dblNumerator / iu.dblDenominator
					,CASE 
						WHEN iu.ysnStockUnit = 1
							THEN 1
						ELSE 0
						END
					,1
					,1
				FROM tblIPItemUOMStage iu
				JOIN tblICUnitMeasure um ON iu.strUOM = um.strSymbol
				WHERE iu.strItemNo = @strItemNo
					AND iu.intStageItemId = @intStageItemId
					AND um.intUnitMeasureId NOT IN (
						SELECT intUnitMeasureId
						FROM tblICItemUOM
						WHERE intItemId = @intItemId
						)

				IF NOT EXISTS (
						SELECT 1
						FROM tblICItem I
						JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
							AND IL.intLocationId = @intCompanyLocationId
						WHERE I.intItemId = @intItemId
						)
				BEGIN
					INSERT INTO tblICItemLocation (
						intConcurrencyId
						,intItemId
						,intLocationId
						,intCostingMethod
						,intAllowNegativeInventory
						,intAllowZeroCostTypeId
						)
					SELECT 1
						,@intItemId
						,@intCompanyLocationId
						,2
						,3
						,2
				END
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				,strReceiptNo
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,13 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText
				,@strItemNo

			INSERT INTO tblIPInvReceiptArchive (
				intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
				)
			SELECT intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageItemId

			SELECT @intNewStageItemId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemArchive (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
				)
			SELECT @intNewStageItemId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intStageItemId

			INSERT INTO tblIPInvReceiptItemLotArchive (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				)
			SELECT @intNewStageItemId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
			FROM tblIPInvReceiptItemLotStage
			WHERE intStageReceiptId = @intStageItemId

			DELETE
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageItemId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				,strReceiptNo
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,13 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText
				,@strItemNo

			INSERT INTO tblIPInvReceiptError (
				intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
				,strErrorMessage
				,strImportStatus
				)
			SELECT intTrxSequenceNo
				,strCompCode
				,intActionId
				,dtmCreated
				,strCreatedBy
				,strVendorAccountNo
				,strVendorRefNo
				,strERPReceiptNo
				,dtmReceiptDate
				,strBLNumber
				,strWarehouseRefNo
				,strTransferOrderNo
				,strERPTransferOrderNo
				,dtmTransactionDate
				,@ErrMsg
				,'Failed'
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageItemId

			SELECT @intNewStageItemId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemError (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
				)
			SELECT @intNewStageItemId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strSubLocationName
				,strStorageLocationName
				,strContainerNumber
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intStageItemId

			INSERT INTO tblIPInvReceiptItemLotError (
				intStageReceiptId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
				)
			SELECT @intNewStageItemId
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,strMotherLotNo
				,strLotNo
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strWeightUOM
			FROM tblIPInvReceiptItemLotStage
			WHERE intStageReceiptId = @intStageItemId

			DELETE
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intStageItemId
		END CATCH

		SELECT @intStageItemId = MIN(intStageItemId)
		FROM tblIPItemStage
		WHERE intStageItemId > @intStageItemId
	END

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
