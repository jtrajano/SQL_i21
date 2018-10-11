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

    PRINT 'BEGIN updating unmatched dtmHistoryDate'
    IF EXISTS ( SELECT TOP 1 1 
                FROM tblSCTicket SC
                INNER JOIN tblGRCustomerStorage GR 
                    ON GR.intTicketId = SC.intTicketId
                INNER JOIN tblGRStorageHistory GRH 
                    ON GRH.intCustomerStorageId = GR.intCustomerStorageId
                WHERE SC.dtmTicketDateTime <> GRH.dtmHistoryDate
                    AND GRH.strSettleTicket IS NULL
            )
        UPDATE GRH
        SET GRH.dtmHistoryDate = ISNULL(SC.dtmTicketDateTime,GRH.dtmHistoryDate)
        FROM tblGRStorageHistory GRH
        INNER JOIN tblGRCustomerStorage GR 
            ON GR.intCustomerStorageId = GRH.intCustomerStorageId
        INNER JOIN tblSCTicket SC
            ON SC.intTicketId = GR.intTicketId
        WHERE SC.dtmTicketDateTime <> GRH.dtmHistoryDate
            AND GRH.strSettleTicket IS NULL
    PRINT 'END updating unmatched dtmHistoryDate'
GO
	