CREATE PROCEDURE uspQMImportSampleType @intUserId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX) = ''
	DECLARE @intRowId INT
		,@strSampleTypeName NVARCHAR(50)
		,@strDescription NVARCHAR(100)
		,@strControlPointName NVARCHAR(50)
		,@ysnFinalApproval BIT
		,@strApprovalBase NVARCHAR(50)
		,@strSampleLabelName NVARCHAR(100)
		,@ysnAdjustInventoryQtyBySampleQty BIT
		,@strApprovalLotStatus NVARCHAR(50)
		,@strRejectionLotStatus NVARCHAR(50)
		,@strBondedApprovalLotStatus NVARCHAR(50)
		,@strBondedRejectionLotStatus NVARCHAR(50)
		,@strAttributeName NVARCHAR(50)
		,@ysnIsMandatory BIT
		,@intSampleTypeId INT
		,@intControlPointId INT
		,@intSampleLabelId INT
		,@intApprovalLotStatusId INT
		,@intRejectionLotStatusId INT
		,@intBondedApprovalLotStatusId INT
		,@intBondedRejectionLotStatusId INT
		,@intAttributeId INT

	IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity
		WHERE LOWER(strUserName) = 'irelyadmin'
	END

	SELECT @intRowId = MIN(intImportId)
	FROM tblQMSampleTypeImport
	WHERE ISNULL(ysnProcessed, 0) = 0

	WHILE (ISNULL(@intRowId, 0) > 0)
	BEGIN
		BEGIN TRY
			SELECT @strSampleTypeName = ''
				,@strDescription = ''
				,@strControlPointName = ''
				,@ysnFinalApproval = 0
				,@strApprovalBase = ''
				,@strSampleLabelName = ''
				,@ysnAdjustInventoryQtyBySampleQty = 0
				,@strApprovalLotStatus = ''
				,@strRejectionLotStatus = ''
				,@strBondedApprovalLotStatus = ''
				,@strBondedRejectionLotStatus = ''
				,@strAttributeName = ''
				,@ysnIsMandatory = 0
				,@intSampleTypeId = NULL
				,@intControlPointId = NULL
				,@intSampleLabelId = NULL
				,@intApprovalLotStatusId = NULL
				,@intRejectionLotStatusId = NULL
				,@intBondedApprovalLotStatusId = NULL
				,@intBondedRejectionLotStatusId = NULL
				,@intAttributeId = NULL

			SELECT @strSampleTypeName = strSampleTypeName
				,@strDescription = strDescription
				,@strControlPointName = strControlPointName
				,@ysnFinalApproval = ysnFinalApproval
				,@strApprovalBase = strApprovalBase
				,@strSampleLabelName = strSampleLabelName
				,@ysnAdjustInventoryQtyBySampleQty = ysnAdjustInventoryQtyBySampleQty
				,@strApprovalLotStatus = strApprovalLotStatus
				,@strRejectionLotStatus = strRejectionLotStatus
				,@strBondedApprovalLotStatus = strBondedApprovalLotStatus
				,@strBondedRejectionLotStatus = strBondedRejectionLotStatus
				,@strAttributeName = strAttributeName
				,@ysnIsMandatory = ysnIsMandatory
			FROM tblQMSampleTypeImport
			WHERE intImportId = @intRowId

			IF ISNULL(@strSampleTypeName, '') = ''
			BEGIN
				RAISERROR (
						'Sample Type Name cannot be empty. '
						,16
						,1
						)
			END

			IF ISNULL(@strDescription, '') = ''
			BEGIN
				RAISERROR (
						'Description cannot be empty. '
						,16
						,1
						)
			END

			IF ISNULL(@strControlPointName, '') = ''
			BEGIN
				RAISERROR (
						'Control Point cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intControlPointId = intControlPointId
				FROM tblQMControlPoint
				WHERE strControlPointName = @strControlPointName

				IF ISNULL(@intControlPointId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Control Point. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strApprovalBase, '') <> ''
			BEGIN
				IF NOT EXISTS (
						SELECT *
						FROM dbo.fnSplitString('Container,Lot,Parent Lot,Item & Parent Lot,Warehouse Ref No,Warehouse Ref No & Parent Lot,Work Order', ',')
						WHERE LOWER(Item) = LOWER(@strApprovalBase)
						)
				BEGIN
					RAISERROR (
							'Invalid Approval Base. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strSampleLabelName, '') <> ''
			BEGIN
				SELECT @intSampleLabelId = intSampleLabelId
				FROM tblQMSampleLabel
				WHERE strSampleLabelName = @strSampleLabelName

				IF ISNULL(@intSampleLabelId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Sample Label. '
							,16
							,1
							)
				END

				IF @intControlPointId = 1 -- Offer Sample
				BEGIN
					IF (@strSampleLabelName <> 'Offer Sample Label')
					BEGIN
						RAISERROR (
								'Sample Label should be Offer Sample Label. '
								,16
								,1
								)
					END
				END
				ELSE IF @intControlPointId = 2 -- Approval Sample
				BEGIN
					IF (@strSampleLabelName <> 'Approval Sample Label')
					BEGIN
						RAISERROR (
								'Sample Label should be Approval Sample Label. '
								,16
								,1
								)
					END
				END
				ELSE IF @intControlPointId = 5 -- Inbound Sample
				BEGIN
					IF (
							@strSampleLabelName <> 'Inbound Sample Label'
							AND @strSampleLabelName <> 'Pre-Shipment Sample Label'
							)
					BEGIN
						RAISERROR (
								'Sample Label should be Inbound Sample Label / Pre-Shipment Sample Label. '
								,16
								,1
								)
					END
				END
				ELSE IF @intControlPointId = 9 -- Receipt Sample
				BEGIN
					IF (@strSampleLabelName <> 'Receipt Sample Label')
					BEGIN
						RAISERROR (
								'Sample Label should be Receipt Sample Label. '
								,16
								,1
								)
					END
				END
				ELSE IF @intControlPointId = 10 -- Outbound Sample
				BEGIN
					IF (@strSampleLabelName <> 'Outbound Sample Label')
					BEGIN
						RAISERROR (
								'Sample Label should be Outbound Sample Label. '
								,16
								,1
								)
					END
				END
				ELSE
				BEGIN
					RAISERROR (
							'Invalid Sample Label. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strApprovalLotStatus, '') <> ''
			BEGIN
				SELECT @intApprovalLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strApprovalLotStatus

				IF ISNULL(@intApprovalLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Approval Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strRejectionLotStatus, '') <> ''
			BEGIN
				SELECT @intRejectionLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strRejectionLotStatus

				IF ISNULL(@intRejectionLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Rejection Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strBondedApprovalLotStatus, '') <> ''
			BEGIN
				SELECT @intBondedApprovalLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strBondedApprovalLotStatus

				IF ISNULL(@intBondedApprovalLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Bonded Approval Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strBondedRejectionLotStatus, '') <> ''
			BEGIN
				SELECT @intBondedRejectionLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strBondedRejectionLotStatus

				IF ISNULL(@intBondedRejectionLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Bonded Rejection Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strAttributeName, '') <> ''
			BEGIN
				SELECT @intAttributeId = intAttributeId
				FROM tblQMAttribute
				WHERE strAttributeName = @strAttributeName

				IF ISNULL(@intAttributeId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Attribute Name. '
							,16
							,1
							)
				END
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblQMSampleType
					WHERE strSampleTypeName = @strSampleTypeName
					)
			BEGIN
				INSERT INTO tblQMSampleType (
					[intConcurrencyId]
					,[strSampleTypeName]
					,[strDescription]
					,[intControlPointId]
					,[ysnFinalApproval]
					,[strApprovalBase]
					,[intSampleLabelId]
					,[ysnAdjustInventoryQtyBySampleQty]
					,[intApprovalLotStatusId]
					,[intRejectionLotStatusId]
					,[intBondedApprovalLotStatusId]
					,[intBondedRejectionLotStatusId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,@strSampleTypeName
					,@strDescription
					,@intControlPointId
					,@ysnFinalApproval
					,@strApprovalBase
					,@intSampleLabelId
					,@ysnAdjustInventoryQtyBySampleQty
					,@intApprovalLotStatusId
					,@intRejectionLotStatusId
					,@intBondedApprovalLotStatusId
					,@intBondedRejectionLotStatusId
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()

				SELECT @intSampleTypeId = SCOPE_IDENTITY()

				IF ISNULL(@intAttributeId, 0) > 0
				BEGIN
					INSERT INTO tblQMSampleTypeDetail (
						[intSampleTypeId]
						,[intAttributeId]
						,[intConcurrencyId]
						,[ysnIsMandatory]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT @intSampleTypeId
						,@intAttributeId
						,1
						,@ysnIsMandatory
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()
				END
			END
			ELSE IF ISNULL(@intAttributeId, 0) > 0
			BEGIN
				SELECT @intSampleTypeId = intSampleTypeId
				FROM tblQMSampleType
				WHERE strSampleTypeName = @strSampleTypeName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMSampleTypeDetail
						WHERE intSampleTypeId = @intSampleTypeId
							AND intAttributeId = @intAttributeId
						)
				BEGIN
					INSERT INTO tblQMSampleTypeDetail (
						[intSampleTypeId]
						,[intAttributeId]
						,[intConcurrencyId]
						,[ysnIsMandatory]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT @intSampleTypeId
						,@intAttributeId
						,1
						,@ysnIsMandatory
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()
				END
			END
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ' ' + ERROR_MESSAGE()

			UPDATE tblQMSampleTypeImport
			SET strErrorMsg = @ErrMsg
			WHERE intImportId = @intRowId
		END CATCH

		UPDATE tblQMSampleTypeImport
		SET ysnProcessed = 1
		WHERE intImportId = @intRowId

		SELECT @intRowId = MIN(intImportId)
		FROM tblQMSampleTypeImport
		WHERE intImportId > @intRowId
			AND ISNULL(ysnProcessed, 0) = 0
	END

	SELECT 'Error'
		,*
	FROM tblQMSampleTypeImport
	WHERE ISNULL(ysnProcessed, 0) = 1
		AND ISNULL(strErrorMsg, '') <> ''
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
