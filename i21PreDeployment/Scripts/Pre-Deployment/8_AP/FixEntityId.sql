--set to null the intEntityID so that migrate transaction user will work
--BillBatch 

PRINT 'BEGIN Fixing intEntityId'
DECLARE @hasEntityIdToFixed BIT = 0;


--Make sure column already exists
IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'intEntityId' AND [object_id] = OBJECT_ID(N'tblAPBill'))
BEGIN
	IF EXISTS(SELECT 1 FROM tblAPBillBatch WHERE ISNULL(intEntityId,0) = 0)
	BEGIN

		ALTER TABLE dbo.tblAPBillBatch ALTER COLUMN [intEntityId] INT NULL

		UPDATE A
			SET A.intEntityId = CASE WHEN intUserId = 0 THEN (SELECT intEntityId FROM tblSMUserSecurity WHERE LOWER(strUserName) = 'jeb') ELSE NULL END
		FROM tblAPBillBatch A
		WHERE ISNULL(intEntityId,0) = 0

		SET @hasEntityIdToFixed = 1

	END

	IF EXISTS(SELECT 1 FROM tblAPBill WHERE ISNULL(intEntityId,0) = 0)
	BEGIN

		ALTER TABLE dbo.tblAPBill ALTER COLUMN [intEntityId] INT NULL

		UPDATE A
			SET A.intEntityId = CASE WHEN intUserId = 0 THEN (SELECT intEntityId FROM tblSMUserSecurity WHERE LOWER(strUserName) = 'jeb') ELSE NULL END
		FROM tblAPBill A
		WHERE ISNULL(intEntityId,0) = 0

		SET @hasEntityIdToFixed = 1

	END

	IF EXISTS(SELECT 1 FROM tblAPPayment WHERE ISNULL(intEntityId,0) = 0)
	BEGIN

		ALTER TABLE dbo.tblAPPayment ALTER COLUMN [intEntityId] INT NULL

		--default to jill user if intUser = 0 and no intEntityId
		UPDATE A
			SET A.intEntityId = CASE WHEN intUserId = 0 THEN (SELECT intEntityId FROM tblSMUserSecurity WHERE LOWER(strUserName) = 'jeb') ELSE NULL END
		FROM tblAPPayment A
		WHERE ISNULL(intEntityId,0) = 0

		SET @hasEntityIdToFixed = 1

	END

	IF(@hasEntityIdToFixed = 1)
	BEGIN

		EXEC uspSMMigrateTransactionUser 'AP'

		ALTER TABLE dbo.tblAPPayment ALTER COLUMN [intEntityId] INTEGER NOT NULL
		ALTER TABLE dbo.tblAPBill ALTER COLUMN [intEntityId] INTEGER NOT NULL
		ALTER TABLE dbo.tblAPBillBatch ALTER COLUMN [intEntityId] INTEGER NOT NULL

		--PRINT 'BEGIN Adding Constraint'
		--ALTER TABLE dbo.tblAPPayment
		--ADD CONSTRAINT [FK_dbo.tblAPPayment_dbo.tblEntity_intEntityId] FOREIGN KEY (intEntityId)
		--REFERENCES tblEntity(intEntityId)
	
		--ALTER TABLE dbo.tblAPBill
		--ADD CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEntity_intEntityId] FOREIGN KEY (intEntityId)
		--REFERENCES tblEntity(intEntityId)

		--ALTER TABLE dbo.tblAPBillBatch
		--ADD CONSTRAINT [FK_dbo.tblAPBillBatch_dbo.tblEntity_intEntityId] FOREIGN KEY (intEntityId)
		--REFERENCES tblEntity(intEntityId)
		--PRINT 'END Adding Constraint'

	END
END
PRINT 'END Fixing intEntityId'