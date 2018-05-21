--UPDATE SHIP FROM ENTITY
UPDATE A
	SET A.intShipFromEntityId = A.intEntityVendorId
FROM tblAPBill A
WHERE ISNULL(A.intShipFromEntityId,0) = 0