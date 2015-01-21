IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intDimensionUOMId' AND object_id = object_id('tblICItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICUnitMeasure'))
	BEGIN
		EXEC('UPDATE tblICItem
			SET intDimensionUOMId = NULL
			WHERE intDimensionUOMId NOT IN (SELECT intUnitMeasureId FROM tblICUnitMeasure)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intWeightUOMId' AND object_id = object_id('tblICItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICUnitMeasure'))
	BEGIN
		EXEC('UPDATE tblICItem
		SET intWeightUOMId = NULL
		WHERE intWeightUOMId NOT IN (SELECT intUnitMeasureId FROM tblICUnitMeasure)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICItemPricingLevel'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intItemUOMId' AND object_id = object_id('tblICItemUOM'))
	BEGIN
		EXEC('UPDATE tblICItemPricingLevel
		SET intUnitMeasureId = NULL
		WHERE intUnitMeasureId NOT IN (SELECT intItemUOMId FROM tblICItemUOM)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICItemSpecialPricing'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intItemUOMId' AND object_id = object_id('tblICItemUOM'))
	BEGIN
		EXEC('UPDATE tblICItemSpecialPricing
		SET intUnitMeasureId = NULL
		WHERE intUnitMeasureId NOT IN (SELECT intItemUOMId FROM tblICItemUOM)')
	END
END