CREATE PROCEDURE uspMFGetAdditionalBasisError
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	SELECT intAdditionalBasisImportErrorId
		,intAdditionalBasisImportId
		,intConcurrencyId
		,dtmAdditionalBasisDate
		,strComment
		,strItemNo
		,strOtherChargeItemNo
		,dblBasis
		,strCurrency
		,strUnitMeasure
		,intCreatedUserId
		,dtmCreated
		,strErrorMessage
	FROM tblMFAdditionalBasisImportError
	ORDER BY intAdditionalBasisImportErrorId
END

