--THIS WILL UPDATE THE tblAPBillDetail.ysnOverrideTaxGroup
IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'ysnOverrideTaxGroup' AND [object_id] = OBJECT_ID(N'tblAPBillDetail'))
BEGIN
	EXEC('
		IF (EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail A WHERE A.ysnOverrideTaxGroup IS NULL))
		BEGIN
			UPDATE A
				SET A.ysnOverrideTaxGroup = 0
				FROM tblAPBillDetail A
				WHERE A.ysnOverrideTaxGroup IS NULL
		END
	')
END