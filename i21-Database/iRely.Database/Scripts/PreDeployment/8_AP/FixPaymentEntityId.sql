--THIS WILL UPDATE THE intEntityId of tblAPPayment
IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'intEntityId' AND [object_id] = OBJECT_ID(N'tblAPPayment'))
BEGIN

	EXEC('
		IF (EXISTS(SELECT TOP 1 1 FROM tblAPPayment A WHERE A.intEntityId IS NULL OR A.intEntityId <= 0))
		BEGIN 
			UPDATE A
				SET A.intEntityId = (SELECT TOP 1 intEntityId FROM tblSMUserSecurity)
			FROM tblAPPayment A
			WHERE A.intEntityId IS NULL OR A.intEntityId <= 0	
		END
	')

END