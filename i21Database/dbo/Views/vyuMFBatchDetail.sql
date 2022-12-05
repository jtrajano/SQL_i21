CREATE VIEW vyuMFBatchDetail
AS
SELECT B.*
	,ABS(dblTeaTaste - dblTeaTastePinpoint) AS dblTeaTasteOrderBy
	,ABS(dblTeaHue - dblTeaHuePinpoint) AS dblTeaHueOrderBy
	,ABS(dblTeaIntensity - dblTeaIntensityPinpoint) AS dblTeaIntensityOrderBy
	,ABS(dblTeaMouthFeel - dblTeaMouthFeelPinpoint) AS dblTeaMouthFeelOrderBy
	,ABS(dblTeaAppearance - dblTeaAppearancePinpoint) AS dblTeaAppearanceOrderBy
FROM tblMFBatch B
