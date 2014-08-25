--This script will fix the data from entity schema changes.
--1. Transfer data from tblEntityToContact to tblAPVendorToContact
--2. Update intVendorId from tblAPVendorToContact
--3. Update intContactId from tblAPVendorToContact
--4. Update intDefaultContactId from tblAPVendor
--5. Update intDefaultLocationId from tblAPVendor
--6. Update intVendorId from tblAPBill
--7. Update intVendorId from tblAPPayment


BEGIN TRANSACTION

PRINT 'BEGIN Inserting data to tblAPVendorToContact'
INSERT INTO tblAPVendorToContact(intVendorId, intContactId, intEntityLocationId)
SELECT B.intVendorId, C.intContactId, intLocationId 
	FROM tblEntityToContact A
	INNER JOIN tblAPVendor B
		ON A.intEntityId = B.intEntityId
	INNER JOIN tblEntityContact C
		ON A.intContactId = C.intEntityId
PRINT 'END Inserting data to tblAPVendorToContact'		

PRINT 'BEGIN Updating tblAPVendor default contact and location'		
UPDATE tblAPVendor
SET intDefaultContactId = B.intContactId
FROM tblAPVendor A
INNER JOIN tblEntityContact B
	ON A.intDefaultContactId = B.intEntityId
PRINT 'END Updating tblAPVendor default contact and location'	


PRINT 'BEGIN updating intVendorId from tblAPBill'
UPDATE tblAPBill
SET intVendorId = B.intVendorId
FROM tblAPBill A
	INNER JOIN tblAPVendor B
	ON A.intVendorId = B.intEntityId
PRINT 'END updating intVendorId from tblAPBill'

PRINT 'BEGIN updating intVendorId from tblAPPayment'
UPDATE tblAPPayment
SET intVendorId = B.intVendorId
FROM tblAPPayment A
	INNER JOIN tblAPVendor B
	ON A.intVendorId = B.intEntityId
PRINT 'END updating intVendorId from tblAPPayment'

--Verify the data integrity
DECLARE @invalidVendor INT
SELECT @invalidVendor = COUNT(*)
FROM tblAPVendorToContact A
	WHERE A.intVendorId NOT IN (SELECT intVendorId FROM tblAPVendor)

DECLARE @invalidContact INT
SELECT @invalidContact = COUNT(*)
FROM tblAPVendorToContact A
	WHERE A.intContactId NOT IN (SELECT intContactId FROM tblEntityContact)

DECLARE @invalidDefaultContact INT
SELECT @invalidDefaultContact = COUNT(*)
FROM tblAPVendor A
	WHERE A.intDefaultContactId NOT IN (SELECT intContactId FROM tblEntityContact)

DECLARE @invalidBillVendor INT
SELECT @invalidBillVendor = COUNT(*)
FROM tblAPBill A
	WHERE A.intVendorId NOT IN (SELECT intVendorId FROM tblAPVendor)

DECLARE @invalidPaymentVendor INT
SELECT @invalidPaymentVendor = COUNT(*)
FROM tblAPPayment A
	WHERE A.intVendorId NOT IN (SELECT intVendorId FROM tblAPVendor)

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