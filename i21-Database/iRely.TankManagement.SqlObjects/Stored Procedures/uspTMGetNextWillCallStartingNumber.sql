CREATE PROCEDURE [dbo].[uspTMGetNextWillCallStartingNumber]
	@newStartingNumber AS NVARCHAR(75) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
BEGIN
	DECLARE @intNextNumber INT
	DECLARE @strPrefix NVARCHAR(50)
	DECLARE @intCurrentNumber INT

GETSTART:
	SELECT @intCurrentNumber = intNumber 
		,@strPrefix = strPrefix
	FROM tblSMStartingNumber 
	WHERE strTransactionType = 'Will Call'
		AND strModule = 'Tank Management'

	SET @intNextNumber = @intCurrentNumber + 1

	UPDATE tblSMStartingNumber SET intNumber = @intNextNumber
	WHERE strTransactionType = 'Will Call'
		AND strModule = 'Tank Management'
		
	SET @newStartingNumber = ISNULL(@strPrefix,'') + CAST(@intCurrentNumber AS NVARCHAR(10))

	IF EXISTS(SELECT TOP 1 1 FROM tblTMDispatch WHERE strOrderNumber = @newStartingNumber)
	BEGIN
		GOTO GETSTART
	END
END
	
GO