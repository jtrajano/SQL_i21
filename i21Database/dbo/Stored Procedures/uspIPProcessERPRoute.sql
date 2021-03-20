CREATE PROCEDURE uspIPProcessERPRoute @strInfo1 NVARCHAR(MAX) = '' OUT
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
	DECLARE @intTrxSequenceNo INT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intItemRouteStageId INT
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
		,@intNewItemRouteStageId INT
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

	SELECT @intItemRouteStageId = MIN(intStageItemId)
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

	WHILE (@intItemRouteStageId IS NOT NULL)
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
				,@intNewItemRouteStageId = NULL

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
			WHERE intStageItemId = @intItemRouteStageId

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
					WHERE intStageItemId = @intItemRouteStageId
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

			IF ISNULL(@strOrigin, '') <> ''
				AND @intOriginId IS NULL
				AND @intCountryID IS NOT NULL
			BEGIN
				INSERT INTO tblICCommodityAttribute (
					intCommodityId
					,strType
					,strDescription
					,intCountryID
					,intConcurrencyId
					,dtmDateCreated
					,intCreatedByUserId
					)
				SELECT @intCommodityId
					,'Origin'
					,@strOrigin
					,@intCountryID
					,1
					,GETDATE()
					,@intUserId

				SELECT @intOriginId = intCommodityAttributeId
				FROM dbo.tblICCommodityAttribute
				WHERE intCommodityId = @intCommodityId
					AND strType = 'Origin'
					AND strDescription = @strOrigin
			END

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
						WHERE intStageItemId = @intItemRouteStageId
						)
				BEGIN
					RAISERROR (
							'UOM is required.'
							,16
							,1
							)
				END
			END
			ELSE
			BEGIN
				IF @intItemId IS NULL
				BEGIN
					SELECT @strError = 'Item not found.'

					RAISERROR (
							@strError
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
					AND iu.intStageItemId = @intItemRouteStageId
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
			ELSE IF @intActionId = 2
			BEGIN
				DELETE
				FROM @tblICItem

				UPDATE tblICItem
				SET intConcurrencyId = intConcurrencyId + 1
					,strDescription = @strDescription
					,strShortName = @strShortName
					,intLifeTime = @intLifeTime
					,strLifeTimeType = @strLifeTimeType
					,strStatus = @strItemStatus
					,ysnFairTradeCompliant = @ysnFairTradeCompliance
					,ysnOrganic = @ysnOrganicItem
					,ysnRainForestCertified = @ysnRainForestCertified
					,strExternalGroup = @strExternalGroup
					,intOriginId = @intOriginId
					,intProductTypeId = @intProductTypeId
				OUTPUT deleted.strDescription
					,deleted.strShortName
					,deleted.intLifeTime
					,deleted.strLifeTimeType
					,deleted.strStatus
					,deleted.ysnFairTradeCompliant
					,deleted.ysnOrganic
					,deleted.ysnRainForestCertified
					,deleted.strExternalGroup
					,deleted.intOriginId
					,deleted.intProductTypeId
					,inserted.strDescription
					,inserted.strShortName
					,inserted.intLifeTime
					,inserted.strLifeTimeType
					,inserted.strStatus
					,inserted.ysnFairTradeCompliant
					,inserted.ysnOrganic
					,inserted.ysnRainForestCertified
					,inserted.strExternalGroup
					,inserted.intOriginId
					,inserted.intProductTypeId
				INTO @tblICItem
				WHERE intItemId = @intItemId

				DELETE
				FROM @tblICItemUOM

				INSERT INTO tblICItemUOM (
					intConcurrencyId
					,intItemId
					,intUnitMeasureId
					,dblUnitQty
					,ysnStockUnit
					,ysnAllowPurchase
					,ysnAllowSale
					)
				OUTPUT inserted.intItemUOMId
					,inserted.intUnitMeasureId
				INTO @tblICItemUOM
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
					AND iu.intStageItemId = @intItemRouteStageId
					AND um.intUnitMeasureId NOT IN (
						SELECT intUnitMeasureId
						FROM tblICItemUOM
						WHERE intItemId = @intItemId
						)

				IF EXISTS (
						SELECT 1
						FROM tblICItemUOM iu WITH (NOLOCK)
						JOIN tblICUnitMeasure um WITH (NOLOCK) ON iu.intUnitMeasureId = um.intUnitMeasureId
							AND iu.intItemId = @intItemId
						JOIN tblIPItemUOMStage st ON st.strUOM = um.strSymbol
							AND st.intStageItemId = @intItemRouteStageId
							AND iu.dblUnitQty <> st.dblNumerator / st.dblDenominator
						JOIN tblICLot L WITH (NOLOCK) ON L.intItemId = iu.intItemId
							AND L.dblQty > 0
							AND (
								L.intItemUOMId = iu.intItemUOMId
								OR L.intWeightUOMId = iu.intItemUOMId
								)
						)
					--WHERE iu.intItemId = @intItemId
					--	AND st.intStageItemId = @intItemRouteStageId
					--	AND iu.dblUnitQty <> st.dblNumerator / st.dblDenominator
				BEGIN
					RAISERROR (
							'When UOM has a transaction, Unit or Unit Qty is not allowed to change.'
							,16
							,1
							)
				END

				UPDATE iu
				SET iu.dblUnitQty = st.dblNumerator / st.dblDenominator
				FROM tblICItemUOM iu
				JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
					AND iu.intItemId = @intItemId
				JOIN tblIPItemUOMStage st ON st.strUOM = um.strSymbol
					AND st.intStageItemId = @intItemRouteStageId

				--WHERE iu.intItemId = @intItemId
				--	AND st.intStageItemId = @intItemRouteStageId
				DECLARE @strDetails NVARCHAR(MAX) = ''

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(strOldDescription, '') <> IsNULL(strNewDescription, '')
						)
					SELECT @strDetails += '{"change":"strDescription","iconCls":"small-gear","from":"' + IsNULL(strOldDescription, '') + '","to":"' + IsNULL(strNewDescription, '') + '","leaf":true,"changeDescription":"Description"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(strOldShortName, '') <> IsNULL(strNewShortName, '')
						)
					SELECT @strDetails += '{"change":"strShortName","iconCls":"small-gear","from":"' + IsNULL(strOldShortName, '') + '","to":"' + IsNULL(strNewShortName, '') + '","leaf":true,"changeDescription":"Short Name"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(intOldLifeTime, 0) <> IsNULL(intNewLifeTime, 0)
						)
					SELECT @strDetails += '{"change":"intLifeTime","iconCls":"small-gear","from":"' + LTRIM(intOldLifeTime) + '","to":"' + LTRIM(intNewLifeTime) + '","leaf":true,"changeDescription":"Life Time"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(strOldLifeTimeType, '') <> IsNULL(strNewLifeTimeType, '')
						)
					SELECT @strDetails += '{"change":"strLifeTimeType","iconCls":"small-gear","from":"' + IsNULL(strOldLifeTimeType, '') + '","to":"' + IsNULL(strNewLifeTimeType, '') + '","leaf":true,"changeDescription":"Life Time Type"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(strOldItemStatus, '') <> IsNULL(strNewItemStatus, '')
						)
					SELECT @strDetails += '{"change":"strStatus","iconCls":"small-gear","from":"' + IsNULL(strOldItemStatus, '') + '","to":"' + IsNULL(strNewItemStatus, '') + '","leaf":true,"changeDescription":"Status"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(ysnOldFairTradeCompliance, 0) <> IsNULL(ysnNewFairTradeCompliance, 0)
						)
					SELECT @strDetails += '{"change":"ysnFairTradeCompliant","iconCls":"small-gear","from":"' + LTRIM(ysnOldFairTradeCompliance) + '","to":"' + LTRIM(ysnNewFairTradeCompliance) + '","leaf":true,"changeDescription":"Fair Trade Compliant"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(ysnOldOrganicItem, 0) <> IsNULL(ysnNewOrganicItem, 0)
						)
					SELECT @strDetails += '{"change":"ysnOrganic","iconCls":"small-gear","from":"' + LTRIM(ysnOldOrganicItem) + '","to":"' + LTRIM(ysnNewOrganicItem) + '","leaf":true,"changeDescription":"Organic Item"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(ysnOldRainForestCertified, 0) <> IsNULL(ysnNewRainForestCertified, 0)
						)
					SELECT @strDetails += '{"change":"ysnRainForestCertified","iconCls":"small-gear","from":"' + LTRIM(ysnOldRainForestCertified) + '","to":"' + LTRIM(ysnNewRainForestCertified) + '","leaf":true,"changeDescription":"Rain Forest Certified"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(strOldExternalGroup, '') <> IsNULL(strNewExternalGroup, '')
						)
					SELECT @strDetails += '{"change":"strExternalGroup","iconCls":"small-gear","from":"' + IsNULL(strOldExternalGroup, '') + '","to":"' + IsNULL(strNewExternalGroup, '') + '","leaf":true,"changeDescription":"External Group"},'
					FROM @tblICItem

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(intOldOriginId, 0) <> IsNULL(intNewOriginId, 0)
						)
					SELECT @strDetails += '{"change":"strOrigin","iconCls":"small-gear","from":"' + IsNULL(CA.strDescription, '') + '","to":"' + IsNULL(CA1.strDescription, '') + '","leaf":true,"changeDescription":"Origin"},'
					FROM @tblICItem I
					LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOldOriginId
					LEFT JOIN tblICCommodityAttribute CA1 ON CA1.intCommodityAttributeId = I.intNewOriginId

				IF EXISTS (
						SELECT 1
						FROM @tblICItem
						WHERE IsNULL(intOldProductTypeId, 0) <> IsNULL(intNewProductTypeId, 0)
						)
					SELECT @strDetails += '{"change":"strProductType","iconCls":"small-gear","from":"' + IsNULL(CA.strDescription, '') + '","to":"' + IsNULL(CA1.strDescription, '') + '","leaf":true,"changeDescription":"Product Type"},'
					FROM @tblICItem I
					LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOldProductTypeId
					LEFT JOIN tblICCommodityAttribute CA1 ON CA1.intCommodityAttributeId = I.intNewProductTypeId

				IF EXISTS (
						SELECT 1
						FROM @tblICItemUOM
						)
				BEGIN
					SELECT @strDetails += '{"change":"tblICItemUOMs","children":['

					SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + UM.strUnitMeasure + '","keyValue":' + ltrim(IU.intItemUOMId) + ',"iconCls":"small-new-plus","leaf":true},'
					FROM @tblICItemUOM IU
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId

					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Unit of Measure"},'
				END

				IF (LEN(@strDetails) > 1)
				BEGIN
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					EXEC uspSMAuditLog @keyValue = @intItemId
						,@screenName = 'Inventory.view.Item'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END
			END
			ELSE IF @intActionId = 4
			BEGIN
				IF @intItemId > 0
				BEGIN
					DELETE
					FROM tblICItem
					WHERE intItemId = @intItemId

					EXEC uspSMAuditLog @keyValue = @intItemId
						,@screenName = 'Inventory.view.Item'
						,@entityId = @intUserId
						,@actionType = 'Deleted'
				END
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPItemRouteArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			SELECT @intNewItemRouteStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPItemRouteDetailArchive (
				intItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				)
			SELECT @intNewItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
			FROM tblIPItemRouteDetailStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			DELETE
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPItemRouteError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,@ErrMsg
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			SELECT @intNewItemRouteStageId = SCOPE_IDENTITY()

			INSERT INTO tblIPItemRouteDetailError (
				intItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				)
			SELECT @intNewItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
			FROM tblIPItemRouteDetailStage
			WHERE intItemRouteStageId = @intItemRouteStageId

			DELETE
			FROM tblIPItemRouteStage
			WHERE intItemRouteStageId = @intItemRouteStageId
		END CATCH

		SELECT @intItemRouteStageId = MIN(intStageItemId)
		FROM tblIPItemStage
		WHERE intStageItemId > @intItemRouteStageId
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
