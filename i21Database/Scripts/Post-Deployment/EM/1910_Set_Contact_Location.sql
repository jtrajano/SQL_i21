GO
	PRINT ('*****Begin Set Default Location*****')

	UPDATE a SET a.intEntityLocationId = b.intEntityLocationId
	FROM tblEMEntityToContact a
	INNER JOIN tblEMEntityLocation b ON a.intEntityId = b.intEntityId AND b.ysnDefaultLocation = 1
	WHERE a.intEntityLocationId IS NULL

	PRINT ('*****End Set Default Location*****')
GO