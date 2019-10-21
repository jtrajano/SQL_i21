CREATE PROCEDURE uspMFGetDemandError
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	SELECT intDemandImportErrorId
		,intDemandImportId
		,intConcurrencyId
		,strDemandName
		,strBook
		,strSubBook
		,strItemNo
		,strSubstituteItemNo
		,dtmDemandDate
		,dblQuantity
		,strUnitMeasure
		,strLocationName
		,intCreatedUserId
		,dtmCreated
		,strErrorMessage
	FROM tblMFDemandImportError
	ORDER BY intDemandImportErrorId
END
