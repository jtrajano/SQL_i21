CREATE PROCEDURE [dbo].[uspSCUpdateDeliverySheetStatus]
    @dsId INT,
	@status INT = NULL
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	CREATE TABLE #tmpSC(intTicketId INT)

	IF @status IS NOT NULL
	BEGIN
		UPDATE A SET A.ysnPost = 
		(CASE	
			WHEN ISNULL(@status, 0) = 0
				THEN 1 --Post
			WHEN @status = 1
				THEN 0 --Unpost
		END)
		FROM tblSCDeliverySheet A
		WHERE A.intDeliverySheetId = @dsId

		UPDATE tblSCTicket SET ysnDeliverySheetPost = 
		(CASE	
			WHEN ISNULL(@status, 0) = 0
				THEN 1 --Post
			WHEN @status = 1
				THEN 0 --Unpost
		END) 
		WHERE intDeliverySheetId = @dsId
		AND strTicketStatus = 'C'
	END
	ELSE
	BEGIN
		IF @dsId > 0
		BEGIN
			INSERT INTO #tmpSC
			SELECT 
				A.intDeliverySheetId 
			FROM tblSCDeliverySheet A
			WHERE intDeliverySheetId = @dsId
		END
		ELSE
		BEGIN
			INSERT INTO #tmpSC
			SELECT 
				A.intDeliverySheetId 
			FROM tblSCDeliverySheet A
		END

		UPDATE B
		SET B.ysnPost = (CASE	
							WHEN ISNULL(@status, 0) = 0
								THEN 1 --Post
							WHEN @status = 1
								THEN 0 --Unpost
						END)
		FROM #tmpSC A
			INNER JOIN tblSCDeliverySheet B
				ON A.intDeliverySheetId = B.intDeliverySheetId
	END
END
