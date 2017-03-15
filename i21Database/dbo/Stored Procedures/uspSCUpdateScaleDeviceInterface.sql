CREATE PROCEDURE [dbo].[uspSCUpdateScaleDeviceInterface]
       @intScaleDeviceId INT,
	   @strDeviceData NVARCHAR(256),
	   @ReturnValue INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intDeviceInterfaceFileId AS INT

BEGIN
       SELECT @intDeviceInterfaceFileId = SD.intDeviceInterfaceFileId from tblSCDeviceInterfaceFile SD
       WHERE intScaleDeviceId = @intScaleDeviceId
       IF @intDeviceInterfaceFileId IS NULL
       BEGIN
              INSERT INTO tblSCDeviceInterfaceFile (intScaleDeviceId, strDeviceData, intConcurrencyId, dtmScaleTime) 
              VALUES (@intScaleDeviceId, @strDeviceData, 1, GETDATE())

			  SET @ReturnValue = SCOPE_IDENTITY()
       END
       ELSE
       BEGIN
              UPDATE tblSCDeviceInterfaceFile SET strDeviceData = @strDeviceData , dtmScaleTime = GETDATE()
              WHERE intDeviceInterfaceFileId = @intDeviceInterfaceFileId

			  SET @ReturnValue = @intDeviceInterfaceFileId
       END
END
GO
