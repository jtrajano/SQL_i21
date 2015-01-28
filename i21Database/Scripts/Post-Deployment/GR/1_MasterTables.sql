--tblGRDiscountCalculationOption
GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDisplayField = 'Net Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 1,'Net Weight',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDisplayField = 'Wet Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 2,'Wet Weight',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDisplayField = 'Gross Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 3,'Gross Weight',1	
END
GO

--tblGRShrinkCalculationOption
GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Net Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 1,'Net Weight',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Wet Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 2,'Wet Weight',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Price Shrink')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 3,'Price Shrink',1	
END
GO