--CREATE PROCEDURE [dbo].[uspMFTrialBlendSheet] 
--(
--	@intWorkOrderId			INT
--  , @intWorkOrderInputLotId INT
--  , @ysnKeep				NVARCHAR(10) = NULL
--  , @type					NVARCHAR(50) = NULL
--  , @UserId					INT = NULL
--  , @dblTBSQuantity			NUMERIC(18, 6) = 0
--)
--AS

--	Declare @ysnTBSReserveOnSave BIT
--	SELECT TOP 1 @ysnTBSReserveOnSave = IsNULL(ysnTBSReserveOnSave, 0)
--	FROM tblMFCompanyPreference
--IF @dblTBSQuantity=0
--BEGIN
--	SELECT @dblTBSQuantity=dblQuantity  FROM tblMFWorkOrderInputLot WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId
--END

--/* Confirm Transaction. */
--IF @type = 'Confirm'
--	BEGIN
--		IF EXISTS (SELECT * FROM tblMFWorkOrderInputLot WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId AND ISNULL(ysnTBSReserved, 0) = 0)
--			BEGIN
--				EXEC [dbo].[uspMFUpdateTrialBlendSheetReservation] @intWorkOrderId
--																 , @intWorkOrderInputLotId
--			END

--		IF @ysnKeep IS NOT NULL
--			BEGIN
--				UPDATE tblMFWorkOrderInputLot
--				SET ysnKeep = CASE WHEN @ysnKeep = 'true' THEN 1
--								   ELSE 0
--							  END
--				WHERE intWorkOrderId = @intWorkOrderId AND intWorkOrderInputLotId = @intWorkOrderInputLotId;
--			END

--		IF @dblTBSQuantity <> 0
--			BEGIN
--				UPDATE tblMFWorkOrderInputLot
--				SET dblTBSQuantity = @dblTBSQuantity
--				  , ysnTBSReserved = 1
--				WHERE intWorkOrderId = @intWorkOrderId AND intWorkOrderInputLotId = @intWorkOrderInputLotId;
--			END

--		UPDATE tblMFWorkOrder
--		SET intTrialBlendSheetStatusId	= 15
--		  , intConfirmedBy				= @UserId
--		  , dtmConfirmedDate			= GETDATE()
--		WHERE intWorkOrderId = @intWorkOrderId
--	END
--/* End of Confirm Transaction. */

--/* Delete Transaction. */
--IF @type = 'Delete'
--	BEGIN
--		IF @ysnTBSReserveOnSave = 0
--		BEGIN
--			UPDATE tblMFWorkOrderInputLot
--			SET ysnKeep			= 0
--			  , ysnTBSReserved	= 0
--			WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

--			EXEC [dbo].[uspMFDeleteTrialBlendSheetReservation] @intWorkOrderId
--														 , @intWorkOrderInputLotId
--		END

--		/* JIRA: MFG-4739 */
--		UPDATE tblMFWorkOrder
--		SET intApprovedBy				= NULL
--		  , dtmLastModified				= GETDATE()
--		  , intLastModifiedUserId		= @UserId
--		  , dtmApprovedDate				= NULL
--		  , intTrialBlendSheetStatusId	= NULL
--		WHERE intWorkOrderId = @intWorkOrderId


--	END
--/* End of Delete Transaction. */

--/* Approve Transaction. */
--IF @type = 'Approve'
--	BEGIN
--		UPDATE tblMFWorkOrder
--		SET intTrialBlendSheetStatusId	= 17
--		  , intApprovedBy				= @UserId
--		  , dtmApprovedDate				= GETDATE()
--		WHERE intWorkOrderId = @intWorkOrderId
--	END
--END
--/* End of Approve Transaction. */
