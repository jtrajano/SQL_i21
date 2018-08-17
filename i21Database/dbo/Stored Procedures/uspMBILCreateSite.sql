﻿CREATE PROCEDURE [dbo].[uspMBILCreateSite]
	@UserId INT,
	@SiteId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @Message NVARCHAR(MAX)
		, @DefaultSiteNo NVARCHAR(50)
		, @CountNo INT = 0
		, @SiteNo NVARCHAR(50)

	SELECT TOP 1 @DefaultSiteNo = ISNULL(strDefaultSiteNo, '') FROM tblMBILCompanyPreference

	WHILE EXISTS(SELECT TOP 1 1 FROM tblTMSite WHERE strDescription = @SiteNo)
	BEGIN
		SET @CountNo += 1
		SET @SiteNo = @DefaultSiteNo + CAST(@CountNo AS NVARCHAR(50))
	END

	--INSERT INTO 

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH