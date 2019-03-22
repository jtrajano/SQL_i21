IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'intItemUOMId'
          AND Object_ID = Object_ID(N'dbo.tblVRProgramItem'))
BEGIN

	EXEC ('
	UPDATE tblVRProgramItem 
	SET intUnitMeasureId = A.intUnitMeasureId
	FROM tblICItemUOM A
	WHERE A.intItemUOMId = tblVRProgramItem.intItemUOMId
		AND tblVRProgramItem.intItemUOMId IS NOT NULL

	ALTER TABLE tblVRProgramItem DROP COLUMN intItemUOMId
	')

END