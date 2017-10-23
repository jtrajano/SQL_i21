GO
print('/*******************  START UPDATING CALENDAR  *******************/')

IF EXISTS (SELECT TOP 1 1 FROM [dbo].[tblSMCalendars] WHERE strCalendarName = 'Time Off' and strCalendarType = 'System')
	BEGIN
		UPDATE [dbo].[tblSMCalendars]
		SET 
			intEntityId		= 1,
			strDescription	= 'Calendar for Time Off',
			ysnReadOnly		= 1,
			ysnShowEvents	= 1,
			dtmCreated		= GETDATE(),
			dtmModified		= GETDATE()
		WHERE strCalendarName = 'Time Off' and strCalendarType = 'System'
	END	  
ELSE --NEW DATABASE, ADD DEFAULT
	BEGIN
		INSERT INTO [dbo].[tblSMCalendars] 
				([intEntityId], [strCalendarName], [strDescription], [strCalendarType], [ysnReadOnly], [ysnShowEvents], [intConcurrencyId], [dtmCreated], [dtmModified]) 
				VALUES(1, 'Time Off', 'Calendar for Time Off', 'System', 1, 1, 1, GETDATE(), GETDATE())
	END

print('/*******************  END UPDATING HOME PANELS  *******************/')