
GO
/****** Object:  Table [dbo].[tblTMWorkCloseReason]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMWorkCloseReason] ON
INSERT [dbo].[tblTMWorkCloseReason] ([intCloseReasonID], [strCloseReason], [ysnDefault], [intConcurrencyID]) VALUES (1, N'LEAK TEST COMPLETED', 1, NULL)
INSERT [dbo].[tblTMWorkCloseReason] ([intCloseReasonID], [strCloseReason], [ysnDefault], [intConcurrencyID]) VALUES (2, N'CUSTOMER CANCELED', 1, NULL)
INSERT [dbo].[tblTMWorkCloseReason] ([intCloseReasonID], [strCloseReason], [ysnDefault], [intConcurrencyID]) VALUES (3, N'WORK COMPLETED', 1, NULL)
SET IDENTITY_INSERT [dbo].[tblTMWorkCloseReason] OFF
/****** Object:  Table [dbo].[tblTMTankType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMTankType] ON
INSERT [dbo].[tblTMTankType] ([intConcurrencyID], [intTankTypeID], [strTankType]) VALUES (1, 7, N'D')
INSERT [dbo].[tblTMTankType] ([intConcurrencyID], [intTankTypeID], [strTankType]) VALUES (1, 8, N'F')
INSERT [dbo].[tblTMTankType] ([intConcurrencyID], [intTankTypeID], [strTankType]) VALUES (1, 9, N'P')
INSERT [dbo].[tblTMTankType] ([intConcurrencyID], [intTankTypeID], [strTankType]) VALUES (1, 10, N'G')
INSERT [dbo].[tblTMTankType] ([intConcurrencyID], [intTankTypeID], [strTankType]) VALUES (1, 11, N'RF')
INSERT [dbo].[tblTMTankType] ([intConcurrencyID], [intTankTypeID], [strTankType]) VALUES (1, 12, N'SV')
SET IDENTITY_INSERT [dbo].[tblTMTankType] OFF
/****** Object:  Table [dbo].[tblTMTankTownship]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMTankMeasurement]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSyncPurged]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSyncOutOfRange]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSyncFailed]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSiteSeasonResetArchive]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSiteLink]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSiteJulianCalendar]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSiteDeviceLink]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMWorkStatusType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMWorkStatusType] ON
INSERT [dbo].[tblTMWorkStatusType] ([intWorkStatusID], [strWorkStatus], [ysnDefault], [intConcurrencyID]) VALUES (1, N'Open', 1, 0)
INSERT [dbo].[tblTMWorkStatusType] ([intWorkStatusID], [strWorkStatus], [ysnDefault], [intConcurrencyID]) VALUES (2, N'Create Pending', 1, NULL)
INSERT [dbo].[tblTMWorkStatusType] ([intWorkStatusID], [strWorkStatus], [ysnDefault], [intConcurrencyID]) VALUES (3, N'Waiting for Parts', 1, NULL)
INSERT [dbo].[tblTMWorkStatusType] ([intWorkStatusID], [strWorkStatus], [ysnDefault], [intConcurrencyID]) VALUES (4, N'Closed', 1, NULL)
SET IDENTITY_INSERT [dbo].[tblTMWorkStatusType] OFF
/****** Object:  Table [dbo].[tblTMWorkToDoItem]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMWorkToDoItem] ON
INSERT [dbo].[tblTMWorkToDoItem] ([intToDoItemID], [strToDoItem], [ysnDefault], [intConcurrencyID]) VALUES (1, N'PICK UP TANK', 1, NULL)
INSERT [dbo].[tblTMWorkToDoItem] ([intToDoItemID], [strToDoItem], [ysnDefault], [intConcurrencyID]) VALUES (2, N'LEAK CHECK', 1, NULL)
INSERT [dbo].[tblTMWorkToDoItem] ([intToDoItemID], [strToDoItem], [ysnDefault], [intConcurrencyID]) VALUES (3, N'GAS CHECK', 1, NULL)
INSERT [dbo].[tblTMWorkToDoItem] ([intToDoItemID], [strToDoItem], [ysnDefault], [intConcurrencyID]) VALUES (4, N'MARK THE LINE', 1, NULL)
INSERT [dbo].[tblTMWorkToDoItem] ([intToDoItemID], [strToDoItem], [ysnDefault], [intConcurrencyID]) VALUES (5, N'LABOR', 1, NULL)
INSERT [dbo].[tblTMWorkToDoItem] ([intToDoItemID], [strToDoItem], [ysnDefault], [intConcurrencyID]) VALUES (7, N'SET TANK', 1, NULL)
INSERT [dbo].[tblTMWorkToDoItem] ([intToDoItemID], [strToDoItem], [ysnDefault], [intConcurrencyID]) VALUES (8, N'BURY LINE', 1, NULL)
SET IDENTITY_INSERT [dbo].[tblTMWorkToDoItem] OFF
/****** Object:  Table [dbo].[tblTMDDReadingSeasonResetArchive]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMCustomer]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMCOBOLLeaseBilling]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMClock]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMClock] ON
INSERT [dbo].[tblTMClock] ([intConcurrencyID], [intClockID], [strClockNumber], [dtmSummerChangeDate], [dtmWinterChangeDate], [strDeliveryTicketPrinter], [strDeliveryTicketNumber], [strDeliveryTicketFormat], [strReadingEntryMethod], [intBaseTemperature], [dblAccumulatedWinterClose], [dblJanuaryDailyAverage], [dblFebruaryDailyAverage], [dblMarchDailyAverage], [dblAprilDailyAverage], [dblMayDailyAverage], [dblJuneDailyAverage], [dblJulyDailyAverage], [dblAugustDailyAverage], [dblSeptemberDailyAverage], [dblOctoberDailyAverage], [dblNovemberDailyAverage], [dblDecemberDailyAverage], [strAddress], [strZipCode], [strCity], [strCountry], [strCurrentSeason], [strState]) VALUES (NULL, 2, N'C1', CAST(0x000000000083D600 AS DateTime), CAST(0x000000000083D600 AS DateTime), N'', N'', N'', N'Daily', 64, CAST(0.000000 AS Numeric(18, 6)), CAST(50.000000 AS Numeric(18, 6)), CAST(45.000000 AS Numeric(18, 6)), CAST(40.000000 AS Numeric(18, 6)), CAST(40.000000 AS Numeric(18, 6)), CAST(20.000000 AS Numeric(18, 6)), CAST(50.000000 AS Numeric(18, 6)), CAST(35.000000 AS Numeric(18, 6)), CAST(35.000000 AS Numeric(18, 6)), CAST(30.000000 AS Numeric(18, 6)), CAST(15.000000 AS Numeric(18, 6)), CAST(40.000000 AS Numeric(18, 6)), CAST(45.000000 AS Numeric(18, 6)), N'', N'43322', N'Green Camp', N'United States', N'Winter', N'OH')
INSERT [dbo].[tblTMClock] ([intConcurrencyID], [intClockID], [strClockNumber], [dtmSummerChangeDate], [dtmWinterChangeDate], [strDeliveryTicketPrinter], [strDeliveryTicketNumber], [strDeliveryTicketFormat], [strReadingEntryMethod], [intBaseTemperature], [dblAccumulatedWinterClose], [dblJanuaryDailyAverage], [dblFebruaryDailyAverage], [dblMarchDailyAverage], [dblAprilDailyAverage], [dblMayDailyAverage], [dblJuneDailyAverage], [dblJulyDailyAverage], [dblAugustDailyAverage], [dblSeptemberDailyAverage], [dblOctoberDailyAverage], [dblNovemberDailyAverage], [dblDecemberDailyAverage], [strAddress], [strZipCode], [strCity], [strCountry], [strCurrentSeason], [strState]) VALUES (1, 32, N'C2', CAST(0x0000000000000000 AS DateTime), CAST(0x0000000000000000 AS DateTime), N'', N'', N'', N'Daily', 64, CAST(0.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), CAST(10.000000 AS Numeric(18, 6)), N'', N'', N'', N'', N'Summer', N'0')
SET IDENTITY_INSERT [dbo].[tblTMClock] OFF
/****** Object:  Table [dbo].[tblTMApplianceType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMApplianceType] ON
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 19, N'K KILN', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 20, N'J SAUNA', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 21, N'T FIREPLACE', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 22, N'W WATERHEATER', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 23, N'H HOTTUB', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 24, N'E GENERATOR', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (2, 25, N'A/C AIR CONDITIONER-edited', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 26, N'S SPACE HEATER', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 27, N'D CLOTHES DRYER', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 28, N'F FURNACE', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 29, N'P SWIMMING POOL', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 30, N'L GAS LIGHTS', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 31, N'Q GAS REFRIGERATOR', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 32, N'G GAS GRILL', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 33, N'R COOKING RANGE', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 34, N'C CROP DRYER', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (1, 35, N'B  BOILER', 1)
INSERT [dbo].[tblTMApplianceType] ([intConcurrencyID], [intApplianceTypeID], [strApplianceType], [ysnDefault]) VALUES (2, 36, N'I IN-FLOOR HEAT', 1)
SET IDENTITY_INSERT [dbo].[tblTMApplianceType] OFF
/****** Object:  Table [dbo].[tblTMDeployedStatus]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDeliverySchedule]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDeliveryMethod]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDeliveryHistoryDetail]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDeliveryHistory]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDispatch]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDeviceType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMDeviceType] ON
INSERT [dbo].[tblTMDeviceType] ([intConcurrencyID], [intDeviceTypeID], [strDeviceType], [ysnDefault]) VALUES (1, 1, N'Tank', 1)
INSERT [dbo].[tblTMDeviceType] ([intConcurrencyID], [intDeviceTypeID], [strDeviceType], [ysnDefault]) VALUES (1, 2, N'Flow Meter', 1)
INSERT [dbo].[tblTMDeviceType] ([intConcurrencyID], [intDeviceTypeID], [strDeviceType], [ysnDefault]) VALUES (1, 3, N'Regulator', 1)
SET IDENTITY_INSERT [dbo].[tblTMDeviceType] OFF
/****** Object:  Table [dbo].[tblTMJulianCalendarDelivery]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMInventoryStatusType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMInventoryStatusType] ON
INSERT [dbo].[tblTMInventoryStatusType] ([intConcurrencyID], [intInventoryStatusTypeID], [strInventoryStatusType], [ysnDefault]) VALUES (1, 1, N'In', 1)
INSERT [dbo].[tblTMInventoryStatusType] ([intConcurrencyID], [intInventoryStatusTypeID], [strInventoryStatusType], [ysnDefault]) VALUES (1, 2, N'Out', 1)
INSERT [dbo].[tblTMInventoryStatusType] ([intConcurrencyID], [intInventoryStatusTypeID], [strInventoryStatusType], [ysnDefault]) VALUES (1, 3, N'Sold', 1)
INSERT [dbo].[tblTMInventoryStatusType] ([intConcurrencyID], [intInventoryStatusTypeID], [strInventoryStatusType], [ysnDefault]) VALUES (1, 4, N'Not In Service', 1)
SET IDENTITY_INSERT [dbo].[tblTMInventoryStatusType] OFF
/****** Object:  Table [dbo].[tblTMHoldReason]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMHoldReason] ON
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 36, N'05 INACTIVE')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 37, N'23 APPLIANCE INSPECTION NEEDED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 38, N'29 DRIVEWAY NEEDS PLOWING')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 39, N'09 WILL CALL ONE TIME')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 40, N'15 RED TAGGED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 41, N'03 MOVED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 42, N'32 TANK SET W/RUBBER HOSE')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 43, N'26 TANK REPAIR NEEDED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 44, N'12 SELLING PROPERTY')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 45, N'35 FLOOD DAMAGE/NEEDS TESTING')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 46, N'06 VACATION FOR WINTER')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 47, N'21 CODE VIOLATION')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 48, N'27 IF TANK RENT IS DUE, COLLECT')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 49, N'07 BANKRUPTCY')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 50, N'01 COMPETITOR')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 51, N'24 BURY LINE IN SPRING ')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 52, N'18 2ND LEAK TEST')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 53, N'30 SEE TICKLER NOTE B/4 DELIVERY')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 54, N'10 LEAK TEST NEEDED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 55, N'04 DECEASED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 56, N'19 3RD LEAK TEST')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 57, N'25 CO2 SUSPECT CALL')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 58, N'13 HOLD FOR PREBUY')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 59, N'22 GET PAYMENT FIRST')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 60, N'33 5 YEAR LEAK TEST NEEDED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 61, N'16 LATE BUDGET')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 62, N'02 DELIQUENT')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 63, N'17 1ST LEAK TEST')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 64, N'31 TANK NEEDS LEVELING')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 65, N'34 TANK LOCKED')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 66, N'11 NO DELIVERIES FOR SUMMER')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 67, N'20 UNSIGNED LEASE')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 68, N'28 ADD ADDITIONAL COUNTY TAX')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (1, 69, N'14 DENIED PROPANE DELIVERY')
INSERT [dbo].[tblTMHoldReason] ([intConcurrencyID], [intHoldReasonID], [strHoldReason]) VALUES (3, 70, N'08 CALL CREDIT DEPT')
SET IDENTITY_INSERT [dbo].[tblTMHoldReason] OFF
/****** Object:  Table [dbo].[tblTMFillMethod]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMFillMethod] ON
INSERT [dbo].[tblTMFillMethod] ([intConcurrencyID], [intFillMethodID], [strFillMethod], [ysnDefault]) VALUES (1, 1, N'Julian Calendar', 1)
INSERT [dbo].[tblTMFillMethod] ([intConcurrencyID], [intFillMethodID], [strFillMethod], [ysnDefault]) VALUES (1, 2, N'Will Call', 1)
SET IDENTITY_INSERT [dbo].[tblTMFillMethod] OFF
/****** Object:  Table [dbo].[tblTMFillGroup]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMFillGroup] ON
INSERT [dbo].[tblTMFillGroup] ([intFillGroupID], [strFillGroupCode], [strDescription], [ysnActive], [intConcurrencyID]) VALUES (2, N'FG1', N'This is for cycle testing', 0, 10)
INSERT [dbo].[tblTMFillGroup] ([intFillGroupID], [strFillGroupCode], [strDescription], [ysnActive], [intConcurrencyID]) VALUES (3, N'FG2', N'This is for cycle testing', 1, 5)
INSERT [dbo].[tblTMFillGroup] ([intFillGroupID], [strFillGroupCode], [strDescription], [ysnActive], [intConcurrencyID]) VALUES (6, N'asdasd', N'', 0, NULL)
INSERT [dbo].[tblTMFillGroup] ([intFillGroupID], [strFillGroupCode], [strDescription], [ysnActive], [intConcurrencyID]) VALUES (7, N'FG3', N'This is for testing purposes only', 1, 2)
INSERT [dbo].[tblTMFillGroup] ([intFillGroupID], [strFillGroupCode], [strDescription], [ysnActive], [intConcurrencyID]) VALUES (9, N'VOn', N'Von', 1, NULL)
SET IDENTITY_INSERT [dbo].[tblTMFillGroup] OFF
/****** Object:  Table [dbo].[tblTMEventType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMEventType] ON
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 1, N'Event-001', 1, N'Consumption Site Activated')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 2, N'Event-002', 1, N'Consumption Site Deactivated')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 3, N'Event-003', 1, N'Consumption Site Gas Checked')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 4, N'Event-004', 1, N'Consumption Site Leak Checked')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 5, N'Event-005', 1, N'Consumption Site Reassigned ')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 6, N'Event-006', 1, N'Device At Customer to be Picked up and Transferred')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 7, N'Event-007', 1, N'Device Deleted from Consumption Site')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 8, N'Event-008', 1, N'Device Detached from Consumption Site')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 9, N'Event-009', 1, N'Device Installed')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 10, N'Event-010', 1, N'Device Painted')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 11, N'Event-011', 1, N'Device Picked up and Transferred')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 12, N'Event-012', 1, N'Device Pick up and Transfer Cancelled')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 13, N'Event-013', 1, N'Device Repair Note')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 14, N'Event-014', 1, N'Device Sold')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 15, N'Event-015', 1, N'Device Transferred to Another Consumption Site')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 16, N'Event-016', 1, N'General Comment')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 17, N'Event-017', 1, N'Consumption Site Taken Off Hold')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (1, 18, N'Event-018', 1, N'Consumption Site Put On Hold')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (29, 19, N'Event-021', 1, N'Tank Monitor Reading')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (0, 20, N'Event-020', 1, N'Device Lease Billed')
INSERT [dbo].[tblTMEventType] ([intConcurrencyID], [intEventTypeID], [strEventType], [ysnDefault], [strDescription]) VALUES (0, 22, N'Event-022', 1, N'Season Change')
SET IDENTITY_INSERT [dbo].[tblTMEventType] OFF
/****** Object:  Table [dbo].[tblTMSeasonResetArchive]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMRoute]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMRoute] ON
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (88, N'0071', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (89, N'0181', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (90, N'055', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (91, N'056', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (92, N'057', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (93, N'058', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (94, N'059', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (95, N'060', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (96, N'061', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (97, N'062', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (98, N'063', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (99, N'064', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (100, N'065', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (101, N'067', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (102, N'068', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (103, N'069', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (104, N'070', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (105, N'071', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (106, N'072', 0)
INSERT [dbo].[tblTMRoute] ([intRouteID], [strRouteID], [intConcurrencyID]) VALUES (107, N'073', 0)
SET IDENTITY_INSERT [dbo].[tblTMRoute] OFF
/****** Object:  Table [dbo].[tblTMRegulatorType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMRegulatorType] ON
INSERT [dbo].[tblTMRegulatorType] ([intConcurrencyID], [intRegulatorTypeID], [strRegulatorType]) VALUES (1, 5, N'1st Stage')
INSERT [dbo].[tblTMRegulatorType] ([intConcurrencyID], [intRegulatorTypeID], [strRegulatorType]) VALUES (1, 6, N'2nd Stage')
INSERT [dbo].[tblTMRegulatorType] ([intConcurrencyID], [intRegulatorTypeID], [strRegulatorType]) VALUES (1, 7, N'Dual Stage')
INSERT [dbo].[tblTMRegulatorType] ([intConcurrencyID], [intRegulatorTypeID], [strRegulatorType]) VALUES (1, 8, N'2 lb')
SET IDENTITY_INSERT [dbo].[tblTMRegulatorType] OFF
/****** Object:  Table [dbo].[tblTMPreferenceCompany]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMPreferenceCompany] ON
INSERT [dbo].[tblTMPreferenceCompany] ([intConcurrencyID], [strSummitIntegration], [intPreferenceCompanyID], [intCeilingBurnRate], [intFloorBurnRate], [ysnAllowClassFill], [dblDefaultReservePercent], [strSMTPServer], [strSMTPUsername], [strSMTPPassword], [strFromMail], [strFromName], [intMailServerPort], [ysnEnableAuthentication], [ysnEnableSSL], [strLeaseProductNumber], [ysnEnableETracker], [strETrackerURL], [ysnUseDeliveryTermOnCS], [ysnEnableLeaseBillingAboveMinUse]) VALUES (NULL, N'AG', 1, 40, 40, 1, CAST(20.000000 AS Numeric(18, 6)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'7900         ', 0, N'http://trackcustomercomplaints.com/cflash/index.php?action=complaint&proc=create&account=', 1, 1)
SET IDENTITY_INSERT [dbo].[tblTMPreferenceCompany] OFF
/****** Object:  Table [dbo].[tblTMPossessionType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMPossessionType] ON
INSERT [dbo].[tblTMPossessionType] ([intConcurrencyID], [intPossessionTypeID], [strPossessionType]) VALUES (1, 1, N'Customer Owned')
INSERT [dbo].[tblTMPossessionType] ([intConcurrencyID], [intPossessionTypeID], [strPossessionType]) VALUES (1, 2, N'Company Owned')
INSERT [dbo].[tblTMPossessionType] ([intConcurrencyID], [intPossessionTypeID], [strPossessionType]) VALUES (1, 3, N'Lease')
INSERT [dbo].[tblTMPossessionType] ([intConcurrencyID], [intPossessionTypeID], [strPossessionType]) VALUES (1, 4, N'Lease to Own')
SET IDENTITY_INSERT [dbo].[tblTMPossessionType] OFF
/****** Object:  Table [dbo].[tblTMMeterType]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMMeterType] ON
INSERT [dbo].[tblTMMeterType] ([intConcurrencyID], [intMeterTypeID], [strMeterType], [dblConversionFactor], [ysnDefault]) VALUES (1, 1, N'11" Water Column Cu Meter', CAST(0.97639230 AS Numeric(18, 8)), 1)
INSERT [dbo].[tblTMMeterType] ([intConcurrencyID], [intMeterTypeID], [strMeterType], [dblConversionFactor], [ysnDefault]) VALUES (1, 2, N'11" Water Column Gallon', CAST(1.00659000 AS Numeric(18, 8)), 1)
INSERT [dbo].[tblTMMeterType] ([intConcurrencyID], [intMeterTypeID], [strMeterType], [dblConversionFactor], [ysnDefault]) VALUES (1, 3, N'2 lb Cu Foot x 100', CAST(3.06040132 AS Numeric(18, 8)), 1)
SET IDENTITY_INSERT [dbo].[tblTMMeterType] OFF
/****** Object:  Table [dbo].[tblTMLeaseMinimumUse]    Script Date: 10/07/2013 15:54:30 ******/
SET IDENTITY_INSERT [dbo].[tblTMLeaseMinimumUse] ON
INSERT [dbo].[tblTMLeaseMinimumUse] ([intLeaseMinimumUseID], [dblSiteCapacity], [dblMinimumUsage], [intConcurrencyID]) VALUES (15, CAST(500.000000 AS Numeric(18, 6)), CAST(200.000000 AS Numeric(18, 6)), 4)
INSERT [dbo].[tblTMLeaseMinimumUse] ([intLeaseMinimumUseID], [dblSiteCapacity], [dblMinimumUsage], [intConcurrencyID]) VALUES (16, CAST(800.000000 AS Numeric(18, 6)), CAST(300.000000 AS Numeric(18, 6)), NULL)
INSERT [dbo].[tblTMLeaseMinimumUse] ([intLeaseMinimumUseID], [dblSiteCapacity], [dblMinimumUsage], [intConcurrencyID]) VALUES (18, CAST(911.000000 AS Numeric(18, 6)), CAST(300.010000 AS Numeric(18, 6)), NULL)
SET IDENTITY_INSERT [dbo].[tblTMLeaseMinimumUse] OFF
/****** Object:  Table [dbo].[tblTMLeaseCode]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMLease]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMEventAutomation]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMEvent]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDevice]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMDegreeDayReading]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSite]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMWorkToDo]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMWorkOrder]    Script Date: 10/07/2013 15:54:30 ******/
/****** Object:  Table [dbo].[tblTMSiteDevice]    Script Date: 10/07/2013 15:54:30 ******/
