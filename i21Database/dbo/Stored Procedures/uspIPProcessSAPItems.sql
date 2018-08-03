CREATE PROCEDURE [dbo].[uspIPProcessSAPItems] @strSessionId NVARCHAR(50) = ''
	,@strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	--SET ANSI_WARNINGS OFF
	DECLARE @intMinItem INT
	DECLARE @strItemNo NVARCHAR(50)
	DECLARE @strItemType NVARCHAR(50)
	DECLARE @strSKUItemNo NVARCHAR(50)
	DECLARE @intCommodityId INT
	DECLARE @intCategoryId INT
	DECLARE @strCommodity NVARCHAR(50)
	DECLARE @intItemId INT
	DECLARE @strStockUOM NVARCHAR(50)
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @ysnDeleted BIT
	DECLARE @intStageItemId INT
	DECLARE @intNewStageItemId INT
	DECLARE @strDescription NVARCHAR(250)
	DECLARE @strJson NVARCHAR(Max)
	DECLARE @dtmDate DATETIME
	DECLARE @intUserId INT
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@strCustomerCode NVARCHAR(50)
		,@strProductType NVARCHAR(50)
		,@intCommodityAttributeId INT

	SELECT @strCustomerCode = strCustomerCode
	FROM tblIPCompanyPreference

	IF IsNULL(@strCustomerCode, '') = ''
	BEGIN
		RAISERROR (
				'Customer code cannot be blank.'
				,16
				,1
				)

		RETURN
	END

	IF ISNULL(@strSessionId, '') = ''
		SELECT @intMinItem = MIN(intStageItemId)
		FROM tblIPItemStage
	ELSE IF @strSessionId = 'ProcessOneByOne'
		SELECT @intMinItem = MIN(intStageItemId)
		FROM tblIPItemStage
	ELSE
		SELECT @intMinItem = MIN(intStageItemId)
		FROM tblIPItemStage
		WHERE strSessionId = @strSessionId

	SELECT @strInfo1 = ''

	SELECT @strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(strItemNo, '') + ', '
	FROM tblIPItemStage

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strItemType, '') + ', '
	FROM (
		SELECT DISTINCT strItemType
		FROM tblIPItemStage
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intMinItem IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1
			SET @intItemId = NULL
			SET @intCategoryId = NULL
			SET @intCommodityId = NULL
			SET @strCommodity = NULL
			SET @strItemNo = NULL
			SET @strItemType = NULL
			SET @strSKUItemNo = NULL
			SET @strStockUOM = NULL
			SET @strDescription = NULL
			SET @ysnDeleted = 0

			SELECT @strProductType = NULL

			SELECT @intStageItemId = intStageItemId
				,@strItemNo = strItemNo
				,@strItemType = strItemType
				,@strSKUItemNo = strSKUItemNo
				,@strStockUOM = strStockUOM
				,@ysnDeleted = ISNULL(ysnDeleted, 0)
				,@strDescription = strDescription
				,@strProductType = strProductType
			FROM tblIPItemStage
			WHERE intStageItemId = @intMinItem

			SELECT @intCategoryId = intCategoryId
			FROM tblICCategory
			WHERE strCategoryCode = @strItemType

			IF @strItemType = 'ZMPN' --Contract Item
				SELECT TOP 1 @intItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strSKUItemNo
			ELSE
				SELECT TOP 1 @intItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strItemNo

			IF @strItemType = 'ZCOM'
			BEGIN
				IF ISNULL(@intCategoryId, 0) = 0
					RAISERROR (
							'Category not found.'
							,16
							,1
							)

				IF EXISTS (
						SELECT 1
						WHERE RIGHT(@strItemNo, 8) LIKE '496%'
						)
					SELECT @strCommodity = 'Coffee'

				IF EXISTS (
						SELECT 1
						WHERE RIGHT(@strItemNo, 8) LIKE '491%'
						)
					SELECT @strCommodity = 'Tea'

				SELECT @intCommodityId = intCommodityId
				FROM tblICCommodity
				WHERE strCommodityCode = @strCommodity

				IF ISNULL(@intCommodityId, 0) = 0
					RAISERROR (
							'Commodity not found.'
							,16
							,1
							)
			END

			IF @strCustomerCode = 'HE'
			BEGIN
				IF EXISTS (
						SELECT iu.strUOM
							,iu.strUOM
						FROM tblIPItemUOMStage iu
						WHERE NOT EXISTS (
								SELECT *
								FROM tblIPSAPUOM su
								WHERE su.strSAPUOM = iu.strUOM
								)
							AND NOT EXISTS (
								SELECT *
								FROM tblICUnitMeasure um
								WHERE um.strSymbol = iu.strUOM
								)
							AND iu.intStageItemId = @intStageItemId
						)
					RAISERROR (
							'UOM not found.'
							,16
							,1
							)

				SELECT @intCommodityAttributeId = intCommodityAttributeId
					,@intCommodityId = intCommodityId
				FROM tblICCommodityAttribute
				WHERE strType = 'ProductType'
					AND strDescription = @strProductType
			END

			BEGIN TRAN

			IF @ysnDeleted = 1
				AND @strItemType <> 'ZMPN'
			BEGIN
				UPDATE tblICItem
				SET strStatus = 'Discontinued'
				WHERE intItemId = @intItemId

				GOTO MOVE_TO_ARCHIVE
			END

			IF @strItemType = 'ZMPN' --Contract Item
			BEGIN
				IF ISNULL(@intItemId, 0) = 0
				BEGIN
					SET @ErrMsg = 'ZCOM item ' + @strSKUItemNo + ' not found.'

					RAISERROR (
							@ErrMsg
							,16
							,1
							)
				END

				IF @ysnDeleted = 1
					DELETE
					FROM tblICItemContract
					WHERE intItemId = @intItemId
						AND strContractItemNo = @strItemNo
				ELSE
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblICItemContract
							WHERE intItemId = @intItemId
								AND strContractItemNo = @strItemNo
							) --Add
					BEGIN
						INSERT INTO tblICItemContract (
							intItemId
							,strContractItemNo
							,strContractItemName
							,intItemLocationId
							)
						SELECT @intItemId
							,@strItemNo
							,@strDescription
							,intItemLocationId
						FROM tblICItemLocation
						WHERE intItemId = @intItemId
					END
					ELSE
					BEGIN --Update
						UPDATE tblICItemContract
						SET strContractItemName = @strDescription
						WHERE intItemId = @intItemId
							AND strContractItemNo = @strItemNo
					END
				END

				GOTO MOVE_TO_ARCHIVE
			END
			ELSE
			BEGIN
				INSERT INTO tblIPSAPUOM (
					strSAPUOM
					,stri21UOM
					)
				SELECT iu.strUOM
					,iu.strUOM
				FROM tblIPItemUOMStage iu
				WHERE NOT EXISTS (
						SELECT *
						FROM tblIPSAPUOM su
						WHERE su.strSAPUOM = iu.strUOM
						)
					AND EXISTS (
						SELECT *
						FROM tblICUnitMeasure um
						WHERE um.strSymbol = iu.strUOM
						)
					AND iu.intStageItemId = @intStageItemId

				--Inventory Item
				IF ISNULL(@intItemId, 0) = 0 --Create
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblIPItemUOMStage
							WHERE intStageItemId = @intStageItemId
							)
						RAISERROR (
								'UOM is required.'
								,16
								,1
								)

					INSERT INTO tblICItem (
						strItemNo
						,strDescription
						,strShortName
						,strType
						,strLotTracking
						,strInventoryTracking
						,intCategoryId
						,intCommodityId
						,strStatus
						,intLifeTime
						,intProductTypeId
						)
					SELECT strItemNo
						,strDescription
						,LEFT(strDescription, 50)
						,'Inventory'
						,'Yes - Manual/Serial Number'
						,'Lot Level'
						,@intCategoryId
						,@intCommodityId
						,'Active'
						,0
						,@intCommodityAttributeId
					FROM tblIPItemStage
					WHERE strItemNo = @strItemNo
						AND intStageItemId = @intStageItemId

					SELECT @intItemId = SCOPE_IDENTITY()

					INSERT INTO tblICItemUOM (
						intItemId
						,intUnitMeasureId
						,dblUnitQty
						,ysnStockUnit
						,ysnAllowPurchase
						,ysnAllowSale
						)
					SELECT @intItemId
						,um.intUnitMeasureId
						,iu.dblNumerator / iu.dblDenominator
						,CASE 
							WHEN iu.strUOM = @strStockUOM
								THEN 1
							ELSE 0
							END
						,1
						,1
					FROM tblIPItemUOMStage iu
					JOIN tblIPSAPUOM su ON iu.strUOM = su.strSAPUOM
					JOIN tblICUnitMeasure um ON su.stri21UOM = um.strSymbol
					WHERE strItemNo = @strItemNo
						AND iu.intStageItemId = @intStageItemId

					--if stock uom is KG then add TO as one of the uom
					IF (
							SELECT UPPER(strSymbol)
							FROM tblICUnitMeasure
							WHERE UPPER(strUnitMeasure) = UPPER(dbo.fnIPConvertSAPUOMToi21(@strStockUOM))
							) = 'KG'
						AND @strCustomerCode = 'JDE'
					BEGIN
						IF NOT EXISTS (
								SELECT 1
								FROM tblICItemUOM iu
								JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
								WHERE iu.intItemId = @intItemId
									AND um.strSymbol = 'TO'
								)
							INSERT INTO tblICItemUOM (
								intItemId
								,intUnitMeasureId
								,dblUnitQty
								,ysnStockUnit
								,ysnAllowPurchase
								,ysnAllowSale
								)
							SELECT TOP 1 @intItemId
								,intUnitMeasureId
								,1000
								,0
								,1
								,1
							FROM tblICUnitMeasure
							WHERE strSymbol = 'TO'

						--Add 70/69/60/50/65 Kg Bags for coffee
						IF (
								SELECT UPPER(strCommodityCode)
								FROM tblICCommodity
								WHERE intCommodityId = @intCommodityId
								) = 'COFFEE'
							INSERT INTO tblICItemUOM (
								intItemId
								,intUnitMeasureId
								,dblUnitQty
								,ysnStockUnit
								,ysnAllowPurchase
								,ysnAllowSale
								)
							SELECT @intItemId
								,intUnitMeasureId
								,SUBSTRING(strUnitMeasure, 1, 2)
								,0
								,1
								,1
							FROM tblICUnitMeasure
							WHERE UPPER(strUnitMeasure) LIKE '%KG BAG%'
								AND ISNUMERIC(SUBSTRING(strUnitMeasure, 1, 2)) = 1
					END

					INSERT INTO tblICItemLocation (
						intItemId
						,intLocationId
						,intCostingMethod
						,intAllowNegativeInventory
						)
					SELECT @intItemId
						,cl.intCompanyLocationId
						,1
						,3
					FROM tblSMCompanyLocation cl

					INSERT INTO tblICItemSubLocation (
						intItemLocationId
						,intSubLocationId
						)
					SELECT il.intItemLocationId
						,sl.intCompanyLocationSubLocationId
					FROM tblIPItemSubLocationStage s
					JOIN tblSMCompanyLocationSubLocation sl ON s.strSubLocation = sl.strSubLocationName
					JOIN tblICItemLocation il ON sl.intCompanyLocationId = il.intLocationId
					WHERE s.intStageItemId = @intStageItemId
						AND il.intItemId = @intItemId

					--Add Audit Trail Record
					SET @strJson = '{"action":"Created","change":"Created - Record: ' + CONVERT(VARCHAR, @intItemId) + '","keyValue":' + CONVERT(VARCHAR, @intItemId) + ',"iconCls":"small-new-plus","leaf":true}'

					SELECT @dtmDate = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), dtmCreated)
					FROM tblIPItemStage
					WHERE intStageItemId = @intStageItemId

					IF @dtmDate IS NULL
						SET @dtmDate = GETUTCDATE()

					SELECT @strUserName = strCreatedUserName
					FROM tblIPItemStage
					WHERE intStageItemId = @intStageItemId

					SELECT @intUserId = e.intEntityId
					FROM tblEMEntity e
					JOIN tblEMEntityType et ON e.intEntityId = et.intEntityId
					WHERE e.strExternalERPId = @strUserName
						AND et.strType = 'User'

					INSERT INTO tblSMAuditLog (
						strActionType
						,strTransactionType
						,strRecordNo
						,strDescription
						,strRoute
						,strJsonData
						,dtmDate
						,intEntityId
						,intConcurrencyId
						)
					VALUES (
						'Created'
						,'Inventory.view.Item'
						,@intItemId
						,''
						,''
						,@strJson
						,@dtmDate
						,@intUserId
						,1
						)
				END
				ELSE
				BEGIN --Update
					IF @strCustomerCode = 'JDE'
					BEGIN
						UPDATE i
						SET i.strDescription = si.strDescription
							,i.strShortName = LEFT(si.strDescription, 50)
						FROM tblICItem i
						JOIN tblIPItemStage si ON i.strItemNo = si.strItemNo
						WHERE intItemId = @intItemId
							AND si.intStageItemId = @intStageItemId
							AND si.strDescription <> '/'
					END
					ELSE
					BEGIN
						UPDATE i
						SET i.strDescription = si.strDescription
							,i.strShortName = LEFT(si.strDescription, 50)
							,intProductTypeId = @intCommodityAttributeId
						FROM tblICItem i
						JOIN tblIPItemStage si ON i.strItemNo = si.strItemNo
						WHERE intItemId = @intItemId
							AND si.intStageItemId = @intStageItemId
					END

					INSERT INTO tblICItemUOM (
						intItemId
						,intUnitMeasureId
						,dblUnitQty
						,ysnStockUnit
						,ysnAllowPurchase
						,ysnAllowSale
						)
					SELECT @intItemId
						,um.intUnitMeasureId
						,iu.dblNumerator / iu.dblDenominator
						,CASE 
							WHEN iu.strUOM = @strStockUOM
								THEN 1
							ELSE 0
							END
						,1
						,1
					FROM tblIPItemUOMStage iu
					JOIN tblIPSAPUOM su ON iu.strUOM = su.strSAPUOM
					JOIN tblICUnitMeasure um ON su.stri21UOM = um.strSymbol
					WHERE strItemNo = @strItemNo
						AND iu.intStageItemId = @intStageItemId
						AND um.intUnitMeasureId NOT IN (
							SELECT intUnitMeasureId
							FROM tblICItemUOM
							WHERE intItemId = @intItemId
							)

					UPDATE iu
					SET iu.dblUnitQty = st.dblNumerator / st.dblDenominator
					FROM tblICItemUOM iu
					JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
					JOIN tblIPSAPUOM su ON um.strSymbol = su.stri21UOM
					JOIN tblIPItemUOMStage st ON st.strUOM = su.strSAPUOM
					WHERE intItemId = @intItemId
						AND st.intStageItemId = @intStageItemId

					--add new sublocations
					INSERT INTO tblICItemSubLocation (
						intItemLocationId
						,intSubLocationId
						)
					SELECT il.intItemLocationId
						,sl.intCompanyLocationSubLocationId
					FROM tblIPItemSubLocationStage s
					JOIN tblSMCompanyLocationSubLocation sl ON s.strSubLocation = sl.strSubLocationName
					JOIN tblICItemLocation il ON sl.intCompanyLocationId = il.intLocationId
						AND il.intItemId = @intItemId
					WHERE s.intStageItemId = @intStageItemId
						AND sl.intCompanyLocationSubLocationId NOT IN (
							SELECT isl.intSubLocationId
							FROM tblICItemSubLocation isl
							JOIN tblICItemLocation il ON isl.intItemLocationId = il.intItemLocationId
							WHERE il.intItemId = @intItemId
							)

					--Delete the SubLocation if it is marked for deletion
					DELETE
					FROM tblICItemSubLocation
					WHERE intItemLocationId IN (
							SELECT intItemLocationId
							FROM tblICItemLocation
							WHERE intItemId = @intItemId
							)
						AND intSubLocationId IN (
							SELECT sl.intCompanyLocationSubLocationId
							FROM tblSMCompanyLocationSubLocation sl
							JOIN tblIPItemSubLocationStage s ON sl.strSubLocationName = s.strSubLocation
							WHERE s.intStageItemId = @intStageItemId
								AND ISNULL(s.ysnDeleted, 0) = 1
							)
				END
			END

			MOVE_TO_ARCHIVE:

			--Move to Archive
			INSERT INTO tblIPItemArchive (
				strItemNo
				,dtmCreated
				,strCreatedUserName
				,dtmLastModified
				,strLastModifiedUserName
				,ysnDeleted
				,strItemType
				,strStockUOM
				,strSKUItemNo
				,strDescription
				,strSessionId
				,strProductType
				)
			SELECT strItemNo
				,dtmCreated
				,strCreatedUserName
				,dtmLastModified
				,strLastModifiedUserName
				,ysnDeleted
				,strItemType
				,strStockUOM
				,strSKUItemNo
				,strDescription
				,strSessionId
				,strProductType
			FROM tblIPItemStage
			WHERE intStageItemId = @intStageItemId

			SELECT @intNewStageItemId = SCOPE_IDENTITY()

			INSERT INTO tblIPItemUOMArchive (
				intStageItemId
				,strItemNo
				,strUOM
				,dblNumerator
				,dblDenominator
				)
			SELECT @intNewStageItemId
				,@strItemNo
				,strUOM
				,dblNumerator
				,dblDenominator
			FROM tblIPItemUOMStage
			WHERE intStageItemId = @intStageItemId

			INSERT INTO tblIPItemSubLocationArchive (
				intStageItemId
				,strItemNo
				,strSubLocation
				,ysnDeleted
				)
			SELECT @intNewStageItemId
				,@strItemNo
				,strSubLocation
				,ysnDeleted
			FROM tblIPItemSubLocationStage
			WHERE intStageItemId = @intStageItemId

			DELETE
			FROM tblIPItemStage
			WHERE intStageItemId = @intStageItemId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPItemError (
				strItemNo
				,dtmCreated
				,strCreatedUserName
				,dtmLastModified
				,strLastModifiedUserName
				,ysnDeleted
				,strItemType
				,strStockUOM
				,strSKUItemNo
				,strDescription
				,strErrorMessage
				,strImportStatus
				,strSessionId
				,strProductType
				)
			SELECT strItemNo
				,dtmCreated
				,strCreatedUserName
				,dtmLastModified
				,strLastModifiedUserName
				,ysnDeleted
				,strItemType
				,strStockUOM
				,strSKUItemNo
				,strDescription
				,@ErrMsg
				,'Failed'
				,strSessionId
				,strProductType
			FROM tblIPItemStage
			WHERE intStageItemId = @intStageItemId

			SELECT @intNewStageItemId = SCOPE_IDENTITY()

			INSERT INTO tblIPItemUOMError (
				intStageItemId
				,strItemNo
				,strUOM
				,dblNumerator
				,dblDenominator
				)
			SELECT @intNewStageItemId
				,@strItemNo
				,strUOM
				,dblNumerator
				,dblDenominator
			FROM tblIPItemUOMStage
			WHERE intStageItemId = @intStageItemId

			INSERT INTO tblIPItemSubLocationError (
				intStageItemId
				,strItemNo
				,strSubLocation
				,ysnDeleted
				)
			SELECT @intNewStageItemId
				,@strItemNo
				,strSubLocation
				,ysnDeleted
			FROM tblIPItemSubLocationStage
			WHERE intStageItemId = @intStageItemId

			DELETE
			FROM tblIPItemStage
			WHERE intStageItemId = @intStageItemId
		END CATCH

		IF ISNULL(@strSessionId, '') = ''
			SELECT @intMinItem = MIN(intStageItemId)
			FROM tblIPItemStage
			WHERE intStageItemId > @intMinItem
		ELSE IF @strSessionId = 'ProcessOneByOne'
			SELECT @intMinItem = NULL
		ELSE
			SELECT @intMinItem = MIN(intStageItemId)
			FROM tblIPItemStage
			WHERE intStageItemId > @intMinItem
				AND strSessionId = @strSessionId
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
