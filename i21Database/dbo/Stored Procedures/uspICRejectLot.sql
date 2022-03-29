CREATE PROCEDURE [dbo].[uspICRejectLot]
	@intLotId INT,
	@intEntityId INT
AS
	
IF @intLotId IS NOT NULL 
	AND @intEntityId IS NOT NULL 
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblICLotRejected r WHERE r.intLotId = @intLotId AND intRejectedByEntityId = @intEntityId)
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
				, 2 -- We expect the divider used in COA setup is always one character. 
				, '' 
			)			
	FROM 
		tblICLot lot
	WHERE
		lot.intLotId = @intLotId 
END 