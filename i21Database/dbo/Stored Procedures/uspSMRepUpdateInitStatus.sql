﻿

CREATE  PROCEDURE [dbo].[uspSMRepUpdateInitStatus]
 @initStatus  INT
 AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

 BEGIN
	UPDATE tblSMRepInitStatus SET intStatus = @initStatus
 END

