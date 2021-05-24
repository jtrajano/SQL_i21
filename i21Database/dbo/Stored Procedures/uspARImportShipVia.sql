CREATE PROCEDURE [dbo].[uspARImportShipVia]
	 @Checking	bit = 0,
	@UserId		int = 0,
	@Total		int = 0 OUTPUT,
	@Message	nvarchar(max) = '' OUTPUT
AS
BEGIN
	DECLARE @strDuplicateShipVia NVARCHAR(100) = ''

	SELECT TOP 1 @strDuplicateShipVia = RTRIM(LTRIM(sscar_name COLLATE Latin1_General_CI_AS))
	FROM sscarmst
	INNER JOIN (
		SELECT strShipVia = RTRIM(LTRIM(sscar_name COLLATE Latin1_General_CI_AS))
		FROM sscarmst 
		WHERE RTRIM(LTRIM(sscar_name COLLATE Latin1_General_CI_AS)) IS NOT NULL
		GROUP BY RTRIM(LTRIM(sscar_name COLLATE Latin1_General_CI_AS))
		HAVING COUNT(*) > 1
	) DUPLICATES ON RTRIM(LTRIM(sscar_name COLLATE Latin1_General_CI_AS)) = DUPLICATES.strShipVia
	ORDER BY RTRIM(LTRIM(sscar_name COLLATE Latin1_General_CI_AS))

	IF @strDuplicateShipVia = '' OR @Checking = 1
		EXEC uspSMImportShipVia @Checking = @Checking, @UserId = @UserId, @Total = @Total OUT
	ELSE 
		SET @Message = 'The import has found multiple customers having identical ship names ' + @strDuplicateShipVia + '.  i21 requires each customer to have a unique name.  Please edit the names of the customer(s) listed to ensure that each name is unique and re-import.  Thank you.'
END

RETURN 0