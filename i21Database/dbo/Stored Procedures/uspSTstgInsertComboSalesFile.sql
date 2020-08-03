CREATE PROCEDURE [dbo].[uspSTstgInsertComboSalesFile]
	@strFilePrefix						NVARCHAR(50)
	, @intStoreId						INT
	, @intRegisterId					INT
	, @ysnClearRegisterPromotion		BIT
	, @dtmBeginningChangeDate			DATETIME
	, @dtmEndingChangeDate				DATETIME
	, @strGeneratedXML					NVARCHAR(MAX)	OUTPUT
	, @intImportFileHeaderId			INT				OUTPUT
	, @ysnSuccessResult					BIT				OUTPUT
	, @strMessageResult					NVARCHAR(1000)	OUTPUT
AS
BEGIN
	BEGIN TRY
		
		-- =========================================================================================================
		-- [START] - CREATE TRANSACTION
		-- =========================================================================================================
		DECLARE @InitTranCount INT;
		SET @InitTranCount = @@TRANCOUNT
		DECLARE @Savepoint NVARCHAR(150) = 'uspSTstgInsertComboSalesFile' + CAST(NEWID() AS NVARCHAR(100)); 

		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END		
		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END
		-- =========================================================================================================
		-- [START] - CREATE TRANSACTION
		-- =========================================================================================================



		SET @ysnSuccessResult = CAST(1 AS BIT) -- Set to true
		SET @strMessageResult = ''

		DECLARE @xml XML = N''
		DECLARE @strXML AS NVARCHAR(MAX)
		DECLARE @strVersion NVARCHAR(50)

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'CBT'

		DECLARE @strRegister NVARCHAR(200)
				, @strRegisterClass NVARCHAR(200)
				, @strXmlVersion NVARCHAR(10)

		SELECT @strRegister = strRegisterName 
				, @strRegisterClass = strRegisterClass
				, @strXmlVersion = strXmlVersion
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId


		-- =========================================================================================================
		-- Check if register has intImportFileHeaderId
		IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
			BEGIN
					SELECT TOP 1 @intImportFileHeaderId = intImportFileHeaderId 
					FROM tblSTRegisterFileConfiguration 
					WHERE intRegisterId = @intRegisterId 
					AND strFilePrefix = @strFilePrefix
			END
		ELSE
			BEGIN
					SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
					SET @strGeneratedXML = ''
					SET @intImportFileHeaderId = 0
					SET @strMessageResult = 'Register ' + @strRegister + ' has no Outbound setup for Promotion Sales List - Combo (' + @strFilePrefix + ')'

					RETURN
			END
		-- =========================================================================================================

		-- Create temp table @tblTempSapphireCommanderWeekDayAvailability
		BEGIN
			DECLARE @tblTempSapphireCommanderWeekDayAvailability TABLE 
			(
				[intPromoSalesListId]		INT,
				[PromotionID]				INT,
				[strAvailable]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
				[strWeekDay]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
				[intSort]					INT, 
				[strStartTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
				[strEndTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL
			)
		END




		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				-- Create Unique Identifier
				-- Handles multiple Update of registers by different Stores
				DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

				-- Table and Condition
				DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookComboCBT33~strUniqueGuid=''' + @strUniqueGuid + ''''

				IF(@strXmlVersion = '3.4')
					BEGIN	
					
						-- OLD CODE
						BEGIN
							PRINT 'OLD CODE'
							-- INSERT INTO tblSTstgPassportPricebookComboCBT33
							--(
							--	[StoreLocationID], 
							--	[VendorName], 
							--	[VendorModelVersion], 
							--	[TableActionType], 
							--	[RecordActionType], 
							--	[CBTDetailRecordActionType], 
							--	[PromotionID], 
							--	[PromotionReason], 
							--	[ComboDescription],
							--	[ComboPrice],
							--	[ItemListID],
							--	[ComboItemQuantity],
							--	[ComboItemUnitPrice],
							--	[StartDate],
							--	[StartTime],
							--	[StopDate],
							--	[StopTime],
							--	[strUniqueGuid]
							--)
							--SELECT DISTINCT
							--	ST.intStoreNo AS [StoreLocationID]
							--	, 'iRely' AS [VendorName] 
							--	, (SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC) AS [VendorModelVersion] 
							--	, CASE
							--			WHEN @ysnClearRegisterPromotion = CAST(1 AS BIT) THEN 'initialize'
							--			WHEN @ysnClearRegisterPromotion = CAST(0 AS BIT) THEN 'update'
							--	END AS [TableActionType]
							--	, 'addchange' AS [RecordActionType] 
							--	, CASE 
							--		WHEN PSL.ysnDeleteFromRegister = CAST(0 AS BIT) 
							--			THEN 'addchange' 
							--		WHEN PSL.ysnDeleteFromRegister = CAST(1 AS BIT)  
							--			THEN 'delete' 
							--		ELSE 'addchange' 
							--	END [CBTDetailRecordActionType] 
							--	, PSL.intPromoSalesId AS [PromotionID]
							--	, PSL.strPromoReason AS [PromotionReason]
							--	, PSL.strPromoSalesDescription AS [ComboDescription]
							--	, PSL.dblPromoPrice AS [ComboPrice]
							--	, PIL.intPromoItemListNo AS [ItemListID]
							--	, PSLD.intQuantity AS [ComboItemQuantity]
							--	, PSLD.dblPrice AS [ComboItemUnitPrice]
							--	, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) AS [StartDate]
							--	, CONVERT(varchar, CAST('0:00:00' AS TIME), 108) AS [StartTime]
							--	, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) AS [StopDate]
							--	, CONVERT(varchar, CAST('23:59:59' AS TIME), 108) AS [StopTime] 
							--	, @strUniqueGuid AS [strUniqueGuid]
							--FROM tblICItem I
							--JOIN tblICItemLocation IL 
							--	ON IL.intItemId = I.intItemId
							--JOIN tblSMCompanyLocation L 
							--	ON L.intCompanyLocationId = IL.intLocationId 
							--JOIN tblSTStore ST 
							--	ON ST.intCompanyLocationId = L.intCompanyLocationId 
							--JOIN tblSTRegister R 
							--	ON R.intStoreId = ST.intStoreId
							--JOIN tblSTPromotionSalesList PSL 
							--	ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
							--JOIN tblSTPromotionSalesListDetail PSLD 
							--	ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
							--JOIN tblSTPromotionItemList PIL 
							--	ON PIL.intPromoItemListId = PSLD.intPromoItemListId
							--JOIN tblSTPromotionItemListDetail PILD 
							--	ON PILD.intPromoItemListId = PIL.intPromoItemListId
							--JOIN tblICItemUOM IUOM 
							--	ON IUOM.intItemUOMId = PILD.intItemUOMId 
							--JOIN tblICUnitMeasure IUM 
							--	ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
							--WHERE R.intRegisterId = @intRegisterId
							--AND ST.intStoreId = @intStoreId
							--AND PSL.strPromoType = 'C' -- <--- 'C' = Combo
							---- AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId



							--IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookComboCBT33 WHERE strUniqueGuid = @strUniqueGuid)
							--	BEGIN
							--		--Generate XML for the pricebook data availavle in staging table
							--		EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

							--		--Once XML is generated delete the data from pricebook staging table.
							--		DELETE 
							--		FROM tblSTstgPassportPricebookComboCBT33
							--		WHERE strUniqueGuid = @strUniqueGuid
							--	END
							--ELSE 
							--	BEGIN
							--		SET @ysnSuccessResult = CAST(0 AS BIT)
							--		SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'
							--	END
					
						END

						-- NEW
						BEGIN
								-- Create temp table @tblTempPassportMixMatch
								BEGIN
									DECLARE @tblTempPassportCombo TABLE 
									(
										[intPromoSalesId]			INT,
										[intPromoSalesListId]		INT,
										[intPromoSalesListDetailId]	INT,
										[StoreLocationID]			INT, 
										[VendorName]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[VendorModelVersion]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,  
										[TableActionType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[RecordActionType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,  
										[CBTDetailRecordActionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[PromotionID]				INT, 
										[PromotionReason]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
										[ComboDescription]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
										[ComboPrice]				NUMERIC(18, 2),
										--[TransactionLimit]			INT,
										[ItemListID]				INT,
										[ComboItemQuantity]			INT,
										[ComboItemUnitPrice]		NUMERIC(18, 2),
										[StartDate]					DATE,
										[StartTime]					TIME,
										[StopDate]					DATE,
										[StopTime]					TIME
										
									)
								END

								---- Create temp table @tblTempSapphireCommanderWeekDayAvailability
								--BEGIN
								--	DECLARE @tblTempSapphireCommanderWeekDayAvailability TABLE 
								--	(
								--		[intPromoSalesListId]		INT,
								--		[PromotionID]				INT,
								--		[strAvailable]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
								--		[strWeekDay]				NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
								--		[intSort]					INT, 
								--		[strStartTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
								--		[strEndTime]				NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL
								--	)
								--END



								-- INSERT TO @@tblTempPassportCombo
								BEGIN
									INSERT INTO @tblTempPassportCombo
									(
										[intPromoSalesId],
										[intPromoSalesListId],
										[intPromoSalesListDetailId],

										[StoreLocationID], 
										[VendorName], 
										[VendorModelVersion],  
										[TableActionType], 
										[RecordActionType],  
										[CBTDetailRecordActionType], 
										[PromotionID], 
										[PromotionReason], 
										[ComboDescription], 
										[ComboPrice],
										-- [TransactionLimit],
										[ItemListID],
										[ComboItemQuantity],
										[ComboItemUnitPrice],
										[StartDate],
										[StartTime],
										[StopDate],
										[StopTime]
									)
									SELECT DISTINCT
										[intPromoSalesId]				= PSL.intPromoSalesId,
										[intPromoSalesListId]			= PSLD.intPromoSalesListId,
										[intPromoSalesListDetailId]		= PSLD.intPromoSalesListDetailId,

										[StoreLocationID]				= ST.intStoreNo, 
										[VendorName]					= 'iRely', 
										[VendorModelVersion]			= (SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),  
										[TableActionType]				= CASE
																			WHEN @ysnClearRegisterPromotion = CAST(1 AS BIT) THEN 'initialize'
																			WHEN @ysnClearRegisterPromotion = CAST(0 AS BIT) THEN 'update'
																		END, 
										[RecordActionType]				= 'addchange',  
										[CBTDetailRecordActionType]		= CASE 
																			WHEN PSL.ysnDeleteFromRegister = CAST(0 AS BIT) 
																				THEN 'addchange' 
																			WHEN PSL.ysnDeleteFromRegister = CAST(1 AS BIT)  
																				THEN 'delete' 
																			ELSE 'addchange' 
																		END, 
										[PromotionID]					= PSL.intPromoSalesId, 
										[PromotionReason]				= PSL.strPromoReason, 
										[ComboDescription]				= PSL.strPromoSalesDescription, 
										[ComboPrice]					= PSL.dblPromoPrice,
										-- [TransactionLimit],
										[ItemListID]					= PIL.intPromoItemListNo,
										[ComboItemQuantity]				= PSLD.intQuantity,
										[ComboItemUnitPrice]			= PSLD.dblPrice,
										[StartDate]						= CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126),
										[StartTime]						= CONVERT(varchar, CAST('0:00:00' AS TIME), 108),
										[StopDate]						= CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126),
										[StopTime]						= CONVERT(varchar, CAST('23:59:59' AS TIME), 108)
									FROM tblICItem I
									JOIN tblICItemLocation IL 
										ON IL.intItemId = I.intItemId
									JOIN tblSMCompanyLocation L 
										ON L.intCompanyLocationId = IL.intLocationId 
									JOIN tblSTStore ST 
										ON ST.intCompanyLocationId = L.intCompanyLocationId 
									JOIN tblSTRegister R 
										ON R.intStoreId = ST.intStoreId
									JOIN tblSTPromotionSalesList PSL 
										ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
									JOIN tblSTPromotionSalesListDetail PSLD 
										ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
									JOIN tblSTPromotionItemList PIL 
										ON PIL.intPromoItemListId = PSLD.intPromoItemListId
									JOIN tblSTPromotionItemListDetail PILD 
										ON PILD.intPromoItemListId = PIL.intPromoItemListId
									JOIN tblICItemUOM IUOM 
										ON IUOM.intItemUOMId = PILD.intItemUOMId 
									JOIN tblICUnitMeasure IUM 
										ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
									WHERE ST.intStoreId = @intStoreId
										AND PSL.strPromoType = 'C' -- <--- 'C' = Combo
										AND (
										       CAST(PSL.dtmPromoBegPeriod AS DATE) >= CAST(@dtmBeginningChangeDate AS DATE)
										       AND 
											   CAST(PSL.dtmPromoEndPeriod AS DATE)  <= CAST(@dtmEndingChangeDate AS DATE)
											   AND 
											   CAST(PSL.dtmPromoEndPeriod AS DATE)  >= GETDATE()
											) -- ST-1227

								END

								-- INSERT @tblTempSapphireCommanderWeekDayAvailability
								BEGIN
									INSERT INTO @tblTempSapphireCommanderWeekDayAvailability
									(
										[intPromoSalesListId],
										[PromotionID],
										[strAvailable],
										[strWeekDay], 
										[intSort], 
										[strStartTime],
										[strEndTime]
									)
									SELECT 
										[intPromoSalesListId]	= [Changes].intPromoSalesListId,
										[PromotionID]			= [Changes].intPromoSalesId,
										[strAvailable]			= [Changes].strAvailable,
										[strWeekDay]			= [Changes].strWeekDay, 
										[intSort]				= [Changes].intSort, 
										[strStartTime]			= [Changes].strStartTime,
										[strEndTime]			= [Changes].strEndTime
									FROM 
									(
										SELECT DISTINCT 
											intPromoSalesListId, 
											intPromoSalesId,
											strWeekDay = CASE	
															WHEN StartTime = 'strStartTimePromotionSunday'
																THEN 'Sunday'
															WHEN StartTime = 'strStartTimePromotionMonday'
																THEN 'Monday'
															WHEN StartTime = 'strStartTimePromotionTuesday'
																THEN 'Tuesday'
															WHEN StartTime = 'strStartTimePromotionWednesday'
																THEN 'Wednesday'
															WHEN StartTime = 'strStartTimePromotionThursday'
																THEN 'Thursday'
															WHEN StartTime = 'strStartTimePromotionFriday'
																THEN 'Friday'
															WHEN StartTime = 'strStartTimePromotionSaturday'
																THEN 'Saturday'
														END,
											intSort = CASE	
															WHEN StartTime = 'strStartTimePromotionSunday'
																THEN 1
															WHEN StartTime = 'strStartTimePromotionMonday'
																THEN 2
															WHEN StartTime = 'strStartTimePromotionTuesday'
																THEN 3
															WHEN StartTime = 'strStartTimePromotionWednesday'
																THEN 4
															WHEN StartTime = 'strStartTimePromotionThursday'
																THEN 5
															WHEN StartTime = 'strStartTimePromotionFriday'
																THEN 6
															WHEN StartTime = 'strStartTimePromotionSaturday'
																THEN 7
														END,
											strAvailable,
											strStartTime, 
											strEndTime
										FROM 
										(
											SELECT sl.intPromoSalesListId
													, sl.intPromoSalesId
													, strWeekDayPromotionSunday				= CASE WHEN sl.ysnWeekDayPromotionSunday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionMonday				= CASE WHEN sl.ysnWeekDayPromotionMonday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionTuesday			= CASE WHEN sl.ysnWeekDayPromotionTuesday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionWednesday			= CASE WHEN sl.ysnWeekDayPromotionWednesday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionThursday			= CASE WHEN sl.ysnWeekDayPromotionThursday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionFriday				= CASE WHEN sl.ysnWeekDayPromotionFriday = 1 THEN 'yes' ELSE 'no' END
													, strWeekDayPromotionSaturday			= CASE WHEN sl.ysnWeekDayPromotionSaturday = 1 THEN 'yes' ELSE 'no' END

													, strStartTimePromotionSunday			= CAST(ISNULL(sl.dtmStartTimePromotionSunday, '') AS NVARCHAR(8))
													, strStartTimePromotionMonday			= CAST(ISNULL(sl.dtmStartTimePromotionMonday, '') AS NVARCHAR(8))
													, strStartTimePromotionTuesday			= CAST(ISNULL(sl.dtmStartTimePromotionTuesday, '') AS NVARCHAR(8))
													, strStartTimePromotionWednesday		= CAST(ISNULL(sl.dtmStartTimePromotionWednesday, '') AS NVARCHAR(8))
													, strStartTimePromotionThursday			= CAST(ISNULL(sl.dtmStartTimePromotionThursday, '') AS NVARCHAR(8))
													, strStartTimePromotionFriday			= CAST(ISNULL(sl.dtmStartTimePromotionFriday, '') AS NVARCHAR(8))
													, strStartTimePromotionSaturday			= CAST(ISNULL(sl.dtmStartTimePromotionSaturday, '') AS NVARCHAR(8))
			
													, strEndTimePromotionSunday				= CAST(ISNULL(sl.dtmEndTimePromotionSunday, '') AS NVARCHAR(8))
													, strEndTimePromotionMonday				= CAST(ISNULL(sl.dtmEndTimePromotionMonday, '') AS NVARCHAR(8))
													, strEndTimePromotionTuesday			= CAST(ISNULL(sl.dtmEndTimePromotionTuesday, '') AS NVARCHAR(8))
													, strEndTimePromotionWednesday			= CAST(ISNULL(sl.dtmEndTimePromotionWednesday, '') AS NVARCHAR(8))
													, strEndTimePromotionThursday			= CAST(ISNULL(sl.dtmEndTimePromotionThursday, '') AS NVARCHAR(8))
													, strEndTimePromotionFriday				= CAST(ISNULL(sl.dtmEndTimePromotionFriday, '') AS NVARCHAR(8))
													, strEndTimePromotionSaturday			= CAST(ISNULL(sl.dtmEndTimePromotionSaturday, '') AS NVARCHAR(8))
											FROM tblSTPromotionSalesList sl
											INNER JOIN @tblTempPassportCombo temp
												ON sl.intPromoSalesId = temp.intPromoSalesId
										) t
										unpivot
										(
											strAvailable for Available in (strWeekDayPromotionSunday, strWeekDayPromotionMonday, strWeekDayPromotionTuesday, strWeekDayPromotionWednesday, strWeekDayPromotionThursday, strWeekDayPromotionFriday, strWeekDayPromotionSaturday)
										) a
										unpivot
										(
											strStartTime for StartTime in (strStartTimePromotionSunday, strStartTimePromotionMonday, strStartTimePromotionTuesday, strStartTimePromotionWednesday, strStartTimePromotionThursday, strStartTimePromotionFriday, strStartTimePromotionSaturday)
										) o
										unpivot
										(
											strEndTime for EndTime in (strEndTimePromotionSunday, strEndTimePromotionMonday, strEndTimePromotionTuesday, strEndTimePromotionWednesday, strEndTimePromotionThursday, strEndTimePromotionFriday, strEndTimePromotionSaturday)
										) n
										WHERE REPLACE(StartTime, 'strStartTimePromotion', '') = REPLACE(EndTime, 'strEndTimePromotion', '')	
											AND REPLACE(Available, 'strWeekDayPromotion', '') = REPLACE(StartTime, 'strStartTimePromotion', '')
									) [Changes]
								END


								IF EXISTS(SELECT TOP 1 1 FROM @tblTempPassportCombo)
									BEGIN
										--DECLARE @xml XML = N''

										SELECT @xml = 
										(
											SELECT
												trans.StoreLocationID		AS 'TransmissionHeader/StoreLocationID',
												trans.VendorName 			AS 'TransmissionHeader/VendorName',
												trans.VendorModelVersion 	AS 'TransmissionHeader/VendorModelVersion',
												(
													SELECT
													   ComboMaintenance.TableActionType			AS [TableAction/@type]
														,  ComboMaintenance.RecordActionType	AS [RecordAction/@type]
														, (
															SELECT
																CBTDetail.CBTDetailRecordActionType	AS [RecordAction/@type]
																, CBTDetail.PromotionID				AS [Promotion/PromotionID]
																, CBTDetail.PromotionReason			AS [Promotion/PromotionReason]		
																, CBTDetail.ComboDescription		AS [ComboDescription]
																, CBTDetail.ComboPrice				AS [ComboPrice]

																, (
																	SELECT
																		ComboList.ItemListID		 AS [ComboItemList/ItemListID],
																		ComboList.ComboItemQuantity	 AS [ComboItemList/ComboItemQuantity],
																		ComboList.ComboItemUnitPrice AS [ComboItemList/ComboItemUnitPrice]
																	FROM 
																	(
																		SELECT DISTINCT
																			combo.ItemListID
																			, combo.ComboItemQuantity
																			, combo.ComboItemUnitPrice
																		FROM @tblTempPassportCombo combo
																		WHERE combo.intPromoSalesListId = CBTDetail.intPromoSalesListId
																	) ComboList
																	ORDER BY ComboList.ItemListID ASC
																	FOR XML PATH('ComboList'), TYPE

																)

																, CBTDetail.StartDate				AS [StartDate]
																, CBTDetail.StartTime				AS [StartTime]
																, CBTDetail.StopDate				AS [StopDate]
																, CBTDetail.StopTime				AS [StopTime]

																, (
																	SELECT
																		--wda.strStartTime			AS [@startTime],
																		wda.strWeekDay				AS [@weekday],
																		wda.strAvailable			AS [@available]
																		--wda.strEndTime				AS [@stopTime]
																	FROM 
																	(
																		SELECT DISTINCT
																			wda.intSort
																			, wda.strAvailable
																			, wda.strStartTime
																			, wda.strEndTime
																			, wda.strWeekDay
																		FROM @tblTempSapphireCommanderWeekDayAvailability wda
																		WHERE wda.intPromoSalesListId = CBTDetail.intPromoSalesListId
																	) wda
																	ORDER BY wda.intSort ASC
																	FOR XML PATH('WeekdayAvailability'), TYPE

																)
															FROM
															(
																SELECT DISTINCT
																	comboDetail.intPromoSalesListId
																	, comboDetail.PromotionID
																	, comboDetail.CBTDetailRecordActionType
																	, comboDetail.PromotionReason
																	, comboDetail.ComboDescription
																	, comboDetail.ComboPrice
																	, comboDetail.StartDate
																	, comboDetail.StartTime
																	, comboDetail.StopDate
																	, comboDetail.StopTime
																FROM @tblTempPassportCombo comboDetail
																WHERE ComboMaintenance.PromotionID = comboDetail.PromotionID
															) CBTDetail
															FOR XML PATH('CBTDetail'), TYPE
														)
													FROM 
													(
														SELECT DISTINCT	
															PromotionID
															, TableActionType
															,  RecordActionType
															FROM @tblTempPassportCombo
														--ORDER BY PromotionID ASC
													) ComboMaintenance
													FOR XML PATH('ComboMaintenance'), TYPE
												)
											FROM 
											(
												SELECT DISTINCT
													StoreLocationID, 
													VendorName, 
													VendorModelVersion
												FROM @tblTempPassportCombo
											) trans
											FOR XML PATH('NAXML-MaintenanceRequest'), TYPE
										);

						
						
										SET @strVersion = N'3.4'
						
										-- INSERT Attributes 'page' and 'ofpages' to Root header
										SET @xml.modify('insert 
													   (
															attribute version { 
																					sql:variable("@strVersion")
																			  }		   
														) into (/*:NAXML-MaintenanceRequest)[1]');
						
										--SET @strXML = REPLACE(@strXML, '<NAXML-MaintenanceRequest', '<NAXML-MaintenanceRequest xmlns="http://www.naxml.org/POSBO/Vocabulary/2003-10-16"')
										-- SELECT @xml

										SET @strXML = CAST(@xml AS NVARCHAR(MAX))
										SET @strGeneratedXML = REPLACE(@strXML, '><', '>' + CHAR(13) + '<')

										--EXEC CopierDB.dbo.LongPrint @strGeneratedXML
									END
								ELSE
									BEGIN

										SET @strGeneratedXML		= ''
										SET @intImportFileHeaderId	= 0
										SET @ysnSuccessResult		= CAST(0 AS BIT)
										SET @strMessageResult		= 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'

										GOTO ExitWithRollback
									END
							END
						
					END
			END
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				INSERT INTO tblSTstgComboSalesFile
				SELECT DISTINCT
				  ST.intStoreNo [StoreLocationID]
					, 'iRely' [VendorName]  	
					, 'Rel. 13.2.0' [VendorModelVersion]
					, 'update' [TableActionType]
					, 'addchange' [RecordActionType] 
					, CASE PSL.ysnDeleteFromRegister 
						WHEN 0 
							THEN 'addchange' 
						WHEN 1 
							THEN 'delete' 
						ELSE 'addchange' 
					END [CBTDetailRecordActionType] 
					, PSL.intPromoSalesId [PromotionID]
					, PSL.strPromoReason [PromotionReason]
					, NULL [SalesRestrictCode]
					, 2 [LinkCodeType]
					, NULL [LinkCodeValue]
					, PSL.strPromoSalesDescription [ComboDescription]
					, PSL.dblPromoPrice [ComboPrice]
					, PIL.intPromoItemListNo [ItemListID]
					, PSLD.intQuantity [ComboItemQuantity]
					, IUM.strUnitMeasure [ComboItemQuantityUOM]
					, PSLD.dblPrice [ComboItemUnitPrice]
					, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) [StartDate]
					, '0:00:01' [StartTime]
					, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) [StopDate]
					, '23:59:59' [StopTime]
					, PSL.intPurchaseLimit [TransactionLimit]
					, CASE 
						WHEN R.strRegisterClass = 'RADIANT' 
							THEN 0 
						ELSE NULL 
					END [Priority]
					, 'yes' [WeekdayAvailabilitySunday]
					, 'Sunday' [WeekdaySunday]
					, 'yes' [WeekdayAvailabilityMonday]
					, 'Monday' [WeekdayMonday]
					, 'yes' [WeekdayAvailabilityTuesday]
					, 'Tuesday' [WeekdayTuesday]
					, 'yes' [WeekdayAvailabilityWednesday]
					, 'Wednesday' [WeekdayWednesday]
					, 'yes' [WeekdayAvailabilityThursday]
					, 'Thursday' [WeekdayThursday]
					, 'yes' [WeekdayAvailabilityFriday]
					, 'Friday' [WeekdayFriday]
					, 'yes' [WeekdayAvailabilitySaturday]
					, 'Saturday' [WeekdaySaturday]
				FROM tblICItem I
				JOIN tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN tblSMCompanyLocation L 
					ON L.intCompanyLocationId = IL.intLocationId 
				JOIN tblSTStore ST 
					ON ST.intCompanyLocationId = L.intCompanyLocationId 
				JOIN tblSTRegister R 
					ON R.intStoreId = ST.intStoreId
				JOIN tblSTPromotionSalesList PSL 
					ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
				JOIN tblSTPromotionSalesListDetail PSLD 
					ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
				JOIN tblSTPromotionItemList PIL 
					ON PIL.intPromoItemListId = PSLD.intPromoItemListId
				JOIN tblSTPromotionItemListDetail PILD 
					ON PILD.intPromoItemListId = PIL.intPromoItemListId
				JOIN tblICItemUOM IUOM 
					ON IUOM.intItemUOMId = PILD.intItemUOMId 
				JOIN tblICUnitMeasure IUM 
					ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
				WHERE R.intRegisterId = @intRegisterId 
					AND ST.intStoreId = @intStoreId
					AND PSL.strPromoType = 'C' -- <--- 'C' = Combo
					-- AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId
					AND (
							CAST(@dtmBeginningChangeDate AS DATE) >= CAST(PSL.dtmPromoBegPeriod AS DATE)
							 AND 
							CAST(@dtmEndingChangeDate AS DATE) <= CAST(PSL.dtmPromoEndPeriod AS DATE)  
							AND 
							CAST(PSL.dtmPromoEndPeriod AS DATE)  > GETDATE()
						) -- ST-1227
				

				IF EXISTS(SELECT StoreLocationID FROM tblSTstgComboSalesFile)
					BEGIN
							--Generate XML for the pricebook data availavle in staging table
							Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgComboSalesFile~intComboSalesFile > 0', 0, @strGeneratedXML OUTPUT

							--Once XML is generated delete the data from pricebook  staging table.
							DELETE FROM tblSTstgComboSalesFile	
					END
				ELSE 
					BEGIN
							SET @ysnSuccessResult = CAST(0 AS BIT)
							SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'
					END
				
			END
		ELSE IF(@strRegisterClass = 'SAPPHIRE/COMMANDER')
			BEGIN
				
				-- Create temp table @tblTempSapphireCommanderCombos
				BEGIN
					DECLARE @tblTempSapphireCommanderCombos TABLE 
					(
						[intPrimaryId] INT,
						[strStoreNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
						[strVendorName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
						[strVendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,

						[strRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 

						[strPromotionID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
						[strComboDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,

						[strItemListID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
						[strComboItemQuantity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
						[strComboItemUnitPrice] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,

						[strStartDate] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
						[strStartTime] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL,
						[strStopDate] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
						[strStopTime] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL
					)
				END

				-- Insert to temp table @tblTempSapphireCommanderCombos
				BEGIN
					INSERT INTO @tblTempSapphireCommanderCombos
					SELECT
						[intPrimaryId]						=	CAST(SL.intPromoSalesListId AS NVARCHAR(50)), 
						[strStoreNo]						=	CAST(Store.intStoreNo AS NVARCHAR(50)), 
						[strVendorName]						=	'iRely', 
						[strVendorModelVersion]				=	(SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),

						[strRecordActionType]				=	CASE
																	WHEN (SL.ysnDeleteFromRegister = 1)
																		THEN 'delete'
																	ELSE 'addchange'
																END, 
						[strPromotionID]					=	CAST(SL.intPromoSalesId AS NVARCHAR(50)),
						[strComboDescription]				=	SL.strPromoSalesDescription,

						[strItemListID]						=	PIL.strPromoItemListId,
						[strComboItemQuantity]				=	CAST(SLD.intQuantity AS NVARCHAR(50)),
						[strComboItemUnitPrice]				=	CAST(CAST(SLD.dblPrice AS DECIMAL(18, 2)) AS NVARCHAR(50)),

						[strStartDate]						=	CAST(CONVERT(DATE, SL.dtmPromoBegPeriod) AS NVARCHAR(10)),
						[strStartTime]						=	CAST(CONVERT(TIME, SL.dtmPromoBegPeriod) AS NVARCHAR(8)),
						[strStopDate]						=	CAST(CONVERT(DATE, SL.dtmPromoEndPeriod) AS NVARCHAR(10)),
						[strStopTime]						=	CAST(CONVERT(TIME, SL.dtmPromoEndPeriod) AS NVARCHAR(8))
					FROM tblSTPromotionSalesListDetail SLD
					INNER JOIN tblSTPromotionSalesList SL
						ON SLD.intPromoSalesListId = SL.intPromoSalesListId
					INNER JOIN tblSTPromotionItemList PIL
						ON SLD.intPromoItemListId = PIL.intPromoItemListId
					INNER JOIN tblSTStore Store
						ON SL.intStoreId = Store.intStoreId
					WHERE SL.intStoreId = @intStoreId
						AND SL.strPromoType = 'C'
						AND (
								CAST(@dtmBeginningChangeDate AS DATE) >= CAST(SL.dtmPromoBegPeriod AS DATE)
								 AND 
								CAST(@dtmEndingChangeDate AS DATE) <= CAST(SL.dtmPromoEndPeriod AS DATE) 
								AND 
								CAST(SL.dtmPromoEndPeriod AS DATE)  > GETDATE()
							) -- ST-1227
				END

				-- INSERT @tblTempSapphireCommanderWeekDayAvailability
				BEGIN
					INSERT INTO @tblTempSapphireCommanderWeekDayAvailability
					(
						[intPromoSalesListId],
						[strAvailable],
						[strWeekDay], 
						[intSort], 
						[strStartTime],
						[strEndTime]
					)
					SELECT 
						[intPromoSalesListId]	= [Changes].intPromoSalesListId,
						[strAvailable]			= [Changes].strAvailable,
						[strWeekDay]			= [Changes].strWeekDay, 
						[intSort]				= [Changes].intSort, 
						[strStartTime]			= [Changes].strStartTime,
						[strEndTime]			= [Changes].strEndTime
					FROM 
					(
						SELECT DISTINCT 
							intPromoSalesListId, 
							strWeekDay = CASE	
											WHEN StartTime = 'strStartTimePromotionSunday'
												THEN 'Sunday'
											WHEN StartTime = 'strStartTimePromotionMonday'
												THEN 'Monday'
											WHEN StartTime = 'strStartTimePromotionTuesday'
												THEN 'Tuesday'
											WHEN StartTime = 'strStartTimePromotionWednesday'
												THEN 'Wednesday'
											WHEN StartTime = 'strStartTimePromotionThursday'
												THEN 'Thursday'
											WHEN StartTime = 'strStartTimePromotionFriday'
												THEN 'Friday'
											WHEN StartTime = 'strStartTimePromotionSaturday'
												THEN 'Saturday'
										END,
							intSort = CASE	
											WHEN StartTime = 'strStartTimePromotionSunday'
												THEN 1
											WHEN StartTime = 'strStartTimePromotionMonday'
												THEN 2
											WHEN StartTime = 'strStartTimePromotionTuesday'
												THEN 3
											WHEN StartTime = 'strStartTimePromotionWednesday'
												THEN 4
											WHEN StartTime = 'strStartTimePromotionThursday'
												THEN 5
											WHEN StartTime = 'strStartTimePromotionFriday'
												THEN 6
											WHEN StartTime = 'strStartTimePromotionSaturday'
												THEN 7
										END,
							strAvailable,
							strStartTime, 
							strEndTime
						FROM 
						(
							SELECT sl.intPromoSalesListId
									, strWeekDayPromotionSunday				= CASE WHEN sl.ysnWeekDayPromotionSunday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionMonday				= CASE WHEN sl.ysnWeekDayPromotionMonday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionTuesday			= CASE WHEN sl.ysnWeekDayPromotionTuesday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionWednesday			= CASE WHEN sl.ysnWeekDayPromotionWednesday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionThursday			= CASE WHEN sl.ysnWeekDayPromotionThursday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionFriday				= CASE WHEN sl.ysnWeekDayPromotionFriday = 1 THEN 'yes' ELSE 'no' END
									, strWeekDayPromotionSaturday			= CASE WHEN sl.ysnWeekDayPromotionSaturday = 1 THEN 'yes' ELSE 'no' END

									, strStartTimePromotionSunday			= CAST(ISNULL(sl.dtmStartTimePromotionSunday, '') AS NVARCHAR(8))
									, strStartTimePromotionMonday			= CAST(ISNULL(sl.dtmStartTimePromotionMonday, '') AS NVARCHAR(8))
									, strStartTimePromotionTuesday			= CAST(ISNULL(sl.dtmStartTimePromotionTuesday, '') AS NVARCHAR(8))
									, strStartTimePromotionWednesday		= CAST(ISNULL(sl.dtmStartTimePromotionWednesday, '') AS NVARCHAR(8))
									, strStartTimePromotionThursday			= CAST(ISNULL(sl.dtmStartTimePromotionThursday, '') AS NVARCHAR(8))
									, strStartTimePromotionFriday			= CAST(ISNULL(sl.dtmStartTimePromotionFriday, '') AS NVARCHAR(8))
									, strStartTimePromotionSaturday			= CAST(ISNULL(sl.dtmStartTimePromotionSaturday, '') AS NVARCHAR(8))
			
									, strEndTimePromotionSunday				= CAST(ISNULL(sl.dtmEndTimePromotionSunday, '') AS NVARCHAR(8))
									, strEndTimePromotionMonday				= CAST(ISNULL(sl.dtmEndTimePromotionMonday, '') AS NVARCHAR(8))
									, strEndTimePromotionTuesday			= CAST(ISNULL(sl.dtmEndTimePromotionTuesday, '') AS NVARCHAR(8))
									, strEndTimePromotionWednesday			= CAST(ISNULL(sl.dtmEndTimePromotionWednesday, '') AS NVARCHAR(8))
									, strEndTimePromotionThursday			= CAST(ISNULL(sl.dtmEndTimePromotionThursday, '') AS NVARCHAR(8))
									, strEndTimePromotionFriday				= CAST(ISNULL(sl.dtmEndTimePromotionFriday, '') AS NVARCHAR(8))
									, strEndTimePromotionSaturday			= CAST(ISNULL(sl.dtmEndTimePromotionSaturday, '') AS NVARCHAR(8))
							FROM tblSTPromotionSalesList sl
							LEFT JOIN @tblTempSapphireCommanderCombos temp
								ON sl.intPromoSalesId = temp.intPrimaryId
						) t
						unpivot
						(
							strAvailable for Available in (strWeekDayPromotionSunday, strWeekDayPromotionMonday, strWeekDayPromotionTuesday, strWeekDayPromotionWednesday, strWeekDayPromotionThursday, strWeekDayPromotionFriday, strWeekDayPromotionSaturday)
						) a
						unpivot
						(
							strStartTime for StartTime in (strStartTimePromotionSunday, strStartTimePromotionMonday, strStartTimePromotionTuesday, strStartTimePromotionWednesday, strStartTimePromotionThursday, strStartTimePromotionFriday, strStartTimePromotionSaturday)
						) o
						unpivot
						(
							strEndTime for EndTime in (strEndTimePromotionSunday, strEndTimePromotionMonday, strEndTimePromotionTuesday, strEndTimePromotionWednesday, strEndTimePromotionThursday, strEndTimePromotionFriday, strEndTimePromotionSaturday)
						) n
						WHERE REPLACE(StartTime, 'strStartTimePromotion', '') = REPLACE(EndTime, 'strEndTimePromotion', '')	
							AND REPLACE(Available, 'strWeekDayPromotion', '') = REPLACE(StartTime, 'strStartTimePromotion', '')
					) [Changes]
				END


				IF EXISTS(SELECT TOP 1 1 FROM @tblTempSapphireCommanderCombos)
					BEGIN
						
						--DECLARE @xml XML = N''
				
						SELECT @xml =
						(
							SELECT
								trans.strStoreNo				AS 'TransmissionHeader/StoreLocationID',
								trans.strVendorName 			AS 'TransmissionHeader/VendorName',
								trans.strVendorModelVersion 	AS 'TransmissionHeader/VendorModelVersion'
								,(	
									SELECT
										'update' AS [TableAction/@type],
										'addchange' AS [RecordAction/@type],
										(	
											SELECT
												Combo.strRecordActionType		AS [RecordAction/@type],
												(
													SELECT
														Promo.strPromotionID	AS [PromotionID]
													FROM 
													(
														SELECT DISTINCT
															strPromotionID
														FROM @tblTempSapphireCommanderCombos
													) Promo
													WHERE Combo.strPromotionID = Promo.strPromotionID
													ORDER BY Promo.strPromotionID ASC
													FOR XML PATH('Promotion'), TYPE
												),
												Combo.strComboDescription		AS [ComboDescription],
												(
													SELECT
														comboItem.strItemListID	AS [ItemListID],
														comboItem.strComboItemQuantity	AS [ComboItemQuantity],
														comboItem.strComboItemUnitPrice	AS [ComboItemUnitPrice]
													FROM 
													(
														SELECT DISTINCT
															strPromotionID
															, strItemListID
															, strComboItemQuantity
															, strComboItemUnitPrice
														FROM @tblTempSapphireCommanderCombos
													) comboItem
													WHERE Combo.strPromotionID = comboItem.strPromotionID
													ORDER BY comboItem.strPromotionID ASC
													FOR XML PATH('ComboItemList'),
													ROOT('ComboList'), TYPE
												),
												Combo.strStartDate		AS [StartDate],
												Combo.strStartTime		AS [StartTime],
												Combo.strStopDate		AS [StopDate],
												Combo.strStopTime		AS [StopTime],

												(
													SELECT 
														wda.strStartTime			AS [@startTime],
														wda.strAvailable			AS [@available],
														wda.strWeekDay				AS [@weekday],
														wda.strEndTime				AS [@stopTime]
													FROM 
													(
														SELECT DISTINCT
															wda.intSort
															, wda.strAvailable
															, wda.strStartTime
															, wda.strEndTime
															, wda.strWeekDay
														FROM @tblTempSapphireCommanderWeekDayAvailability wda
														WHERE wda.intPromoSalesListId = Combo.intPrimaryId
													) wda
													ORDER BY wda.intSort ASC
													FOR XML PATH('WeekdayAvailability'), TYPE
												)

											FROM 
											(
												SELECT DISTINCT
													intPrimaryId
													, strPromotionID
													, strRecordActionType
													, strComboDescription
													, strStartDate
													, strStartTime
													, strStopDate
													, strStopTime
												FROM @tblTempSapphireCommanderCombos
											) Combo
											ORDER BY Combo.strPromotionID ASC
											FOR XML PATH('CBTDetail'), TYPE
										)
									FOR XML PATH('ComboMaintenance'), TYPE		
								)
							FROM 
							(
								SELECT DISTINCT
									[strStoreNo], 
									[strVendorName], 
									[strVendorModelVersion]
								FROM @tblTempSapphireCommanderCombos
							) trans
							FOR XML PATH('NAXML-MaintenanceRequest'), TYPE
						);


						DECLARE @strXmlns AS NVARCHAR(50) = 'http://www.naxml.org/POSBO/Vocabulary/2003-10-16'
						SET @strVersion = N'3.4'

						-- INSERT Attributes 'page' and 'ofpages' to Root header
						SET @xml.modify('insert 
									   (
											attribute version { 
																	sql:variable("@strVersion")
															  }		   
										) into (/*:NAXML-MaintenanceRequest)[1]');

						SET @strXML = CAST(@xml AS NVARCHAR(MAX))
						SET @strXML = REPLACE(@strXML, '<NAXML-MaintenanceRequest', '<NAXML-MaintenanceRequest xmlns="http://www.naxml.org/POSBO/Vocabulary/2003-10-16"')
						
						SET @strGeneratedXML = REPLACE(@strXML, '><', '>' + CHAR(13) + '<')
					END
				ELSE 
					BEGIN

						SET @strGeneratedXML		= ''
						SET @intImportFileHeaderId	= 0
						SET @ysnSuccessResult = CAST(0 AS BIT)
						SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'

						GOTO ExitWithRollback

					END
			END

		-- COMMIT
		GOTO ExitWithCommit

	END TRY

	BEGIN CATCH
		SET @strGeneratedXML		= ''
		SET @intImportFileHeaderId	= 0
		SET @ysnSuccessResult		= CAST(0 AS BIT)
		SET @strMessageResult		= ERROR_MESSAGE()

		GOTO ExitWithRollback
	END CATCH
END




ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost
	





ExitWithRollback:
		SET @ysnSuccessResult			= CAST(0 AS BIT)

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					SET @strMessageResult = @strMessageResult + ' Will Rollback Transaction.'

					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strMessageResult = @strMessageResult + ' Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				
		
		
	

		
ExitPost: