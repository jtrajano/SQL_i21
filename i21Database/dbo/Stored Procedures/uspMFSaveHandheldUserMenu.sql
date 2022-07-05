CREATE PROCEDURE uspMFSaveHandheldUserMenu 
	  @intUserSecurityId INT
	, @strXML			 NVARCHAR(MAX)
	, @intUserId		 INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @idoc		 INT
	      , @strErrMsg   NVARCHAR(MAX)
		  , @actionType	 NVARCHAR(50)
		  , @fromValue	 NVARCHAR(15)
		  , @toValue	 NVARCHAR(15)
		  , @description NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	BEGIN TRANSACTION

	IF (SELECT TOP 1 1 FROM tblMFHaldheldUserMenuItemMap WHERE intUserSecurityId = @intUserSecurityId) = 1 
		BEGIN
			SET @actionType = 'Updated';
		END
	ELSE
		BEGIN
			SET @actionType = 'Created';

			EXEC	dbo.uspSMAuditLog @keyValue   = @intUserSecurityId -- User ID. 
									, @screenName = 'Manufacturing.view.HandheldAccess'
									, @entityId   = @intUserId
									, @actionType = @actionType
									, @changeDescription = 'Created Record'
								    , @fromValue = ''
									, @toValue = ''	
		END
	
	IF @actionType = 'Updated'
		BEGIN
		    /*======================================================================*/
			/*Audit log for deleted or unchecked handheld menu item access
			 *Fetch @description = strHandHheldMenuItemName eg. View Lot, FG Release and etc.
			*/
			DECLARE delete_cursor CURSOR FOR
			SELECT strHandheldMenuItemName
			FROM tblMFHaldheldUserMenuItemMap A
			LEFT JOIN tblMFHandheldMenuItem B ON A.intHandheldMenuItemId = B.intHandheldMenuItemId
			WHERE A.intUserSecurityId = @intUserSecurityId AND A.intHandheldMenuItemId NOT IN (SELECT C.intHandheldMenuItemId
																							   FROM OPENXML(@idoc, 'root/MenuPermission', 2) WITH (intHandheldMenuItemId INT) AS C)

			OPEN delete_cursor
			FETCH NEXT FROM delete_cursor INTO @description

			WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC	dbo.uspSMAuditLog @keyValue   = @intUserSecurityId -- User ID. 
											, @screenName = 'Manufacturing.view.HandheldAccess'
											, @entityId   = @intUserId
											, @actionType = @actionType
											, @changeDescription = @description
											, @fromValue = 'Checked/True'
											, @toValue = 'Unchecked/False';
					FETCH NEXT FROM delete_cursor INTO @description
				END
   
		    CLOSE delete_cursor
		    DEALLOCATE delete_cursor
			/*======================================================================*/
			/*Audit log for new/update handheld menu item access
			 *Fetch @description = strHandHheldMenuItemName eg. View Lot, FG Release and etc.
			*/
			DECLARE update_cursor CURSOR FOR

			SELECT strHandheldMenuItemName
			FROM OPENXML(@idoc, 'root/MenuPermission', 2) WITH (intHandheldMenuItemId INT) AS A
			LEFT JOIN tblMFHandheldMenuItem B ON A.intHandheldMenuItemId = B.intHandheldMenuItemId
			WHERE A.intHandheldMenuItemId NOT IN (SELECT C.intHandheldMenuItemId
												  FROM tblMFHaldheldUserMenuItemMap AS C
												  WHERE C.intUserSecurityId = @intUserSecurityId)

			OPEN update_cursor
			FETCH NEXT FROM update_cursor INTO @description

			WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC	dbo.uspSMAuditLog @keyValue   = @intUserSecurityId -- User ID. 
											, @screenName = 'Manufacturing.view.HandheldAccess'
											, @entityId   = @intUserId
											, @actionType = @actionType
											, @changeDescription = @description
											, @fromValue = 'Unchecked/False'
											, @toValue = 'Checked/True';
					FETCH NEXT FROM update_cursor INTO @description
				END
   
		    CLOSE update_cursor
		    DEALLOCATE update_cursor
		END
	

	DELETE
	FROM tblMFHaldheldUserMenuItemMap
	WHERE intUserSecurityId = @intUserSecurityId
		AND intHandheldMenuItemId NOT IN (
			SELECT intHandheldMenuItemId
			FROM OPENXML(@idoc, 'root/MenuPermission', 2) WITH (intHandheldMenuItemId INT)
			)

	INSERT INTO tblMFHaldheldUserMenuItemMap (
		intConcurrencyId
		,intUserSecurityId
		,intHandheldMenuItemId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intUserSecurityId
		,intHandheldMenuItemId
		,@intUserId
		,GETDATE()
		,@intUserId
		,GETDATE()
	FROM OPENXML(@idoc, 'root/MenuPermission', 2) WITH (intHandheldMenuItemId INT)
	WHERE intHandheldMenuItemId NOT IN (
			SELECT intHandheldMenuItemId
			FROM tblMFHaldheldUserMenuItemMap
			WHERE intUserSecurityId = @intUserSecurityId
			)

	EXEC sp_xml_removedocument @idoc



	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (@strErrMsg
			 , 16
			 , 1
			 , 'WITH NOWAIT')
END CATCH