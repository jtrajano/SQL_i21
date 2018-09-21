GO
    PRINT 'BEGIN updating of intUserId in tblGRStorageHistory'
    IF EXISTS(SELECT TOP 1 1 FROM tblGRStorageHistory WHERE intUserId IS NULL AND strUserName IS NOT NULL)
    BEGIN
        UPDATE SH
        SET SH.intUserId = US.intEntityId
        FROM tblGRStorageHistory SH
        LEFT JOIN tblSMUserSecurity US
            ON US.strUserName = SH.strUserName
    END
	PRINT 'END updating of intUserId in tblGRStorageHistory'
GO
	