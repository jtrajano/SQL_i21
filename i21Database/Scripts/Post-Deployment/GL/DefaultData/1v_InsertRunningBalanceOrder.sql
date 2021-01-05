
/*
Post-Deployment Script
--------------------------------------------------------------------------------------
tblGLRunningBalanceOrder - This table is used for running balance screen in GL Detail				
--------------------------------------------------------------------------------------
*/
GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLRunningBalanceOrder)
        INSERT INTO tblGLRunningBalanceOrder(intGLDetailId,intAccountId,dtmDate,rowId)
        SELECT intGLDetailId,intAccountId,dtmDate, ROW_NUMBER() 
        OVER (PARTITION by intAccountId,dtmDate ORDER BY intGLDetailId)rowId
        FROM tblGLDetail WHERE ysnIsUnposted = 0 
GO
  