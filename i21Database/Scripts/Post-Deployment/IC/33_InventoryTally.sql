IF EXISTS (SELECT TOP 1 1 FROM sys.tables WHERE [name] = 'tblICTally')
BEGIN	
	EXEC('IF NOT EXISTS (SELECT TOP 1 1 FROM tblICTally) DROP TABLE tblICTally') 
END 
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.tables WHERE [name] = 'tblICTally')
BEGIN 
	DECLARE @t1 TABLE (number int); 
	DECLARE @t2 TABLE (number int); 

	WITH Tally (n) AS
	(
		-- 100,000 rows
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
		FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) a(n)
		CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n)
		CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(n)
		CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) d(n)
		CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) e(n)
	)
	INSERT INTO @t1
	SELECT 
		t1.n
	FROM 
		Tally t1
	;

	WITH Tally (n) AS
	(
		-- 1,000 rows
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
		FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) a(n)
		CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n)
		CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(n)
	)
	INSERT INTO @t2
	SELECT CAST(NULL AS INT) 
	UNION ALL 
	SELECT 
		t2.n
	FROM 
		Tally t2
	;

	-- Recreate the tally table
	SELECT 
		[intKey] = IDENTITY(INT, 1, 1) 
		,[intId1] = t1.number
		,[intId2] = t2.number
	INTO
		tblICTally 
	FROM
		@t1 t1
		CROSS APPLY @t2 t2 
	ORDER BY 
		t1.number
		,t2.number

	EXEC ('CREATE NONCLUSTERED INDEX [IX_tblICTally_Id] ON [dbo].[tblICTally]([intId1] ASC, [intId2] ASC)')
END 
GO