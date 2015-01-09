IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intDimensionUOMId' AND object_id = object_id('tblICItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICUnitMeasure'))
	BEGIN
		UPDATE tblICItem
		SET intDimensionUOMId = NULL
		WHERE intDimensionUOMId NOT IN (SELECT intUnitMeasureId FROM tblICUnitMeasure)
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intWeightUOMId' AND object_id = object_id('tblICItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICUnitMeasure'))
	BEGIN
		UPDATE tblICItem
		SET intWeightUOMId = NULL
		WHERE intWeightUOMId NOT IN (SELECT intUnitMeasureId FROM tblICUnitMeasure)
	END
END