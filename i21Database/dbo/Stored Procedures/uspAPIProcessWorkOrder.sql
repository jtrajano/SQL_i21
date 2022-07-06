CREATE PROCEDURE uspAPIProcessWorkOrder (@guiApiUniqueId UNIQUEIDENTIFIER)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
	DECLARE @tblWOBatch TABLE (intBatchId INT)
	DECLARE @intBatchId INT
		,@intDetailId INT
		,@strProduceXml NVARCHAR(MAX)
		,@strConsumeXml NVARCHAR(MAX)
		,@strBatchXml NVARCHAR(MAX)
	DECLARE @dblQuantity NUMERIC(18, 6)
		
		,@strLotNumber NVARCHAR(50)
		,@intTransactionTypeId INT
		,@strUserName NVARCHAR(100)
		,@dtmDate DATETIME
	DECLARE @intItemId INT
		,@intQtyUnitMeasureId INT
		,@intQtyItemUOMId INT
		,@intCompanyLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intLotId INT
		,@intCreatedUserId INT
		,@intItemFactoryId INT
		,@intManufacturingCellId INT
	DECLARE @strWorkOrderNo NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@intOutputLotId INT
		,@strOutputLotNumber NVARCHAR(50)

	INSERT INTO @tblWOBatch (intBatchId)
	SELECT DISTINCT intBatchId
	FROM tblAPIWODetail WITH (NOLOCK)
	WHERE ysnProcessed = 0
		AND guiApiUniqueId = @guiApiUniqueId

	SELECT @intBatchId = MIN(intBatchId)
	FROM @tblWOBatch

	IF @intBatchId IS NULL
	BEGIN
		RETURN
	END

	WHILE @intBatchId > 0
	BEGIN
		SELECT @intDetailId = NULL
			,@strProduceXml = ''
			,@strConsumeXml = ''
			,@strBatchXml = ''
			,@strWorkOrderNo = NULL
			,@strBatchId = NULL
			,@intOutputLotId = NULL
			,@strOutputLotNumber = NULL

		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			IF (
					SELECT COUNT(1)
					FROM tblAPIWODetail WITH (NOLOCK)
					WHERE intBatchId = @intBatchId
						AND intTransactionTypeId = 9
						AND ysnProcessed = 0
						AND guiApiUniqueId = @guiApiUniqueId
					) > 1
			BEGIN
				RAISERROR (
						'Multiple Output item is available in a batch. '
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblAPIWODetail WITH (NOLOCK)
					WHERE intBatchId = @intBatchId
						AND intTransactionTypeId = 9
						AND ysnProcessed = 0
						AND guiApiUniqueId = @guiApiUniqueId
					)
			BEGIN
				RAISERROR (
						'WO Output item is not available. '
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblAPIWODetail WITH (NOLOCK)
					WHERE intBatchId = @intBatchId
						AND intTransactionTypeId = 8
						AND ysnProcessed = 0
						AND guiApiUniqueId = @guiApiUniqueId
					)
			BEGIN
				RAISERROR (
						'WO Input item is not available. '
						,16
						,1
						)
			END

			SELECT @intDetailId = MIN(intDetailId)
			FROM tblAPIWODetail WITH (NOLOCK)
			WHERE intBatchId = @intBatchId
				AND ysnProcessed = 0
				AND guiApiUniqueId = @guiApiUniqueId

			WHILE @intDetailId IS NOT NULL
			BEGIN
				SELECT @dblQuantity = NULL
					,@strLotNumber = NULL
					,@intTransactionTypeId = NULL
					,@strUserName = NULL
					,@dtmDate = NULL

				SELECT @intItemId = NULL
					,@intQtyUnitMeasureId = NULL
					,@intQtyItemUOMId = NULL
					,@intCompanyLocationId = NULL
					,@intSubLocationId = NULL
					,@intStorageLocationId = NULL
					,@intLotId = NULL
					,@intCreatedUserId = NULL
					,@intItemFactoryId = NULL
					,@intManufacturingCellId = NULL

				SELECT @dblQuantity = dblQuantity
					,@strLotNumber = strLotNumber
					,@intTransactionTypeId = intTransactionTypeId
					,@strUserName = strUserName
					,@dtmDate = dtmDate
					,@intStorageLocationId = intStorageLocationId
					,@intSubLocationId = intSubLocationId
					,@intCompanyLocationId = intCompanyLocationId
					,@intQtyItemUOMId = intQtyItemUOMId
					,@intItemId = intItemId
				FROM tblAPIWODetail WITH (NOLOCK)
				WHERE intDetailId = @intDetailId
					AND ysnProcessed = 0
					AND guiApiUniqueId = @guiApiUniqueId

				IF @intItemId IS NULL
				BEGIN
					RAISERROR (
							'Invalid Item No. '
							,16
							,1
							)
				END

				IF ISNULL(@dblQuantity, 0) <= 0
				BEGIN
					RAISERROR (
							'Invalid Quantity. '
							,16
							,1
							)
				END

				IF @intQtyItemUOMId IS NULL
				BEGIN
					RAISERROR (
							'Invalid Quantity UOM. '
							,16
							,1
							)
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT *
					FROM tblICItemUOM t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.intItemUOMId = @intQtyItemUOMId)
					BEGIN
						RAISERROR (
								'Quantity UOM does not belongs to the Item. '
								,16
								,1
								)
					END
				END

				IF @intCompanyLocationId IS NULL
				BEGIN
					RAISERROR (
							'Invalid Location. '
							,16
							,1
							)
				END

				IF @intSubLocationId IS NOT NULL
				BEGIN
					IF NOT EXISTS(SELECT *
					FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
					WHERE t.intCompanyLocationSubLocationId = @intSubLocationId
						AND t.intCompanyLocationId = @intCompanyLocationId)
					BEGIN
						RAISERROR (
								'Invalid Storage Location. '
								,16
								,1
								)
					END
				END

				IF @intStorageLocationId IS NOT NULL
				BEGIN
					IF NOT EXISTS(SELECT *
					FROM tblICStorageLocation t WITH (NOLOCK)
					WHERE t.intStorageLocationId = @intStorageLocationId
						AND t.intSubLocationId = @intSubLocationId)
					BEGIN
						RAISERROR (
								'Invalid Storage Unit. '
								,16
								,1
								)
					END
				END

				IF ISNULL(@strLotNumber, '') <> ''
				BEGIN
					IF @intSubLocationId IS NULL
					BEGIN
						RAISERROR (
								'Storage Location not found. '
								,16
								,1
								)
					END

					IF @intStorageLocationId IS NULL
					BEGIN
						RAISERROR (
								'Storage Unit not found. '
								,16
								,1
								)
					END

					SELECT @intLotId = L.intLotId
					FROM tblICLot L WITH (NOLOCK)
					WHERE L.strLotNumber = @strLotNumber
						AND L.intItemId = @intItemId
						AND L.intSubLocationId = @intSubLocationId
						AND L.intStorageLocationId = @intStorageLocationId
						AND L.dblQty > 0

					IF @intLotId IS NULL
					BEGIN
						RAISERROR (
								'Invalid Lot Number. '
								,16
								,1
								)
					END
				END

				IF @intTransactionTypeId <> 8
					AND @intTransactionTypeId <> 9
				BEGIN
					RAISERROR (
							'Invalid Transaction Type. '
							,16
							,1
							)
				END

				SELECT @intCreatedUserId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'User'
					AND t.strName = @strUserName

				IF @intCreatedUserId IS NULL
				BEGIN
					IF EXISTS (
							SELECT 1
							FROM tblSMUserSecurity WITH (NOLOCK)
							WHERE strUserName = 'irelyadmin'
							)
						SELECT TOP 1 @intCreatedUserId = intEntityId
						FROM tblSMUserSecurity WITH (NOLOCK)
						WHERE strUserName = 'irelyadmin'
					ELSE
						SELECT TOP 1 @intCreatedUserId = intEntityId
						FROM tblSMUserSecurity WITH (NOLOCK)
				END

				IF @dtmDate IS NULL
					SELECT @dtmDate = GETDATE()

				IF @intTransactionTypeId = 9
				BEGIN
					SELECT @intItemFactoryId = intItemFactoryId
					FROM tblICItemFactory WITH (NOLOCK)
					WHERE intItemId = @intItemId
						AND intFactoryId = @intCompanyLocationId

					SELECT @intManufacturingCellId = intManufacturingCellId
					FROM tblICItemFactoryManufacturingCell WITH (NOLOCK)
					WHERE intItemFactoryId = @intItemFactoryId
						AND ysnDefault = 1

					IF @intManufacturingCellId IS NULL
					BEGIN
						SELECT @intManufacturingCellId = intManufacturingCellId
						FROM tblICItemFactoryManufacturingCell WITH (NOLOCK)
						WHERE intItemFactoryId = @intItemFactoryId
					END

					IF @intManufacturingCellId IS NULL
					BEGIN
						RAISERROR (
								'Unable to find the Manufacturing Cell. '
								,16
								,1
								)
					END

					SELECT @strProduceXml = '<root>'

					SELECT @strProduceXml = @strProduceXml + '<intWorkOrderId>0</intWorkOrderId>'

					SELECT @strProduceXml = @strProduceXml + '<intItemId>' + CONVERT(VARCHAR, @intItemId) + '</intItemId>'

					SELECT @strProduceXml = @strProduceXml + '<intItemUOMId>' + CONVERT(VARCHAR, @intQtyItemUOMId) + '</intItemUOMId>'

					SELECT @strProduceXml = @strProduceXml + '<dblQtyToProduce>' + CONVERT(VARCHAR, @dblQuantity) + '</dblQtyToProduce>'

					SELECT @strProduceXml = @strProduceXml + '<dblIssuedQuantity>0</dblIssuedQuantity>'

					SELECT @strProduceXml = @strProduceXml + '<intItemIssuedUOMId>0</intItemIssuedUOMId>'

					SELECT @strProduceXml = @strProduceXml + '<dblWeightPerUnit>0</dblWeightPerUnit>'

					SELECT @strProduceXml = @strProduceXml + '<intManufacturingCellId>' + CONVERT(VARCHAR, @intManufacturingCellId) + '</intManufacturingCellId>'

					SELECT @strProduceXml = @strProduceXml + '<dblPlannedQuantity>' + CONVERT(VARCHAR, @dblQuantity) + '</dblPlannedQuantity>'

					SELECT @strProduceXml = @strProduceXml + '<intLocationId>' + CONVERT(VARCHAR, @intCompanyLocationId) + '</intLocationId>'

					SELECT @strProduceXml = @strProduceXml + '<intStorageLocationId>' + ISNULL(CONVERT(VARCHAR, @intStorageLocationId), '') + '</intStorageLocationId>'

					SELECT @strProduceXml = @strProduceXml + '<intUserId>' + CONVERT(VARCHAR, @intCreatedUserId) + '</intUserId>'

					SELECT @strProduceXml = @strProduceXml + '<dtmProductionDate>' + CONVERT(VARCHAR, @dtmDate) + '</dtmProductionDate>'
				END

				IF @intTransactionTypeId = 8
				BEGIN
					SELECT @strConsumeXml = @strConsumeXml + '<lot>'

					SELECT @strConsumeXml = @strConsumeXml + '<intWorkOrderId>0</intWorkOrderId>'

					SELECT @strConsumeXml = @strConsumeXml + '<intWorkOrderConsumedLotId>0</intWorkOrderConsumedLotId>'

					SELECT @strConsumeXml = @strConsumeXml + '<intLotId>' + ISNULL(CONVERT(VARCHAR, @intLotId), '') + '</intLotId>'

					SELECT @strConsumeXml = @strConsumeXml + '<intItemId>' + CONVERT(VARCHAR, @intItemId) + '</intItemId>'

					SELECT @strConsumeXml = @strConsumeXml + '<dblQty>' + CONVERT(VARCHAR, @dblQuantity) + '</dblQty>'

					SELECT @strConsumeXml = @strConsumeXml + '<intItemUOMId>' + CONVERT(VARCHAR, @intQtyItemUOMId) + '</intItemUOMId>'

					SELECT @strConsumeXml = @strConsumeXml + '<dblIssuedQuantity>' + CONVERT(VARCHAR, @dblQuantity) + '</dblIssuedQuantity>'

					SELECT @strConsumeXml = @strConsumeXml + '<intItemIssuedUOMId>' + CONVERT(VARCHAR, @intQtyItemUOMId) + '</intItemIssuedUOMId>'

					SELECT @strConsumeXml = @strConsumeXml + '<intSubLocationId>' + ISNULL(CONVERT(VARCHAR, @intSubLocationId), '') + '</intSubLocationId>'

					SELECT @strConsumeXml = @strConsumeXml + '<intStorageLocationId>' + ISNULL(CONVERT(VARCHAR, @intStorageLocationId), '') + '</intStorageLocationId>'

					SELECT @strConsumeXml = @strConsumeXml + '</lot>'
				END

				SELECT @intDetailId = MIN(intDetailId)
				FROM tblAPIWODetail WITH (NOLOCK)
				WHERE intBatchId = @intBatchId
					AND intDetailId > @intDetailId
					AND ysnProcessed = 0
					AND guiApiUniqueId = @guiApiUniqueId
			END

			IF ISNULL(@strProduceXml, '') = ''
			BEGIN
				RAISERROR (
						'WO Production XML is not available. '
						,16
						,1
						)
			END

			IF ISNULL(@strConsumeXml, '') = ''
			BEGIN
				RAISERROR (
						'WO Consumption XML is not available. '
						,16
						,1
						)
			END

			SELECT @strBatchXml = @strProduceXml + @strConsumeXml + '</root>'

			EXEC [dbo].[uspMFCompleteBlendSheet] @strXml = @strBatchXml
				,@intLotId = @intOutputLotId OUT
				,@strLotNumber = @strOutputLotNumber OUT
				,@intLoadDistributionDetailId = NULL
				,@ysnRecap = 0
				,@strBatchId = @strBatchId OUT
				,@ysnAutoBlend = 0
				,@strWorkOrderNo = @strWorkOrderNo OUT

			UPDATE tblAPIWODetail
			SET strMessage = 'Success'
				,strFeedStatus = 'Success'
				,ysnProcessed = 1
				,strWorkOrderNo = @strWorkOrderNo
				,ysnCompleted = 0
			WHERE intBatchId = @intBatchId
				AND ysnProcessed = 0
				AND guiApiUniqueId = @guiApiUniqueId

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblAPIWODetail
			SET strMessage = @ErrMsg
				,strFeedStatus = 'Failed'
				,ysnProcessed = 1
				,strWorkOrderNo = NULL
				,ysnCompleted = 0
			WHERE intBatchId = @intBatchId
				AND ysnProcessed = 0
				AND guiApiUniqueId = @guiApiUniqueId
		END CATCH

		SELECT @intBatchId = MIN(intBatchId)
		FROM @tblWOBatch
		WHERE intBatchId > @intBatchId
	END
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
