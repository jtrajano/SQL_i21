
IF OBJECT_ID('tblAPBasisAdvanceCommodity') IS NOT NULL
BEGIN
	IF COLUMNPROPERTY(object_id('tblAPBasisAdvanceCommodity'),'intBasisAdvanceCommodityId','IsIdentity') = 0 AND
		EXISTS(SELECT 1
			FROM sys.key_constraints A
			INNER JOIN sys.tables B ON A.parent_object_id = B.object_id
			where A.name = 'PK__tblAPBas__518F70D27B787164'
			AND B.name = 'tblAPBasisAdvanceCommodity')
	BEGIN
		ALTER TABLE tblAPBasisAdvanceCommodity
		DROP CONSTRAINT PK__tblAPBas__518F70D27B787164

		ALTER TABLE tblAPBasisAdvanceCommodity
		DROP COLUMN intBasisAdvanceCommodityId

		ALTER TABLE tblAPBasisAdvanceCommodity
		ADD [intBasisAdvanceCommodityId] INT IDENTITY(1,1) PRIMARY KEY
	END
END

IF OBJECT_ID('tblAPBasisAdvanceFuture') IS NOT NULL
BEGIN
	IF COLUMNPROPERTY(object_id('tblAPBasisAdvanceFuture'),'intBasisAdvanceFuturesId','IsIdentity') = 0 AND
		EXISTS(SELECT 1
			FROM sys.key_constraints A
			INNER JOIN sys.tables B ON A.parent_object_id = B.object_id
			where A.name = 'PK__tblAPBas__7B40A28B0C33D56F'
			AND B.name = 'tblAPBasisAdvanceFuture')
	BEGIN
		ALTER TABLE tblAPBasisAdvanceFuture
		DROP CONSTRAINT PK__tblAPBas__7B40A28B0C33D56F

		ALTER TABLE tblAPBasisAdvanceFuture
		DROP COLUMN intBasisAdvanceFuturesId

		ALTER TABLE tblAPBasisAdvanceFuture
		ADD intBasisAdvanceFuturesId INT IDENTITY(1,1) PRIMARY KEY
	END
END