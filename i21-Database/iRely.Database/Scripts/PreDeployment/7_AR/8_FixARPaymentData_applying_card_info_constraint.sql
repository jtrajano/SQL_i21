
IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intEntityCardInfoId' AND object_id = OBJECT_ID('tblARPayment'))
AND EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intEntityCardInfoId' AND object_id = OBJECT_ID('tblEMEntityCardInformation'))
BEGIN
	EXEC('
		UPDATE tblARPayment SET intEntityCardInfoId = NULL 
			WHERE intEntityCardInfoId IS NOT NULL AND 
				intEntityCardInfoId NOT IN (SELECT intEntityCardInfoId FROM tblEMEntityCardInformation)
	')
	
END

