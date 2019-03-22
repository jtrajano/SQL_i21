CREATE PROCEDURE [dbo].[uspLGUpdateTMSiteGeocodes]

	@XML		NVARCHAR(MAX),
	@ErrMsg		NVARCHAR(MAX) = NULL OUTPUT
	
AS

BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON 
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT,
			@GPSTable TMGPSUpdateByIdTable

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML
  
	INSERT INTO @GPSTable
		SELECT intSiteId, dblLatitude, dblLongitude 
		FROM OPENXML(@idoc,'TMGeocodes/Geocode', 2)
		WITH (intSiteId INT, dblLatitude NUMERIC(18, 6), dblLongitude NUMERIC(18, 6))
	
	IF EXISTS(select * from @GPSTable)
	BEGIN
		 Exec uspTMUpdateSiteGPSById @GPSTable
	END
    
	EXEC sp_xml_removedocument @idoc
	SET @ErrMsg = 'Success'
	SELECT @ErrMsg

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGUpdateTMSiteGeocodes - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO
