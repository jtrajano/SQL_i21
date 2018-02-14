CREATE PROCEDURE [dbo].[uspSMRepInitializationStatus]
  @status INT OUTPUT
  
  AS 
  
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	BEGIN
		SELECT @status = intStatus FROM tblSMRepInitStatus
	END
