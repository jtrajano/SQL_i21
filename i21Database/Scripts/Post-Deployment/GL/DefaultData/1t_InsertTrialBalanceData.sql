﻿GO

GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM  tblGLTrialBalance )
    BEGIN
        PRINT ('Started Recalculating Trial Balance')
        EXEC dbo.uspGLRecalcTrialBalance
        PRINT ('Finished Recalculating Trial Balance')
    END
GO

GO