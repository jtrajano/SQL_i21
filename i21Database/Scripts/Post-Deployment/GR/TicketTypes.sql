﻿GO
    PRINT 'BEGIN Checking default value of SCListTicketType'
    SET IDENTITY_INSERT [dbo].[tblSCListTicketTypes] ON
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 1 AND [strInOutIndicator] = 'I')
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (1 , 1 , 'Load In' , 'I' , 1, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 1 AND [strInOutIndicator] = 'O')
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (2 , 1 , 'Load Out' , 'O' , 1, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 2 AND [strInOutIndicator] = 'I')
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (3 , 2 , 'Transfer In' , 'I' , 1, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 2 AND [strInOutIndicator] = 'O')
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (4 , 2 , 'Transfer Out' , 'O' , 1, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 3)
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (5 , 3 , 'Memo/Weigh' , 'I' , 1, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 4)
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (6 , 4 , 'Storage Take Out' , 'I' , 0, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 5)
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (7 , 5 , 'AG Outbound' , 'I' , 0, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 6 AND [strInOutIndicator] = 'I')
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (8 , 6 , 'Direct In' , 'I' , 1, 0)
    END
GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSCListTicketTypes WHERE [intTicketType] = 6 AND [strInOutIndicator] = 'O')
    BEGIN
        INSERT [dbo].[tblSCListTicketTypes] ([intTicketTypeId], [intTicketType], [strTicketType], [strInOutIndicator], [ysnActive], [intConcurrencyId])
        VALUES (9 , 6 , 'Direct Out' , 'O' , 1, 0)
    END
    SET IDENTITY_INSERT [dbo].[tblSCListTicketTypes] OFF
GO
	UPDATE
    Table_A
		SET
			Table_A.intListTicketTypeId = Table_B.intTicketTypeId
		FROM
			tblSCTicketType AS Table_A
		INNER JOIN
			tblSCListTicketTypes AS Table_B
		ON
			Table_A.intTicketType = Table_B.intTicketType
			AND Table_A.strInOutIndicator = Table_B.strInOutIndicator
		WHERE intListTicketTypeId IS NULL
GO