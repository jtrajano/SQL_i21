IF EXISTS(SELECT 1 FROM tblLGLoad WHERE ISNULL(intShipmentType,0) = 0)
BEGIN
	UPDATE tblLGLoad SET intShipmentType = 1 WHERE ISNULL(intShipmentType,0) = 0
END
GO
IF NOT EXISTS(SELECT 1 FROM tblLGCompanyPreference)
BEGIN
	INSERT INTO tblLGCompanyPreference(intConcurrencyId)
	SELECT 1
END
GO