﻿CREATE PROCEDURE [dbo].[uspSMResetOriginMenus]
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

DELETE FROM tblSMMasterMenu WHERE ysnIsLegacy = 1

END