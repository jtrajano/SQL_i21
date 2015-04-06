--This script will fix the data from entity schema changes.
--1. Transfer data from tblEntityToContact to tblAPVendorToContact
--2. Update intVendorId from tblAPVendorToContact
--3. Update intContactId from tblAPVendorToContact
--4. Update intDefaultContactId from tblAPVendor
--5. Update intDefaultLocationId from tblAPVendor
--6. Update intVendorId from tblAPBill
--7. Update intVendorId from tblAPPayment

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPTempBillData]'))
BEGIN

	BEGIN TRANSACTION

	PRINT 'BEGIN Inserting data to tblAPVendorToContact'
	INSERT INTO tblAPVendorToContact([intEntityVendorId], [intEntityContactId], intEntityLocationId)
	SELECT B.[intEntityVendorId], C.[intEntityContactId], intLocationId 
		FROM tblEntityToContact A
		INNER JOIN tblAPVendor B
			ON A.intEntityId = B.[intEntityVendorId]
		INNER JOIN tblEntityContact C
			ON A.[intEntityContactId] = C.[intEntityContactId]
	PRINT 'END Inserting data to tblAPVendorToContact'		

	PRINT 'BEGIN Updating tblAPVendor default contact and location'		
	UPDATE tblAPVendor
	SET intDefaultContactId = B.[intEntityContactId]
	FROM tblAPVendor A
	INNER JOIN tblEntityContact B
		ON A.intDefaultContactId = B.[intEntityContactId]
	PRINT 'END Updating tblAPVendor default contact and location'	


	PRINT 'BEGIN updating intVendorId from tblAPBill'
	UPDATE tblAPBill
	SET intVendorId = B.[intEntityVendorId]
	FROM tblAPBill A
		INNER JOIN tblAPVendor B
		ON A.intVendorId = B.[intEntityVendorId]
	PRINT 'END updating intVendorId from tblAPBill'

	PRINT 'BEGIN updating intVendorId from tblAPPayment'
	UPDATE tblAPPayment
	SET intVendorId = B.[intEntityVendorId]
	FROM tblAPPayment A
		INNER JOIN tblAPVendor B
		ON A.intVendorId = B.[intEntityVendorId]
	PRINT 'END updating intVendorId from tblAPPayment'

	--Verify the data integrity
	DECLARE @invalidVendor INT
	SELECT @invalidVendor = COUNT(*)
	FROM tblAPVendorToContact A
		WHERE A.[intEntityVendorId] NOT IN (SELECT [intEntityVendorId] FROM tblAPVendor)

	DECLARE @invalidContact INT
	SELECT @invalidContact = COUNT(*)
	FROM tblAPVendorToContact A
		WHERE A.[intEntityContactId] NOT IN (SELECT [intEntityContactId] FROM tblEntityContact)

	DECLARE @invalidDefaultContact INT
	SELECT @invalidDefaultContact = COUNT(*)
	FROM tblAPVendor A
		WHERE A.intDefaultContactId NOT IN (SELECT [intEntityContactId] FROM tblEntityContact)

	DECLARE @invalidBillVendor INT
	SELECT @invalidBillVendor = COUNT(*)
	FROM tblAPBill A
		WHERE A.intVendorId NOT IN (SELECT [intEntityVendorId] FROM tblAPVendor)

	DECLARE @invalidPaymentVendor INT
	SELECT @invalidPaymentVendor = COUNT(*)
	FROM tblAPPayment A
		WHERE A.intVendorId NOT IN (SELECT [intEntityVendorId] FROM tblAPVendor)

	--Re-enable check constraint
	ALTER TABLE dbo.tblAPPayment
	CHECK CONSTRAINT[FK_tblAPPayment_tblAPVendor];

	ALTER TABLE dbo.tblAPBill
	CHECK CONSTRAINT [FK_tblAPBill_tblAPVendor];

	IF @@ERROR <> 0 
		OR @invalidVendor > 0 
		OR @invalidContact > 0 
		OR @invalidDefaultContact > 0 
		OR @invalidBillVendor > 0
		OR @invalidPaymentVendor > 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN 
		COMMIT TRANSACTION
	END

END