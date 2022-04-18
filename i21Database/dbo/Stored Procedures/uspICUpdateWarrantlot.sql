CREATE PROCEDURE [dbo].[uspICUpdateWarrantlot]
  @intLotId INT 
  ,@intUserId INT
  ,@strWarrantStatus NVARCHAR(100) = ''
  ,@strWarrantNo NVARCHAR(100) = ''
AS

BEGIN

    DECLARE @strOldWarrantStatus NVARCHAR(100) = ''
	DECLARE @strOldWarrantNo NVARCHAR(100) = ''
	DECLARE @intWarrantStatus INT


	--GEt  Old data
	SELECT TOP 1
		@strOldWarrantStatus = ISNULL(B.strWarrantStatus,'')
		,@strOldWarrantNo = A.strWarrantNo
	FROM tblICLot A
	LEFT JOIN tblICWarrantStatus B
		ON A.intWarrantStatus  = B.intWarrantStatus
	WHERE intLotId = @intLotId

	--Get Warrant Status Id
	SELECT TOP 1
		@intWarrantStatus = intWarrantStatus
	FROM tblICWarrantStatus
	WHERE strWarrantStatus =  @strWarrantStatus

	--update data
	UPDATE tblICLot
	SET strWarrantNo = @strWarrantNo
		,intWarrantStatus = ISNULL(@intWarrantStatus,intWarrantStatus)
	WHERE intLotId = @intLotId


	--Audit Log for Warrant Status
	IF(ISNULL(@intWarrantStatus,0) > 0 AND @strWarrantStatus <> @strOldWarrantStatus )
	BEGIN
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intLotId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.Warrant'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= 'Warrant Status'		-- Description
			,@fromValue			= @strOldWarrantStatus						-- Old Value
			,@toValue			= @strWarrantStatus			-- New Value
			,@details			= '';
	END

	--Audit Log for Warrant No
	IF(@strWarrantNo <> @strOldWarrantNo)
	BEGIN
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intLotId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.Warrant'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= 'Warrant No'		-- Description
			,@fromValue			= @strOldWarrantNo						-- Old Value
			,@toValue			= @strWarrantNo			-- New Value
			,@details			= '';
	END
	

END