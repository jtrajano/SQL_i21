
CREATE FUNCTION [dbo].[fnCTGetQualityResultAmount]
(
		 @dblActualValue NUMERIC(18, 6),
		 @dblMinValue NUMERIC(18, 6),
		 @dblMaxValue NUMERIC(18, 6),
		 @dblTargetValue NUMERIC(18, 6),
		 @dblFactorUnderTarget NUMERIC(18, 6),
		 @dblFactorOverTarget NUMERIC(18,6),
		 @dblDiscount NUMERIC(18,6),
		 @dblPremium NUMERIC(18,6),
		 @strEscalatedBy nvarchar(20),
		 @dblBasis NUMERIC(18,6),
		 @intComputationType INT,
		 @intQualityId INT,
		 @dblFXRate numeric(18,6)
)
RETURNS @returntable	TABLE
(
	dblResult NUMERIC(18,6),
	dblAmount NUMERIC(18,6) 
)
AS
BEGIN
	
	--@intComputationType
	--1 = PERCENTAGE
	--2 = Same Currency and UOM
	--3 = Same Currency , Differenct UOM
	--4 = Different Currency , Same UOM
	--5 = Differenct Currency, Different UOM

	Declare @dblResult Numeric(18,6) 
	Declare @dblAmount Numeric(18,6)
	Declare @dblConversionFactor Numeric(18,6)

	SET @dblResult = CASE WHEN @dblActualValue between @dblMinValue and @dblMaxValue THEN
						((@dblActualValue - @dblTargetValue) / (CASE WHEN @dblActualValue < @dblTargetValue THEN @dblFactorUnderTarget ELSE @dblFactorOverTarget END)) *
						CASE WHEN @dblActualValue < @dblTargetValue THEN @dblDiscount ELSE @dblPremium END
					ELSE NULL END
	if (@strEscalatedBy = 'Exact Factor')
	BEGIN 
		SET @dblResult = @dblResult - (@dblResult % CASE WHEN @dblActualValue < @dblTargetValue THEN @dblDiscount ELSE @dblPremium END)
	END

	SELECT @dblConversionFactor = ICF.dblUnitQty / ICT.dblUnitQty 
	FROM tblCTContractQuality CQ
	INNER JOIN tblICItemUOM ICF on CQ.intUnitMeasureId = ICF.intUnitMeasureId and CQ.intItemId = ICF.intItemId
	INNER JOIN tblICItemUOM ICT on CQ.intSequenceUnitMeasureId = ICT.intUnitMeasureId and CQ.intItemId = ICT.intItemId
	WHERE CQ.intQualityId = @intQualityId		

	--1
	IF (@intComputationType = 1)
	BEGIN
		SET @dblAmount = @dblResult * @dblBasis
	END

	IF (@intComputationType = 2)
	BEGIN
		SET @dblAmount = @dblResult
	END

	IF (@intComputationType = 3)
	BEGIN
		SET @dblAmount = @dblResult * @dblConversionFactor
	END

	IF (@intComputationType = 4)
	BEGIN
		SET @dblAmount = @dblResult * @dblFXRate
	END

	IF (@intComputationType = 5)
	BEGIN
		SET @dblAmount = @dblResult * @dblFXRate * @dblConversionFactor
	END

	INSERT INTO @returntable(dblResult, dblAmount)
	Values (@dblResult, @dblAmount)

	RETURN;
END