CREATE PROCEDURE [dbo].[uspICRejectLot]
	@intLotId INT,
	@intEntityId INT,
	@ysnAdd AS BIT = 1
AS

-- Exit immediately if the lot id and entity id is invalid. 
IF (@intLotId IS NULL OR @intEntityId IS NULL) RETURN 0
IF NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntity WHERE intEntityId = @intEntityId) RETURN 0; 
	
-- If @ysnAdd = 1, add the entity in the reject list. 
IF @ysnAdd = 1 
BEGIN 
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICLotRejected r WHERE r.intLotId = @intLotId AND intRejectedByEntityId = @intEntityId)
	BEGIN 
		-- Insert names of the vendor or customers that rejected the lot. 
		INSERT INTO tblICLotRejected (
			intLotId
			,intRejectedByEntityId
		)
		SELECT
			@intLotId
			,@intEntityId
		
		-- Update the "rejected" fields in the lot table. 
		UPDATE lot
		SET
			lot.ysnRejected = 1
			,lot.strRejectedBy = 			
				STUFF(
					(	
						SELECT 
							', ' + e.strName
						FROM 
							tblICLotRejected r INNER JOIN tblEMEntity e
								ON r.intRejectedByEntityId = e.intEntityId
						WHERE
							r.intLotId = @intLotId
						ORDER BY 
							e.strName
						FOR XML PATH('')
					)
					, 1
					, 2 
					, '' 
				)			
		FROM 
			tblICLot lot
		WHERE
			lot.intLotId = @intLotId 
	END 
END 
-- If @ysnAdd = 0, remove the entity from the rejected list. 
ELSE IF ISNULL(@ysnAdd, 0) = 0
BEGIN 
	DELETE rejected
	FROM 
		tblICLotRejected rejected
	WHERE
		intLotId = @intLotId
		AND intRejectedByEntityId = @intEntityId

	IF EXISTS (SELECT TOP 1 1 FROM tblICLotRejected WHERE intLotId = @intLotId) 
	BEGIN 
		-- Update the "rejected" fields in the lot table. 
		UPDATE lot
		SET
			lot.ysnRejected = 1
			,lot.strRejectedBy = 			
				STUFF(
					(	
						SELECT 
							', ' + e.strName
						FROM 
							tblICLotRejected r INNER JOIN tblEMEntity e
								ON r.intRejectedByEntityId = e.intEntityId
						WHERE
							r.intLotId = @intLotId
						ORDER BY 
							e.strName
						FOR XML PATH('')
					)
					, 1
					, 2 
					, '' 
				)			
		FROM 
			tblICLot lot
		WHERE
			lot.intLotId = @intLotId 
	END
	ELSE 
	BEGIN 
		-- Update the "rejected" fields in the lot table. 
		UPDATE lot
		SET
			lot.ysnRejected = 0
			,lot.strRejectedBy = NULL 
		FROM 
			tblICLot lot
		WHERE
			lot.intLotId = @intLotId 
	END 
END 