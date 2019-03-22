CREATE PROCEDURE [dbo].[uspMBDuplicateConsignmentRate]
	@ConsignmentRateId INT,
	@NewConsignmentRateId INT OUTPUT
AS
BEGIN

	---------------------------------------------
	-- Duplicate Consignment Rate Header table --
	---------------------------------------------
	INSERT INTO tblMBConsignmentRate(intConsignmentGroupId
		, dtmEffectiveDate)
	SELECT intConsignmentGroupId
		, GETDATE()
	FROM tblMBConsignmentRate
	WHERE intConsignmentRateId = @ConsignmentRateId
	------------------------------------------------------
	-- End duplication of Consignment Rate Header table --
	------------------------------------------------------

	SET @NewConsignmentRateId = SCOPE_IDENTITY()
	
	---------------------------------------------
	-- Duplicate Consignment Rate Detail table --
	---------------------------------------------
	INSERT INTO tblMBConsignmentRateDetail(intConsignmentRateId
		, intItemId
		, dblBasePumpPrice
		, dblBaseRate
		, dblIntervalPumpPrice
		, dblIntervalRate
		, dblConsignmentFloor
		, intSort)
	SELECT @NewConsignmentRateId
		, intItemId
		, dblBasePumpPrice
		, dblBaseRate
		, dblIntervalPumpPrice
		, dblIntervalRate
		, dblConsignmentFloor
		, intSort
	FROM tblMBConsignmentRateDetail
	WHERE intConsignmentRateId = @ConsignmentRateId
	------------------------------------------------------
	-- End duplication of Consignment Rate Detail table --
	------------------------------------------------------

	select @NewConsignmentRateId;

END
GO