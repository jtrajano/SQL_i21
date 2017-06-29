CREATE TABLE [dbo].[tblSCDeliverySheet]
(
	[intDeliverySheetId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intEntityId] INT NULL, 
    [intLocationId] INT NULL, 
    [dtmDeliverySheetDate] DATETIME NULL, 
    [strDeliverySheetNumber] INT NULL,

)
