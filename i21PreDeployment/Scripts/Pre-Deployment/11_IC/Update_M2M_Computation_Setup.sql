PRINT 'Updating Item M2M computation..'

-- create m2m maintenance table if not exists
IF(NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblICM2MComputation'))
BEGIN
	CREATE TABLE [dbo].[tblICM2MComputation]
	(
		[intM2MComputationId] INT IDENTITY(1, 1) NOT NULL, 
		[strM2MComputation] VARCHAR(50) NOT NULL,
		[intConcurrencyId] INT NULL DEFAULT 0, 
		CONSTRAINT [PK_tblICM2MComputation] PRIMARY KEY ([intM2MComputationId])
	);
END
INSERT INTO [tblICM2MComputation]([strM2MComputation])
SELECT 'No' WHERE NOT EXISTS(SELECT 1 FROM tblICM2MComputation WHERE strM2MComputation = 'No')
UNION
SELECT 'Add' WHERE NOT EXISTS(SELECT 1 FROM tblICM2MComputation WHERE strM2MComputation = 'Add')
UNION
SELECT 'Reduce' WHERE NOT EXISTS(SELECT 1 FROM tblICM2MComputation WHERE strM2MComputation = 'Reduce')

IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblICItem'))
BEGIN
	IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ysnMTM' AND TABLE_NAME = 'tblICItem'))
	BEGIN
		-- IF intM2MComputationId does not exists, create the column
		IF(NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'intM2MComputationId' AND TABLE_NAME = 'tblICItem'))
		BEGIN
			ALTER TABLE tblICItem ADD intM2MComputationId INT NULL DEFAULT((1)), CONSTRAINT [FK_tblICItem_tblICM2MComputation] FOREIGN KEY ([intM2MComputationId]) REFERENCES [tblICM2MComputation]([intM2MComputationId])
		END

		EXEC('UPDATE tblICItem SET intM2MComputationId = CASE ISNULL(ysnMTM, 0) WHEN 1 THEN 2 ELSE 1 END')
	END
END