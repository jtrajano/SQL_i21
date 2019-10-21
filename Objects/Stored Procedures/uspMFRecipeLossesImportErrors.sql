CREATE PROCEDURE uspMFRecipeLossesImportErrors
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT intRecipeLossesImportErrorId
	,intRecipeLossesImportId
	,intConcurrencyId
	,strRecipeName
	,strItemNo
	,strComponent
	,dblLoss1
	,dblLoss2
	,strErrorMsg
	,intCreatedUserId
	,dtmCreated
FROM tblMFRecipeLossesImportError
