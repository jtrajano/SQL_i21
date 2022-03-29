CREATE PROCEDURE [dbo].[uspICMoveRejectLot]
	@intSourceLotId INT
	,@intTargeLotId INT 
AS
	
IF @intSourceLotId IS NOT NULL 
	AND @intTargeLotId IS NOT NULL 
	AND @intSourceLotId <> @intTargeLotId
BEGIN 
	-- Copy the rejected list from source lot to target lot. 
	INSERT INTO tblICLotRejected (
		intLotId
		,intRejectedByEntityId
	)
	SELECT
		@intTargeLotId
		,sourceLot.intRejectedByEntityId
	FROM
		tblICLotRejected sourceLot 
		OUTER APPLY (
			SELECT TOP 1 
				targetLot.*
			FROM 
				tblICLotRejected targetLot
			WHERE
				targetLot.intLotId = @intTargeLotId
				AND targetLot.intRejectedByEntityId = sourceLot.intRejectedByEntityId
		) targetLot
	WHERE
		sourceLot.intLotId = @intSourceLotId
		AND targetLot.intRejectedByEntityId IS NULL 
		
	-- Update the "rejected" fields in the target lot table. 
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
						r.intLotId = @intTargeLotId
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
		lot.intLotId = @intTargeLotId 
END 