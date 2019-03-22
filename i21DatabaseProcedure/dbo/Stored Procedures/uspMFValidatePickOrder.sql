CREATE PROCEDURE uspMFValidatePickOrder (
	@strPickNo NVARCHAR(50)
	,@intUserId INT
	,@intLocationId INT
	)
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblMFOrderHeader
			WHERE strOrderNo = @strPickNo
				AND intLocationId = @intLocationId
			)
	BEGIN
		RAISERROR (
				'INVALID PICK ORDER #.'
				,16
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM tblMFOrderHeader
			WHERE strOrderNo = @strPickNo
				AND intOrderStatusId = 10
				AND intLocationId = @intLocationId
			)
	BEGIN
		RAISERROR (
				'PICK ORDER HAS ALREADY BEEN COMPLETED.'
				,16
				,1
				)

		RETURN
	END

	--IF EXISTS (
	--		SELECT *
	--		FROM tblMFOrderHeader
	--		WHERE strOrderNo = @strPickNo
	--			AND intOrderStatusId <> 6
	--		)
	--BEGIN
	--	RAISERROR (
	--			'PICK ORDER IS NOT STAGED.'
	--			,16
	--			,1
	--			)

	--	RETURN
	--END
END
