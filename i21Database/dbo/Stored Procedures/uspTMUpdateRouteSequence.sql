CREATE PROCEDURE uspTMUpdateRouteSequence 
	@intDispatchId AS INT
	,@intDriverId AS INT = NULL
	,@intRoutingId AS INT = NULL
	,@dblLatitude AS NUMERIC(18,6) = NULL
	,@dblLongitude AS NUMERIC(18,6) = NULL
AS
BEGIN

	DECLARE @ysnUpdated BIT 
	DECLARE @intSiteId INT

	SELECT TOP 1 @intSiteId = intSiteID FROM tblTMDispatch WHERE intDispatchID = @intDispatchId

	SET @ysnUpdated = 0

	IF(ISNULL(@intDriverId,0) <> 0)
	BEGIN
		UPDATE tblTMDispatch
		SET intDriverID = @intDriverId
		WHERE intDispatchID = @intDispatchId
	END


	IF(ISNULL(@intRoutingId,0) <> 0)
	BEGIN
		UPDATE tblTMDispatch
		SET intRouteId = @intRoutingId
		WHERE intDispatchID = @intDispatchId
	END

	
	IF(@dblLatitude IS NOT NULL)
	BEGIN
		UPDATE tblTMSite
		SET dblLatitude = @dblLatitude
		WHERE intSiteID = @intSiteId
		SET @ysnUpdated = 1
	END

	IF(@dblLongitude IS NOT NULL)
	BEGIN
		UPDATE tblTMSite
		SET dblLongitude = @dblLongitude
		WHERE intSiteID = @intSiteId
		SET @ysnUpdated = 1
	END

	IF(@ysnUpdated = 1)
	BEGIN
		UPDATE tblTMSite
		SET intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
		WHERE intSiteID = @intSiteId
	END

	UPDATE tblTMDispatch
	SET intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
		,strWillCallStatus = 'Routed'
	WHERE intDispatchID = @intDispatchId

	
END

